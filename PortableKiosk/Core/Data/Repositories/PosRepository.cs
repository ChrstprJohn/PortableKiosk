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

            const string lockSql = "dbo.Pos_CompleteNewCashSale_Lock";
            const string existingSql = "dbo.Pos_CompleteNewCashSale_Existing";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            {
                connection.Open();
                using (SqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand command = new SqlCommand(
                            lockSql, connection, transaction) { CommandType = CommandType.StoredProcedure })
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
                            existingSql, connection, transaction) { CommandType = CommandType.StoredProcedure })
                        {
                            command.Parameters.Add("@Reference", SqlDbType.NVarChar, 100)
                                .Value = payment.TransactionReference;
                            using (SqlDataReader reader = command.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    existingOrder = OrderRepository.Map(reader);
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
            const string sql = "dbo.Pos_GetAvailableCatalog";

            List<PosCatalogItem> items = new List<PosCatalogItem>();

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
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
            Payment payment,
            int staffAccountID)
        {
            if (orderID <= 0 || staffAccountID <= 0 || items == null || items.Count == 0 ||
                payment == null || payment.OrderID != orderID ||
                string.IsNullOrEmpty(originalItemsSignature))
            {
                throw new ArgumentException("A valid cash sale is required.");
            }

            const string lockSql = "dbo.Pos_CompleteKioskCashOrder_Lock";

            const string deleteItemsSql = "dbo.Pos_CompleteKioskCashOrder_DeleteItems";

            const string currentItemsSql = "dbo.Pos_CompleteKioskCashOrder_CurrentItems";

            const string paySql = "dbo.Pos_CompleteKioskCashOrder_Pay";

            const string queueSql = "dbo.Pos_CompleteKioskCashOrder_Queue";

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
                            lockSql, connection, transaction) { CommandType = CommandType.StoredProcedure })
                        {
                            command.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                            command.Parameters.Add("@ExpiryMinutes", SqlDbType.Int).Value =
                                OrderSettings.LegacyPendingPaymentExpiryMinutes;

                            using (SqlDataReader reader = command.ExecuteReader())
                            {
                                if (!reader.Read())
                                {
                                    throw new InvalidOperationException(
                                        "This kiosk order is no longer available.");
                                }

                                order = OrderRepository.Map(reader);
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
                            currentItemsSql, connection, transaction) { CommandType = CommandType.StoredProcedure })
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
                            deleteItemsSql, connection, transaction) { CommandType = CommandType.StoredProcedure })
                        {
                            command.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                            command.ExecuteNonQuery();
                        }

                        new OrderItemRepository().AddRange(
                            items, connection, transaction);

                        using (SqlCommand command = new SqlCommand(
                            paySql, connection, transaction) { CommandType = CommandType.StoredProcedure })
                        {
                            command.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                            command.Parameters.Add("@PaymentMethod", SqlDbType.NVarChar, 20).Value = payment.PaymentMethod;
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
                            queueSql, connection, transaction) { CommandType = CommandType.StoredProcedure })
                        {
                            command.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                            command.Parameters.Add("@ExpiryMinutes", SqlDbType.Int).Value =
                                OrderSettings.LegacyPendingPaymentExpiryMinutes;

                            command.Parameters.Add("@PlacedByStaffAccountID", SqlDbType.Int).Value = staffAccountID;
                            using (SqlDataReader reader = command.ExecuteReader())
                            {
                                if (!reader.Read())
                                {
                                    throw new InvalidOperationException(
                                        "This kiosk order expired before payment. Choose another order.");
                                }
                                order.PlacedByStaffAccountID = reader.GetInt32(0);
                                order.PlacedByName = reader.GetString(1);
                                order.ProcessedByRole = reader.GetString(2);
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
