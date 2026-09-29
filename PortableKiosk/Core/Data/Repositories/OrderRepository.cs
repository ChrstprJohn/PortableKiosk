using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using PortableKiosk.Core.Models;
using PortableKiosk.Shared.Constants;

namespace PortableKiosk.Core.Data.Repositories
{
    public class OrderRepository
    {
        public int Add(Order order)
        {
            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            {
                connection.Open();

                using (SqlTransaction transaction =
                    connection.BeginTransaction())
                {
                    try
                    {
                        int orderID = Add(
                            order,
                            connection,
                            transaction);
                        transaction.Commit();
                        return orderID;
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        public int AddCompleteOrder(
            Order order,
            IList<OrderItem> items,
            Payment payment)
        {
            if (items == null || items.Count == 0)
            {
                throw new ArgumentException(
                    "An order must contain at least one item.",
                    "items");
            }

            if (payment == null)
            {
                throw new ArgumentNullException("payment");
            }

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            {
                connection.Open();

                using (SqlTransaction transaction =
                    connection.BeginTransaction())
                {
                    try
                    {
                        int orderID = Add(
                            order,
                            connection,
                            transaction);

                        foreach (OrderItem item in items)
                        {
                            item.OrderID = orderID;
                        }

                        payment.OrderID = orderID;

                        OrderItemRepository itemRepository =
                            new OrderItemRepository();
                        PaymentRepository paymentRepository =
                            new PaymentRepository();

                        itemRepository.AddRange(
                            items,
                            connection,
                            transaction);
                        paymentRepository.Add(
                            payment,
                            connection,
                            transaction);

                        transaction.Commit();
                        return orderID;
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        public Order GetByID(int orderID)
        {
            ValidateID(orderID, "orderID");
            return GetSingle(
                "OrderID = @Value",
                orderID,
                null);
        }

        public Order GetByOrderNumber(string orderNumber)
        {
            if (string.IsNullOrWhiteSpace(orderNumber))
            {
                throw new ArgumentException(
                    "Order number is required.",
                    "orderNumber");
            }

            string trimmedNumber = orderNumber.Trim();
            Order order = GetSingle(
                "OrderNumber = @Value",
                null,
                trimmedNumber);
            if (order != null)
            {
                return order;
            }

            return null;
        }

        public List<Order> GetAll()
        {
            const string sql = @"
                SELECT
                    OrderID,
                    OrderNumber,
                    OrderType,
                    FulfillmentMethod,
                    TableNumber,
                    KitchenStatus,
                    ExpiresAt,
                    CreatedAt
                FROM Orders
                ORDER BY CreatedAt DESC, OrderID DESC;";

            List<Order> orders = new List<Order>();

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                connection.Open();

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        orders.Add(Map(reader));
                    }
                }
            }

            return orders;
        }

        public int CancelExpiredPendingOrders()
        {
            const string sql = @"
                SET NOCOUNT ON;

                DECLARE @ExpiredOrders TABLE (OrderID INT PRIMARY KEY);
                DECLARE @ExpiredCount INT = 0;
                DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

                UPDATE p
                SET PaymentStatus = N'EXPIRED'
                OUTPUT inserted.OrderID INTO @ExpiredOrders (OrderID)
                FROM Payments p
                INNER JOIN Orders o ON o.OrderID = p.OrderID
                WHERE p.PaymentMethod = N'CASH_COUNTER'
                    AND p.PaymentStatus = N'PENDING'
                    AND COALESCE(
                        o.ExpiresAt,
                        DATEADD(
                            MINUTE,
                            @ExpiryMinutes,
                            o.CreatedAt)) <= @Now;

                SET @ExpiredCount = @@ROWCOUNT;

                UPDATE o
                SET KitchenStatus = N'CANCELLED'
                FROM Orders o
                INNER JOIN @ExpiredOrders expired
                    ON expired.OrderID = o.OrderID
                WHERE o.KitchenStatus IN (
                    N'AWAITING_PAYMENT',
                    N'QUEUED'
                );

                SELECT @ExpiredCount;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            {
                connection.Open();

                using (SqlTransaction transaction =
                    connection.BeginTransaction())
                {
                    try
                    {
                        int expiredCount;

                        using (SqlCommand command =
                            new SqlCommand(sql, connection, transaction))
                        {
                            command.Parameters.Add(
                                "@ExpiryMinutes",
                                SqlDbType.Int).Value =
                                    OrderSettings.LegacyPendingPaymentExpiryMinutes;
                            expiredCount = Convert.ToInt32(
                                command.ExecuteScalar());
                        }

                        transaction.Commit();
                        return expiredCount;
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        public bool Update(Order order)
        {
            Validate(order);
            ValidateID(order.OrderID, "orderID");

            const string sql = @"
                UPDATE Orders
                SET
                    OrderType = @OrderType,
                    FulfillmentMethod = @FulfillmentMethod,
                    TableNumber = @TableNumber,
                    KitchenStatus = @KitchenStatus,
                    ExpiresAt = @ExpiresAt
                WHERE OrderID = @OrderID
                    AND (
                        @KitchenStatus IN (N'AWAITING_PAYMENT', N'CANCELLED')
                        OR EXISTS (
                            SELECT 1
                            FROM Payments p
                            WHERE p.OrderID = Orders.OrderID
                                AND p.PaymentStatus = N'PAID'
                        )
                    );";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                AddWriteParameters(command, order, order.OrderNumber);
                command.Parameters.Add(
                    "@OrderID",
                    SqlDbType.Int).Value = order.OrderID;
                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        public bool Delete(int orderID)
        {
            ValidateID(orderID, "orderID");

            const string sql = @"
                DELETE FROM Orders
                WHERE OrderID = @OrderID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@OrderID",
                    SqlDbType.Int).Value = orderID;
                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        internal int Add(
            Order order,
            SqlConnection connection,
            SqlTransaction transaction)
        {
            Validate(order);

            bool shouldGenerateOrderNumber =
                string.IsNullOrWhiteSpace(order.OrderNumber);
            string insertedOrderNumber = shouldGenerateOrderNumber
                ? "TMP" + Guid.NewGuid().ToString("N").Substring(0, 17)
                : order.OrderNumber.Trim();

            const string insertSql = @"
                INSERT INTO Orders
                    (
                        OrderNumber,
                        OrderType,
                        FulfillmentMethod,
                        TableNumber,
                        KitchenStatus,
                        ExpiresAt
                    )
                OUTPUT INSERTED.OrderID, INSERTED.CreatedAt
                VALUES
                    (
                        @OrderNumber,
                        @OrderType,
                        @FulfillmentMethod,
                        @TableNumber,
                        @KitchenStatus,
                        @ExpiresAt
                    );";

            using (SqlCommand command =
                new SqlCommand(insertSql, connection, transaction))
            {
                AddWriteParameters(
                    command,
                    order,
                    insertedOrderNumber);

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    reader.Read();
                    order.OrderID = reader.GetInt32(0);
                    order.CreatedAt = reader.GetDateTime(1);
                }
            }

            if (shouldGenerateOrderNumber)
            {
                order.OrderNumber = order.OrderID.ToString("D4");

                const string updateNumberSql = @"
                    UPDATE Orders
                    SET OrderNumber = @OrderNumber
                    WHERE OrderID = @OrderID;";

                using (SqlCommand command =
                    new SqlCommand(
                        updateNumberSql,
                        connection,
                        transaction))
                {
                    command.Parameters.Add(
                        "@OrderNumber",
                        SqlDbType.NVarChar,
                        20).Value = order.OrderNumber;
                    command.Parameters.Add(
                        "@OrderID",
                        SqlDbType.Int).Value = order.OrderID;
                    command.ExecuteNonQuery();
                }
            }
            else
            {
                order.OrderNumber = insertedOrderNumber;
            }

            return order.OrderID;
        }

        private static Order GetSingle(
            string predicate,
            int? integerValue,
            string stringValue)
        {
            string sql = @"
                SELECT
                    OrderID,
                    OrderNumber,
                    OrderType,
                    FulfillmentMethod,
                    TableNumber,
                    KitchenStatus,
                    ExpiresAt,
                    CreatedAt
                FROM Orders
                WHERE " + predicate + ";";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                if (integerValue.HasValue)
                {
                    command.Parameters.Add(
                        "@Value",
                        SqlDbType.Int).Value = integerValue.Value;
                }
                else
                {
                    command.Parameters.Add(
                        "@Value",
                        SqlDbType.NVarChar,
                        20).Value = stringValue;
                }

                connection.Open();

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    return reader.Read() ? Map(reader) : null;
                }
            }
        }

        private static void AddWriteParameters(
            SqlCommand command,
            Order order,
            string orderNumber)
        {
            command.Parameters.Add(
                "@OrderNumber",
                SqlDbType.NVarChar,
                20).Value = orderNumber ?? string.Empty;
            command.Parameters.Add(
                "@OrderType",
                SqlDbType.NVarChar,
                10).Value = order.OrderType.Trim().ToUpperInvariant();
            command.Parameters.Add(
                "@FulfillmentMethod",
                SqlDbType.NVarChar,
                20).Value = order.FulfillmentMethod.Trim().ToUpperInvariant();
            command.Parameters.Add(
                "@TableNumber",
                SqlDbType.NVarChar,
                20).Value = string.IsNullOrWhiteSpace(order.TableNumber)
                    ? (object)DBNull.Value
                    : order.TableNumber.Trim();
            command.Parameters.Add(
                "@KitchenStatus",
                SqlDbType.NVarChar,
                20).Value = order.KitchenStatus.Trim().ToUpperInvariant();
            command.Parameters.Add(
                "@ExpiresAt",
                SqlDbType.DateTime2).Value = order.ExpiresAt.HasValue
                    ? (object)order.ExpiresAt.Value
                    : DBNull.Value;
        }

        private static Order Map(SqlDataReader reader)
        {
            int tableNumberOrdinal = reader.GetOrdinal("TableNumber");
            int expiresAtOrdinal = reader.GetOrdinal("ExpiresAt");

            return new Order
            {
                OrderID = reader.GetInt32(
                    reader.GetOrdinal("OrderID")),
                OrderNumber = reader.GetString(
                    reader.GetOrdinal("OrderNumber")),
                OrderType = reader.GetString(
                    reader.GetOrdinal("OrderType")),
                FulfillmentMethod = reader.GetString(
                    reader.GetOrdinal("FulfillmentMethod")),
                TableNumber = reader.IsDBNull(tableNumberOrdinal)
                    ? null
                    : reader.GetString(tableNumberOrdinal),
                KitchenStatus = reader.GetString(
                    reader.GetOrdinal("KitchenStatus")),
                ExpiresAt = reader.IsDBNull(expiresAtOrdinal)
                    ? (DateTime?)null
                    : reader.GetDateTime(expiresAtOrdinal),
                CreatedAt = reader.GetDateTime(
                    reader.GetOrdinal("CreatedAt"))
            };
        }

        private static void Validate(Order order)
        {
            if (order == null)
            {
                throw new ArgumentNullException("order");
            }

            if (!string.IsNullOrWhiteSpace(order.OrderNumber) &&
                order.OrderNumber.Trim().Length > 20)
            {
                throw new ArgumentException(
                    "Order number cannot exceed 20 characters.",
                    "order");
            }

            string orderType = (order.OrderType ?? string.Empty)
                .Trim()
                .ToUpperInvariant();
            string fulfillment =
                (order.FulfillmentMethod ?? string.Empty)
                    .Trim()
                    .ToUpperInvariant();
            string kitchenStatus =
                (order.KitchenStatus ?? string.Empty)
                    .Trim()
                    .ToUpperInvariant();

            if (orderType != "DINE_IN" && orderType != "TAKEOUT")
            {
                throw new ArgumentException(
                    "Choose dine-in or takeout.",
                    "order");
            }

            if (fulfillment != "TABLE_SERVICE" &&
                fulfillment != "COUNTER_PICKUP")
            {
                throw new ArgumentException(
                    "Choose a valid fulfillment method.",
                    "order");
            }

            if (fulfillment == "TABLE_SERVICE" &&
                string.IsNullOrWhiteSpace(order.TableNumber))
            {
                throw new ArgumentException(
                    "A locator number is required for table service.",
                    "order");
            }

            if (fulfillment == "COUNTER_PICKUP")
            {
                order.TableNumber = null;
            }

            if (!string.IsNullOrWhiteSpace(order.TableNumber) &&
                order.TableNumber.Trim().Length > 20)
            {
                throw new ArgumentException(
                    "Locator number cannot exceed 20 characters.",
                    "order");
            }

            if (kitchenStatus != "AWAITING_PAYMENT" &&
                kitchenStatus != "QUEUED" &&
                kitchenStatus != "PREPARING" &&
                kitchenStatus != "READY" &&
                kitchenStatus != "COMPLETED" &&
                kitchenStatus != "CANCELLED")
            {
                throw new ArgumentException(
                    "Choose a valid kitchen status.",
                    "order");
            }
        }

        private static void ValidateID(int id, string parameterName)
        {
            if (id <= 0)
            {
                throw new ArgumentException(
                    "A valid ID is required.",
                    parameterName);
            }
        }
    }
}
