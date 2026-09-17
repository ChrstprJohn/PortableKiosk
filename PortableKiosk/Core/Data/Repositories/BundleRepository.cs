using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace PortableKiosk.Core.Data.Repositories
{
    public class BundleRepository
    {
        public int Add(Bundle bundle)
        {
            if (bundle == null)
            {
                throw new ArgumentNullException("bundle");
            }

            if (string.IsNullOrWhiteSpace(
                bundle.BundleName))
            {
                throw new ArgumentException(
                    "Bundle name is required.",
                    "bundle");
            }

            if (bundle.BasePrice < 0)
            {
                throw new ArgumentException(
                    "Base price cannot be negative.",
                    "bundle");
            }

            if (bundle.BasePrice > 99999999.99m)
            {
                throw new ArgumentException(
                    "Base price is too large.",
                    "bundle");
            }

            if (!string.IsNullOrWhiteSpace(
                    bundle.ImagePath) &&
                bundle.ImagePath.Length > 500)
            {
                throw new ArgumentException(
                    "Image path cannot exceed 500 characters.",
                    "bundle");
            }

            if (bundle.DisplayOrder < 0)
            {
                throw new ArgumentException(
                    "Display order cannot be negative.",
                    "bundle");
            }

            const string sql = @"
                INSERT INTO Bundles
                    (
                        BundleName,
                        BasePrice,
                        ImagePath,
                        IsAvailable,
                        DisplayOrder
                    )
                OUTPUT INSERTED.BundleID
                VALUES
                    (
                        @BundleName,
                        @BasePrice,
                        @ImagePath,
                        @IsAvailable,
                        @DisplayOrder
                    );";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@BundleName",
                    SqlDbType.NVarChar,
                    100).Value =
                        bundle.BundleName.Trim();

                SqlParameter basePriceParameter =
                    command.Parameters.Add(
                        "@BasePrice",
                        SqlDbType.Decimal);

                basePriceParameter.Precision = 10;
                basePriceParameter.Scale = 2;
                basePriceParameter.Value =
                    bundle.BasePrice;

                command.Parameters.Add(
                    "@ImagePath",
                    SqlDbType.NVarChar,
                    500).Value =
                        string.IsNullOrWhiteSpace(
                            bundle.ImagePath)
                                ? (object)DBNull.Value
                                : bundle.ImagePath.Trim();

                command.Parameters.Add(
                    "@IsAvailable",
                    SqlDbType.Bit).Value =
                        bundle.IsAvailable;

                command.Parameters.Add(
                    "@DisplayOrder",
                    SqlDbType.Int).Value =
                        bundle.DisplayOrder;

                connection.Open();

                int bundleID =
                    Convert.ToInt32(
                        command.ExecuteScalar());

                bundle.BundleID = bundleID;

                return bundleID;
            }
        }

        public List<Bundle> GetAll()
        {
            const string sql = @"
                SELECT
                    BundleID,
                    BundleName,
                    BasePrice,
                    ImagePath,
                    IsAvailable,
                    DisplayOrder
                FROM Bundles
                ORDER BY
                    DisplayOrder ASC,
                    BundleName ASC;";

            List<Bundle> bundles =
                new List<Bundle>();

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
                        int imagePathOrdinal =
                            reader.GetOrdinal(
                                "ImagePath");

                        Bundle bundle = new Bundle
                        {
                            BundleID =
                                reader.GetInt32(
                                    reader.GetOrdinal(
                                        "BundleID")),

                            BundleName =
                                reader.GetString(
                                    reader.GetOrdinal(
                                        "BundleName")),

                            BasePrice =
                                reader.GetDecimal(
                                    reader.GetOrdinal(
                                        "BasePrice")),

                            ImagePath =
                                reader.IsDBNull(
                                    imagePathOrdinal)
                                        ? null
                                        : reader.GetString(
                                            imagePathOrdinal),

                            IsAvailable =
                                reader.GetBoolean(
                                    reader.GetOrdinal(
                                        "IsAvailable")),

                            DisplayOrder =
                                reader.GetInt32(
                                    reader.GetOrdinal(
                                        "DisplayOrder"))
                        };

                        bundles.Add(bundle);
                    }
                }
            }

            return bundles;
        }
    }
}