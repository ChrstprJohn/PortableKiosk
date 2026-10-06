using System;
using System.Globalization;
using System.Linq;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class AnalyticsDetailService
    {
        private static readonly CultureInfo Culture = CultureInfo.GetCultureInfo("en-PH");
        private static readonly TimeZoneInfo Zone = TimeZoneInfo.FindSystemTimeZoneById("Singapore Standard Time");

        public AnalyticsDetailReport GetDetail(string kind, string key, DateTime start, DateTime end)
        {
            if (end <= start || (end - start).TotalDays > 370) throw new ArgumentException("Invalid date range.");
            bool items = new[] { "popular", "least", "product", "categories", "category" }.Contains(kind);
            bool cohort = new[] { "placed", "conversion", "converted", "expired", "awaiting" }.Contains(kind);
            string[] allowed = { "revenue", "paid-orders", "average", "trend", "payments", "payment", "cashless",
                "popular", "least", "product", "categories", "category", "placed", "conversion", "converted", "expired", "awaiting" };
            if (!allowed.Contains(kind)) throw new ArgumentException("Unknown analytics component.");

            if (new[] { "popular", "least", "categories", "payments", "placed", "conversion" }.Contains(kind)
                || (kind == "trend" && string.IsNullOrEmpty(key)))
                return GetBreakdown(kind, start, end);

            var detail = new AnalyticsDetailReport
            {
                Period = start.ToString("MMM d, yyyy", Culture) + " – " + end.AddDays(-1).ToString("MMM d, yyyy", Culture) + " · Philippine time",
                Title = kind == "revenue" ? "Total revenue" : kind == "paid-orders" ? "Paid orders" : kind == "average" ? "Average order" :
                    kind == "trend" ? "Sales trend" : kind == "popular" ? "Popular products" : kind == "least" ? "Least-selling products" :
                    kind == "categories" ? "Sales by category" : kind == "converted" ? "Paid order outcomes" : kind == "expired" ? "Expired orders" :
                    kind == "awaiting" ? "Awaiting payment" : kind == "conversion" ? "Paid share of placed orders" : kind == "placed" ? "Order outcomes" : "Payment methods"
            };
            int productId = 0, categoryId = 0;
            AnalyticsReport report = null;
            if (items)
            {
                report = new AnalyticsService().GetReport(start, end);
                if (kind == "product")
                {
                    if (!int.TryParse(key, out productId) || productId <= 0) throw new ArgumentException("Invalid product.");
                    var product = report.AllProducts.FirstOrDefault(row => row.ProductId == productId);
                    if (product == null) throw new ArgumentException("Product not found.");
                    detail.Title = product.Name;
                }
                if (kind == "category")
                {
                    if (!int.TryParse(key, out categoryId) || categoryId <= 0) throw new ArgumentException("Invalid category.");
                    var category = report.Categories.FirstOrDefault(row => row.CategoryId == categoryId);
                    if (category == null) throw new ArgumentException("Category not found.");
                    detail.Title = category.Name;
                }
            }
            string method = null;
            if (kind == "payment" || kind == "cashless")
            {
                method = kind == "cashless" ? "CASHLESS" : key;
                if (method != "CASHLESS" && method != "CASH_COUNTER") throw new ArgumentException("Invalid payment method.");
                detail.Title = method == "CASHLESS" ? "Cashless payments" : "Cash counter payments";
            }
            if (kind == "trend" && !string.IsNullOrEmpty(key))
            {
                DateTime bucket;
                bool monthly = (end - start).TotalDays > 90;
                if (!DateTime.TryParseExact(key, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out bucket)
                    || bucket < start || bucket >= end || (monthly && bucket.Day != 1)) throw new ArgumentException("Invalid trend bucket.");
                detail.Title = "Sales · " + bucket.ToString(monthly ? "MMMM yyyy" : "MMM d, yyyy", Culture);
                start = bucket;
                end = monthly ? (bucket.AddMonths(1) < end ? bucket.AddMonths(1) : end) : bucket.AddDays(1);
                detail.Period = start.ToString("MMM d, yyyy", Culture) + " – " + end.AddDays(-1).ToString("MMM d, yyyy", Culture) + " · Philippine time";
            }
            string status = kind == "converted" ? "PAID" : kind == "expired" ? "EXPIRED" : kind == "awaiting" ? "AWAITING" : null;
            var sources = new AnalyticsRepository().GetSources(ToUtc(start), ToUtc(end), items, cohort, status, productId, categoryId, method);
            detail.Description = items ? "Source: OrderItems joined to paid Payments. Includes payments received in this period. Line revenue = quantity × the price recorded at sale; category and product names use the current catalog." :
                cohort ? "Source: Orders created in this period and their current Payments status. Pending orders past their expiry are counted as expired. Failed, cancelled, and orders without a payment are included in the remaining unpaid group." :
                "Source: Payments with PAID status and a payment date in this period, joined to Orders. Each row contributes one payment amount to revenue.";
            if (kind == "average") detail.Description += " Average order = total paid revenue ÷ number of paid orders.";
            if (kind == "conversion") detail.Description += " Conversion = paid orders ÷ all placed orders × 100.";
            if (kind == "expired") detail.Description += " These amounts are unpaid, not revenue.";

            if (items)
            {
                detail.Columns = new[] { "Order", "Paid at (PH)", "Product", "Category", "Size", "Quantity", "Unit price (PHP)", "Line revenue (PHP)" };
                detail.Formats = new[] { "text", "text", "text", "text", "text", "count", "money", "money" };
                foreach (var row in sources)
                    detail.Rows.Add(new object[] { row.OrderNumber, Local(row.PaidAt), row.Product, row.Category, row.Size, row.Quantity, row.UnitPrice, row.UnitPrice * row.Quantity });
                string totals = sources.Select(row => row.OrderId).Distinct().Count().ToString("N0", Culture) + " orders · " +
                    sources.Sum(row => row.Quantity).ToString("N0", Culture) + " units · " + Money(sources.Sum(row => row.Quantity * row.UnitPrice)) + " line revenue";
                detail.Summary = string.IsNullOrEmpty(detail.Summary) ? totals : totals + ". " + detail.Summary;
            }
            else
            {
                detail.Columns = new[] { "Order", "Placed at (PH)", "Paid at (PH)", "Payment method", "Payment status", "Amount (PHP)", "Items" };
                detail.Formats = new[] { "text", "text", "text", "text", "text", "money", "text" };
                foreach (var row in sources)
                    detail.Rows.Add(new object[] { row.OrderNumber, Local(row.CreatedAt), Local(row.PaidAt),
                        row.Method == "CASHLESS" ? "Cashless" : row.Method == "CASH_COUNTER" ? "Cash counter" : "No payment", row.Status, row.Amount, row.Items });
                decimal paid = sources.Where(row => row.Status == "PAID").Sum(row => row.Amount);
                detail.Summary = sources.Count.ToString("N0", Culture) + " orders · " + Money(paid) + " paid revenue";
                if (kind == "average") detail.Summary += " ÷ " + sources.Count + " = " + Money(sources.Count == 0 ? 0 : paid / sources.Count) + " average";
                if (kind == "conversion" || kind == "placed") detail.Summary += " · " + sources.Count(row => row.Status == "PAID") + " paid / " + sources.Count + " placed = " +
                    (sources.Count == 0 ? 0 : 100m * sources.Count(row => row.Status == "PAID") / sources.Count).ToString("N1", Culture) + "%";
                if (kind == "expired") detail.Summary = sources.Count + " expired orders · " + Money(sources.Sum(row => row.Amount)) + " unpaid value";
                if (kind == "payment" || kind == "cashless")
                {
                    var paymentsReport = new AnalyticsService().GetReport(start, end);
                    detail.Summary += " / " + Money(paymentsReport.TotalSales) + " total paid revenue = " +
                        (paymentsReport.TotalSales == 0 ? 0 : 100m * paid / paymentsReport.TotalSales).ToString("N1", Culture) + "% of paid sales";
                    detail.Description += " Sales share = this method's paid amount ÷ all paid revenue × 100.";
                }
                if (kind == "converted" || kind == "expired" || kind == "awaiting")
                {
                    var outcomesReport = new AnalyticsService().GetReport(start, end);
                    detail.Summary += " · " + sources.Count + " / " + outcomesReport.PlacedOrders + " placed = " +
                        (outcomesReport.PlacedOrders == 0 ? 0 : 100m * sources.Count / outcomesReport.PlacedOrders).ToString("N1", Culture) + "% of placed orders";
                }
            }
            return detail;
        }

        private AnalyticsDetailReport GetBreakdown(string kind, DateTime start, DateTime end)
        {
            var report = new AnalyticsService().GetReport(start, end);
            var detail = new AnalyticsDetailReport
            {
                Period = start.ToString("MMM d, yyyy", Culture) + " – " + end.AddDays(-1).ToString("MMM d, yyyy", Culture) + " · Philippine time"
            };
            if (kind == "popular" || kind == "least")
            {
                var products = kind == "popular" ? report.PopularProducts : report.LeastProducts;
                detail.Title = kind == "popular" ? "Popular products" : "Least-selling products";
                detail.Description = (kind == "popular" ? "Top 5 by units sold. " : "Bottom 5 currently available products, including zero sales. ") +
                    "Source: paid order items, grouped by product. Select a product to see its individual sales.";
                detail.Columns = new[] { "Product", "Units sold", "Revenue (PHP)" };
                detail.Formats = new[] { "text", "count", "money" };
                foreach (var product in products)
                {
                    detail.Rows.Add(new object[] { product.Name, product.Units, product.Revenue });
                    detail.RowTargets.Add(new AnalyticsDetailTarget { Kind = "product", Key = product.ProductId.ToString(CultureInfo.InvariantCulture) });
                }
                detail.Summary = products.Count + " products · " + products.Sum(row => row.Units).ToString("N0", Culture) + " units · " + Money(products.Sum(row => row.Revenue)) + " revenue for this ranking";
            }
            else if (kind == "categories")
            {
                detail.Title = "Sales by category";
                detail.Description = "Source: paid order items, grouped by category. Share = category line revenue ÷ all category line revenue. Select a category to see only its sold items.";
                detail.Columns = new[] { "Category", "Units sold", "Revenue (PHP)", "Revenue share" };
                detail.Formats = new[] { "text", "count", "money", "percent" };
                decimal total = report.Categories.Sum(row => row.Revenue);
                foreach (var category in report.Categories)
                {
                    detail.Rows.Add(new object[] { category.Name, category.Units, category.Revenue, total == 0 ? 0 : category.Revenue / total });
                    detail.RowTargets.Add(new AnalyticsDetailTarget { Kind = "category", Key = category.CategoryId.ToString(CultureInfo.InvariantCulture) });
                }
                detail.Summary = report.Categories.Count + " categories · " + report.Categories.Sum(row => row.Units).ToString("N0", Culture) + " units · " + Money(total) + " line revenue";
            }
            else if (kind == "payments")
            {
                detail.Title = "Payment methods";
                detail.Description = "Source: paid Payments received in this period, grouped by payment method. Share = method revenue ÷ total paid revenue. Select a method to see only its payments.";
                detail.Columns = new[] { "Payment method", "Paid orders", "Revenue (PHP)", "Sales share" };
                detail.Formats = new[] { "text", "count", "money", "percent" };
                foreach (string method in new[] { "CASHLESS", "CASH_COUNTER" })
                {
                    var payment = report.PaymentMethods.FirstOrDefault(row => row.Method == method);
                    decimal sales = payment == null ? 0 : payment.Sales;
                    detail.Rows.Add(new object[] { method == "CASHLESS" ? "Cashless" : "Cash counter", payment == null ? 0 : payment.Orders, sales,
                        report.TotalSales == 0 ? 0 : sales / report.TotalSales });
                    detail.RowTargets.Add(new AnalyticsDetailTarget { Kind = "payment", Key = method });
                }
                detail.Summary = report.PaidOrders.ToString("N0", Culture) + " paid orders · " + Money(report.TotalSales) + " total revenue";
            }
            else if (kind == "trend")
            {
                bool monthly = (end - start).TotalDays > 90;
                detail.Title = monthly ? "Monthly sales trend" : "Daily sales trend";
                detail.Description = "Source: paid Payments grouped by payment date in Philippine time, including dates with zero revenue. Select a date to see only its payments.";
                detail.Columns = new[] { monthly ? "Month" : "Date", "Revenue (PHP)" };
                detail.Formats = new[] { "text", "money" };
                for (DateTime date = start; date < end; date = monthly ? date.AddMonths(1) : date.AddDays(1))
                {
                    var point = report.Trend.FirstOrDefault(row => row.Date == date);
                    detail.Rows.Add(new object[] { date.ToString(monthly ? "MMMM yyyy" : "MMM d, yyyy", Culture), point == null ? 0 : point.Sales });
                    detail.RowTargets.Add(new AnalyticsDetailTarget { Kind = "trend", Key = date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) });
                }
                detail.Summary = Money(report.TotalSales) + " revenue · " + detail.Rows.Count + (monthly ? " months" : " days");
            }
            else
            {
                detail.Title = kind == "conversion" ? "Paid share of placed orders" : "Order outcomes";
                detail.Description = "Source: Orders created in this period and their current payment status. Conversion = paid orders ÷ placed orders × 100. Select an outcome to see its orders. Expired and remaining unpaid values are not revenue.";
                detail.Columns = new[] { "Outcome", "Orders", "Share of placed orders", "Paid value (PHP)", "Unpaid value (PHP)" };
                detail.Formats = new[] { "text", "count", "percent", "money", "money" };
                int remaining = Math.Max(0, report.PlacedOrders - report.ConvertedOrders - report.ExpiredOrders);
                var sources = new AnalyticsRepository().GetSources(ToUtc(start), ToUtc(end), false, true, null, 0, 0, null);
                decimal unpaid = sources.Where(row => row.Status != "PAID" && row.Status != "EXPIRED").Sum(row => row.Amount);
                detail.Rows.Add(new object[] { "Paid", report.ConvertedOrders, report.PlacedOrders == 0 ? 0 : (decimal)report.ConvertedOrders / report.PlacedOrders, report.ConvertedValue, 0m });
                detail.Rows.Add(new object[] { "Expired", report.ExpiredOrders, report.PlacedOrders == 0 ? 0 : (decimal)report.ExpiredOrders / report.PlacedOrders, 0m, report.ExpiredValue });
                detail.Rows.Add(new object[] { "Remaining unpaid", remaining, report.PlacedOrders == 0 ? 0 : (decimal)remaining / report.PlacedOrders, 0m, unpaid });
                foreach (string outcome in new[] { "converted", "expired", "awaiting" }) detail.RowTargets.Add(new AnalyticsDetailTarget { Kind = outcome });
                detail.Summary = report.ConvertedOrders.ToString("N0", Culture) + " paid / " + report.PlacedOrders.ToString("N0", Culture) + " placed = " + report.ConversionRate.ToString("N1", Culture) + "% · " + Money(report.ConvertedValue) + " paid value";
            }
            return detail;
        }

        private static DateTime ToUtc(DateTime date) { return TimeZoneInfo.ConvertTimeToUtc(DateTime.SpecifyKind(date, DateTimeKind.Unspecified), Zone); }
        private static string Local(DateTime? date) { return date.HasValue ? TimeZoneInfo.ConvertTimeFromUtc(DateTime.SpecifyKind(date.Value, DateTimeKind.Utc), Zone).ToString("MMM d, yyyy HH:mm", Culture) : "—"; }
        private static string Money(decimal value) { return value.ToString("C2", Culture); }
    }
}
