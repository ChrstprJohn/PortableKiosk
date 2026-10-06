using System;
using System.Data;
using System.Collections.Generic;
using System.Data.SqlClient;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Data.Repositories
{
    public class AnalyticsRepository
    {
        public AnalyticsReport GetReport(DateTime startUtc, DateTime endUtc)
        {
            AnalyticsReport report = new AnalyticsReport();
            using (SqlConnection connection = DatabaseConnection.GetConnection())
            {
                connection.Open();
                // Sales use the payment date. Conversion and expiry use the order-created cohort.
                ReadSummary(connection, startUtc, endUtc, report);
                ReadTrend(connection, startUtc, endUtc, report);
                ReadProducts(connection, startUtc, endUtc, report);
                ReadCategories(connection, startUtc, endUtc, report);
                ReadPaymentMethods(connection, startUtc, endUtc, report);
            }
            return report;
        }

        public List<AnalyticsSourceRow> GetSources(DateTime start, DateTime end, bool items, bool cohort,
            string status, int productId, int categoryId, string method)
        {
            var rows = new List<AnalyticsSourceRow>();
            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = Command(connection, "dbo.Analytics_ReadDetails", start, end))
            {
                command.Parameters.Add("@Items", SqlDbType.Bit).Value = items;
                command.Parameters.Add("@Cohort", SqlDbType.Bit).Value = cohort;
                command.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = (object)status ?? DBNull.Value;
                command.Parameters.Add("@ProductID", SqlDbType.Int).Value = productId;
                command.Parameters.Add("@CategoryID", SqlDbType.Int).Value = categoryId;
                command.Parameters.Add("@Method", SqlDbType.NVarChar, 20).Value = (object)method ?? DBNull.Value;
                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                    while (reader.Read())
                    {
                        var row = new AnalyticsSourceRow
                        {
                            OrderId = reader.GetInt32(0), OrderNumber = reader.GetString(1),
                            CreatedAt = reader.GetDateTime(2), PaidAt = reader.IsDBNull(3) ? (DateTime?)null : reader.GetDateTime(3),
                            Method = reader.GetString(4), Status = reader.GetString(5), Amount = reader.GetDecimal(6),
                            Items = reader.GetString(7)
                        };
                        if (items)
                        {
                            row.ProductId = reader.GetInt32(8); row.Product = reader.GetString(9);
                            row.Category = reader.GetString(10); row.Size = reader.GetString(11);
                            row.Quantity = reader.GetInt32(12); row.UnitPrice = reader.GetDecimal(13);
                        }
                        rows.Add(row);
                    }
            }
            return rows;
        }

        private static SqlCommand Command(SqlConnection connection, string sql, DateTime start, DateTime end)
        {
            SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure };
            command.Parameters.Add("@Start", SqlDbType.DateTime2).Value = start;
            command.Parameters.Add("@End", SqlDbType.DateTime2).Value = end;
            if (sql == "dbo.Analytics_ReadTrend")
                command.Parameters.Add("@Monthly", SqlDbType.Bit).Value = (end - start).TotalDays > 90;
            return command;
        }

        private static void ReadSummary(SqlConnection connection, DateTime start, DateTime end, AnalyticsReport report)
        {
            const string sql = "dbo.Analytics_ReadSummary";
            using (SqlCommand command = Command(connection, sql, start, end))
            using (SqlDataReader reader = command.ExecuteReader())
            {
                reader.Read();
                report.TotalSales = reader.GetDecimal(0);
                report.PaidOrders = reader.GetInt32(1);
                reader.NextResult();
                reader.Read();
                report.PlacedOrders = reader.GetInt32(0);
                report.ConvertedOrders = reader.GetInt32(1);
                report.ConvertedValue = reader.GetDecimal(2);
                report.ExpiredOrders = reader.GetInt32(3);
                report.ExpiredValue = reader.GetDecimal(4);
            }
        }

        private static void ReadTrend(SqlConnection connection, DateTime start, DateTime end, AnalyticsReport report)
        {
            const string sql = "dbo.Analytics_ReadTrend";
            using (SqlCommand command = Command(connection, sql, start, end))
            using (SqlDataReader reader = command.ExecuteReader())
                while (reader.Read())
                    report.Trend.Add(new AnalyticsTrendPoint { Date = reader.GetDateTime(0), Sales = reader.GetDecimal(1) });
        }

        private static void ReadProducts(SqlConnection connection, DateTime start, DateTime end, AnalyticsReport report)
        {
            const string sql = "dbo.Analytics_ReadProducts";
            using (SqlCommand command = Command(connection, sql, start, end))
            using (SqlDataReader reader = command.ExecuteReader())
                while (reader.Read())
                {
                    AnalyticsProductRow row = new AnalyticsProductRow
                    {
                        Name = reader.GetString(0),
                        Units = reader.GetInt32(1),
                        Revenue = reader.GetDecimal(2),
                        IsOnMenu = reader.GetInt32(3) == 1,
                        ImagePath = reader.IsDBNull(4) ? null : reader.GetString(4),
                        ProductId = reader.GetInt32(5)
                    };
                    report.AllProducts.Add(row);
                    if (row.Units > 0) report.PopularProducts.Add(row);
                    if (row.IsOnMenu) report.LeastProducts.Add(row);
                }
            report.PopularProducts.Sort((a, b) => { int result = b.Units.CompareTo(a.Units); return result != 0 ? result : string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase); });
            report.LeastProducts.Sort((a, b) => { int result = a.Units.CompareTo(b.Units); return result != 0 ? result : string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase); });
            if (report.PopularProducts.Count > 5) report.PopularProducts.RemoveRange(5, report.PopularProducts.Count - 5);
            if (report.LeastProducts.Count > 5) report.LeastProducts.RemoveRange(5, report.LeastProducts.Count - 5);
        }

        private static void ReadCategories(SqlConnection connection, DateTime start, DateTime end, AnalyticsReport report)
        {
            const string sql = "dbo.Analytics_ReadCategories";
            using (SqlCommand command = Command(connection, sql, start, end))
            using (SqlDataReader reader = command.ExecuteReader())
                while (reader.Read())
                    report.Categories.Add(new AnalyticsCategoryRow { Name = reader.GetString(0), Units = reader.GetInt32(1), Revenue = reader.GetDecimal(2), CategoryId = reader.GetInt32(3) });
        }

        private static void ReadPaymentMethods(SqlConnection connection, DateTime start, DateTime end, AnalyticsReport report)
        {
            const string sql = "dbo.Analytics_ReadPaymentMethods";
            using (SqlCommand command = Command(connection, sql, start, end))
            using (SqlDataReader reader = command.ExecuteReader())
                while (reader.Read())
                    report.PaymentMethods.Add(new AnalyticsPaymentRow { Method = reader.GetString(0), Orders = reader.GetInt32(1), Sales = reader.GetDecimal(2) });
        }
    }
}
