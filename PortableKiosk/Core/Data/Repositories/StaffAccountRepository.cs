using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Net.Mail;
using PortableKiosk.Core.Models;
using PortableKiosk.Shared.Security;

namespace PortableKiosk.Core.Data.Repositories
{
    public class StaffAccountRepository
    {
        private const int PasswordIterations = 100000;

        public int AddAdmin(
            StaffAccount account,
            string plainTextPassword)
        {
            return Add(account, plainTextPassword, "ADMIN");
        }

        public int AddCrew(
            StaffAccount account,
            string plainTextPassword)
        {
            return Add(account, plainTextPassword, "CREW");
        }

        public StaffAccount GetByEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                return null;
            }

            const string sql = @"
                SELECT
                    StaffAccountID,
                    FirstName,
                    MiddleName,
                    LastName,
                    Suffix,
                    Email,
                    PasswordHash,
                    PasswordSalt,
                    PasswordIterations,
                    StaffRole,
                    IsActive,
                    CreatedAt,
                    UpdatedAt
                FROM StaffAccounts
                WHERE Email = @Email;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@Email",
                    SqlDbType.NVarChar,
                    256).Value = NormalizeEmail(email);

                connection.Open();

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    return reader.Read()
                        ? Map(reader, true)
                        : null;
                }
            }
        }

        public List<StaffAccount> GetAll()
        {
            const string sql = @"
                SELECT
                    StaffAccountID,
                    FirstName,
                    MiddleName,
                    LastName,
                    Suffix,
                    Email,
                    StaffRole,
                    IsActive,
                    CreatedAt,
                    UpdatedAt
                FROM StaffAccounts
                ORDER BY LastName, FirstName, StaffAccountID;";

            List<StaffAccount> accounts =
                new List<StaffAccount>();

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
                        accounts.Add(Map(reader, false));
                    }
                }
            }

            return accounts;
        }

        private static int Add(
            StaffAccount account,
            string plainTextPassword,
            string staffRole)
        {
            Validate(account, plainTextPassword);

            byte[] passwordSalt;
            byte[] passwordHash;

            PasswordHasher.Create(
                plainTextPassword,
                PasswordIterations,
                out passwordSalt,
                out passwordHash);

            const string sql = @"
                INSERT INTO StaffAccounts
                (
                    FirstName,
                    MiddleName,
                    LastName,
                    Suffix,
                    Email,
                    PasswordHash,
                    PasswordSalt,
                    PasswordIterations,
                    StaffRole,
                    IsActive
                )
                OUTPUT
                    INSERTED.StaffAccountID,
                    INSERTED.CreatedAt
                VALUES
                (
                    @FirstName,
                    @MiddleName,
                    @LastName,
                    @Suffix,
                    @Email,
                    @PasswordHash,
                    @PasswordSalt,
                    @PasswordIterations,
                    @StaffRole,
                    @IsActive
                );";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@FirstName",
                    SqlDbType.NVarChar,
                    50).Value = account.FirstName.Trim();

                command.Parameters.Add(
                    "@MiddleName",
                    SqlDbType.NVarChar,
                    50).Value = ToDatabaseValue(account.MiddleName);

                command.Parameters.Add(
                    "@LastName",
                    SqlDbType.NVarChar,
                    50).Value = account.LastName.Trim();

                command.Parameters.Add(
                    "@Suffix",
                    SqlDbType.NVarChar,
                    20).Value = ToDatabaseValue(account.Suffix);

                command.Parameters.Add(
                    "@Email",
                    SqlDbType.NVarChar,
                    256).Value = NormalizeEmail(account.Email);

                command.Parameters.Add(
                    "@PasswordHash",
                    SqlDbType.VarBinary,
                    32).Value = passwordHash;

                command.Parameters.Add(
                    "@PasswordSalt",
                    SqlDbType.VarBinary,
                    16).Value = passwordSalt;

                command.Parameters.Add(
                    "@PasswordIterations",
                    SqlDbType.Int).Value = PasswordIterations;

                command.Parameters.Add(
                    "@StaffRole",
                    SqlDbType.NVarChar,
                    20).Value = staffRole;

                command.Parameters.Add(
                    "@IsActive",
                    SqlDbType.Bit).Value = account.IsActive;

                connection.Open();

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    reader.Read();

                    account.StaffAccountID = reader.GetInt32(0);
                    account.CreatedAt = reader.GetDateTime(1);
                }
            }

            account.Email = NormalizeEmail(account.Email);
            account.PasswordHash = passwordHash;
            account.PasswordSalt = passwordSalt;
            account.PasswordIterations = PasswordIterations;
            account.StaffRole = staffRole;

            return account.StaffAccountID;
        }

        private static StaffAccount Map(
            SqlDataReader reader,
            bool includeCredentials)
        {
            StaffAccount account = new StaffAccount
            {
                StaffAccountID = reader.GetInt32(
                    reader.GetOrdinal("StaffAccountID")),
                FirstName = reader.GetString(
                    reader.GetOrdinal("FirstName")),
                MiddleName = GetNullableString(
                    reader,
                    "MiddleName"),
                LastName = reader.GetString(
                    reader.GetOrdinal("LastName")),
                Suffix = GetNullableString(
                    reader,
                    "Suffix"),
                Email = reader.GetString(
                    reader.GetOrdinal("Email")),
                StaffRole = reader.GetString(
                    reader.GetOrdinal("StaffRole")),
                IsActive = reader.GetBoolean(
                    reader.GetOrdinal("IsActive")),
                CreatedAt = reader.GetDateTime(
                    reader.GetOrdinal("CreatedAt")),
                UpdatedAt = GetNullableDateTime(
                    reader,
                    "UpdatedAt")
            };

            if (includeCredentials)
            {
                account.PasswordHash =
                    (byte[])reader["PasswordHash"];
                account.PasswordSalt =
                    (byte[])reader["PasswordSalt"];
                account.PasswordIterations = reader.GetInt32(
                    reader.GetOrdinal("PasswordIterations"));
            }

            return account;
        }

        private static void Validate(
            StaffAccount account,
            string password)
        {
            if (account == null)
            {
                throw new ArgumentNullException("account");
            }

            ValidateRequiredText(
                account.FirstName,
                "First name",
                50);
            ValidateOptionalText(
                account.MiddleName,
                "Middle name",
                50);
            ValidateRequiredText(
                account.LastName,
                "Last name",
                50);
            ValidateOptionalText(
                account.Suffix,
                "Suffix",
                20);

            string email = NormalizeEmail(account.Email);

            try
            {
                MailAddress parsedEmail =
                    new MailAddress(email);

                if (!string.Equals(
                    parsedEmail.Address,
                    email,
                    StringComparison.OrdinalIgnoreCase))
                {
                    throw new FormatException();
                }
            }
            catch (FormatException)
            {
                throw new ArgumentException(
                    "Enter a valid email address.",
                    "account");
            }

            if (email.Length > 256)
            {
                throw new ArgumentException(
                    "Email cannot exceed 256 characters.",
                    "account");
            }

            if (string.IsNullOrEmpty(password) ||
                password.Length < 8)
            {
                throw new ArgumentException(
                    "Password must contain at least 8 characters.",
                    "password");
            }

            if (password.Length > 100)
            {
                throw new ArgumentException(
                    "Password cannot exceed 100 characters.",
                    "password");
            }
        }

        private static void ValidateRequiredText(
            string value,
            string fieldName,
            int maximumLength)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                throw new ArgumentException(
                    fieldName + " is required.");
            }

            if (value.Trim().Length > maximumLength)
            {
                throw new ArgumentException(
                    fieldName + " is too long.");
            }
        }

        private static void ValidateOptionalText(
            string value,
            string fieldName,
            int maximumLength)
        {
            if (!string.IsNullOrWhiteSpace(value) &&
                value.Trim().Length > maximumLength)
            {
                throw new ArgumentException(
                    fieldName + " is too long.");
            }
        }

        private static string NormalizeEmail(string email)
        {
            return string.IsNullOrWhiteSpace(email)
                ? string.Empty
                : email.Trim().ToLowerInvariant();
        }

        private static object ToDatabaseValue(string value)
        {
            return string.IsNullOrWhiteSpace(value)
                ? (object)DBNull.Value
                : value.Trim();
        }

        private static string GetNullableString(
            SqlDataReader reader,
            string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);

            return reader.IsDBNull(ordinal)
                ? null
                : reader.GetString(ordinal);
        }

        private static DateTime? GetNullableDateTime(
            SqlDataReader reader,
            string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);

            return reader.IsDBNull(ordinal)
                ? (DateTime?)null
                : reader.GetDateTime(ordinal);
        }
    }
}
