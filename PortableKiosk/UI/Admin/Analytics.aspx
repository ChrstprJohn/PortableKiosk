<%@ Page Title="Analytics" Language="C#" MasterPageFile="~/Shared/Layouts/Admin.Master" AutoEventWireup="true" CodeBehind="Analytics.aspx.cs" Inherits="PortableKiosk.UI.Admin.Analytics" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="AdminContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/css/analytics.css") %>" />
    <main class="w-full pb-10 text-slate-900">
        <header class="mb-6 flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">
            <div>
                <h1 class="text-2xl font-semibold tracking-tight text-slate-950 sm:text-3xl">Analytics</h1>
            </div>
            <div class="flex flex-wrap items-center gap-2">
            <nav class="flex flex-wrap gap-2" aria-label="Analytics period">
                <asp:HyperLink ID="lnkToday" runat="server" NavigateUrl="~/UI/Admin/Analytics.aspx?period=today" CssClass="inline-flex min-h-10 items-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 no-underline hover:bg-slate-100 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" Text="Today" />
                <asp:HyperLink ID="lnkWeek" runat="server" NavigateUrl="~/UI/Admin/Analytics.aspx?period=week" CssClass="inline-flex min-h-10 items-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 no-underline hover:bg-slate-100 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" Text="Last 7 days" />
                <asp:HyperLink ID="lnkMonth" runat="server" NavigateUrl="~/UI/Admin/Analytics.aspx?period=month" CssClass="inline-flex min-h-10 items-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 no-underline hover:bg-slate-100 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" Text="This month" />
                <asp:HyperLink ID="lnkYear" runat="server" NavigateUrl="~/UI/Admin/Analytics.aspx?period=year" CssClass="inline-flex min-h-10 items-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 no-underline hover:bg-slate-100 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" Text="This year" />
            </nav>
            <button type="button" class="inline-flex min-h-10 items-center gap-2 rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-white hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-toggle="true" data-modal-target="#analyticsExportModal">
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3v12m0 0 4-4m-4 4-4-4M4 17v3h16v-3" /></svg>
                Export data
            </button>
            </div>
        </header>

        <p class="mb-4 text-sm text-slate-500"><asp:Literal ID="litPeriod" runat="server" /> &middot; Philippine time</p>
        <p class="mb-5 text-xs text-slate-600">Select a card, chart point, or row to view and export its data.</p>
        <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="mb-5 rounded-lg bg-red-50 p-4 text-sm text-red-800" role="alert"><asp:Literal ID="litError" runat="server" /></asp:Panel>
        <asp:Panel ID="pnlReport" runat="server">
            <section class="mb-6 grid gap-4 md:grid-cols-3" aria-label="Sales summary">
                <button type="button" data-analytics-kind="revenue" data-analytics-title="Total revenue" aria-haspopup="dialog" class="analytics-card min-w-0 rounded-xl border border-slate-200 bg-white p-5 sm:p-6"><span class="block text-sm font-medium text-slate-600">Total revenue</span><strong class="mt-3 block break-words text-3xl font-semibold tracking-tight tabular-nums text-slate-950"><asp:Literal ID="litSales" runat="server" /></strong><span class="mt-2 block text-xs text-slate-500">Payments received in this period</span></button>
                <button type="button" data-analytics-kind="paid-orders" data-analytics-title="Paid orders" aria-haspopup="dialog" class="analytics-card min-w-0 rounded-xl border border-slate-200 bg-white p-5 sm:p-6"><span class="block text-sm font-medium text-slate-600">Paid orders</span><strong class="mt-3 block text-3xl font-semibold tracking-tight tabular-nums text-slate-950"><asp:Literal ID="litPaidOrders" runat="server" /></strong><span class="mt-2 block text-xs text-slate-500">Orders paid in this period</span></button>
                <button type="button" data-analytics-kind="average" data-analytics-title="Average order" aria-haspopup="dialog" class="analytics-card min-w-0 rounded-xl border border-slate-200 bg-white p-5 sm:p-6"><span class="block text-sm font-medium text-slate-600">Average order</span><strong class="mt-3 block break-words text-3xl font-semibold tracking-tight tabular-nums text-slate-950"><asp:Literal ID="litAverage" runat="server" /></strong><span class="mt-2 block text-xs text-slate-500">Revenue per paid order</span></button>
            </section>

            <section class="mb-5 rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="trendHeading" data-analytics-surface="trend">
                <div class="mb-4 flex flex-wrap items-start justify-between gap-2"><div class="flex flex-wrap items-center justify-between gap-x-3"><h2 id="trendHeading" class="text-lg font-semibold text-slate-950">Sales trend</h2><button type="button" class="analytics-view" data-analytics-kind="trend" aria-haspopup="dialog">View breakdown <span aria-hidden="true">&rarr;</span></button></div><span class="rounded-md bg-slate-100 px-2.5 py-1 text-xs font-medium text-slate-600"><asp:Literal ID="litTrendGranularity" runat="server" /></span></div>
                <asp:Panel ID="pnlNoTrend" runat="server" Visible="false" CssClass="flex h-52 items-center justify-center text-sm text-slate-500">No paid sales in this period.</asp:Panel>
                <div class="overflow-x-auto"><asp:Literal ID="litTrendSvg" runat="server" /></div>
            </section>

            <div class="mb-5 grid gap-5 xl:grid-cols-2">
                <section class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="popularHeading" data-analytics-surface="popular"><div class="mb-5"><div class="flex flex-wrap items-center justify-between gap-x-3"><h2 id="popularHeading" class="text-lg font-semibold text-slate-950">Popular products</h2><button type="button" class="analytics-view" data-analytics-kind="popular" aria-haspopup="dialog">View breakdown <span aria-hidden="true">&rarr;</span></button></div><p class="mt-1 text-sm text-slate-500">Top 5 by units sold</p></div><asp:Repeater ID="rptPopular" runat="server"><ItemTemplate><button type="button" data-analytics-kind="product" data-analytics-key='<%# Eval("ProductId") %>' aria-haspopup="dialog" class="analytics-row mb-5 flex items-center gap-3 last:mb-0"><%# ProductThumbnail(Eval("ImagePath")) %><span class="block min-w-0 flex-1"><span class="mb-2 flex flex-wrap items-baseline justify-between gap-x-3 gap-y-1 text-sm"><span class="min-w-0 font-medium text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></span><span class="tabular-nums text-slate-600"><%# Eval("Units") %> sold &middot; <%# Money(Eval("Revenue")) %></span></span><span class="block h-2 rounded-full bg-slate-100"><span class="block h-2 rounded-full bg-blue-600" style='<%# PopularWidth(Eval("Units")) %>'></span></span></span></button></ItemTemplate></asp:Repeater><asp:Panel ID="pnlNoPopular" runat="server" Visible="false" CssClass="py-8 text-center text-sm text-slate-500">No products sold in this period.</asp:Panel></section>
                <section class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="leastHeading" data-analytics-surface="least"><div class="mb-5"><div class="flex flex-wrap items-center justify-between gap-x-3"><h2 id="leastHeading" class="text-lg font-semibold text-slate-950">Least-selling products</h2><button type="button" class="analytics-view" data-analytics-kind="least" aria-haspopup="dialog">View breakdown <span aria-hidden="true">&rarr;</span></button></div><p class="mt-1 text-sm text-slate-500">Bottom 5 on the menu, including zero sales</p></div><asp:Repeater ID="rptLeast" runat="server"><ItemTemplate><button type="button" data-analytics-kind="product" data-analytics-key='<%# Eval("ProductId") %>' aria-haspopup="dialog" class="analytics-row flex items-center gap-3 border-b border-slate-100 py-3 text-sm last:border-b-0"><%# ProductThumbnail(Eval("ImagePath")) %><span class="min-w-0 flex-1 font-medium text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></span><span class="shrink-0 text-right tabular-nums text-slate-600"><strong class="font-semibold text-slate-900"><%# Eval("Units") %></strong> sold <span class="hidden sm:inline">&middot; <%# Money(Eval("Revenue")) %></span></span></button></ItemTemplate></asp:Repeater><asp:Panel ID="pnlNoLeast" runat="server" Visible="false" CssClass="py-8 text-center text-sm text-slate-500">No available products to show.</asp:Panel></section>
            </div>

            <div class="mb-5 grid gap-5 xl:grid-cols-2">
                <section class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="categoryHeading" data-analytics-surface="categories"><div class="mb-5 flex items-baseline justify-between gap-3"><div class="flex flex-wrap items-center justify-between gap-x-3"><h2 id="categoryHeading" class="text-lg font-semibold text-slate-950">Sales by category</h2><button type="button" class="analytics-view" data-analytics-kind="categories" aria-haspopup="dialog">View breakdown <span aria-hidden="true">&rarr;</span></button></div><span class="text-xs text-slate-500">Paid revenue</span></div><div class="space-y-5"><asp:Repeater ID="rptCategories" runat="server"><ItemTemplate><button type="button" class="analytics-row" data-analytics-kind="category" data-analytics-key='<%# Eval("CategoryId") %>' aria-haspopup="dialog"><span class="mb-2 flex items-baseline justify-between gap-3 text-sm"><span class="min-w-0 truncate font-medium text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></span><span class="shrink-0 tabular-nums text-slate-700"><%# Money(Eval("Revenue")) %> <span class="text-slate-500">&middot; <%# Eval("Units") %> units</span></span></span><span class="block h-3 overflow-hidden rounded-full bg-slate-100" role="img" aria-label='<%# CategoryBarLabel(Eval("Name"), Eval("Revenue"), Eval("Units")) %>'><span class="block h-full rounded-full bg-blue-600" style='<%# CategoryWidth(Eval("Revenue")) %>'></span></span></button></ItemTemplate></asp:Repeater></div><asp:Panel ID="pnlNoCategories" runat="server" Visible="false" CssClass="py-8 text-center text-sm text-slate-500">No categories to show.</asp:Panel></section>
                <section class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="paymentHeading" data-analytics-surface="payments"><div class="mb-5"><div class="flex flex-wrap items-center justify-between gap-x-3"><h2 id="paymentHeading" class="text-lg font-semibold text-slate-950">Payment methods</h2><button type="button" class="analytics-view" data-analytics-kind="payments" aria-haspopup="dialog">View breakdown <span aria-hidden="true">&rarr;</span></button></div><p class="mt-1 text-sm text-slate-500">Share of paid revenue</p></div><div class="flex flex-col items-center gap-6 sm:flex-row sm:justify-center"><div class="relative size-44 shrink-0" role="group" aria-label='<%= PaymentDonutLabel() %>'><%= PaymentDonutSegments() %><button type="button" data-analytics-kind="cashless" aria-haspopup="dialog" aria-label="View cashless sales share and source payments" class="absolute inset-7 flex flex-col items-center justify-center rounded-full bg-white"><strong class="text-2xl font-semibold tabular-nums text-slate-950"><asp:Literal ID="litCashlessPercent" runat="server" /></strong><span class="text-xs text-slate-500">cashless</span></button></div><div class="w-full max-w-60 space-y-4"><asp:Repeater ID="rptPayments" runat="server"><ItemTemplate><button type="button" class="analytics-row" data-analytics-kind="payment" data-analytics-key='<%# Eval("Method") %>' aria-haspopup="dialog"><span class="flex items-center gap-2 text-sm font-medium text-slate-900"><span class='<%# PaymentDotClass(Eval("Method")) %>' aria-hidden="true"></span><%# PaymentName(Eval("Method")) %></span><span class="block mt-1 pl-4 text-sm tabular-nums text-slate-600"><%# Money(Eval("Sales")) %> &middot; <%# Eval("Orders") %> orders</span></button></ItemTemplate></asp:Repeater><asp:Panel ID="pnlNoPayments" runat="server" Visible="false" CssClass="text-sm text-slate-500">No paid orders in this period.</asp:Panel></div></div></section>
            </div>

            <div class="grid gap-5 xl:grid-cols-[minmax(0,2fr)_minmax(0,1fr)]">
                <section class="min-w-0 rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="outcomesHeading" data-analytics-surface="placed">
                    <div class="flex flex-wrap items-center justify-between gap-x-3"><h2 id="outcomesHeading" class="text-lg font-semibold text-slate-950">Order outcomes</h2><button type="button" class="analytics-view" data-analytics-kind="placed" aria-haspopup="dialog">View breakdown <span aria-hidden="true">&rarr;</span></button></div>
                    <button type="button" class="analytics-row mt-1 text-sm text-slate-500" data-analytics-kind="placed" aria-haspopup="dialog"><asp:Literal ID="litPlacedOrders" runat="server" /> orders placed in this period</button>
                    <asp:Panel ID="pnlNoOutcomes" runat="server" Visible="false" CssClass="flex h-52 items-center justify-center text-sm text-slate-500">No orders placed in this period.</asp:Panel>
                    <asp:Literal ID="litOutcomeChart" runat="server" />
                    <p class="mt-5 text-xs leading-5 text-slate-500">Orders placed in this period, by payment status.</p>
                    <asp:Panel ID="pnlOtherOrders" runat="server" data-analytics-kind="awaiting" role="button" tabindex="0" aria-haspopup="dialog" CssClass="mt-1 text-xs leading-5 text-slate-500"><asp:Literal ID="litOtherOrders" runat="server" /> orders remain unpaid.</asp:Panel>
                </section>
                <div class="grid gap-5 sm:grid-cols-2 xl:grid-cols-1">
                    <section class="min-w-0 rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="paidOutcomeHeading" data-analytics-surface="converted">
                        <div class="flex flex-wrap items-center justify-between gap-x-3"><h3 id="paidOutcomeHeading" class="flex items-center gap-2 text-sm font-medium text-slate-700"><span class="size-2 rounded-full bg-emerald-600" aria-hidden="true"></span>Paid orders</h3><button type="button" class="analytics-view" data-analytics-kind="converted" aria-haspopup="dialog">View records <span aria-hidden="true">&rarr;</span></button></div>
                        <div class="mt-3 flex flex-wrap items-baseline gap-x-3 gap-y-1"><strong class="text-3xl font-semibold tabular-nums text-slate-950"><asp:Literal ID="litConversionDetail" runat="server" /></strong><button type="button" class="min-h-11 text-sm tabular-nums text-emerald-700" data-analytics-kind="conversion" aria-haspopup="dialog"><asp:Literal ID="litConversion" runat="server" /> of placed orders</button></div>
                        <p class="mt-3 break-words text-sm tabular-nums text-slate-600"><asp:Literal ID="litConvertedValue" runat="server" /> paid value</p>
                    </section>
                    <section class="min-w-0 rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="expiredOutcomeHeading" data-analytics-surface="expired">
                        <div class="flex flex-wrap items-center justify-between gap-x-3"><h3 id="expiredOutcomeHeading" class="flex items-center gap-2 text-sm font-medium text-slate-700"><span class="size-2 rounded-full bg-amber-500" aria-hidden="true"></span>Expired orders</h3><button type="button" class="analytics-view" data-analytics-kind="expired" aria-haspopup="dialog">View records <span aria-hidden="true">&rarr;</span></button></div>
                        <div class="mt-3 flex flex-wrap items-baseline gap-x-3 gap-y-1"><strong class="text-3xl font-semibold tabular-nums text-slate-950"><asp:Literal ID="litExpired" runat="server" /></strong><span class="text-sm tabular-nums text-amber-700"><asp:Literal ID="litExpiredPercent" runat="server" /> of placed orders</span></div>
                        <p class="mt-3 break-words text-sm tabular-nums text-slate-600"><asp:Literal ID="litExpiredValue" runat="server" /> unpaid value</p>
                    </section>
                </div>
            </div>
        </asp:Panel>
    </main>
    <div id="analyticsExportModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" tabindex="-1" role="dialog" aria-modal="true" aria-labelledby="analyticsExportTitle" aria-hidden="true">
        <div class="w-full max-w-md overflow-hidden rounded-xl bg-white shadow-lg">
            <div class="flex items-center justify-between border-b border-slate-200 px-5 py-4">
                <h2 id="analyticsExportTitle" class="text-base font-semibold text-slate-950">Export analytics</h2>
                <button type="button" class="flex size-8 items-center justify-center rounded-md text-slate-500 hover:bg-slate-100" data-modal-dismiss="true" aria-label="Close export options"><svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
            </div>
            <div class="px-5 py-5">
                <asp:Label ID="lblExportPeriod" runat="server" AssociatedControlID="ddlExportPeriod" CssClass="mb-2 block text-sm font-medium text-slate-700" Text="Choose a period" />
                <asp:DropDownList ID="ddlExportPeriod" runat="server" CssClass="block w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400">
                    <asp:ListItem Text="Today" Value="today" />
                    <asp:ListItem Text="Last 7 days" Value="week" />
                    <asp:ListItem Text="This month" Value="month" />
                    <asp:ListItem Text="This year" Value="year" />
                </asp:DropDownList>
                <p class="mt-3 text-xs leading-5 text-slate-500">Excel includes the overview, sales trend, products, categories, and payments.</p>
            </div>
            <div class="flex justify-end gap-2 border-t border-slate-200 px-5 py-4">
                <button type="button" class="rounded-md border border-slate-200 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50" data-modal-dismiss="true">Cancel</button>
                <asp:Button ID="btnExportAnalytics" runat="server" Text="Download Excel" OnClick="btnExportAnalytics_Click" CssClass="cursor-pointer rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-white hover:bg-slate-800" />
            </div>
        </div>
    </div>
    <div id="analyticsDetailModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" tabindex="-1" role="dialog" aria-modal="true" aria-labelledby="analyticsDetailTitle" aria-describedby="analyticsDetailDescription" aria-hidden="true" data-endpoint="<%= ResolveUrl("~/UI/Admin/AnalyticsDetails.ashx") %>" data-period="<%= AnalyticsPeriod %>" data-period-label="<%= Server.HtmlEncode(litPeriod.Text) %>">
        <div class="analytics-detail-shell">
            <div class="flex items-start justify-between gap-4 border-b border-slate-200 px-5 py-4">
                <div class="min-w-0"><button id="analyticsDetailBack" type="button" class="mb-2 min-h-11 text-sm font-medium text-blue-700" hidden>&larr; Back to breakdown</button><h2 id="analyticsDetailTitle" tabindex="-1" class="break-words text-lg font-semibold text-slate-950">Analytics details</h2><p id="analyticsDetailPeriod" class="mt-1 text-xs text-slate-600"></p></div>
                <button type="button" class="flex size-11 shrink-0 items-center justify-center rounded-md text-slate-600 hover:bg-slate-100" data-modal-dismiss="true" aria-label="Close analytics details"><svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
            </div>
            <div class="analytics-detail-body">
                <p id="analyticsDetailDescription" class="text-sm leading-6 text-slate-600"></p>
                <p id="analyticsDetailSummary" class="mt-3 rounded-lg bg-slate-50 p-3 text-sm font-medium leading-6 text-slate-900"></p>
                <p id="analyticsDetailStatus" class="py-6 text-sm text-slate-700" role="status" aria-live="polite"></p>
                <button id="analyticsDetailRetry" type="button" class="min-h-11 rounded-md border border-slate-300 px-4 text-sm font-medium" hidden>Try again</button>
                <div id="analyticsDetailContent" hidden>
                    <div class="my-4"><label for="analyticsDetailSearch" class="mb-2 block text-sm font-medium text-slate-700">Search this view</label><input id="analyticsDetailSearch" type="search" placeholder="Search records" class="min-h-11 w-full rounded-md border border-slate-300 px-3 text-sm" /></div>
                    <div class="overflow-x-auto" role="region" aria-label="Analytics data table" tabindex="0"><table id="analyticsDetailTable" class="analytics-detail-table"></table></div>
                    <div class="mt-4 flex flex-wrap items-center justify-between gap-3"><p id="analyticsDetailCount" class="text-xs text-slate-600" aria-live="polite"></p><div class="flex gap-2"><button id="analyticsDetailPrevious" type="button" class="min-h-11 rounded-md border border-slate-300 px-3 text-sm">Previous</button><button id="analyticsDetailNext" type="button" class="min-h-11 rounded-md border border-slate-300 px-3 text-sm">Next</button></div></div>
                </div>
            </div>
            <div class="flex flex-wrap items-center justify-between gap-3 border-t border-slate-200 px-5 py-4"><p class="text-xs text-slate-600">Exports all rows in this view.</p><div class="flex gap-2"><button type="button" class="min-h-11 rounded-md border border-slate-300 px-4 text-sm font-medium text-slate-700" data-modal-dismiss="true">Close</button><button id="analyticsDetailExport" type="button" class="min-h-11 rounded-md bg-slate-900 px-4 text-sm font-medium text-white hover:bg-slate-800" disabled>Export Excel</button></div></div>
        </div>
    </div>
    <script src="<%= ResolveUrl("~/Scripts/app/admin/analytics.js") %>" defer></script>
</asp:Content>
