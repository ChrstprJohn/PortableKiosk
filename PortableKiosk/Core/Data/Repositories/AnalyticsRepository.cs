using System;
using System.Data;
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

        private static SqlCommand Command(SqlConnection connection, string sql, DateTime start, DateTime end)
        {
            SqlCommand command = new SqlCommand(sql, connection);
            command.Parameters.Add("@Start", SqlDbType.DateTime2).Value = start;
            command.Parameters.Add("@End", SqlDbType.DateTime2).Value = end;
            return command;
        }

        private static void ReadSummary(SqlConnection connection, DateTime start, DateTime end, AnalyticsReport report)
        {
            const string sql = @"
                SELECT COALESCE(SUM(Amount), 0), COUNT(*)
                FROM Payments WHERE PaymentStatus = N'PAID' AND PaidAt >= @Start AND PaidAt < @End;
                SELECT COUNT(*), COALESCE(SUM(CASE WHEN p.PaymentStatus = N'PAID' THEN 1 ELSE 0 END), 0),
                    COALESCE(SUM(CASE WHEN p.PaymentStatus = N'PAID' THEN p.Amount ELSE 0 END), 0),
                    COALESCE(SUM(CASE WHEN p.PaymentStatus = N'EXPIRED'
                        OR (p.PaymentStatus = N'PENDING' AND o.ExpiresAt IS NOT NULL
                            AND o.ExpiresAt <= SYSUTCDATETIME()) THEN 1 ELSE 0 END), 0),
                    COALESCE(SUM(CASE WHEN p.PaymentStatus = N'EXPIRED'
                        OR (p.PaymentStatus = N'PENDING' AND o.ExpiresAt IS NOT NULL
                            AND o.ExpiresAt <= SYSUTCDATETIME()) THEN p.Amount ELSE 0 END), 0)
                FROM Orders o LEFT JOIN Payments p ON p.OrderID = o.OrderID
                WHERE o.CreatedAt >= @Start AND o.CreatedAt < @End;";
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
            bool monthly = (end - start).TotalDays > 90;
            string bucket = monthly
                ? "DATEFROMPARTS(YEAR(DATEADD(HOUR, 8, PaidAt)), MONTH(DATEADD(HOUR, 8, PaidAt)), 1)"
                : "CAST(DATEADD(HOUR, 8, PaidAt) AS date)";
            string sql = @"
                SELECT " + bucket + @", SUM(Amount)
                FROM Payments WHERE PaymentStatus = N'PAID' AND PaidAt >= @Start AND PaidAt < @End
                GROUP BY " + bucket + @"
                ORDER BY 1;";
            using (SqlCommand command = Command(connection, sql, start, end))
            using (SqlDataReader reader = command.ExecuteReader())
                while (reader.Read())
                    report.Trend.Add(new AnalyticsTrendPoint { Date = reader.GetDateTime(0), Sales = reader.GetDecimal(1) });
        }

        private static void ReadProducts(SqlConnection connection, DateTime start, DateTime end, AnalyticsReport report)
        {
            const string sql = @"
                SELECT p.ProductName, COALESCE(SUM(oi.Quantity), 0) AS Units,
                    COALESCE(SUM(oi.UnitPrice * oi.Quantity), 0) AS Revenue,
                    CASE WHEN p.IsAvailable = 1 AND c.IsAvailable = 1
                        AND EXISTS (SELECT 1 FROM ProductVariants available
                            WHERE available.ProductID = p.ProductID AND available.IsAvailable = 1)
                        THEN 1 ELSE 0 END AS OnMenu,
                    (SELECT TOP (1) imageVariant.ImagePath
                        FROM ProductVariants imageVariant
                        WHERE imageVariant.ProductID = p.ProductID
                            AND imageVariant.ImagePath IS NOT NULL
                            AND LTRIM(RTRIM(imageVariant.ImagePath)) <> N''
                        ORDER BY imageVariant.IsAvailable DESC,
                            imageVariant.ProductVariantID) AS ImagePath
                FROM Products p
                INNER JOIN Categories c ON c.CategoryID = p.CategoryID
                LEFT JOIN ProductVariants pv ON pv.ProductID = p.ProductID
                LEFT JOIN OrderItems oi ON oi.ProductVariantID = pv.ProductVariantID
                    AND EXISTS (SELECT 1 FROM Payments pay WHERE pay.OrderID = oi.OrderID
                        AND pay.PaymentStatus = N'PAID' AND pay.PaidAt >= @Start AND pay.PaidAt < @End)
                GROUP BY p.ProductID, p.ProductName, p.IsAvailable, c.IsAvailable;";
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
                        ImagePath = reader.IsDBNull(4) ? null : reader.GetString(4)
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
            const string sql = @"
                SELECT c.CategoryName, COALESCE(SUM(oi.Quantity), 0),
                    COALESCE(SUM(oi.UnitPrice * oi.Quantity), 0)
                FROM Categories c LEFT JOIN Products p ON p.CategoryID = c.CategoryID
                LEFT JOIN ProductVariants pv ON pv.ProductID = p.ProductID
                LEFT JOIN OrderItems oi ON oi.ProductVariantID = pv.ProductVariantID
                    AND EXISTS (SELECT 1 FROM Payments pay WHERE pay.OrderID = oi.OrderID
                        AND pay.PaymentStatus = N'PAID' AND pay.PaidAt >= @Start AND pay.PaidAt < @End)
                GROUP BY c.CategoryID, c.CategoryName ORDER BY 3 DESC, c.CategoryName;";
            using (SqlCommand command = Command(connection, sql, start, end))
            using (SqlDataReader reader = command.ExecuteReader())
                while (reader.Read())
                    report.Categories.Add(new AnalyticsCategoryRow { Name = reader.GetString(0), Units = reader.GetInt32(1), Revenue = reader.GetDecimal(2) });
        }

        private static void ReadPaymentMethods(SqlConnection connection, DateTime start, DateTime end, AnalyticsReport report)
        {
            const string sql = @"
                SELECT PaymentMethod, COUNT(*), SUM(Amount)
                FROM Payments WHERE PaymentStatus = N'PAID' AND PaidAt >= @Start AND PaidAt < @End
                GROUP BY PaymentMethod ORDER BY 3 DESC;";
            using (SqlCommand command = Command(connection, sql, start, end))
            using (SqlDataReader reader = command.ExecuteReader())
                while (reader.Read())
                    report.PaymentMethods.Add(new AnalyticsPaymentRow { Method = reader.GetString(0), Orders = reader.GetInt32(1), Sales = reader.GetDecimal(2) });
        }
    }
}
