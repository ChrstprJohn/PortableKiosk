using System;
using System.Collections.Generic;

namespace PortableKiosk.Core.Models
{
    public class AnalyticsReport
    {
        public decimal TotalSales { get; set; }
        public int PaidOrders { get; set; }
        public decimal AverageOrderValue { get { return PaidOrders == 0 ? 0 : TotalSales / PaidOrders; } }
        public int PlacedOrders { get; set; }
        public int ConvertedOrders { get; set; }
        public decimal ConversionRate { get { return PlacedOrders == 0 ? 0 : 100m * ConvertedOrders / PlacedOrders; } }
        public int ExpiredOrders { get; set; }
        public decimal ExpiredValue { get; set; }
        public List<AnalyticsTrendPoint> Trend { get; set; } = new List<AnalyticsTrendPoint>();
        public List<AnalyticsProductRow> AllProducts { get; set; } = new List<AnalyticsProductRow>();
        public List<AnalyticsProductRow> PopularProducts { get; set; } = new List<AnalyticsProductRow>();
        public List<AnalyticsProductRow> LeastProducts { get; set; } = new List<AnalyticsProductRow>();
        public List<AnalyticsCategoryRow> Categories { get; set; } = new List<AnalyticsCategoryRow>();
        public List<AnalyticsPaymentRow> PaymentMethods { get; set; } = new List<AnalyticsPaymentRow>();
    }

    public class AnalyticsTrendPoint
    {
        public DateTime Date { get; set; }
        public decimal Sales { get; set; }
    }

    public class AnalyticsProductRow
    {
        public string Name { get; set; }
        public string ImagePath { get; set; }
        public bool IsOnMenu { get; set; }
        public int Units { get; set; }
        public decimal Revenue { get; set; }
    }

    public class AnalyticsCategoryRow
    {
        public string Name { get; set; }
        public int Units { get; set; }
        public decimal Revenue { get; set; }
    }

    public class AnalyticsPaymentRow
    {
        public string Method { get; set; }
        public int Orders { get; set; }
        public decimal Sales { get; set; }
    }
}
