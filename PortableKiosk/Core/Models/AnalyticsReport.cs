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
        public decimal ConvertedValue { get; set; }
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
        public int ProductId { get; set; }
        public string Name { get; set; }
        public string ImagePath { get; set; }
        public bool IsOnMenu { get; set; }
        public int Units { get; set; }
        public decimal Revenue { get; set; }
    }

    public class AnalyticsCategoryRow
    {
        public int CategoryId { get; set; }
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

    public class AnalyticsDetailReport
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public string Period { get; set; }
        public string Summary { get; set; }
        public string[] Columns { get; set; }
        public string[] Formats { get; set; }
        public List<object[]> Rows { get; set; } = new List<object[]>();
        public List<AnalyticsDetailTarget> RowTargets { get; set; } = new List<AnalyticsDetailTarget>();
    }

    public class AnalyticsDetailTarget
    {
        public string Kind { get; set; }
        public string Key { get; set; }
    }

    public class AnalyticsSourceRow
    {
        public int OrderId { get; set; }
        public string OrderNumber { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? PaidAt { get; set; }
        public string Method { get; set; }
        public string Status { get; set; }
        public decimal Amount { get; set; }
        public string Items { get; set; }
        public int ProductId { get; set; }
        public string Product { get; set; }
        public string Category { get; set; }
        public string Size { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
    }
}
