using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace PortableKiosk.Core.Data.Repositories
{
    public class CategoryRepository
    {
        public int Add(Category category)
        {
            if (category == null)
            {
                throw new ArgumentNullException("category");
            }

            if (string.IsNullOrWhiteSpace(category.CategoryName))
            {
                throw new ArgumentException(
                    "Category name is required.",
                    "category");
            }

            if (category.DisplayOrder < 0)
            {
                throw new ArgumentException(
                    "Display order cannot be negative.",
                    "category");
            }

            const string sql = @"
                INSERT INTO Categories
                    (CategoryName, DisplayOrder, IsAvailable)
                OUTPUT INSERTED.CategoryID
                VALUES
                    (@CategoryName, @DisplayOrder, @IsAvailable);";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@CategoryName",
                    SqlDbType.NVarChar,
                    100).Value = category.CategoryName.Trim();

                command.Parameters.Add(
                    "@DisplayOrder",
                    SqlDbType.Int).Value = category.DisplayOrder;

                command.Parameters.Add(
                    "@IsAvailable",
                    SqlDbType.Bit).Value = category.IsAvailable;

                connection.Open();

                int categoryID =
                    Convert.ToInt32(command.ExecuteScalar());

                category.CategoryID = categoryID;

                return categoryID;
            }
        }

        public List<Category> GetAll()
        {
            const string sql = @"
        SELECT
            CategoryID,
            CategoryName,
            DisplayOrder,
            IsAvailable
        FROM Categories
        ORDER BY DisplayOrder ASC, CategoryName ASC;";

            List<Category> categories = new List<Category>();

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
                        Category category = new Category
                        {
                            CategoryID =
                                reader.GetInt32(
                                    reader.GetOrdinal("CategoryID")),

                            CategoryName =
                                reader.GetString(
                                    reader.GetOrdinal("CategoryName")),

                            DisplayOrder =
                                reader.GetInt32(
                                    reader.GetOrdinal("DisplayOrder")),

                            IsAvailable =
                                reader.GetBoolean(
                                    reader.GetOrdinal("IsAvailable"))
                        };

                        categories.Add(category);
                    }
                }
            }

            return categories;
        }
    }
}