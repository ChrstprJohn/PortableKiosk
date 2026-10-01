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

            const string sql = "dbo.Product_Add";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
            {
                AddWriteParameters(command, product);
                connection.Open();
                product.ProductID = Convert.ToInt32(command.ExecuteScalar());
                return product.ProductID;
            }
        }

        public List<Product> GetAll()
        {
            const string sql = "dbo.Product_GetAll";

            List<Product> products = new List<Product>();
            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
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

            const string sql = "dbo.Product_GetByID";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
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

            const string sql = "dbo.Product_GetAvailableByID";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
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

            const string sql = "dbo.Product_GetAvailableByCategoryID";

            List<Product> products = new List<Product>();

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
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
            const string sql = "dbo.Product_GetTopSellingAvailable";

            List<Product> products = new List<Product>();
            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
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

            const string sql = "dbo.Product_Update";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure })
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

            const string deleteVariantsSql = "dbo.Product_Delete_DeleteVariants";
            const string deleteProductSql = "dbo.Product_Delete_DeleteProduct";

            using (SqlConnection connection = DatabaseConnection.GetConnection())
            {
                connection.Open();

                using (SqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand deleteVariants =
                            new SqlCommand(deleteVariantsSql, connection, transaction) { CommandType = CommandType.StoredProcedure })
                        {
                            deleteVariants.Parameters.Add(
                                "@ProductID",
                                SqlDbType.Int).Value = productID;
                            deleteVariants.ExecuteNonQuery();
                        }

                        int deletedProducts;
                        using (SqlCommand deleteProduct =
                            new SqlCommand(deleteProductSql, connection, transaction) { CommandType = CommandType.StoredProcedure })
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
