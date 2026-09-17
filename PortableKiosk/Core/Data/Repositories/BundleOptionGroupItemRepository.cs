using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace PortableKiosk.Core.Data.Repositories
{
    public class BundleOptionGroupItemRepository
    {
        public void Add(
            BundleOptionGroupItem item)
        {
            if (item == null)
            {
                throw new ArgumentNullException("item");
            }

            if (item.OptionGroupID <= 0)
            {
                throw new ArgumentException(
                    "A valid option group is required.",
                    "item");
            }

            if (item.ProductVariantID <= 0)
            {
                throw new ArgumentException(
                    "A valid product variant is required.",
                    "item");
            }

            if (item.AdditionalPrice < 0)
            {
                throw new ArgumentException(
                    "Additional price cannot be negative.",
                    "item");
            }

            if (item.AdditionalPrice > 99999999.99m)
            {
                throw new ArgumentException(
                    "Additional price is too large.",
                    "item");
            }

            if (item.DisplayOrder < 0)
            {
                throw new ArgumentException(
                    "Display order cannot be negative.",
                    "item");
            }

            const string sql = @"
                INSERT INTO BundleOptionGroupItems
                    (
                        OptionGroupID,
                        ProductVariantID,
                        AdditionalPrice,
                        IsAvailable,
                        DisplayOrder
                    )
                VALUES
                    (
                        @OptionGroupID,
                        @ProductVariantID,
                        @AdditionalPrice,
                        @IsAvailable,
                        @DisplayOrder
                    );";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@OptionGroupID",
                    SqlDbType.Int).Value =
                        item.OptionGroupID;

                command.Parameters.Add(
                    "@ProductVariantID",
                    SqlDbType.Int).Value =
                        item.ProductVariantID;

                SqlParameter additionalPriceParameter =
                    command.Parameters.Add(
                        "@AdditionalPrice",
                        SqlDbType.Decimal);

                additionalPriceParameter.Precision = 10;
                additionalPriceParameter.Scale = 2;
                additionalPriceParameter.Value =
                    item.AdditionalPrice;

                command.Parameters.Add(
                    "@IsAvailable",
                    SqlDbType.Bit).Value =
                        item.IsAvailable;

                command.Parameters.Add(
                    "@DisplayOrder",
                    SqlDbType.Int).Value =
                        item.DisplayOrder;

                connection.Open();
                command.ExecuteNonQuery();
            }
        }

        public List<BundleOptionGroupItem> GetAll()
        {
            const string sql = @"
                SELECT
                    item.OptionGroupID,
                    item.ProductVariantID,
                    item.AdditionalPrice,
                    item.IsAvailable,
                    item.DisplayOrder,
                    groupTable.OptionGroupName,
                    variant.Price AS ProductVariantPrice,
                    product.ProductName,
                    category.CategoryName,
                    size.SizeName
                FROM BundleOptionGroupItems AS item
                INNER JOIN BundleOptionGroups AS groupTable
                    ON groupTable.OptionGroupID =
                        item.OptionGroupID
                INNER JOIN ProductVariants AS variant
                    ON variant.ProductVariantID =
                        item.ProductVariantID
                INNER JOIN Products AS product
                    ON product.ProductID = variant.ProductID
                INNER JOIN Categories AS category
                    ON category.CategoryID = product.CategoryID
                LEFT JOIN Sizes AS size
                    ON size.SizeID = variant.SizeID
                ORDER BY
                    groupTable.DisplayOrder ASC,
                    groupTable.OptionGroupName ASC,
                    item.DisplayOrder ASC,
                    category.DisplayOrder ASC,
                    product.DisplayOrder ASC,
                    size.DisplayOrder ASC,
                    product.ProductName ASC;";

            List<BundleOptionGroupItem> items =
                new List<BundleOptionGroupItem>();

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
                        int sizeNameOrdinal =
                            reader.GetOrdinal("SizeName");

                        BundleOptionGroupItem item =
                            new BundleOptionGroupItem
                            {
                                OptionGroupID =
                                    reader.GetInt32(
                                        reader.GetOrdinal(
                                            "OptionGroupID")),

                                ProductVariantID =
                                    reader.GetInt32(
                                        reader.GetOrdinal(
                                            "ProductVariantID")),

                                AdditionalPrice =
                                    reader.GetDecimal(
                                        reader.GetOrdinal(
                                            "AdditionalPrice")),

                                IsAvailable =
                                    reader.GetBoolean(
                                        reader.GetOrdinal(
                                            "IsAvailable")),

                                DisplayOrder =
                                    reader.GetInt32(
                                        reader.GetOrdinal(
                                            "DisplayOrder")),

                                OptionGroupName =
                                    reader.GetString(
                                        reader.GetOrdinal(
                                            "OptionGroupName")),

                                ProductVariantPrice =
                                    reader.GetDecimal(
                                        reader.GetOrdinal(
                                            "ProductVariantPrice")),

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

                        items.Add(item);
                    }
                }
            }

            return items;
        }
    }
}
