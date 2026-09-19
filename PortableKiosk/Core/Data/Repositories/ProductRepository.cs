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
            if (product == null)
            {
                throw new ArgumentNullException("product");
            }

            if (product.CategoryID <= 0)
            {
                throw new ArgumentException(
                    "A valid category is required.",
                    "product");
            }

            if (string.IsNullOrWhiteSpace(
                product.ProductName))
            {
                throw new ArgumentException(
                    "Product name is required.",
                    "product");
            }

            if (product.DisplayOrder < 0)
            {
                throw new ArgumentException(
                    "Display order cannot be negative.",
                    "product");
            }

            const string sql = @"
                INSERT INTO Products
                    (
                        CategoryID,
                        ProductName,
                        IsAvailable,
                        DisplayOrder
                    )
                OUTPUT INSERTED.ProductID
                VALUES
                    (
                        @CategoryID,
                        @ProductName,
                        @IsAvailable,
                        @DisplayOrder
                    );";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@CategoryID",
                    SqlDbType.Int).Value =
                        product.CategoryID;

                command.Parameters.Add(
                    "@ProductName",
                    SqlDbType.NVarChar,
                    100).Value =
                        product.ProductName.Trim();

                command.Parameters.Add(
                    "@IsAvailable",
                    SqlDbType.Bit).Value =
                        product.IsAvailable;

                command.Parameters.Add(
                    "@DisplayOrder",
                    SqlDbType.Int).Value =
                        product.DisplayOrder;

                connection.Open();

                int productID =
                    Convert.ToInt32(
                        command.ExecuteScalar());

                product.ProductID = productID;

                return productID;
            }
        }

        public List<Product> GetAll()
        {
            const string sql = @"
                SELECT
                    p.ProductID,
                    p.CategoryID,
                    c.CategoryName,
                    p.ProductName,
                    p.IsAvailable,
                    p.DisplayOrder
                FROM Products AS p
                INNER JOIN Categories AS c
                    ON c.CategoryID = p.CategoryID
                ORDER BY
                    p.DisplayOrder ASC,
                    p.ProductName ASC;";

            List<Product> products =
                new List<Product>();

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                connection.Open();

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Product product = new Product
                        {
                            ProductID =
                                reader.GetInt32(
                                    reader.GetOrdinal(
                                        "ProductID")),

                            CategoryID =
                                reader.GetInt32(
                                    reader.GetOrdinal(
                                        "CategoryID")),

                            CategoryName =
                                reader.GetString(
                                    reader.GetOrdinal(
                                        "CategoryName")),

                            ProductName =
                                reader.GetString(
                                    reader.GetOrdinal(
                                        "ProductName")),

                            IsAvailable =
                                reader.GetBoolean(
                                    reader.GetOrdinal(
                                        "IsAvailable")),

                            DisplayOrder =
                                reader.GetInt32(
                                    reader.GetOrdinal(
                                        "DisplayOrder"))
                        };

                        products.Add(product);
                    }
                }
            }

            return products;
        }

        public Product GetByID(int productID)
        {
            if (productID <= 0)
            {
                throw new ArgumentException(
                    "A valid product is required.",
                    "productID");
            }

            const string sql = @"
                SELECT
                    p.ProductID,
                    p.CategoryID,
                    c.CategoryName,
                    p.ProductName,
                    p.IsAvailable,
                    p.DisplayOrder
                FROM Products AS p
                INNER JOIN Categories AS c
                    ON c.CategoryID = p.CategoryID
                WHERE p.ProductID = @ProductID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@ProductID",
                    SqlDbType.Int).Value = productID;

                connection.Open();

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        return null;
                    }

                    return new Product
                    {
                        ProductID = reader.GetInt32(
                            reader.GetOrdinal("ProductID")),
                        CategoryID = reader.GetInt32(
                            reader.GetOrdinal("CategoryID")),
                        CategoryName = reader.GetString(
                            reader.GetOrdinal("CategoryName")),
                        ProductName = reader.GetString(
                            reader.GetOrdinal("ProductName")),
                        IsAvailable = reader.GetBoolean(
                            reader.GetOrdinal("IsAvailable")),
                        DisplayOrder = reader.GetInt32(
                            reader.GetOrdinal("DisplayOrder"))
                    };
                }
            }
        }

        public bool Update(Product product)
        {
            if (product == null)
            {
                throw new ArgumentNullException("product");
            }

            if (product.ProductID <= 0)
            {
                throw new ArgumentException(
                    "A valid product is required.",
                    "product");
            }

            if (product.CategoryID <= 0)
            {
                throw new ArgumentException(
                    "A valid category is required.",
                    "product");
            }

            if (string.IsNullOrWhiteSpace(product.ProductName))
            {
                throw new ArgumentException(
                    "Product name is required.",
                    "product");
            }

            if (product.ProductName.Trim().Length > 100)
            {
                throw new ArgumentException(
                    "Product name cannot exceed 100 characters.",
                    "product");
            }

            if (product.DisplayOrder < 0)
            {
                throw new ArgumentException(
                    "Display order cannot be negative.",
                    "product");
            }

            const string sql = @"
                UPDATE Products
                SET
                    CategoryID = @CategoryID,
                    ProductName = @ProductName,
                    IsAvailable = @IsAvailable,
                    DisplayOrder = @DisplayOrder
                WHERE ProductID = @ProductID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@ProductID",
                    SqlDbType.Int).Value = product.ProductID;

                command.Parameters.Add(
                    "@CategoryID",
                    SqlDbType.Int).Value = product.CategoryID;

                command.Parameters.Add(
                    "@ProductName",
                    SqlDbType.NVarChar,
                    100).Value = product.ProductName.Trim();

                command.Parameters.Add(
                    "@IsAvailable",
                    SqlDbType.Bit).Value = product.IsAvailable;

                command.Parameters.Add(
                    "@DisplayOrder",
                    SqlDbType.Int).Value = product.DisplayOrder;

                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        public bool Delete(int productID)
        {
            if (productID <= 0)
            {
                throw new ArgumentException(
                    "A valid product is required.",
                    "productID");
            }

            const string sql = @"
                DELETE FROM Products
                WHERE ProductID = @ProductID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@ProductID",
                    SqlDbType.Int).Value = productID;

                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }
    }
}
