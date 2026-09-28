using System;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class AnalyticsService
    {
        private readonly AnalyticsRepository repository = new AnalyticsRepository();

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
