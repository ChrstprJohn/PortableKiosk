using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace PortableKiosk.Core.Data.Repositories
{
    public class ProductVariantRepository
    {
        public int Add(ProductVariant variant)
        {
            if (variant == null)
            {
                throw new ArgumentNullException("variant");
            }

            if (variant.ProductID <= 0)
            {
                throw new ArgumentException(
                    "A valid product is required.",
                    "variant");
            }

            if (variant.SizeID.HasValue &&
                variant.SizeID.Value <= 0)
            {
                throw new ArgumentException(
                    "The selected size is invalid.",
                    "variant");
            }

            if (variant.Price < 0)
            {
                throw new ArgumentException(
                    "Price cannot be negative.",
                    "variant");
            }

            if (!string.IsNullOrWhiteSpace(
                    variant.ImagePath) &&
                variant.ImagePath.Length > 500)
            {
                throw new ArgumentException(
                    "Image path cannot exceed 500 characters.",
                    "variant");
            }

            const string sql = @"
                INSERT INTO ProductVariants
                    (
                        ProductID,
                        SizeID,
                        Price,
                        ImagePath,
                        IsAvailable
                    )
                OUTPUT INSERTED.ProductVariantID
                VALUES
                    (
                        @ProductID,
                        @SizeID,
                        @Price,
                        @ImagePath,
                        @IsAvailable
                    );";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@ProductID",
                    SqlDbType.Int).Value =
                        variant.ProductID;

                command.Parameters.Add(
                    "@SizeID",
                    SqlDbType.Int).Value =
                        variant.SizeID.HasValue
                            ? (object)variant.SizeID.Value
                            : DBNull.Value;

                SqlParameter priceParameter =
                    command.Parameters.Add(
                        "@Price",
                        SqlDbType.Decimal);

                priceParameter.Precision = 10;
                priceParameter.Scale = 2;
                priceParameter.Value = variant.Price;

                command.Parameters.Add(
                    "@ImagePath",
                    SqlDbType.NVarChar,
                    500).Value =
                        string.IsNullOrWhiteSpace(
                            variant.ImagePath)
                                ? (object)DBNull.Value
                                : variant.ImagePath.Trim();

                command.Parameters.Add(
                    "@IsAvailable",
                    SqlDbType.Bit).Value =
                        variant.IsAvailable;

                connection.Open();

                int productVariantID =
                    Convert.ToInt32(
                        command.ExecuteScalar());

                variant.ProductVariantID =
                    productVariantID;

                return productVariantID;
            }
        }

        public List<ProductVariant> GetAll()
        {
            const string sql = @"
                SELECT
                    pv.ProductVariantID,
                    pv.ProductID,
                    pv.SizeID,
                    pv.Price,
                    pv.ImagePath,
                    pv.IsAvailable,
                    p.ProductName,
                    c.CategoryName,
                    s.SizeName
                FROM ProductVariants AS pv
                INNER JOIN Products AS p
                    ON p.ProductID = pv.ProductID
                INNER JOIN Categories AS c
                    ON c.CategoryID = p.CategoryID
                LEFT JOIN Sizes AS s
                    ON s.SizeID = pv.SizeID
                ORDER BY
                    c.DisplayOrder ASC,
                    p.DisplayOrder ASC,
                    s.DisplayOrder ASC,
                    p.ProductName ASC;";

            List<ProductVariant> variants =
                new List<ProductVariant>();

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
                        int sizeIDOrdinal =
                            reader.GetOrdinal("SizeID");

                        int sizeNameOrdinal =
                            reader.GetOrdinal("SizeName");

                        int imagePathOrdinal =
                            reader.GetOrdinal("ImagePath");

                        ProductVariant variant =
                            new ProductVariant
                            {
                                ProductVariantID =
                                    reader.GetInt32(
                                        reader.GetOrdinal(
                                            "ProductVariantID")),

                                ProductID =
                                    reader.GetInt32(
                                        reader.GetOrdinal(
                                            "ProductID")),

                                SizeID =
                                    reader.IsDBNull(sizeIDOrdinal)
                                        ? (int?)null
                                        : reader.GetInt32(
                                            sizeIDOrdinal),

                                Price =
                                    reader.GetDecimal(
                                        reader.GetOrdinal(
                                            "Price")),

                                ImagePath =
                                    reader.IsDBNull(imagePathOrdinal)
                                        ? null
                                        : reader.GetString(
                                            imagePathOrdinal),

                                IsAvailable =
                                    reader.GetBoolean(
                                        reader.GetOrdinal(
                                            "IsAvailable")),

                                ProductName =
                                    reader.GetString(
                                        reader.GetOrdinal(
                                            "ProductName")),

                                CategoryName =
                                    reader.GetString(
                                        reader.GetOrdinal(
                                            "CategoryName")),

                                SizeName =
                                    reader.IsDBNull(sizeNameOrdinal)
                                        ? "No size"
                                        : reader.GetString(
                                            sizeNameOrdinal)
                            };

                        variants.Add(variant);
                    }
                }
            }

            return variants;
        }
    }
}