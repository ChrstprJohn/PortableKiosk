using System;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;

internal static class KitchenCompletedFilterTests
{
    private static int checks;

    private static void Check(bool condition, string message)
    {
        if (!condition) throw new Exception(message);
        checks++;
    }

    private static Order Completed(DateTime createdAt)
    {
        return new Order { KitchenStatus = "COMPLETED", CreatedAt = createdAt };
    }

    public static int Main()
    {
        try
        {
            // It is already October 7 in Manila while the UTC date is October 6.
            DateTime now = new DateTime(2026, 10, 6, 18, 0, 0, DateTimeKind.Utc);
            DateTime midnight = new DateTime(2026, 10, 6, 16, 0, 0, DateTimeKind.Utc);
            var today = KitchenCompletedFilter.Create(null, null, null, now);
            Check(today.Period == "today", "Default is Today");
            Check(today.FromDate == "2026-10-07", "Today uses the Philippine date");
            Check(today.StartUtc == midnight, "Philippine midnight converts to UTC");
            Check(!today.Includes(Completed(midnight.AddTicks(-1))), "Previous day excluded");
            Check(today.Includes(Completed(midnight)), "Start midnight included");
            Check(today.Includes(Completed(midnight.AddDays(1).AddTicks(-1))), "Last tick of today included");
            Check(!today.Includes(Completed(midnight.AddDays(1))), "Tomorrow excluded");

            var yesterday = KitchenCompletedFilter.Create("YESTERDAY", null, null, now);
            Check(yesterday.FromDate == "2026-10-06", "Yesterday uses Philippine dates");
            Check(yesterday.Includes(Completed(midnight.AddDays(-1))), "Yesterday start included");
            Check(!yesterday.Includes(Completed(midnight)), "Today excluded from Yesterday");

            var custom = KitchenCompletedFilter.Create("custom", "2024-02-28", "2024-02-29", now);
            DateTime customStart = new DateTime(2024, 2, 27, 16, 0, 0, DateTimeKind.Utc);
            Check(custom.Error == null, "Leap-day range accepted");
            Check(custom.Includes(Completed(customStart)), "Custom start inclusive");
            Check(custom.Includes(Completed(customStart.AddDays(2).AddTicks(-1))), "Custom end day fully inclusive");
            Check(!custom.Includes(Completed(customStart.AddDays(2))), "Day after custom range excluded");
            var sameDay = KitchenCompletedFilter.Create("custom", "2026-10-07", "2026-10-07", now);
            Check(sameDay.EndUtc - sameDay.StartUtc == TimeSpan.FromDays(1), "Same-day range is one full day");

            var all = KitchenCompletedFilter.Create("all", "bad", "bad", now);
            Check(all.Error == null && !all.StartUtc.HasValue && !all.EndUtc.HasValue, "All time ignores dates");
            Check(all.Includes(Completed(midnight.AddYears(-10))), "All time includes old orders");
            Check(all.Includes(Completed(midnight.AddYears(1))), "All time has no date ceiling");
            Check(KitchenCompletedFilter.Create("unknown", null, null, now).Period == "today", "Invalid period defaults to Today");

            foreach (var dates in new[] {
                new[] { "", "2026-10-07" }, new[] { "2026-10-07", "" },
                new[] { "2026-02-30", "2026-10-07" }, new[] { "10/07/2026", "2026-10-07" },
                new[] { "2026-10-08", "2026-10-07" }, new[] { "0001-01-01", "2026-10-07" },
                new[] { "2026-10-07", "9999-12-31" }
            })
            {
                var invalid = KitchenCompletedFilter.Create("custom", dates[0], dates[1], now);
                Check(invalid.Error != null, "Invalid range reports an error");
                Check(!invalid.Includes(Completed(midnight)), "Invalid range never reveals all completed orders");
                foreach (string status in new[] { "QUEUED", "PREPARING", "SERVING" })
                    Check(invalid.Includes(new Order { KitchenStatus = status, CreatedAt = midnight.AddYears(-1) }),
                        "Invalid range preserves active " + status + " orders");
            }
            foreach (string status in new[] { "QUEUED", "PREPARING", "SERVING" })
            {
                Check(today.Includes(new Order { KitchenStatus = status, CreatedAt = midnight.AddDays(-10) }),
                    "Today preserves older " + status + " orders");
                Check(custom.Includes(new Order { KitchenStatus = status, CreatedAt = midnight }),
                    "Custom range preserves out-of-range " + status + " orders");
            }
            Console.WriteLine("Passed " + checks + " kitchen completed filter checks.");
            return 0;
        }
        catch (Exception error)
        {
            Console.Error.WriteLine(error.Message);
            return 1;
        }
    }
}
