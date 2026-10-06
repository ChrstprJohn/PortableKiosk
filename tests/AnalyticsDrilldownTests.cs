using System;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Xml.Linq;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

// Read-only integration checks against the configured local database.
internal static class AnalyticsDrilldownTests
{
    private static int checks;
    private static void Equal(decimal expected, decimal actual, string label)
    {
        if (expected != actual) throw new Exception(label + ": expected " + expected + ", got " + actual);
        checks++;
    }
    private static decimal Sum(AnalyticsDetailReport detail, int column)
    {
        return detail.Rows.Sum(row => Convert.ToDecimal(row[column]));
    }
    private static void CheckWorkbook(AnalyticsDetailReport detail)
    {
        var bytes = new AnalyticsExcelExportService().CreateDetailWorkbook(detail);
        using (var stream = new MemoryStream(bytes))
        using (var zip = new ZipArchive(stream, ZipArchiveMode.Read))
        {
            foreach (var entry in zip.Entries.Where(entry => entry.FullName.EndsWith(".xml") || entry.FullName.EndsWith(".rels")))
                using (var xml = entry.Open()) XDocument.Load(xml);
            using (var xml = zip.GetEntry("xl/worksheets/sheet1.xml").Open())
            {
                var sheet = XDocument.Load(xml);
                XNamespace ns = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
                var rows = sheet.Descendants(ns + "row").Skip(4).Take(detail.Rows.Count).ToList();
                Equal(detail.Rows.Count, rows.Count, "Excel includes every source row");
                for (int i = 0; i < rows.Count; i++)
                {
                    var cells = rows[i].Elements(ns + "c").ToList();
                    Equal(detail.Columns.Length, cells.Count, "Excel column count");
                    for (int j = 0; j < cells.Count; j++)
                    {
                        if (detail.Formats[j] == "text")
                        {
                            if ((string)cells[j].Descendants(ns + "t").Single() != Convert.ToString(detail.Rows[i][j]))
                                throw new Exception("Excel text / order number differs from modal");
                            checks++;
                        }
                        else Equal(Convert.ToDecimal(detail.Rows[i][j]), decimal.Parse(cells[j].Element(ns + "v").Value,
                            System.Globalization.CultureInfo.InvariantCulture), "Excel numeric cell");
                    }
                }
            }
        }
    }
    public static int Main()
    {
        try
        {
            var service = new AnalyticsDetailService();
            foreach (string period in new[] { "today", "week", "month", "year" })
            {
                DateTime start, end;
                AnalyticsService.GetDateRange(period, out start, out end);
                var report = new AnalyticsService().GetReport(start, end);
                foreach (string kind in new[] { "revenue", "paid-orders", "average" })
                {
                    var detail = service.GetDetail(kind, null, start, end);
                    Equal(report.PaidOrders, detail.Rows.Count, period + " " + kind + " count");
                    Equal(report.TotalSales, Sum(detail, 5), period + " " + kind + " revenue");
                    CheckWorkbook(detail);
                }
                foreach (string kind in new[] { "converted", "expired", "awaiting" })
                {
                    var detail = service.GetDetail(kind, null, start, end);
                    int expected = kind == "converted" ? report.ConvertedOrders : kind == "expired" ? report.ExpiredOrders :
                        kind == "awaiting" ? report.PlacedOrders - report.ConvertedOrders - report.ExpiredOrders : report.PlacedOrders;
                    Equal(expected, detail.Rows.Count, period + " " + kind + " cohort");
                    if (kind == "converted") Equal(report.ConvertedValue, Sum(detail, 5), "Converted paid value");
                    if (kind == "expired") Equal(report.ExpiredValue, Sum(detail, 5), "Expired unpaid value");
                    CheckWorkbook(detail);
                }
                foreach (string kind in new[] { "placed", "conversion" })
                {
                    var detail = service.GetDetail(kind, null, start, end);
                    Equal(3, detail.Rows.Count, "Outcome breakdown rows");
                    Equal(report.PlacedOrders, Sum(detail, 1), "Outcome denominator");
                    Equal(report.ConvertedValue, Sum(detail, 3), "Outcome paid value");
                    Equal(report.PlacedOrders == 0 ? 0 : 1, Sum(detail, 2), "Outcome shares");
                    for (int i = 0; i < detail.Rows.Count; i++)
                    {
                        var child = service.GetDetail(detail.RowTargets[i].Kind, detail.RowTargets[i].Key, start, end);
                        Equal(Convert.ToDecimal(detail.Rows[i][1]), child.Rows.Count, "Outcome drill-down target");
                    }
                    CheckWorkbook(detail);
                }
                foreach (var product in report.AllProducts)
                {
                    var detail = service.GetDetail("product", product.ProductId.ToString(), start, end);
                    Equal(product.Units, Sum(detail, 5), "Product units including zero sales");
                    Equal(product.Revenue, Sum(detail, 7), "Product sale prices");
                }
                foreach (string kind in new[] { "popular", "least" })
                {
                    var products = kind == "popular" ? report.PopularProducts : report.LeastProducts;
                    var detail = service.GetDetail(kind, null, start, end);
                    Equal(products.Count, detail.Rows.Count, "Ranked product count");
                    Equal(products.Sum(row => row.Units), Sum(detail, 1), "Ranked product units");
                    Equal(products.Sum(row => row.Revenue), Sum(detail, 2), "Ranked product revenue");
                    for (int i = 0; i < products.Count; i++)
                    {
                        if ((string)detail.Rows[i][0] != products[i].Name) throw new Exception("Ranking order / zero-sale product differs");
                        var child = service.GetDetail(detail.RowTargets[i].Kind, detail.RowTargets[i].Key, start, end);
                        Equal(products[i].Revenue, Sum(child, 7), "Ranked product drill-down target");
                    }
                    CheckWorkbook(detail);
                }
                foreach (var category in report.Categories)
                {
                    var detail = service.GetDetail("category", category.CategoryId.ToString(), start, end);
                    Equal(category.Units, Sum(detail, 5), "Category units");
                    Equal(category.Revenue, Sum(detail, 7), "Category revenue");
                }
                var categories = service.GetDetail("categories", null, start, end);
                Equal(report.Categories.Sum(row => row.Revenue), Sum(categories, 2), "All category totals");
                Equal(report.Categories.Count, categories.Rows.Count, "Category breakdown count");
                CheckWorkbook(categories);
                var paymentBreakdown = service.GetDetail("payments", null, start, end);
                Equal(report.PaidOrders, Sum(paymentBreakdown, 1), "Payment breakdown count");
                Equal(report.TotalSales, Sum(paymentBreakdown, 2), "Payment breakdown revenue");
                Equal(report.TotalSales == 0 ? 0 : 1, Sum(paymentBreakdown, 3), "Payment breakdown shares");
                CheckWorkbook(paymentBreakdown);
                foreach (string method in new[] { "CASHLESS", "CASH_COUNTER" })
                {
                    var detail = service.GetDetail("payment", method, start, end);
                    var payment = report.PaymentMethods.FirstOrDefault(row => row.Method == method);
                    Equal(payment == null ? 0 : payment.Orders, detail.Rows.Count, "Payment method count");
                    Equal(payment == null ? 0 : payment.Sales, Sum(detail, 5), "Payment method revenue");
                    CheckWorkbook(detail);
                }
                var cashless = service.GetDetail("cashless", null, start, end);
                Equal(report.PaymentMethods.Where(row => row.Method == "CASHLESS").Sum(row => row.Sales), Sum(cashless, 5), "Donut share");
                var trend = service.GetDetail("trend", null, start, end);
                Equal(report.TotalSales, Sum(trend, 1), "Trend breakdown revenue");
                Equal((end - start).TotalDays > 90 ? end.Month - start.Month + 1 : (end - start).Days, trend.Rows.Count, "Trend includes zero-sale buckets");
                Equal(trend.Rows.Count, trend.RowTargets.Count, "Every trend date can drill down");
                CheckWorkbook(trend);
                foreach (var bucket in report.Trend)
                {
                    var detail = service.GetDetail("trend", bucket.Date.ToString("yyyy-MM-dd"), start, end);
                    Equal(bucket.Sales, Sum(detail, 5), "Trend bucket in Philippine time");
                    CheckWorkbook(detail);
                }
            }
            DateTime validStart, validEnd;
            AnalyticsService.GetDateRange("month", out validStart, out validEnd);
            foreach (var input in new[] { new[] { "unknown", "" }, new[] { "product", "-1" }, new[] { "category", "bad" },
                new[] { "payment", "untrusted" }, new[] { "trend", "2000-01-01" } })
            {
                bool rejected = false;
                try { service.GetDetail(input[0], input[1], validStart, validEnd); }
                catch (ArgumentException) { rejected = true; }
                if (!rejected) throw new Exception("Invalid filter accepted");
                checks++;
            }
            var safeText = new AnalyticsDetailReport { Title = "Safe export", Period = "Test", Description = "Test", Summary = "Test",
                Columns = new[] { "Order", "Amount" }, Formats = new[] { "text", "money" } };
            safeText.Rows.Add(new object[] { "0001", 12.34m });
            safeText.Rows.Add(new object[] { "=HYPERLINK(\"https://example.com\") <script> & text", 0m });
            CheckWorkbook(safeText);
            Console.WriteLine("PASS: " + checks + " reconciliation, filter, zero-sale, and Excel checks across all periods.");
            return 0;
        }
        catch (Exception error) { Console.Error.WriteLine(error.Message); return 1; }
    }
}
