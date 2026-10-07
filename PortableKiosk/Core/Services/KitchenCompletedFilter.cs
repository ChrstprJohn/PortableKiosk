using System;
using System.Globalization;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    // Completed orders are grouped by order date; completion timestamps are not stored.
    public sealed class KitchenCompletedFilter
    {
        public string Period { get; private set; }
        public string FromDate { get; private set; }
        public string ToDate { get; private set; }
        public string Error { get; private set; }
        public DateTime? StartUtc { get; private set; }
        public DateTime? EndUtc { get; private set; }

        public static KitchenCompletedFilter Create(string period, string from, string to, DateTime utcNow)
        {
            string normalized = (period ?? string.Empty).ToLowerInvariant();
            if (normalized != "yesterday" && normalized != "custom" && normalized != "all")
                normalized = "today";

            DateTime today = utcNow.AddHours(8).Date;
            DateTime start = normalized == "yesterday" ? today.AddDays(-1) : today;
            DateTime last = start;
            var filter = new KitchenCompletedFilter { Period = normalized };
            filter.FromDate = start.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            filter.ToDate = filter.FromDate;

            if (normalized == "all") return filter;
            if (normalized == "custom")
            {
                filter.FromDate = from ?? string.Empty;
                filter.ToDate = to ?? string.Empty;
                if (!DateTime.TryParseExact(from, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                        DateTimeStyles.None, out start) ||
                    !DateTime.TryParseExact(to, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                        DateTimeStyles.None, out last))
                {
                    filter.Error = "Choose both a start and end date.";
                    return filter;
                }
                if (start < new DateTime(1753, 1, 1) || last >= DateTime.MaxValue.Date)
                {
                    filter.Error = "Choose dates between January 1, 1753 and December 30, 9999.";
                    return filter;
                }
                if (last < start)
                {
                    filter.Error = "The end date must be on or after the start date.";
                    return filter;
                }
            }

            // Philippine calendar days use UTC+8. Include the entire selected end day.
            filter.StartUtc = DateTime.SpecifyKind(start.AddHours(-8), DateTimeKind.Utc);
            filter.EndUtc = DateTime.SpecifyKind(last.AddDays(1).AddHours(-8), DateTimeKind.Utc);
            return filter;
        }

        public bool Includes(Order order)
        {
            if (order.KitchenStatus != "COMPLETED") return true;
            if (Error != null) return false;
            return (!StartUtc.HasValue || order.CreatedAt >= StartUtc.Value) &&
                (!EndUtc.HasValue || order.CreatedAt < EndUtc.Value);
        }

        public string EmptyMessage
        {
            get
            {
                if (Error != null) return "Choose a valid date range in Settings.";
                if (Period == "today") return "No completed orders for today.";
                if (Period == "yesterday") return "No completed orders for yesterday.";
                if (Period == "custom") return "No completed orders in this date range.";
                return "No completed orders yet.";
            }
        }
    }
}
