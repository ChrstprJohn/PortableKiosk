using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.IO;
using System.Text.RegularExpressions;
using PortableKiosk.Core.Data;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

class OrderPlacedByTests
{
    static int checks;
    static void Check(bool value, string message)
    {
        if (!value) throw new Exception(message);
        checks++;
    }
    static void Sql(string text)
    {
        using (var c = DatabaseConnection.GetConnection())
        using (var cmd = new SqlCommand(text, c)) { c.Open(); cmd.ExecuteNonQuery(); }
    }
    static PosSale Sale()
    {
        var sale = new PosSale();
        sale.Cart.Items.Add(new CartItem { ProductVariantID = 1, ProductName = "Test item", UnitPrice = 10, Quantity = 1 });
        return sale;
    }
    static void Creator(Order order, string source, int? staff, string name)
    {
        Check(order.OrderSource == source, "Order source changed");
        Check(order.PlacedByStaffAccountID == staff, "Wrong staff ID");
        Check(order.PlacedByDisplay == name, "Wrong placed-by name");
    }
    static void Role(Order order, string expected)
    {
        Check(order.ProcessedByRole == expected, "Wrong processor role snapshot");
    }
    static void MigrateRole(string path)
    {
        string database;
        using (var c = DatabaseConnection.GetConnection())
        {
            c.Open();
            database = c.Database;
            if (!database.StartsWith("PortableKiosk_PlacedByTests_", StringComparison.Ordinal))
                throw new Exception("Role migration tests require an isolated database.");
        }
        string migration = File.ReadAllText(path).Replace("portable_kiosk_db", database);
        foreach (string batch in Regex.Split(migration, @"(?im)^\s*GO\s*$"))
            if (!string.IsNullOrWhiteSpace(batch)) Sql(batch);
    }
    static int Main(string[] args)
    {
        try
        {
            using (var c = DatabaseConnection.GetConnection())
            {
                c.Open();
                if (!c.Database.StartsWith("PortableKiosk_PlacedByTests_", StringComparison.Ordinal))
                    throw new Exception("Tests require an isolated test database.");
            }
            Sql(@"INSERT dbo.StaffAccounts (FirstName, MiddleName, LastName, Suffix, Email, PasswordHash, PasswordSalt, StaffRole)
                VALUES (N'Test', N'Crew', N'One', N'Jr.', N'crew@test.invalid', 0x01, 0x02, N'CREW'),
                (N'Test', NULL, N'Admin', NULL, N'admin@test.invalid', 0x01, 0x02, N'ADMIN');
                INSERT dbo.Categories (CategoryName) VALUES (N'Test');
                INSERT dbo.Products (CategoryID, ProductName) VALUES (1, N'Test item');
                INSERT dbo.ProductVariants (ProductID, Price) VALUES (1, 10);");
            var orders = new OrderRepository();
            var pos = new PosService();
            Creator(orders.GetByOrderNumber("LEGACY"), "UNKNOWN", null, "Not recorded");
            Role(orders.GetByOrderNumber("LEGACY"), null);
            var sale = Sale();
            var cash = pos.CompleteCashSale(sale, 20, 1);
            Creator(cash.Order, "POS", 1, "Test Crew One Jr.");
            Role(cash.Order, "CREW");
            Role(orders.GetByID(cash.Order.OrderID), "CREW");
            Creator(orders.GetByID(cash.Order.OrderID), "POS", 1, "Test Crew One Jr.");
            Creator(orders.GetByOrderNumber(cash.Order.OrderNumber), "POS", 1, "Test Crew One Jr.");
            Creator(orders.GetAll().Single(o => o.OrderID == cash.Order.OrderID), "POS", 1, "Test Crew One Jr.");
            Creator(orders.GetPaidKitchenOrders().Single(o => o.OrderID == cash.Order.OrderID), "POS", 1, "Test Crew One Jr.");
            // Retrying the same sale as another staff member keeps the first creator.
            Creator(pos.CompleteCashSale(sale, 20, 2).Order, "POS", 1, "Test Crew One Jr.");
            var cashless = pos.CompleteMockCashlessSale(Sale(), 2);
            Creator(orders.GetByID(cashless.Order.OrderID), "POS", 2, "Test Admin");
            Role(orders.GetByID(cashless.Order.OrderID), "ADMIN");
            // Updating fulfillment/status cannot overwrite placement history.
            cash.Order.PlacedByStaffAccountID = 2;
            cash.Order.PlacedByName = "Changed";
            cash.Order.OrderSource = "KIOSK";
            cash.Order.ProcessedByRole = "ADMIN";
            Check(orders.Update(cash.Order), "Order update failed");
            Creator(orders.GetByID(cash.Order.OrderID), "POS", 1, "Test Crew One Jr.");
            Role(orders.GetByID(cash.Order.OrderID), "CREW");
            var kiosk = new Order { KitchenStatus = "AWAITING_PAYMENT", ExpiresAt = DateTime.UtcNow.AddMinutes(30) };
            orders.AddCompleteOrder(kiosk, new List<OrderItem> { new OrderItem { ProductVariantID = 1, Quantity = 1, UnitPrice = 10 } },
                new Payment { PaymentMethod = "CASH_COUNTER", PaymentStatus = "PENDING", Amount = 10 });
            Creator(orders.GetByID(kiosk.OrderID), "KIOSK", null, "Not processed at POS");
            Role(orders.GetByID(kiosk.OrderID), null);
            var kioskCashless = new Order { KitchenStatus = "QUEUED" };
            orders.AddCompleteOrder(kioskCashless, new List<OrderItem> { new OrderItem { ProductVariantID = 1, Quantity = 1, UnitPrice = 10 } },
                new Payment { PaymentMethod = "CASHLESS", PaymentStatus = "PAID", Amount = 10, PaidAt = DateTime.UtcNow });
            Creator(orders.GetByID(kioskCashless.OrderID), "KIOSK", null, "Not processed at POS");
            Role(orders.GetByID(kioskCashless.OrderID), null);
            var kioskSale = pos.TakeKioskOrder(kiosk.OrderNumber);
            string originalSignature = PosRepository.GetItemSignature(new OrderItemRepository().GetByOrderID(kiosk.OrderID));
            Sql("UPDATE dbo.StaffAccounts SET IsActive = 0 WHERE StaffAccountID = 2;");
            foreach (int invalidStaff in new[] { 2, 99999 })
            {
                bool rejected = false;
                try { pos.CompleteCashSale(kioskSale, 10, invalidStaff); } catch (SqlException) { rejected = true; }
                Check(rejected, "Invalid staff processed kiosk payment");
                Creator(orders.GetByID(kiosk.OrderID), "KIOSK", null, "Not processed at POS");
                Role(orders.GetByID(kiosk.OrderID), null);
                Check(orders.GetByID(kiosk.OrderID).KitchenStatus == "AWAITING_PAYMENT", "Rejected kiosk payment queued order");
                Check(new PaymentRepository().GetByOrderID(kiosk.OrderID).PaymentStatus == "PENDING", "Rejected kiosk payment was saved");
                Check(PosRepository.GetItemSignature(new OrderItemRepository().GetByOrderID(kiosk.OrderID)) == originalSignature,
                    "Rejected kiosk payment changed items");
            }
            Sql("UPDATE dbo.StaffAccounts SET IsActive = 1 WHERE StaffAccountID = 2;");
            var kioskReceipt = pos.CompleteCashSale(kioskSale, 10, 1);
            Creator(kioskReceipt.Order, "KIOSK", 1, "Test Crew One Jr.");
            Role(kioskReceipt.Order, "CREW");
            Creator(orders.GetByID(kiosk.OrderID), "KIOSK", 1, "Test Crew One Jr.");
            bool duplicateRejected = false;
            try { pos.CompleteCashSale(kioskSale, 10, 2); } catch (InvalidOperationException) { duplicateRejected = true; }
            Check(duplicateRejected, "A second crew processed an already paid kiosk order");
            Creator(orders.GetByID(kiosk.OrderID), "KIOSK", 1, "Test Crew One Jr.");
            // Source and account validation happens in the stored insert procedure.
            int before = orders.GetAll().Count;
            foreach (var invalid in new[] {
                new Order { OrderSource = "POS" },
                new Order { OrderSource = "POS", PlacedByStaffAccountID = 99999 },
                new Order { OrderSource = "KIOSK", PlacedByStaffAccountID = 1 },
                new Order { OrderSource = "UNKNOWN" } })
            {
                bool rejected = false;
                try { orders.Add(invalid); } catch (SqlException) { rejected = true; }
                Check(rejected, "Invalid attribution accepted");
            }
            Sql("UPDATE dbo.StaffAccounts SET IsActive = 0 WHERE StaffAccountID = 2;");
            bool inactiveRejected = false;
            try { pos.CompleteCashSale(Sale(), 10, 2); } catch (SqlException) { inactiveRejected = true; }
            Check(inactiveRejected, "Inactive staff accepted");
            Check(orders.GetAll().Count == before, "Rejected sale left an order behind");
            // Backfill old processed orders, then prove reruns cannot rewrite snapshots.
            Sql("UPDATE dbo.Orders SET ProcessedByRole = NULL WHERE OrderID = " + cash.Order.OrderID);
            MigrateRole(args[0]);
            Role(orders.GetByID(cash.Order.OrderID), "CREW");
            Sql("UPDATE dbo.StaffAccounts SET FirstName = N'Renamed', StaffRole = N'ADMIN' WHERE StaffAccountID = 1;");
            MigrateRole(args[0]);
            Role(orders.GetByID(cash.Order.OrderID), "CREW");
            Role(orders.GetByID(kiosk.OrderID), "CREW");
            Creator(orders.GetByID(cash.Order.OrderID), "POS", 1, "Test Crew One Jr.");
            Creator(orders.GetByID(kiosk.OrderID), "KIOSK", 1, "Test Crew One Jr.");
            Sql("DELETE dbo.StaffAccounts WHERE StaffAccountID = 1;");
            Creator(orders.GetByID(cash.Order.OrderID), "POS", null, "Test Crew One Jr.");
            Creator(orders.GetByID(kiosk.OrderID), "KIOSK", null, "Test Crew One Jr.");
            Role(orders.GetByID(cash.Order.OrderID), "CREW");
            Role(orders.GetByID(kiosk.OrderID), "CREW");
            Check(orders.GetByID(kiosk.OrderID).ProcessedByRoleDisplay == "Crew", "Deleted processor lost role display");
            Console.WriteLine("PASS: " + checks + " attribution, role snapshot, migration, POS, kiosk, retry, account-history, and validation checks.");
            return 0;
        }
        catch (Exception e) { Console.Error.WriteLine(e.Message); return 1; }
    }
}
