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
                INSERT INTO Products (CategoryID, ProductName, IsAvailable)
                OUTPUT INSERTED.ProductID
                VALUES (@CategoryID, @ProductName, @IsAvailable);";

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
                    p.ProductName, p.IsAvailable
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
                    p.ProductName, p.IsAvailable
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

        public bool Update(Product product)
        {
            ValidateForSave(product, true);

            const string sql = @"
                UPDATE Products
                SET CategoryID = @CategoryID,
                    ProductName = @ProductName,
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

            const string sql = @"
                DELETE FROM Products
                WHERE ProductID = @ProductID;";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@ProductID", SqlDbType.Int).Value = productID;
                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        private static void AddWriteParameters(SqlCommand command, Product product)
        {
            command.Parameters.Add("@CategoryID", SqlDbType.Int).Value = product.CategoryID;
            command.Parameters.Add("@ProductName", SqlDbType.NVarChar, 100).Value = product.ProductName.Trim();
            command.Parameters.Add("@IsAvailable", SqlDbType.Bit).Value = product.IsAvailable;
        }

        private static Product Map(SqlDataReader reader)
        {
            return new Product
            {
                ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                CategoryID = reader.GetInt32(reader.GetOrdinal("CategoryID")),
                CategoryName = reader.GetString(reader.GetOrdinal("CategoryName")),
                ProductName = reader.GetString(reader.GetOrdinal("ProductName")),
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
