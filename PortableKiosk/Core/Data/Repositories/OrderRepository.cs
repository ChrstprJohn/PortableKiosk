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
                "dbo.Order_GetByID",
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
                "dbo.Order_GetByOrderNumber",
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
            const string sql = "dbo.Order_GetAll";

            List<Order> orders = new List<Order>();

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
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

        public List<Order> GetPaidKitchenOrders(bool includeCompleted = false)
        {
            const string sql = "dbo.Order_GetPaidKitchenOrders";

            List<Order> orders = new List<Order>();
            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
            {
                command.Parameters.Add("@IncludeCompleted", SqlDbType.Bit).Value = includeCompleted;
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
            const string sql = "dbo.Order_CancelExpiredPendingOrders";

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
                            new SqlCommand(sql, connection, transaction) { CommandType = CommandType.StoredProcedure })
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

            const string sql = "dbo.Order_Update";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
            {
                AddWriteParameters(command, order, order.OrderNumber);
                command.Parameters.Add(
                    "@OrderID",
                    SqlDbType.Int).Value = order.OrderID;
                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        public bool SetKitchenStatus(int orderID, string currentStatus, string nextStatus)
        {
            ValidateID(orderID, "orderID");
            bool validCurrent = currentStatus == "QUEUED" ||
                currentStatus == "PREPARING" || currentStatus == "SERVING" ||
                currentStatus == "COMPLETED";
            bool validNext = nextStatus == "QUEUED" ||
                nextStatus == "PREPARING" || nextStatus == "SERVING" ||
                nextStatus == "COMPLETED";
            if (!validCurrent || !validNext || currentStatus == nextStatus)
            {
                throw new ArgumentException("Invalid kitchen status transition.");
            }

            const string sql = "dbo.Order_SetKitchenStatus";
            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
            {
                command.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                command.Parameters.Add("@CurrentStatus", SqlDbType.NVarChar, 20).Value = currentStatus;
                command.Parameters.Add("@NextStatus", SqlDbType.NVarChar, 20).Value = nextStatus;
                connection.Open();
                return command.ExecuteNonQuery() == 1;
            }
        }

        public bool Delete(int orderID)
        {
            ValidateID(orderID, "orderID");

            const string sql = "dbo.Order_Delete";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
            {
                command.Parameters.Add(
                    "@OrderID",
                    SqlDbType.Int).Value = orderID;
                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        public int Add(
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

            const string insertSql = "dbo.Order_Add_Insert";

            using (SqlCommand command =
                new SqlCommand(insertSql, connection, transaction) { CommandType = CommandType.StoredProcedure })
            {
                AddWriteParameters(
                    command,
                    order,
                    insertedOrderNumber);
                command.Parameters.Add("@OrderSource", SqlDbType.NVarChar, 10).Value = order.OrderSource;
                command.Parameters.Add("@PlacedByStaffAccountID", SqlDbType.Int).Value =
                    (object)order.PlacedByStaffAccountID ?? DBNull.Value;

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    reader.Read();
                    order.OrderID = reader.GetInt32(0);
                    order.CreatedAt = reader.GetDateTime(1);
                    order.PlacedByName = reader.IsDBNull(2) ? null : reader.GetString(2);
                    order.ProcessedByRole = reader.IsDBNull(3) ? null : reader.GetString(3);
                }
            }

            if (shouldGenerateOrderNumber)
            {
                order.OrderNumber = order.OrderID.ToString("D4");

                const string updateNumberSql = "dbo.Order_Add_UpdateNumber";

                using (SqlCommand command =
                    new SqlCommand(
                        updateNumberSql,
                        connection,
                        transaction) { CommandType = CommandType.StoredProcedure })
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
            string procedureName,
            int? integerValue,
            string stringValue)
        {
            string sql = procedureName;

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
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

        internal static Order Map(SqlDataReader reader)
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
                    reader.GetOrdinal("CreatedAt")),
                OrderSource = reader.GetString(reader.GetOrdinal("OrderSource")),
                PlacedByStaffAccountID = reader.IsDBNull(reader.GetOrdinal("PlacedByStaffAccountID"))
                    ? (int?)null : reader.GetInt32(reader.GetOrdinal("PlacedByStaffAccountID")),
                PlacedByName = reader.IsDBNull(reader.GetOrdinal("PlacedByName"))
                    ? null : reader.GetString(reader.GetOrdinal("PlacedByName")),
                ProcessedByRole = reader.IsDBNull(reader.GetOrdinal("ProcessedByRole"))
                    ? null : reader.GetString(reader.GetOrdinal("ProcessedByRole"))
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
                kitchenStatus != "SERVING" &&
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
