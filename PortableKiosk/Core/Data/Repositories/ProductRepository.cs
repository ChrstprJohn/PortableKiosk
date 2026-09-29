using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace PortableKiosk.Core.Data.Repositories
{
    public class ProductRepository
    {
        public int Add(Product product)
        {
            ValidateForSave(product, false);

            const string sql = @"
                INSERT INTO Products
                    (CategoryID, ProductName, ProductDescription, IsAvailable)
                OUTPUT INSERTED.ProductID
                VALUES
                    (@CategoryID, @ProductName, @ProductDescription, @IsAvailable);";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                AddWriteParameters(command, product);
                connection.Open();
                product.ProductID = Convert.ToInt32(command.ExecuteScalar());
                return product.ProductID;
            }
        }

        public List<Product> GetAll()
        {
            const string sql = @"
                SELECT p.ProductID, p.CategoryID, c.CategoryName,
                    p.ProductName, p.ProductDescription, p.IsAvailable
                FROM Products AS p
                INNER JOIN Categories AS c ON c.CategoryID = p.CategoryID
                ORDER BY p.ProductName ASC, p.ProductID ASC;";

            List<Product> products = new List<Product>();
            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        products.Add(Map(reader));
                    }
                }
            }

            return products;
        }

        public Product GetByID(int productID)
        {
            ValidateID(productID);

            const string sql = @"
                SELECT p.ProductID, p.CategoryID, c.CategoryName,
                    p.ProductName, p.ProductDescription, p.IsAvailable
                FROM Products AS p
                INNER JOIN Categories AS c ON c.CategoryID = p.CategoryID
                WHERE p.ProductID = @ProductID;";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@ProductID", SqlDbType.Int).Value = productID;
                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    return reader.Read() ? Map(reader) : null;
                }
            }
        }

        public Product GetAvailableByID(int productID)
        {
            ValidateID(productID);

            const string sql = @"
                SELECT p.ProductID, p.CategoryID, c.CategoryName,
                    p.ProductName, p.ProductDescription, p.IsAvailable
                FROM Products AS p
                INNER JOIN Categories AS c ON c.CategoryID = p.CategoryID
                WHERE p.ProductID = @ProductID
                    AND p.IsAvailable = 1
                    AND c.IsAvailable = 1
                    AND EXISTS
                    (
                        SELECT 1
                        FROM ProductVariants AS pv
                        WHERE pv.ProductID = p.ProductID
                            AND pv.IsAvailable = 1
                    );";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@ProductID", SqlDbType.Int).Value = productID;
                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    return reader.Read() ? Map(reader) : null;
                }
            }
        }

        public List<Product> GetAvailableByCategoryID(int categoryID)
        {
            if (categoryID <= 0)
            {
                throw new ArgumentException(
                    "A valid category is required.",
                    "categoryID");
            }

            const string sql = @"
                SELECT p.ProductID, p.CategoryID, c.CategoryName,
                    p.ProductName, p.ProductDescription, p.IsAvailable
                FROM Products AS p
                INNER JOIN Categories AS c ON c.CategoryID = p.CategoryID
                WHERE p.CategoryID = @CategoryID
                    AND p.IsAvailable = 1
                    AND c.IsAvailable = 1
                    AND EXISTS
                    (
                        SELECT 1
                        FROM ProductVariants AS pv
                        WHERE pv.ProductID = p.ProductID
                            AND pv.IsAvailable = 1
                    )
                ORDER BY p.ProductName ASC, p.ProductID ASC;";

            List<Product> products = new List<Product>();

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@CategoryID", SqlDbType.Int).Value = categoryID;
                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        products.Add(Map(reader));
                    }
                }
            }

            return products;
        }

        public List<Product> GetTopSellingAvailable(int count)
        {
            if (count <= 0)
            {
                throw new ArgumentException("Count must be positive.", "count");
            }

            // Match Analytics popular products: units from paid orders, across variants.
            // Only return products that a customer can open and add to the cart now.
            const string sql = @"
                WITH SoldUnits AS
                (
                    SELECT pv.ProductID, SUM(oi.Quantity) AS Units
                    FROM ProductVariants AS pv
                    INNER JOIN OrderItems AS oi
                        ON oi.ProductVariantID = pv.ProductVariantID
                    WHERE EXISTS
                    (
                        SELECT 1 FROM Payments AS pay
                        WHERE pay.OrderID = oi.OrderID
                            AND pay.PaymentStatus = N'PAID'
                    )
                    GROUP BY pv.ProductID
                )
                SELECT TOP (@Count) p.ProductID, p.CategoryID, c.CategoryName,
                    p.ProductName, p.ProductDescription, p.IsAvailable
                FROM Products AS p
                INNER JOIN Categories AS c ON c.CategoryID = p.CategoryID
                INNER JOIN SoldUnits AS sold ON sold.ProductID = p.ProductID
                WHERE p.IsAvailable = 1 AND c.IsAvailable = 1
                    AND EXISTS
                    (
                        SELECT 1 FROM ProductVariants AS available
                        WHERE available.ProductID = p.ProductID
                            AND available.IsAvailable = 1
                    )
                ORDER BY sold.Units DESC, p.ProductName ASC,
                    p.ProductID ASC;";

            List<Product> products = new List<Product>();
            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@Count", SqlDbType.Int).Value = count;
                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        products.Add(Map(reader));
                    }
                }
            }

            return products;
        }

        public bool Update(Product product)
        {
            ValidateForSave(product, true);

            const string sql = @"
                UPDATE Products
                SET CategoryID = @CategoryID,
                    ProductName = @ProductName,
                    ProductDescription = @ProductDescription,
                    IsAvailable = @IsAvailable
                WHERE ProductID = @ProductID;";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                AddWriteParameters(command, product);
                command.Parameters.Add("@ProductID", SqlDbType.Int).Value = product.ProductID;
                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        public bool Delete(int productID)
        {
            ValidateID(productID);

            const string deleteVariantsSql = @"
                DELETE FROM ProductVariants
                WHERE ProductID = @ProductID;";
            const string deleteProductSql = @"
                DELETE FROM Products
                WHERE ProductID = @ProductID;";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            {
                connection.Open();

                using (SqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand deleteVariants =
                            new SqlCommand(deleteVariantsSql, connection, transaction))
                        {
                            deleteVariants.Parameters.Add(
                                "@ProductID",
                                SqlDbType.Int).Value = productID;
                            deleteVariants.ExecuteNonQuery();
                        }

                        int deletedProducts;
                        using (SqlCommand deleteProduct =
                            new SqlCommand(deleteProductSql, connection, transaction))
                        {
                            deleteProduct.Parameters.Add(
                                "@ProductID",
                                SqlDbType.Int).Value = productID;
                            deletedProducts = deleteProduct.ExecuteNonQuery();
                        }

                        transaction.Commit();
                        return deletedProducts > 0;
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        private static void AddWriteParameters(SqlCommand command, Product product)
        {
            command.Parameters.Add("@CategoryID", SqlDbType.Int).Value = product.CategoryID;
            command.Parameters.Add("@ProductName", SqlDbType.NVarChar, 100).Value = product.ProductName.Trim();
            command.Parameters.Add("@ProductDescription", SqlDbType.NVarChar, 500).Value =
                string.IsNullOrWhiteSpace(product.ProductDescription)
                    ? (object)DBNull.Value
                    : product.ProductDescription.Trim();
            command.Parameters.Add("@IsAvailable", SqlDbType.Bit).Value = product.IsAvailable;
        }

        private static Product Map(SqlDataReader reader)
        {
            int descriptionOrdinal =
                reader.GetOrdinal("ProductDescription");

            return new Product
            {
                ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                CategoryID = reader.GetInt32(reader.GetOrdinal("CategoryID")),
                CategoryName = reader.GetString(reader.GetOrdinal("CategoryName")),
                ProductName = reader.GetString(reader.GetOrdinal("ProductName")),
                ProductDescription = reader.IsDBNull(descriptionOrdinal)
                    ? null
                    : reader.GetString(descriptionOrdinal),
                IsAvailable = reader.GetBoolean(reader.GetOrdinal("IsAvailable"))
            };
        }

        private static void ValidateForSave(Product product, bool requireID)
        {
            if (product == null)
            {
                throw new ArgumentNullException("product");
            }

            if (requireID)
            {
                ValidateID(product.ProductID);
            }

            if (product.CategoryID <= 0)
            {
                throw new ArgumentException("A valid category is required.", "product");
            }

            if (string.IsNullOrWhiteSpace(product.ProductName))
            {
                throw new ArgumentException("Product name is required.", "product");
            }

            if (product.ProductName.Trim().Length > 100)
            {
                throw new ArgumentException("Product name cannot exceed 100 characters.", "product");
            }

            if (!string.IsNullOrWhiteSpace(product.ProductDescription) &&
                product.ProductDescription.Trim().Length > 500)
            {
                throw new ArgumentException(
                    "Product description cannot exceed 500 characters.",
                    "product");
            }
        }

        private static void ValidateID(int productID)
        {
            if (productID <= 0)
            {
                throw new ArgumentException("A valid product is required.", "productID");
            }
        }
    }
}
