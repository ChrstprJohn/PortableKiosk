using System;
using System.Data;
using System.Data.SqlClient;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Data.Repositories
{
    public class KioskSettingsRepository
    {
        public KioskSettings Get()
        {
            const string sql = @"SELECT IsAvailable, PendingPaymentExpiryMinutes
                FROM KioskSettings WHERE SettingsID = 1;";
            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        throw new InvalidOperationException("Kiosk settings are missing. Run database migration 005.");
                    }
                    return new KioskSettings
                    {
                        IsAvailable = reader.GetBoolean(0),
                        PendingPaymentExpiryMinutes = reader.GetInt32(1)
                    };
                }
            }
        }

        public void Save(KioskSettings settings)
        {
            const string sql = @"UPDATE KioskSettings
                SET IsAvailable = @IsAvailable,
                    PendingPaymentExpiryMinutes = @ExpiryMinutes
                WHERE SettingsID = 1;";
            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@IsAvailable", SqlDbType.Bit).Value = settings.IsAvailable;
                command.Parameters.Add("@ExpiryMinutes", SqlDbType.Int).Value =
                    settings.PendingPaymentExpiryMinutes;
                connection.Open();
                if (command.ExecuteNonQuery() != 1)
                {
                    throw new InvalidOperationException("Kiosk settings could not be saved.");
                }
            }
        }
    }
}
