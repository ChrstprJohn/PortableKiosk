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
            Validate(category);

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
                AddWriteParameters(command, category);
                connection.Open();

                category.CategoryID =
                    Convert.ToInt32(command.ExecuteScalar());

                return category.CategoryID;
            }
        }

        public Category GetByID(int categoryID)
        {
            ValidateID(categoryID);

            const string sql = @"
                SELECT
                    CategoryID,
                    CategoryName,
                    DisplayOrder,
                    IsAvailable
                FROM Categories
                WHERE CategoryID = @CategoryID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@CategoryID",
                    SqlDbType.Int).Value = categoryID;

                connection.Open();

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    return reader.Read() ? Map(reader) : null;
                }
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
                        categories.Add(Map(reader));
                    }
                }
            }

            return categories;
        }

        public bool Update(Category category)
        {
            Validate(category);
            ValidateID(category.CategoryID);

            const string sql = @"
                UPDATE Categories
                SET
                    CategoryName = @CategoryName,
                    DisplayOrder = @DisplayOrder,
                    IsAvailable = @IsAvailable
                WHERE CategoryID = @CategoryID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                AddWriteParameters(command, category);
                command.Parameters.Add(
                    "@CategoryID",
                    SqlDbType.Int).Value = category.CategoryID;

                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        public bool Delete(int categoryID)
        {
            ValidateID(categoryID);

            const string sql = @"
                DELETE FROM Categories
                WHERE CategoryID = @CategoryID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@CategoryID",
                    SqlDbType.Int).Value = categoryID;

                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        private static void AddWriteParameters(
            SqlCommand command,
            Category category)
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
        }

        private static Category Map(SqlDataReader reader)
        {
            return new Category
            {
                CategoryID = reader.GetInt32(
                    reader.GetOrdinal("CategoryID")),
                CategoryName = reader.GetString(
                    reader.GetOrdinal("CategoryName")),
                DisplayOrder = reader.GetInt32(
                    reader.GetOrdinal("DisplayOrder")),
                IsAvailable = reader.GetBoolean(
                    reader.GetOrdinal("IsAvailable"))
            };
        }

        private static void Validate(Category category)
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

            if (category.CategoryName.Trim().Length > 100)
            {
                throw new ArgumentException(
                    "Category name cannot exceed 100 characters.",
                    "category");
            }

            if (category.DisplayOrder < 0)
            {
                throw new ArgumentException(
                    "Display order cannot be negative.",
                    "category");
            }
        }

        private static void ValidateID(int categoryID)
        {
            if (categoryID <= 0)
            {
                throw new ArgumentException(
                    "A valid category is required.",
                    "categoryID");
            }
        }
    }
}
