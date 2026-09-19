using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace PortableKiosk.Core.Data.Repositories
{
    public class SizeRepository
    {
        public int Add(Size size)
        {
            Validate(size);

            const string sql = @"
                INSERT INTO Sizes
                    (SizeName)
                OUTPUT INSERTED.SizeID
                VALUES
                    (@SizeName);";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                AddWriteParameters(command, size);
                connection.Open();

                size.SizeID =
                    Convert.ToInt32(command.ExecuteScalar());

                return size.SizeID;
            }
        }

        public Size GetByID(int sizeID)
        {
            ValidateID(sizeID);

            const string sql = @"
                SELECT
                    SizeID,
                    SizeName
                FROM Sizes
                WHERE SizeID = @SizeID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@SizeID",
                    SqlDbType.Int).Value = sizeID;

                connection.Open();

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    return reader.Read() ? Map(reader) : null;
                }
            }
        }

        public List<Size> GetAll()
        {
            const string sql = @"
                SELECT
                    SizeID,
                    SizeName
                FROM Sizes
                ORDER BY SizeName ASC, SizeID ASC;";

            List<Size> sizes = new List<Size>();

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
                        sizes.Add(Map(reader));
                    }
                }
            }

            return sizes;
        }

        public bool Update(Size size)
        {
            Validate(size);
            ValidateID(size.SizeID);

            const string sql = @"
                UPDATE Sizes
                SET
                    SizeName = @SizeName
                WHERE SizeID = @SizeID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                AddWriteParameters(command, size);
                command.Parameters.Add(
                    "@SizeID",
                    SqlDbType.Int).Value = size.SizeID;

                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        public bool Delete(int sizeID)
        {
            ValidateID(sizeID);

            const string sql = @"
                DELETE FROM Sizes
                WHERE SizeID = @SizeID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@SizeID",
                    SqlDbType.Int).Value = sizeID;

                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        private static void AddWriteParameters(
            SqlCommand command,
            Size size)
        {
            command.Parameters.Add(
                "@SizeName",
                SqlDbType.NVarChar,
                50).Value = size.SizeName.Trim();

        }

        private static Size Map(SqlDataReader reader)
        {
            return new Size
            {
                SizeID = reader.GetInt32(
                    reader.GetOrdinal("SizeID")),
                SizeName = reader.GetString(
                    reader.GetOrdinal("SizeName"))
            };
        }

        private static void Validate(Size size)
        {
            if (size == null)
            {
                throw new ArgumentNullException("size");
            }

            if (string.IsNullOrWhiteSpace(size.SizeName))
            {
                throw new ArgumentException(
                    "Size name is required.",
                    "size");
            }

            if (size.SizeName.Trim().Length > 50)
            {
                throw new ArgumentException(
                    "Size name cannot exceed 50 characters.",
                    "size");
            }

        }

        private static void ValidateID(int sizeID)
        {
            if (sizeID <= 0)
            {
                throw new ArgumentException(
                    "A valid size is required.",
                    "sizeID");
            }
        }
    }
}
