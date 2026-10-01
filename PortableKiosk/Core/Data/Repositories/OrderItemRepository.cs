using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Data.Repositories
{
    public class OrderItemRepository
    {
        public int Add(OrderItem item)
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
                        int orderItemID = Add(
                            item,
                            connection,
                            transaction);
                        transaction.Commit();
                        return orderItemID;
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        public List<int> AddRange(IList<OrderItem> items)
        {
            ValidateItems(items);

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            {
                connection.Open();

                using (SqlTransaction transaction =
                    connection.BeginTransaction())
                {
                    try
                    {
                        List<int> ids = AddRange(
                            items,
                            connection,
                            transaction);
                        transaction.Commit();
                        return ids;
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        public OrderItem GetByID(int orderItemID)
        {
            ValidateID(orderItemID, "orderItemID");

            const string sql = @"
                SELECT
                    oi.OrderItemID,
                    oi.OrderID,
                    oi.ProductVariantID,
                    p.ProductName,
                    pv.ImagePath,
                    s.SizeName,
                    oi.UnitPrice,
                    oi.Quantity
                FROM OrderItems oi
                INNER JOIN ProductVariants pv
                    ON pv.ProductVariantID = oi.ProductVariantID
                INNER JOIN Products p
                    ON p.ProductID = pv.ProductID
                LEFT JOIN Sizes s
                    ON s.SizeID = pv.SizeID
                WHERE oi.OrderItemID = @OrderItemID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@OrderItemID",
                    SqlDbType.Int).Value = orderItemID;
                connection.Open();

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    return reader.Read() ? Map(reader) : null;
                }
            }
        }

        public List<OrderItem> GetByOrderID(int orderID)
        {
            ValidateID(orderID, "orderID");

            const string sql = @"
                SELECT
                    oi.OrderItemID,
                    oi.OrderID,
                    oi.ProductVariantID,
                    p.ProductName,
                    pv.ImagePath,
                    s.SizeName,
                    oi.UnitPrice,
                    oi.Quantity
                FROM OrderItems oi
                INNER JOIN ProductVariants pv
                    ON pv.ProductVariantID = oi.ProductVariantID
                INNER JOIN Products p
                    ON p.ProductID = pv.ProductID
                LEFT JOIN Sizes s
                    ON s.SizeID = pv.SizeID
                WHERE oi.OrderID = @OrderID
                ORDER BY oi.OrderItemID ASC;";

            List<OrderItem> items = new List<OrderItem>();

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@OrderID",
                    SqlDbType.Int).Value = orderID;
                connection.Open();

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        items.Add(Map(reader));
                    }
                }
            }

            return items;
        }

        public bool Update(OrderItem item)
        {
            Validate(item);
            ValidateID(item.OrderItemID, "orderItemID");

            const string sql = @"
                UPDATE OrderItems
                SET
                    OrderID = @OrderID,
                    ProductVariantID = @ProductVariantID,
                    UnitPrice = @UnitPrice,
                    Quantity = @Quantity
                WHERE OrderItemID = @OrderItemID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                AddWriteParameters(command, item);
                command.Parameters.Add(
                    "@OrderItemID",
                    SqlDbType.Int).Value = item.OrderItemID;
                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        public bool Delete(int orderItemID)
        {
            ValidateID(orderItemID, "orderItemID");

            const string sql = @"
                DELETE FROM OrderItems
                WHERE OrderItemID = @OrderItemID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@OrderItemID",
                    SqlDbType.Int).Value = orderItemID;
                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        public int Add(
            OrderItem item,
            SqlConnection connection,
            SqlTransaction transaction)
        {
            Validate(item);

            const string sql = @"
                INSERT INTO OrderItems
                    (OrderID, ProductVariantID, UnitPrice, Quantity)
                OUTPUT INSERTED.OrderItemID
                VALUES
                    (@OrderID, @ProductVariantID, @UnitPrice, @Quantity);";

            using (SqlCommand command =
                new SqlCommand(sql, connection, transaction))
            {
                AddWriteParameters(command, item);
                item.OrderItemID = Convert.ToInt32(
                    command.ExecuteScalar());
                return item.OrderItemID;
            }
        }

        public List<int> AddRange(
            IList<OrderItem> items,
            SqlConnection connection,
            SqlTransaction transaction)
        {
            ValidateItems(items);
            List<int> ids = new List<int>();

            foreach (OrderItem item in items)
            {
                ids.Add(Add(item, connection, transaction));
            }

            return ids;
        }

        private static void AddWriteParameters(
            SqlCommand command,
            OrderItem item)
        {
            command.Parameters.Add(
                "@OrderID",
                SqlDbType.Int).Value = item.OrderID;
            command.Parameters.Add(
                "@ProductVariantID",
                SqlDbType.Int).Value = item.ProductVariantID;

            SqlParameter price = command.Parameters.Add(
                "@UnitPrice",
                SqlDbType.Decimal);
            price.Precision = 10;
            price.Scale = 2;
            price.Value = item.UnitPrice;

            command.Parameters.Add(
                "@Quantity",
                SqlDbType.Int).Value = item.Quantity;
        }

        private static OrderItem Map(SqlDataReader reader)
        {
            int imagePathOrdinal = reader.GetOrdinal("ImagePath");
            int sizeOrdinal = reader.GetOrdinal("SizeName");

            return new OrderItem
            {
                OrderItemID = reader.GetInt32(
                    reader.GetOrdinal("OrderItemID")),
                OrderID = reader.GetInt32(
                    reader.GetOrdinal("OrderID")),
                ProductVariantID = reader.GetInt32(
                    reader.GetOrdinal("ProductVariantID")),
                ProductName = reader.GetString(
                    reader.GetOrdinal("ProductName")),
                ImagePath = reader.IsDBNull(imagePathOrdinal)
                    ? null
                    : reader.GetString(imagePathOrdinal),
                SizeName = reader.IsDBNull(sizeOrdinal)
                    ? null
                    : reader.GetString(sizeOrdinal),
                UnitPrice = reader.GetDecimal(
                    reader.GetOrdinal("UnitPrice")),
                Quantity = reader.GetInt32(
                    reader.GetOrdinal("Quantity"))
            };
        }

        private static void ValidateItems(IList<OrderItem> items)
        {
            if (items == null || items.Count == 0)
            {
                throw new ArgumentException(
                    "An order must contain at least one item.",
                    "items");
            }

            foreach (OrderItem item in items)
            {
                Validate(item);
            }
        }

        private static void Validate(OrderItem item)
        {
            if (item == null)
            {
                throw new ArgumentNullException("item");
            }

            ValidateID(item.OrderID, "orderID");
            ValidateID(item.ProductVariantID, "productVariantID");

            if (item.UnitPrice < 0)
            {
                throw new ArgumentException(
                    "Unit price cannot be negative.",
                    "item");
            }

            if (item.Quantity < 1)
            {
                throw new ArgumentException(
                    "Quantity must be greater than zero.",
                    "item");
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
