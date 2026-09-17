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

            if (size.DisplayOrder < 0)
            {
                throw new ArgumentException(
                    "Display order cannot be negative.",
                    "size");
            }

            const string sql = @"
                INSERT INTO Sizes
                    (SizeName, DisplayOrder)
                OUTPUT INSERTED.SizeID
                VALUES
                    (@SizeName, @DisplayOrder);";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@SizeName",
                    SqlDbType.NVarChar,
                    50).Value = size.SizeName.Trim();

                command.Parameters.Add(
                    "@DisplayOrder",
                    SqlDbType.Int).Value = size.DisplayOrder;

                connection.Open();

                int sizeID =
                    Convert.ToInt32(command.ExecuteScalar());

                size.SizeID = sizeID;

                return sizeID;
            }
        }

        public List<Size> GetAll()
        {
            const string sql = @"
                SELECT
                    SizeID,
                    SizeName,
                    DisplayOrder
                FROM Sizes
                ORDER BY DisplayOrder ASC, SizeName ASC;";

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
                        Size size = new Size
                        {
                            SizeID =
                                reader.GetInt32(
                                    reader.GetOrdinal("SizeID")),

                            SizeName =
                                reader.GetString(
                                    reader.GetOrdinal("SizeName")),

                            DisplayOrder =
                                reader.GetInt32(
                                    reader.GetOrdinal("DisplayOrder"))
                        };

                        sizes.Add(size);
                    }
                }
            }

            return sizes;
        }
    }
}