using System;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class AnalyticsService
    {
        private readonly AnalyticsRepository repository = new AnalyticsRepository();

        public static string NormalizePeriod(string value)
        {
            string period = (value ?? string.Empty).ToLowerInvariant();
            return period == "today" || period == "week" || period == "year" ? period : "month";
        }

        public static void GetDateRange(string period, out DateTime start, out DateTime end)
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

        public AnalyticsReport GetReport(DateTime localStart, DateTime localEnd)
        {
            if (localEnd <= localStart || (localEnd - localStart).TotalDays > 370)
                throw new ArgumentException("Choose a date range of up to one year.");

            // Philippine business dates, converted to UTC for indexed database comparisons.
            TimeZoneInfo zone = TimeZoneInfo.FindSystemTimeZoneById("Singapore Standard Time");
            DateTime startUtc = TimeZoneInfo.ConvertTimeToUtc(
                DateTime.SpecifyKind(localStart, DateTimeKind.Unspecified), zone);
            DateTime endUtc = TimeZoneInfo.ConvertTimeToUtc(
                DateTime.SpecifyKind(localEnd, DateTimeKind.Unspecified), zone);
            return repository.GetReport(startUtc, endUtc);
        }
    }
}
