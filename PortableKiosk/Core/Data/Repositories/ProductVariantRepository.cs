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
            Validate(variant);

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

        public List<int> AddRange(
            IList<ProductVariant> variants)
        {
            if (variants == null)
            {
                throw new ArgumentNullException("variants");
            }

            if (variants.Count == 0)
            {
                throw new ArgumentException(
                    "Select at least one variant to save.",
                    "variants");
            }

            foreach (ProductVariant variant in variants)
            {
                Validate(variant);
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

            List<int> productVariantIDs = new List<int>();

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            {
                connection.Open();

                using (SqlTransaction transaction =
                    connection.BeginTransaction())
                {
                    try
                    {
                        foreach (ProductVariant variant in variants)
                        {
                            using (SqlCommand command =
                                new SqlCommand(
                                    sql,
                                    connection,
                                    transaction))
                            {
                                AddInsertParameters(command, variant);

                                int productVariantID =
                                    Convert.ToInt32(
                                        command.ExecuteScalar());

                                variant.ProductVariantID =
                                    productVariantID;

                                productVariantIDs.Add(
                                    productVariantID);
                            }
                        }

                        transaction.Commit();
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }

            return productVariantIDs;
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
                    c.CategoryName ASC,
                    p.ProductName ASC,
                    s.SizeName ASC,
                    pv.ProductVariantID ASC;";

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
                        variants.Add(Map(reader));
                    }
                }
            }

            return variants;
        }

        public List<ProductVariant> GetByProductID(
            int productID)
        {
            if (productID <= 0)
            {
                throw new ArgumentException(
                    "A valid product is required.",
                    "productID");
            }

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
                WHERE pv.ProductID = @ProductID
                ORDER BY
                    s.SizeName ASC,
                    pv.ProductVariantID ASC;";

            List<ProductVariant> variants =
                new List<ProductVariant>();

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
                    while (reader.Read())
                    {
                        variants.Add(Map(reader));
                    }
                }
            }

            return variants;
        }

        public List<ProductVariant> GetAvailableByProductID(
            int productID)
        {
            if (productID <= 0)
            {
                throw new ArgumentException(
                    "A valid product is required.",
                    "productID");
            }

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
                WHERE pv.ProductID = @ProductID
                    AND pv.IsAvailable = 1
                    AND p.IsAvailable = 1
                    AND c.IsAvailable = 1
                ORDER BY
                    CASE WHEN pv.SizeID IS NULL THEN 0 ELSE 1 END,
                    pv.Price ASC,
                    s.SizeName ASC,
                    pv.ProductVariantID ASC;";

            List<ProductVariant> variants =
                new List<ProductVariant>();

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
                    while (reader.Read())
                    {
                        variants.Add(Map(reader));
                    }
                }
            }

            return variants;
        }

        public ProductVariant GetByID(int productVariantID)
        {
            ValidateID(productVariantID);

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
                WHERE pv.ProductVariantID = @ProductVariantID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@ProductVariantID",
                    SqlDbType.Int).Value = productVariantID;

                connection.Open();

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    return reader.Read() ? Map(reader) : null;
                }
            }
        }

        public ProductVariant GetAvailableByID(
            int productVariantID)
        {
            ValidateID(productVariantID);

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
                WHERE pv.ProductVariantID = @ProductVariantID
                    AND pv.IsAvailable = 1
                    AND p.IsAvailable = 1
                    AND c.IsAvailable = 1;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@ProductVariantID",
                    SqlDbType.Int).Value = productVariantID;

                connection.Open();

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    return reader.Read() ? Map(reader) : null;
                }
            }
        }

        public bool Update(ProductVariant variant)
        {
            Validate(variant);
            ValidateID(variant.ProductVariantID);

            const string sql = @"
                UPDATE ProductVariants
                SET
                    ProductID = @ProductID,
                    SizeID = @SizeID,
                    Price = @Price,
                    ImagePath = @ImagePath,
                    IsAvailable = @IsAvailable
                WHERE ProductVariantID = @ProductVariantID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                AddInsertParameters(command, variant);
                command.Parameters.Add(
                    "@ProductVariantID",
                    SqlDbType.Int).Value =
                        variant.ProductVariantID;

                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        public bool Delete(int productVariantID)
        {
            ValidateID(productVariantID);

            const string sql = @"
                DELETE FROM ProductVariants
                WHERE ProductVariantID = @ProductVariantID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@ProductVariantID",
                    SqlDbType.Int).Value = productVariantID;

                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        private static void AddInsertParameters(
            SqlCommand command,
            ProductVariant variant)
        {
            command.Parameters.Add(
                "@ProductID",
                SqlDbType.Int).Value = variant.ProductID;

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
                SqlDbType.Bit).Value = variant.IsAvailable;
        }

        private static ProductVariant Map(
            SqlDataReader reader)
        {
            int sizeIDOrdinal = reader.GetOrdinal("SizeID");
            int sizeNameOrdinal = reader.GetOrdinal("SizeName");
            int imagePathOrdinal = reader.GetOrdinal("ImagePath");

            return new ProductVariant
            {
                ProductVariantID = reader.GetInt32(
                    reader.GetOrdinal("ProductVariantID")),
                ProductID = reader.GetInt32(
                    reader.GetOrdinal("ProductID")),
                SizeID = reader.IsDBNull(sizeIDOrdinal)
                    ? (int?)null
                    : reader.GetInt32(sizeIDOrdinal),
                Price = reader.GetDecimal(
                    reader.GetOrdinal("Price")),
                ImagePath = reader.IsDBNull(imagePathOrdinal)
                    ? null
                    : reader.GetString(imagePathOrdinal),
                IsAvailable = reader.GetBoolean(
                    reader.GetOrdinal("IsAvailable")),
                ProductName = reader.GetString(
                    reader.GetOrdinal("ProductName")),
                CategoryName = reader.GetString(
                    reader.GetOrdinal("CategoryName")),
                SizeName = reader.IsDBNull(sizeNameOrdinal)
                    ? "No size"
                    : reader.GetString(sizeNameOrdinal)
            };
        }

        private static void Validate(ProductVariant variant)
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
        }

        private static void ValidateID(int productVariantID)
        {
            if (productVariantID <= 0)
            {
                throw new ArgumentException(
                    "A valid product variant is required.",
                    "productVariantID");
            }
        }
    }
}
