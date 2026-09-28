using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web.UI;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

namespace PortableKiosk.UI.Admin
{
    public partial class Analytics : Page
    {
        private AnalyticsReport report;
        private static readonly CultureInfo PhilippineCulture = CultureInfo.GetCultureInfo("en-PH");

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StaffAccountID"] == null || !string.Equals(Convert.ToString(Session["StaffRole"]), "ADMIN", StringComparison.OrdinalIgnoreCase))
                return; // Admin.Master performs the redirect.

            if (IsPostBack) return;

            string period = NormalizePeriod(Request.QueryString["period"]);
            DateTime start;
            DateTime end;
            GetDateRange(period, out start, out end);
            ddlExportPeriod.SelectedValue = period;
            Highlight(period);
            litPeriod.Text = Server.HtmlEncode(start.ToString("MMM d, yyyy", PhilippineCulture) + " – " + end.AddDays(-1).ToString("MMM d, yyyy", PhilippineCulture));
            try
            {
                report = new AnalyticsService().GetReport(start, end);
                BindReport(start, end);
            }
            catch (Exception)
            {
                pnlReport.Visible = false;
                pnlError.Visible = true;
                litError.Text = "Analytics could not be loaded. Please try again.";
            }
        }

        private static string NormalizePeriod(string value)
        {
            string period = (value ?? string.Empty).ToLowerInvariant();
            return period == "today" || period == "week" || period == "year" ? period : "month";
        }

        private static void GetDateRange(string period, out DateTime start, out DateTime end)
        {
            TimeZoneInfo zone = TimeZoneInfo.FindSystemTimeZoneById("Singapore Standard Time");
            DateTime today = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, zone).Date;
            end = today.AddDays(1);
            switch (period)
            {
                case "today": start = today; break;
                case "week": start = today.AddDays(-6); break;
                case "year": start = new DateTime(today.Year, 1, 1); break;
                default: start = new DateTime(today.Year, today.Month, 1); break;
            }
        }

        protected void btnExportAnalytics_Click(object sender, EventArgs e)
        {
            if (Session["StaffAccountID"] == null || !string.Equals(Convert.ToString(Session["StaffRole"]), "ADMIN", StringComparison.OrdinalIgnoreCase))
                return;

            try
            {
                string period = NormalizePeriod(ddlExportPeriod.SelectedValue);
                DateTime start;
                DateTime end;
                GetDateRange(period, out start, out end);
                AnalyticsReport exportReport = new AnalyticsService().GetReport(start, end);
                string periodName = period == "today" ? "Today" : period == "week" ? "Last 7 days" : period == "year" ? "This year" : "This month";
                byte[] workbook = new AnalyticsExcelExportService().CreateWorkbook(exportReport, periodName, start, end);
                string fileName = "analytics-" + period + "-" + end.AddDays(-1).ToString("yyyyMMdd", CultureInfo.InvariantCulture) + ".xlsx";
                Response.Clear();
                Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                Response.AddHeader("Content-Length", workbook.Length.ToString(CultureInfo.InvariantCulture));
                Response.BinaryWrite(workbook);
                Response.Flush();
                Response.SuppressContent = true;
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception)
            {
                pnlReport.Visible = false;
                pnlError.Visible = true;
                litError.Text = "The Excel file could not be generated. Please try again.";
            }
        }

        private void Highlight(string period)
        {
            var link = period == "today" ? lnkToday : period == "week" ? lnkWeek : period == "year" ? lnkYear : lnkMonth;
            link.CssClass = "rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white no-underline";
            link.Attributes["aria-current"] = "page";
        }

        private void BindReport(DateTime start, DateTime end)
        {
            litSales.Text = Money(report.TotalSales);
            litPaidOrders.Text = report.PaidOrders.ToString("N0", PhilippineCulture);
            litAverage.Text = Money(report.AverageOrderValue);
            litConversion.Text = report.ConversionRate.ToString("N1", PhilippineCulture) + "%";
            litConversionDetail.Text = report.ConvertedOrders.ToString("N0") + " of " + report.PlacedOrders.ToString("N0") + " placed orders are paid";
            litExpired.Text = report.ExpiredOrders.ToString("N0", PhilippineCulture);
            litExpiredValue.Text = Money(report.ExpiredValue);

            bool monthly = (end - start).TotalDays > 90;
            litTrendGranularity.Text = monthly ? "Monthly" : "Daily";
            pnlNoTrend.Visible = report.Trend.Count == 0;
            litTrendSvg.Text = pnlNoTrend.Visible ? string.Empty : BuildTrendSvg(start, end, monthly);
            rptPopular.DataSource = report.PopularProducts;
            rptPopular.DataBind();
            pnlNoPopular.Visible = report.PopularProducts.Count == 0;
            rptLeast.DataSource = report.LeastProducts;
            rptLeast.DataBind();
            pnlNoLeast.Visible = report.LeastProducts.Count == 0;
            rptCategories.DataSource = report.Categories;
            rptCategories.DataBind();
            pnlNoCategories.Visible = report.Categories.Count == 0;
            rptPayments.DataSource = report.PaymentMethods;
            rptPayments.DataBind();
            pnlNoPayments.Visible = report.PaymentMethods.Count == 0;
            decimal cashlessSales = report.PaymentMethods.Where(payment => payment.Method == "CASHLESS").Sum(payment => payment.Sales);
            litCashlessPercent.Text = (report.TotalSales == 0 ? 0 : 100m * cashlessSales / report.TotalSales).ToString("N0", PhilippineCulture) + "%";
        }

        private string BuildTrendSvg(DateTime start, DateTime end, bool monthly)
        {
            Dictionary<DateTime, decimal> values = report.Trend.ToDictionary(point => point.Date, point => point.Sales);
            List<AnalyticsTrendPoint> points = new List<AnalyticsTrendPoint>();
            for (DateTime date = start; date < end; date = monthly ? date.AddMonths(1) : date.AddDays(1))
            {
                decimal sales;
                values.TryGetValue(date, out sales);
                points.Add(new AnalyticsTrendPoint { Date = date, Sales = sales });
            }

            decimal max = points.Max(point => point.Sales);
            Func<double, string> number = value => value.ToString("0.##", CultureInfo.InvariantCulture);
            Func<int, double> x = index => points.Count == 1 ? 430 : 100d + 665d * index / (points.Count - 1);
            Func<decimal, double> y = sales => 190d - (max == 0 ? 0 : 145d * (double)(sales / max));
            StringBuilder line = new StringBuilder();
            for (int i = 0; i < points.Count; i++)
                line.Append(i == 0 ? "M " : " L ").Append(number(x(i))).Append(' ').Append(number(y(points[i].Sales)));
            string area = line + " L " + number(x(points.Count - 1)) + " 190 L " + number(x(0)) + " 190 Z";
            StringBuilder svg = new StringBuilder("<svg viewBox=\"0 0 800 240\" class=\"block w-full\" style=\"min-width:560px\" role=\"img\" aria-label=\"Paid sales trend\" xmlns=\"http://www.w3.org/2000/svg\">");
            svg.Append("<title>Paid sales trend</title>");
            foreach (int level in new[] { 0, 1, 2 })
            {
                double gridY = 45 + level * 72.5;
                decimal gridValue = max * (2 - level) / 2;
                svg.Append("<line x1=\"100\" x2=\"765\" y1=\"").Append(number(gridY)).Append("\" y2=\"").Append(number(gridY)).Append("\" stroke=\"#e2e8f0\"/>");
                svg.Append("<text x=\"88\" y=\"").Append(number(gridY + 4)).Append("\" text-anchor=\"end\" fill=\"#64748b\" font-size=\"11\">").Append(Server.HtmlEncode(ShortMoney(gridValue))).Append("</text>");
            }
            svg.Append("<path d=\"").Append(area).Append("\" fill=\"#dbeafe\"/>");
            svg.Append("<path d=\"").Append(line).Append("\" fill=\"none\" stroke=\"#2563eb\" stroke-width=\"3\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>");
            for (int i = 0; i < points.Count; i++)
            {
                svg.Append("<circle cx=\"").Append(number(x(i))).Append("\" cy=\"").Append(number(y(points[i].Sales))).Append("\" r=\"3.5\" fill=\"#2563eb\"><title>")
                    .Append(Server.HtmlEncode(points[i].Date.ToString(monthly ? "MMMM yyyy" : "MMM d, yyyy", PhilippineCulture) + ": " + Money(points[i].Sales))).Append("</title></circle>");
            }
            foreach (int i in new[] { 0, points.Count / 2, points.Count - 1 }.Distinct())
                svg.Append("<text x=\"").Append(number(x(i))).Append("\" y=\"220\" text-anchor=\"middle\" fill=\"#64748b\" font-size=\"11\">")
                    .Append(Server.HtmlEncode(points[i].Date.ToString(monthly ? "MMM" : "MMM d", PhilippineCulture))).Append("</text>");
            svg.Append("</svg>");
            return svg.ToString();
        }

        private static string ShortMoney(decimal value)
        {
            return value >= 1000000 ? "₱" + (value / 1000000m).ToString("0.#", PhilippineCulture) + "m"
                : value >= 1000 ? "₱" + (value / 1000m).ToString("0.#", PhilippineCulture) + "k"
                : "₱" + value.ToString("0", PhilippineCulture);
        }

        protected string Money(object value) { return Convert.ToDecimal(value).ToString("C2", PhilippineCulture); }
        protected string ProductThumbnail(object imagePath)
        {
            string path = Convert.ToString(imagePath);
            if (!string.IsNullOrWhiteSpace(path) &&
                path.StartsWith("~/Content/images/", StringComparison.OrdinalIgnoreCase) &&
                path.IndexOf("..", StringComparison.Ordinal) < 0)
            {
                string url = System.Web.HttpUtility.HtmlAttributeEncode(ResolveUrl(path));
                return "<img src=\"" + url + "\" alt=\"\" loading=\"lazy\" class=\"size-11 shrink-0 rounded-md bg-slate-100 object-cover\" />";
            }

            return "<span class=\"flex size-11 shrink-0 items-center justify-center rounded-md bg-slate-100 text-slate-400\" aria-hidden=\"true\">" +
                "<svg class=\"size-5\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.5\">" +
                "<rect x=\"3\" y=\"4\" width=\"18\" height=\"16\" rx=\"2\"/><circle cx=\"8\" cy=\"9\" r=\"1.5\"/><path d=\"m3 17 5-5 4 4 3-3 6 6\"/></svg></span>";
        }
        protected string PaymentName(object value) { return Convert.ToString(value) == "CASHLESS" ? "Cashless" : "Cash counter"; }
        protected string PaymentDotClass(object value) { return Convert.ToString(value) == "CASHLESS" ? "size-2 rounded-full bg-blue-600" : "size-2 rounded-full bg-slate-400"; }
        protected string PopularWidth(object value)
        {
            int max = report.PopularProducts.Count == 0 ? 0 : report.PopularProducts.Max(product => product.Units);
            return "width:" + (max == 0 ? 0 : 100 * Convert.ToInt32(value) / max).ToString(CultureInfo.InvariantCulture) + "%";
        }

        protected string ConversionWidth()
        {
            return "width:" + (report == null ? 0 : report.ConversionRate).ToString("0.##", CultureInfo.InvariantCulture) + "%";
        }

        protected string PaymentDonutStyle()
        {
            decimal cashless = report == null ? 0 : report.PaymentMethods
                .Where(payment => payment.Method == "CASHLESS").Sum(payment => payment.Sales);
            decimal percentage = report == null || report.TotalSales == 0 ? 0 : 100m * cashless / report.TotalSales;
            return "background:conic-gradient(#2563eb 0 " + percentage.ToString("0.##", CultureInfo.InvariantCulture) + "%,#94a3b8 " + percentage.ToString("0.##", CultureInfo.InvariantCulture) + "% 100%)";
        }

        protected string PaymentDonutLabel()
        {
            if (report == null || report.TotalSales == 0) return "No paid sales";
            return System.Web.HttpUtility.HtmlAttributeEncode("Cashless " + litCashlessPercent.Text + " of paid sales; remaining sales by cash counter");
        }

    }
}
