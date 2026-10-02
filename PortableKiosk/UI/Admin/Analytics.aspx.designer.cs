namespace PortableKiosk.UI.Admin
{
    public partial class Analytics
    {
        protected global::System.Web.UI.WebControls.HyperLink lnkToday, lnkWeek, lnkMonth, lnkYear;
        protected global::System.Web.UI.WebControls.Literal litPeriod, litError, litSales, litPaidOrders, litAverage, litConversion, litPlacedOrders, litConversionDetail, litConvertedValue, litExpired, litOtherOrders, litExpiredValue, litTrendGranularity, litTrendSvg, litCashlessPercent, litExpiredPercent, litOutcomeChart;
        protected global::System.Web.UI.WebControls.Panel pnlError, pnlReport, pnlNoTrend, pnlNoPayments, pnlNoPopular, pnlNoLeast, pnlNoCategories, pnlOtherOrders, pnlNoOutcomes;
        protected global::System.Web.UI.WebControls.Repeater rptPopular, rptLeast, rptCategories, rptPayments;
        protected global::System.Web.UI.WebControls.Label lblExportPeriod;
        protected global::System.Web.UI.WebControls.DropDownList ddlExportPeriod;
        protected global::System.Web.UI.WebControls.Button btnExportAnalytics;
    }
}
