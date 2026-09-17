using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace PortableKiosk.Core.Data.Repositories
{
    public class BundleSlotRepository
    {
        public int Add(BundleSlot slot)
        {
            Validate(slot);

            const string sql = @"
                INSERT INTO BundleSlots
                    (
                        BundleID,
                        SlotName,
                        FixedProductVariantID,
                        OptionGroupID,
                        DefaultProductVariantID,
                        Quantity,
                        IsRequired,
                        DisplayOrder
                    )
                OUTPUT INSERTED.BundleSlotID
                VALUES
                    (
                        @BundleID,
                        @SlotName,
                        @FixedProductVariantID,
                        @OptionGroupID,
                        @DefaultProductVariantID,
                        @Quantity,
                        @IsRequired,
                        @DisplayOrder
                    );";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@BundleID",
                    SqlDbType.Int).Value =
                        slot.BundleID;

                command.Parameters.Add(
                    "@SlotName",
                    SqlDbType.NVarChar,
                    100).Value =
                        slot.SlotName.Trim();

                command.Parameters.Add(
                    "@FixedProductVariantID",
                    SqlDbType.Int).Value =
                        slot.FixedProductVariantID.HasValue
                            ? (object)slot.FixedProductVariantID.Value
                            : DBNull.Value;

                command.Parameters.Add(
                    "@OptionGroupID",
                    SqlDbType.Int).Value =
                        slot.OptionGroupID.HasValue
                            ? (object)slot.OptionGroupID.Value
                            : DBNull.Value;

                command.Parameters.Add(
                    "@DefaultProductVariantID",
                    SqlDbType.Int).Value =
                        slot.DefaultProductVariantID.HasValue
                            ? (object)slot.DefaultProductVariantID.Value
                            : DBNull.Value;

                command.Parameters.Add(
                    "@Quantity",
                    SqlDbType.Int).Value =
                        slot.Quantity;

                command.Parameters.Add(
                    "@IsRequired",
                    SqlDbType.Bit).Value =
                        slot.IsRequired;

                command.Parameters.Add(
                    "@DisplayOrder",
                    SqlDbType.Int).Value =
                        slot.DisplayOrder;

                connection.Open();

                int bundleSlotID =
                    Convert.ToInt32(
                        command.ExecuteScalar());

                slot.BundleSlotID = bundleSlotID;

                return bundleSlotID;
            }
        }

        public List<BundleSlot> GetAll()
        {
            const string sql = @"
                SELECT
                    slot.BundleSlotID,
                    slot.BundleID,
                    slot.SlotName,
                    slot.FixedProductVariantID,
                    slot.OptionGroupID,
                    slot.DefaultProductVariantID,
                    slot.Quantity,
                    slot.IsRequired,
                    slot.DisplayOrder,
                    bundle.BundleName,
                    fixedProduct.ProductName
                        AS FixedProductName,
                    fixedCategory.CategoryName
                        AS FixedCategoryName,
                    fixedSize.SizeName
                        AS FixedSizeName,
                    optionGroup.OptionGroupName,
                    defaultProduct.ProductName
                        AS DefaultProductName,
                    defaultCategory.CategoryName
                        AS DefaultCategoryName,
                    defaultSize.SizeName
                        AS DefaultSizeName
                FROM BundleSlots AS slot
                INNER JOIN Bundles AS bundle
                    ON bundle.BundleID = slot.BundleID
                LEFT JOIN ProductVariants AS fixedVariant
                    ON fixedVariant.ProductVariantID =
                        slot.FixedProductVariantID
                LEFT JOIN Products AS fixedProduct
                    ON fixedProduct.ProductID =
                        fixedVariant.ProductID
                LEFT JOIN Categories AS fixedCategory
                    ON fixedCategory.CategoryID =
                        fixedProduct.CategoryID
                LEFT JOIN Sizes AS fixedSize
                    ON fixedSize.SizeID = fixedVariant.SizeID
                LEFT JOIN BundleOptionGroups AS optionGroup
                    ON optionGroup.OptionGroupID =
                        slot.OptionGroupID
                LEFT JOIN ProductVariants AS defaultVariant
                    ON defaultVariant.ProductVariantID =
                        slot.DefaultProductVariantID
                LEFT JOIN Products AS defaultProduct
                    ON defaultProduct.ProductID =
                        defaultVariant.ProductID
                LEFT JOIN Categories AS defaultCategory
                    ON defaultCategory.CategoryID =
                        defaultProduct.CategoryID
                LEFT JOIN Sizes AS defaultSize
                    ON defaultSize.SizeID =
                        defaultVariant.SizeID
                ORDER BY
                    bundle.DisplayOrder ASC,
                    bundle.BundleName ASC,
                    slot.DisplayOrder ASC,
                    slot.SlotName ASC;";

            List<BundleSlot> slots =
                new List<BundleSlot>();

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
                        int fixedVariantOrdinal =
                            reader.GetOrdinal(
                                "FixedProductVariantID");

                        int optionGroupOrdinal =
                            reader.GetOrdinal(
                                "OptionGroupID");

                        int defaultVariantOrdinal =
                            reader.GetOrdinal(
                                "DefaultProductVariantID");

                        bool isFixed =
                            !reader.IsDBNull(
                                fixedVariantOrdinal);

                        BundleSlot slot = new BundleSlot
                        {
                            BundleSlotID =
                                reader.GetInt32(
                                    reader.GetOrdinal(
                                        "BundleSlotID")),

                            BundleID =
                                reader.GetInt32(
                                    reader.GetOrdinal(
                                        "BundleID")),

                            SlotName =
                                reader.GetString(
                                    reader.GetOrdinal(
                                        "SlotName")),

                            FixedProductVariantID =
                                reader.IsDBNull(
                                    fixedVariantOrdinal)
                                        ? (int?)null
                                        : reader.GetInt32(
                                            fixedVariantOrdinal),

                            OptionGroupID =
                                reader.IsDBNull(
                                    optionGroupOrdinal)
                                        ? (int?)null
                                        : reader.GetInt32(
                                            optionGroupOrdinal),

                            DefaultProductVariantID =
                                reader.IsDBNull(
                                    defaultVariantOrdinal)
                                        ? (int?)null
                                        : reader.GetInt32(
                                            defaultVariantOrdinal),

                            Quantity =
                                reader.GetInt32(
                                    reader.GetOrdinal(
                                        "Quantity")),

                            IsRequired =
                                reader.GetBoolean(
                                    reader.GetOrdinal(
                                        "IsRequired")),

                            DisplayOrder =
                                reader.GetInt32(
                                    reader.GetOrdinal(
                                        "DisplayOrder")),

                            BundleName =
                                reader.GetString(
                                    reader.GetOrdinal(
                                        "BundleName")),

                            SlotType = isFixed
                                ? "Fixed product"
                                : "Choice group",

                            ConfigurationDescription =
                                isFixed
                                    ? BuildProductDescription(
                                        reader,
                                        "FixedCategoryName",
                                        "FixedProductName",
                                        "FixedSizeName")
                                    : BuildChoiceDescription(
                                        reader)
                        };

                        slots.Add(slot);
                    }
                }
            }

            return slots;
        }

        private static void Validate(BundleSlot slot)
        {
            if (slot == null)
            {
                throw new ArgumentNullException("slot");
            }

            if (slot.BundleID <= 0)
            {
                throw new ArgumentException(
                    "A valid bundle is required.",
                    "slot");
            }

            if (string.IsNullOrWhiteSpace(
                slot.SlotName))
            {
                throw new ArgumentException(
                    "Slot name is required.",
                    "slot");
            }

            if (slot.SlotName.Trim().Length > 100)
            {
                throw new ArgumentException(
                    "Slot name cannot exceed 100 characters.",
                    "slot");
            }

            bool isFixed =
                slot.FixedProductVariantID.HasValue &&
                !slot.OptionGroupID.HasValue &&
                !slot.DefaultProductVariantID.HasValue;

            bool isChoice =
                !slot.FixedProductVariantID.HasValue &&
                slot.OptionGroupID.HasValue &&
                slot.DefaultProductVariantID.HasValue;

            if (!isFixed && !isChoice)
            {
                throw new ArgumentException(
                    "Choose either one fixed product or one option group with a default choice.",
                    "slot");
            }

            if (slot.FixedProductVariantID.HasValue &&
                slot.FixedProductVariantID.Value <= 0)
            {
                throw new ArgumentException(
                    "The selected fixed product is invalid.",
                    "slot");
            }

            if (slot.OptionGroupID.HasValue &&
                slot.OptionGroupID.Value <= 0)
            {
                throw new ArgumentException(
                    "The selected option group is invalid.",
                    "slot");
            }

            if (slot.DefaultProductVariantID.HasValue &&
                slot.DefaultProductVariantID.Value <= 0)
            {
                throw new ArgumentException(
                    "The selected default choice is invalid.",
                    "slot");
            }

            if (slot.Quantity <= 0)
            {
                throw new ArgumentException(
                    "Quantity must be greater than zero.",
                    "slot");
            }

            if (slot.DisplayOrder < 0)
            {
                throw new ArgumentException(
                    "Display order cannot be negative.",
                    "slot");
            }
        }

        private static string BuildChoiceDescription(
            SqlDataReader reader)
        {
            string optionGroupName =
                GetNullableString(
                    reader,
                    "OptionGroupName");

            string defaultProduct =
                BuildProductDescription(
                    reader,
                    "DefaultCategoryName",
                    "DefaultProductName",
                    "DefaultSizeName");

            return optionGroupName +
                " — default: " +
                defaultProduct;
        }

        private static string BuildProductDescription(
            SqlDataReader reader,
            string categoryColumn,
            string productColumn,
            string sizeColumn)
        {
            string categoryName =
                GetNullableString(
                    reader,
                    categoryColumn);

            string productName =
                GetNullableString(
                    reader,
                    productColumn);

            string sizeName =
                GetNullableString(
                    reader,
                    sizeColumn);

            if (string.IsNullOrWhiteSpace(sizeName))
            {
                sizeName = "No size";
            }

            return categoryName +
                " - " +
                productName +
                " - " +
                sizeName;
        }

        private static string GetNullableString(
            SqlDataReader reader,
            string columnName)
        {
            int ordinal =
                reader.GetOrdinal(columnName);

            return reader.IsDBNull(ordinal)
                ? string.Empty
                : reader.GetString(ordinal);
        }
    }
}
