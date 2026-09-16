using System;
using System.Configuration;
using System.Data.SqlClient;

namespace PortableKiosk.Core.Data
{
    public static class DatabaseConnection
    {
        private const string ConnectionStringName = "PortableKioskDb";


        public static SqlConnection GetConnection()
        {
            ConnectionStringSettings settings =
                ConfigurationManager.ConnectionStrings[ConnectionStringName];

            return new SqlConnection(settings.ConnectionString);
        }

        public static string TestConnection()
        {
            try
            {
                using (SqlConnection connection = GetConnection())
                {
                    connection.Open();

                    return "Database connection successful.";
                }
            }
            catch (ConfigurationErrorsException exception)
            {
                return "Database configuration error: " +
                       exception.Message;
            }
            catch (SqlException exception)
            {
                return "Database connection failed: " +
                       exception.Message;
            }
            catch (Exception exception)
            {
                return "Unexpected database error: " +
                       exception.Message;
            }
        }
    }
}