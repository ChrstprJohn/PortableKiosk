using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using PortableKiosk.Core.Models;
using PortableKiosk.Shared.Constants;

namespace PortableKiosk.Core.Data.Repositories
{
    public class PosRepository
    {
        public static string GetItemSignature(IEnumerable<OrderItem> items)
        {
            return string.Join("|", items.OrderBy(item => item.OrderItemID)
                .Select(item => string.Format(CultureInfo.InvariantCulture,
                    "{0}:{1}:{2}:{3:0.00}", item.OrderItemID,
                    item.ProductVariantID, item.Quantity, item.UnitPrice)));
        }

        public Order CompleteNewCashSale(Guid saleKey, Order order,
            IList<OrderItem> items, Payment payment)
        {
            if (saleKey == Guid.Empty || order == null || items == null ||
                items.Count == 0 || payment == null ||
                payment.TransactionReference != "POS-" + saleKey.ToString("N"))
            {
                throw new ArgumentException("A valid cash sale is required.");
            }

            const string lockSql = @"
                DECLARE @Result INT;
                EXEC @Result = sp_getapplock
                    @Resource = @Resource,
                    @LockMode = N'Exclusive',
                    @LockOwner = N'Transaction',
                    @LockTimeout = 10000;
                SELECT @Result;";
            const string existingSql = @"
                SELECT o.OrderID, o.OrderNumber, o.OrderType,
                    o.FulfillmentMethod, o.TableNumber, o.KitchenStatus,
                    o.CreatedAt, p.PaymentID, p.Amount, p.PaidAt
                FROM Payments p
                INNER JOIN Orders o ON o.OrderID = p.OrderID
                WHERE p.TransactionReference = @Reference
                    AND p.PaymentMethod = N'CASH_COUNTER'
                    AND p.PaymentStatus = N'PAID';";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            {
                connection.Open();
                using (SqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand command = new SqlCommand(
                            lockSql, connection, transaction))
                        {
                            command.Parameters.Add("@Resource", SqlDbType.NVarChar, 255)
                                .Value = "POS:" + saleKey.ToString("N");
                            if (Convert.ToInt32(command.ExecuteScalar()) < 0)
                            {
                                throw new InvalidOperationException(
                                    "This sale is being completed. Please try again.");
                            }
                        }

                        Order existingOrder = null;
                        using (SqlCommand command = new SqlCommand(
                            existingSql, connection, transaction))
                        {
                            command.Parameters.Add("@Reference", SqlDbType.NVarChar, 100)
                                .Value = payment.TransactionReference;
                            using (SqlDataReader reader = command.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    int tableNumber = reader.GetOrdinal("TableNumber");
                                    existingOrder = new Order
                                    {
                                        OrderID = reader.GetInt32(reader.GetOrdinal("OrderID")),
                                        OrderNumber = reader.GetString(reader.GetOrdinal("OrderNumber")),
                                        OrderType = reader.GetString(reader.GetOrdinal("OrderType")),
                                        FulfillmentMethod = reader.GetString(reader.GetOrdinal("FulfillmentMethod")),
                                        TableNumber = reader.IsDBNull(tableNumber)
                                            ? null : reader.GetString(tableNumber),
                                        KitchenStatus = reader.GetString(reader.GetOrdinal("KitchenStatus")),
                                        CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
                                    };
                                    payment.PaymentID = reader.GetInt32(reader.GetOrdinal("PaymentID"));
                                    payment.OrderID = existingOrder.OrderID;
                                    payment.Amount = reader.GetDecimal(reader.GetOrdinal("Amount"));
                                    int paidAt = reader.GetOrdinal("PaidAt");
                                    payment.PaidAt = reader.IsDBNull(paidAt)
                                        ? (DateTime?)null : reader.GetDateTime(paidAt);
                                }
                            }
                        }
                        if (existingOrder != null)
                        {
                            transaction.Commit();
                            return existingOrder;
                        }

                        order.OrderID = new OrderRepository().Add(
                            order, connection, transaction);
                        foreach (OrderItem item in items)
                        {
                            item.OrderID = order.OrderID;
                        }
                        payment.OrderID = order.OrderID;
                        new OrderItemRepository().AddRange(
                            items, connection, transaction);
                        new PaymentRepository().Add(
                            payment, connection, transaction);
                        transaction.Commit();
                        return order;
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        public List<PosCatalogItem> GetAvailableCatalog()
        {
            const string sql = @"
                SELECT
                    pv.ProductVariantID,
                    pv.ProductID,
                    c.CategoryID,
                    pv.SizeID,
                    p.ProductName,
                    c.CategoryName,
                    s.SizeName,
                    pv.ImagePath,
                    pv.Price
                FROM ProductVariants pv
                INNER JOIN Products p ON p.ProductID = pv.ProductID
                INNER JOIN Categories c ON c.CategoryID = p.CategoryID
                LEFT JOIN Sizes s ON s.SizeID = pv.SizeID
                WHERE pv.IsAvailable = 1
                    AND p.IsAvailable = 1
                    AND c.IsAvailable = 1
                ORDER BY c.CategoryName, p.ProductName,
                    pv.Price, pv.ProductVariantID;";

            List<PosCatalogItem> items = new List<PosCatalogItem>();

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                connection.Open();

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int sizeID = reader.GetOrdinal("SizeID");
                        int sizeName = reader.GetOrdinal("SizeName");
                        int imagePath = reader.GetOrdinal("ImagePath");

                        items.Add(new PosCatalogItem
                        {
                            ProductVariantID = reader.GetInt32(
                                reader.GetOrdinal("ProductVariantID")),
                            ProductID = reader.GetInt32(
                                reader.GetOrdinal("ProductID")),
                            CategoryID = reader.GetInt32(
                                reader.GetOrdinal("CategoryID")),
                            SizeID = reader.IsDBNull(sizeID)
                                ? (int?)null
                                : reader.GetInt32(sizeID),
                            ProductName = reader.GetString(
                                reader.GetOrdinal("ProductName")),
                            CategoryName = reader.GetString(
                                reader.GetOrdinal("CategoryName")),
                            SizeName = reader.IsDBNull(sizeName)
                                ? "Standard"
                                : reader.GetString(sizeName),
                            ImagePath = reader.IsDBNull(imagePath)
                                ? null
                                : reader.GetString(imagePath),
                            Price = reader.GetDecimal(
                                reader.GetOrdinal("Price"))
                        });
                    }
                }
            }

            return items;
        }

        public Order CompleteKioskCashOrder(
            int orderID,
            string originalItemsSignature,
            IList<OrderItem> items,
            Payment payment)
        {
            if (orderID <= 0 || items == null || items.Count == 0 ||
                payment == null || payment.OrderID != orderID ||
                string.IsNullOrEmpty(originalItemsSignature))
            {
                throw new ArgumentException("A valid cash sale is required.");
            }

            const string lockSql = @"
                SELECT
                    o.OrderID,
                    o.OrderNumber,
                    o.OrderType,
                    o.FulfillmentMethod,
                    o.TableNumber,
                    o.KitchenStatus,
                    o.CreatedAt,
                    COALESCE(
                        o.ExpiresAt,
                        DATEADD(MINUTE, @ExpiryMinutes, o.CreatedAt)
                    ) AS EffectiveExpiresAt,
                    p.PaymentID,
                    p.PaymentMethod,
                    p.PaymentStatus
                FROM Payments p WITH (UPDLOCK, HOLDLOCK)
                INNER JOIN Orders o WITH (UPDLOCK, HOLDLOCK)
                    ON o.OrderID = p.OrderID
                WHERE p.OrderID = @OrderID;";

            const string deleteItemsSql = @"
                DELETE FROM OrderItems WHERE OrderID = @OrderID;";

            const string currentItemsSql = @"
                SELECT OrderItemID, ProductVariantID, UnitPrice, Quantity
                FROM OrderItems WITH (UPDLOCK, HOLDLOCK)
                WHERE OrderID = @OrderID
                ORDER BY OrderItemID;";

            const string paySql = @"
                UPDATE Payments
                SET PaymentStatus = N'PAID',
                    Amount = @Amount,
                    TransactionReference = @TransactionReference,
                    PaidAt = @PaidAt
                WHERE OrderID = @OrderID
                    AND PaymentMethod = N'CASH_COUNTER'
                    AND PaymentStatus = N'PENDING';";

            const string queueSql = @"
                UPDATE Orders
                SET KitchenStatus = N'QUEUED', ExpiresAt = NULL
                WHERE OrderID = @OrderID
                    AND KitchenStatus = N'AWAITING_PAYMENT'
                    AND COALESCE(
                        ExpiresAt,
                        DATEADD(MINUTE, @ExpiryMinutes, CreatedAt)
                    ) > SYSUTCDATETIME();";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            {
                connection.Open();

                using (SqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {
                        Order order;
                        string paymentMethod;
                        string paymentStatus;
                        DateTime expiresAt;

                        using (SqlCommand command = new SqlCommand(
                            lockSql, connection, transaction))
                        {
                            command.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                            command.Parameters.Add("@ExpiryMinutes", SqlDbType.Int).Value =
                                OrderSettings.PendingPaymentExpiryMinutes;

                            using (SqlDataReader reader = command.ExecuteReader())
                            {
                                if (!reader.Read())
                                {
                                    throw new InvalidOperationException(
                                        "This kiosk order is no longer available.");
                                }

                                int tableNumber = reader.GetOrdinal("TableNumber");
                                order = new Order
                                {
                                    OrderID = reader.GetInt32(reader.GetOrdinal("OrderID")),
                                    OrderNumber = reader.GetString(reader.GetOrdinal("OrderNumber")),
                                    OrderType = reader.GetString(reader.GetOrdinal("OrderType")),
                                    FulfillmentMethod = reader.GetString(
                                        reader.GetOrdinal("FulfillmentMethod")),
                                    TableNumber = reader.IsDBNull(tableNumber)
                                        ? null
                                        : reader.GetString(tableNumber),
                                    KitchenStatus = reader.GetString(
                                        reader.GetOrdinal("KitchenStatus")),
                                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
                                };
                                expiresAt = reader.GetDateTime(
                                    reader.GetOrdinal("EffectiveExpiresAt"));
                                payment.PaymentID = reader.GetInt32(
                                    reader.GetOrdinal("PaymentID"));
                                paymentMethod = reader.GetString(
                                    reader.GetOrdinal("PaymentMethod"));
                                paymentStatus = reader.GetString(
                                    reader.GetOrdinal("PaymentStatus"));
                            }
                        }

                        if (paymentMethod != "CASH_COUNTER" ||
                            paymentStatus != "PENDING" ||
                            order.KitchenStatus != "AWAITING_PAYMENT" ||
                            expiresAt <= DateTime.UtcNow)
                        {
                            throw new InvalidOperationException(
                                "This kiosk order can no longer be paid here. Choose another order.");
                        }

                        List<OrderItem> currentItems = new List<OrderItem>();
                        using (SqlCommand command = new SqlCommand(
                            currentItemsSql, connection, transaction))
                        {
                            command.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                            using (SqlDataReader reader = command.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    currentItems.Add(new OrderItem
                                    {
                                        OrderItemID = reader.GetInt32(0),
                                        ProductVariantID = reader.GetInt32(1),
                                        UnitPrice = reader.GetDecimal(2),
                                        Quantity = reader.GetInt32(3)
                                    });
                                }
                            }
                        }
                        if (GetItemSignature(currentItems) != originalItemsSignature)
                        {
                            throw new InvalidOperationException(
                                "This kiosk order changed since you opened it. Reopen it before payment.");
                        }

                        using (SqlCommand command = new SqlCommand(
                            deleteItemsSql, connection, transaction))
                        {
                            command.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                            command.ExecuteNonQuery();
                        }

                        new OrderItemRepository().AddRange(
                            items, connection, transaction);

                        using (SqlCommand command = new SqlCommand(
                            paySql, connection, transaction))
                        {
                            command.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                            SqlParameter amount = command.Parameters.Add(
                                "@Amount", SqlDbType.Decimal);
                            amount.Precision = 10;
                            amount.Scale = 2;
                            amount.Value = payment.Amount;
                            command.Parameters.Add("@TransactionReference",
                                SqlDbType.NVarChar, 100).Value =
                                payment.TransactionReference;
                            command.Parameters.Add("@PaidAt", SqlDbType.DateTime2).Value =
                                payment.PaidAt.Value;

                            if (command.ExecuteNonQuery() != 1)
                            {
                                throw new InvalidOperationException(
                                    "This kiosk order was paid elsewhere. Refresh the order list.");
                            }
                        }

                        using (SqlCommand command = new SqlCommand(
                            queueSql, connection, transaction))
                        {
                            command.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                            command.Parameters.Add("@ExpiryMinutes", SqlDbType.Int).Value =
                                OrderSettings.PendingPaymentExpiryMinutes;

                            if (command.ExecuteNonQuery() != 1)
                            {
                                throw new InvalidOperationException(
                                    "This kiosk order expired before payment. Choose another order.");
                            }
                        }

                        transaction.Commit();
                        order.KitchenStatus = "QUEUED";
                        order.ExpiresAt = null;
                        return order;
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }
    }
}
