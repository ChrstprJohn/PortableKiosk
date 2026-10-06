using System;
using System.Globalization;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using PortableKiosk.Core.Services;

namespace PortableKiosk.UI.Admin
{
    public class AnalyticsDetails : IHttpHandler, IReadOnlySessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();
            if (context.Session["StaffAccountID"] == null || !string.Equals(Convert.ToString(context.Session["StaffRole"]), "ADMIN", StringComparison.OrdinalIgnoreCase))
            {
                Error(context, 401, "Your admin session has ended. Sign in again to view analytics.");
                return;
            }
            if (context.Request.HttpMethod != "GET") { Error(context, 405, "Use GET to read analytics."); return; }
            try
            {
                DateTime start, end;
                string period = AnalyticsService.NormalizePeriod(context.Request.QueryString["period"]);
                AnalyticsService.GetDateRange(period, out start, out end);
                var detail = new AnalyticsDetailService().GetDetail(context.Request.QueryString["kind"], context.Request.QueryString["key"], start, end);
                if (context.Request.QueryString["export"] == "xlsx")
                {
                    byte[] workbook = new AnalyticsExcelExportService().CreateDetailWorkbook(detail);
                    context.Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                    context.Response.AddHeader("Content-Disposition", "attachment; filename=\"analytics-" + context.Request.QueryString["kind"] + "-" + period + "-" + end.AddDays(-1).ToString("yyyyMMdd", CultureInfo.InvariantCulture) + ".xlsx\"");
                    context.Response.BinaryWrite(workbook);
                }
                else
                {
                    context.Response.ContentType = "application/json";
                    context.Response.Write(new JavaScriptSerializer { MaxJsonLength = int.MaxValue }.Serialize(detail));
                }
            }
            catch (ArgumentException) { Error(context, 400, "That analytics selection is invalid. Refresh the page and try again."); }
            catch (Exception) { Error(context, 500, "These records could not be loaded. Please try again."); }
        }

        private static void Error(HttpContext context, int status, string message)
        {
            context.Response.Clear();
            context.Response.StatusCode = status;
            context.Response.TrySkipIisCustomErrors = true;
            context.Response.SuppressFormsAuthenticationRedirect = true;
            context.Response.ContentType = "application/json";
            context.Response.Write(new JavaScriptSerializer().Serialize(new { Error = message }));
        }
    }
}
