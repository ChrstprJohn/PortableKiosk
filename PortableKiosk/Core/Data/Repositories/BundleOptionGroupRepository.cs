using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace PortableKiosk.Core.Data.Repositories
{
    public class BundleOptionGroupRepository
    {
        public int Add(
            BundleOptionGroup optionGroup)
        {
            if (optionGroup == null)
            {
                throw new ArgumentNullException(
                    "optionGroup");
            }

            if (string.IsNullOrWhiteSpace(
                optionGroup.OptionGroupName))
            {
                throw new ArgumentException(
                    "Option group name is required.",
                    "optionGroup");
            }

            if (optionGroup.DisplayOrder < 0)
            {
                throw new ArgumentException(
                    "Display order cannot be negative.",
                    "optionGroup");
            }

            const string sql = @"
                INSERT INTO BundleOptionGroups
                    (
                        OptionGroupName,
                        IsAvailable,
                        DisplayOrder
                    )
                OUTPUT INSERTED.OptionGroupID
                VALUES
                    (
                        @OptionGroupName,
                        @IsAvailable,
                        @DisplayOrder
                    );";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@OptionGroupName",
                    SqlDbType.NVarChar,
                    100).Value =
                        optionGroup.OptionGroupName.Trim();

                command.Parameters.Add(
                    "@IsAvailable",
                    SqlDbType.Bit).Value =
                        optionGroup.IsAvailable;

                command.Parameters.Add(
                    "@DisplayOrder",
                    SqlDbType.Int).Value =
                        optionGroup.DisplayOrder;

                connection.Open();

                int optionGroupID =
                    Convert.ToInt32(
                        command.ExecuteScalar());

                optionGroup.OptionGroupID =
                    optionGroupID;

                return optionGroupID;
            }
        }

        public List<BundleOptionGroup> GetAll()
        {
            const string sql = @"
                SELECT
                    OptionGroupID,
                    OptionGroupName,
                    IsAvailable,
                    DisplayOrder
                FROM BundleOptionGroups
                ORDER BY
                    DisplayOrder ASC,
                    OptionGroupName ASC;";

            List<BundleOptionGroup> optionGroups =
                new List<BundleOptionGroup>();

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
                        BundleOptionGroup optionGroup =
                            new BundleOptionGroup
                            {
                                OptionGroupID =
                                    reader.GetInt32(
                                        reader.GetOrdinal(
                                            "OptionGroupID")),

                                OptionGroupName =
                                    reader.GetString(
                                        reader.GetOrdinal(
                                            "OptionGroupName")),

                                IsAvailable =
                                    reader.GetBoolean(
                                        reader.GetOrdinal(
                                            "IsAvailable")),

                                DisplayOrder =
                                    reader.GetInt32(
                                        reader.GetOrdinal(
                                            "DisplayOrder"))
                            };

                        optionGroups.Add(optionGroup);
                    }
                }
            }

            return optionGroups;
        }
    }
}