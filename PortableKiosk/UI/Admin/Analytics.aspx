<%@ Page Title="Analytics" Language="C#" MasterPageFile="~/Shared/Layouts/Admin.Master" AutoEventWireup="true" CodeBehind="Analytics.aspx.cs" Inherits="PortableKiosk.UI.Admin.Analytics" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="AdminContent" runat="server">
    <main class="mx-auto w-full max-w-7xl pb-10 text-slate-900">
        <header class="mb-6 flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">
            <div>
                <h1 class="text-2xl font-semibold tracking-tight text-slate-950 sm:text-3xl">Analytics</h1>
            </div>
            <div class="flex flex-wrap items-center gap-2">
            <nav class="flex flex-wrap gap-1 rounded-lg border border-slate-200 bg-white p-1" aria-label="Analytics period">
                <asp:HyperLink ID="lnkToday" runat="server" NavigateUrl="~/UI/Admin/Analytics.aspx?period=today" CssClass="rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 no-underline hover:bg-slate-100" Text="Today" />
                <asp:HyperLink ID="lnkWeek" runat="server" NavigateUrl="~/UI/Admin/Analytics.aspx?period=week" CssClass="rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 no-underline hover:bg-slate-100" Text="Last 7 days" />
                <asp:HyperLink ID="lnkMonth" runat="server" NavigateUrl="~/UI/Admin/Analytics.aspx?period=month" CssClass="rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 no-underline hover:bg-slate-100" Text="This month" />
                <asp:HyperLink ID="lnkYear" runat="server" NavigateUrl="~/UI/Admin/Analytics.aspx?period=year" CssClass="rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 no-underline hover:bg-slate-100" Text="This year" />
            </nav>
            <button type="button" class="inline-flex min-h-10 items-center gap-2 rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-white hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-toggle="true" data-modal-target="#analyticsExportModal">
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3v12m0 0 4-4m-4 4-4-4M4 17v3h16v-3" /></svg>
                Export data
            </button>
            </div>
        </header>

        <p class="mb-4 text-sm text-slate-500"><asp:Literal ID="litPeriod" runat="server" /> · Philippine time</p>
        <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="mb-5 rounded-lg bg-red-50 p-4 text-sm text-red-800" role="alert"><asp:Literal ID="litError" runat="server" /></asp:Panel>
        <asp:Panel ID="pnlReport" runat="server">
            <section class="mb-5 grid gap-5 rounded-xl bg-slate-900 p-5 text-white sm:grid-cols-3 sm:p-6" aria-label="Sales summary">
                <div><p class="text-sm text-slate-300">Total revenue</p><strong class="mt-2 block text-3xl font-semibold tracking-tight tabular-nums sm:text-4xl"><asp:Literal ID="litSales" runat="server" /></strong></div>
                <div class="border-t border-slate-700 pt-4 sm:border-l sm:border-t-0 sm:pl-5 sm:pt-0"><p class="text-sm text-slate-300">Paid orders</p><strong class="mt-2 block text-2xl font-semibold tabular-nums sm:text-3xl"><asp:Literal ID="litPaidOrders" runat="server" /></strong></div>
                <div class="border-t border-slate-700 pt-4 sm:border-l sm:border-t-0 sm:pl-5 sm:pt-0"><p class="text-sm text-slate-300">Average order</p><strong class="mt-2 block text-2xl font-semibold tabular-nums sm:text-3xl"><asp:Literal ID="litAverage" runat="server" /></strong></div>
            </section>

            <section class="mb-5 rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="trendHeading">
                <div class="mb-4 flex flex-wrap items-start justify-between gap-2"><h2 id="trendHeading" class="text-lg font-semibold text-slate-950">Sales trend</h2><span class="rounded-md bg-slate-100 px-2.5 py-1 text-xs font-medium text-slate-600"><asp:Literal ID="litTrendGranularity" runat="server" /></span></div>
                <asp:Panel ID="pnlNoTrend" runat="server" Visible="false" CssClass="flex h-52 items-center justify-center text-sm text-slate-500">No paid sales in this period.</asp:Panel>
                <div class="overflow-x-auto"><asp:Literal ID="litTrendSvg" runat="server" /></div>
            </section>

            <div class="mb-5 grid gap-5 xl:grid-cols-2">
                <section class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="popularHeading"><div class="mb-5"><h2 id="popularHeading" class="text-lg font-semibold text-slate-950">Popular products</h2><p class="mt-1 text-sm text-slate-500">Top 5 by units sold</p></div><asp:Repeater ID="rptPopular" runat="server"><ItemTemplate><div class="mb-5 flex items-center gap-3 last:mb-0"><%# ProductThumbnail(Eval("ImagePath")) %><div class="min-w-0 flex-1"><div class="mb-2 flex flex-wrap items-baseline justify-between gap-x-3 gap-y-1 text-sm"><span class="min-w-0 font-medium text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></span><span class="tabular-nums text-slate-600"><%# Eval("Units") %> sold · <%# Money(Eval("Revenue")) %></span></div><div class="h-2 rounded-full bg-slate-100"><div class="h-2 rounded-full bg-blue-600" style='<%# PopularWidth(Eval("Units")) %>'></div></div></div></div></ItemTemplate></asp:Repeater><asp:Panel ID="pnlNoPopular" runat="server" Visible="false" CssClass="py-8 text-center text-sm text-slate-500">No products sold in this period.</asp:Panel></section>
                <section class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="leastHeading"><div class="mb-5"><h2 id="leastHeading" class="text-lg font-semibold text-slate-950">Least-selling products</h2><p class="mt-1 text-sm text-slate-500">Bottom 5 available products, including zero sales</p></div><asp:Repeater ID="rptLeast" runat="server"><ItemTemplate><div class="flex items-center gap-3 border-b border-slate-100 py-3 text-sm last:border-b-0"><%# ProductThumbnail(Eval("ImagePath")) %><span class="min-w-0 flex-1 font-medium text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></span><span class="shrink-0 text-right tabular-nums text-slate-600"><strong class="font-semibold text-slate-900"><%# Eval("Units") %></strong> sold <span class="hidden sm:inline">· <%# Money(Eval("Revenue")) %></span></span></div></ItemTemplate></asp:Repeater><asp:Panel ID="pnlNoLeast" runat="server" Visible="false" CssClass="py-8 text-center text-sm text-slate-500">No available products to show.</asp:Panel></section>
            </div>

            <div class="mb-5 grid gap-5 xl:grid-cols-2">
                <section class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="categoryHeading"><div class="mb-5 flex items-baseline justify-between gap-3"><h2 id="categoryHeading" class="text-lg font-semibold text-slate-950">Sales by category</h2><span class="text-xs text-slate-500">Paid revenue</span></div><div class="space-y-5"><asp:Repeater ID="rptCategories" runat="server"><ItemTemplate><div><div class="mb-2 flex items-baseline justify-between gap-3 text-sm"><span class="min-w-0 truncate font-medium text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></span><span class="shrink-0 tabular-nums text-slate-700"><%# Money(Eval("Revenue")) %> <span class="text-slate-500">· <%# Eval("Units") %> units</span></span></div><div class="h-3 overflow-hidden rounded-full bg-slate-100" role="img" aria-label='<%# CategoryBarLabel(Eval("Name"), Eval("Revenue"), Eval("Units")) %>'><div class="h-full rounded-full bg-blue-600" style='<%# CategoryWidth(Eval("Revenue")) %>'></div></div></div></ItemTemplate></asp:Repeater></div><asp:Panel ID="pnlNoCategories" runat="server" Visible="false" CssClass="py-8 text-center text-sm text-slate-500">No categories to show.</asp:Panel></section>
                <section class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="paymentHeading"><div class="mb-5"><h2 id="paymentHeading" class="text-lg font-semibold text-slate-950">Payment methods</h2><p class="mt-1 text-sm text-slate-500">Share of paid sales by amount</p></div><div class="flex flex-col items-center gap-6 sm:flex-row sm:justify-center"><div class="relative size-44 shrink-0 rounded-full" style='<%= PaymentDonutStyle() %>' role="img" aria-label='<%= PaymentDonutLabel() %>'><div class="absolute inset-7 flex flex-col items-center justify-center rounded-full bg-white"><strong class="text-2xl font-semibold tabular-nums text-slate-950"><asp:Literal ID="litCashlessPercent" runat="server" /></strong><span class="text-xs text-slate-500">cashless</span></div></div><div class="w-full max-w-60 space-y-4"><asp:Repeater ID="rptPayments" runat="server"><ItemTemplate><div><div class="flex items-center gap-2 text-sm font-medium text-slate-900"><span class='<%# PaymentDotClass(Eval("Method")) %>' aria-hidden="true"></span><%# PaymentName(Eval("Method")) %></div><div class="mt-1 pl-4 text-sm tabular-nums text-slate-600"><%# Money(Eval("Sales")) %> · <%# Eval("Orders") %> orders</div></div></ItemTemplate></asp:Repeater><asp:Panel ID="pnlNoPayments" runat="server" Visible="false" CssClass="text-sm text-slate-500">No paid orders in this period.</asp:Panel></div></div></section>
            </div>

            <section class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="outcomesHeading">
                <div class="flex flex-wrap items-start justify-between gap-x-6 gap-y-3"><div><h2 id="outcomesHeading" class="text-lg font-semibold text-slate-950">Order outcomes</h2><p class="mt-1 text-sm text-slate-600"><asp:Literal ID="litPlacedOrders" runat="server" /> orders placed</p></div><div class="text-right"><strong class="text-2xl font-semibold tabular-nums text-slate-950"><asp:Literal ID="litConversion" runat="server" /></strong><span class="ml-2 text-sm text-slate-600">paid</span></div></div>
                <div class="mt-5 flex h-2.5 overflow-hidden rounded-full bg-slate-200" role="img" aria-label='<%= OutcomeBarLabel() %>'><div class="h-full bg-emerald-600" style='<%= ConversionWidth() %>'></div><div class="h-full bg-amber-500" style='<%= ExpiredWidth() %>'></div></div>
                <div class="mt-5 flex flex-wrap gap-x-10 gap-y-4 text-sm"><div class="flex items-start gap-2"><span class="mt-1.5 size-2 shrink-0 rounded-sm bg-emerald-600" aria-hidden="true"></span><div><strong class="block text-lg font-semibold leading-5 tabular-nums text-slate-950"><asp:Literal ID="litConversionDetail" runat="server" /></strong><span class="mt-1 block text-slate-600">Paid · <asp:Literal ID="litConvertedValue" runat="server" /></span></div></div><div class="flex items-start gap-2"><span class="mt-1.5 size-2 shrink-0 rounded-sm bg-amber-500" aria-hidden="true"></span><div><strong class="block text-lg font-semibold leading-5 tabular-nums text-slate-950"><asp:Literal ID="litExpired" runat="server" /></strong><span class="mt-1 block text-slate-600">Expired · <asp:Literal ID="litExpiredValue" runat="server" /></span></div></div><asp:Panel ID="pnlOtherOrders" runat="server" CssClass="flex items-start gap-2"><span class="mt-1.5 size-2 shrink-0 rounded-sm bg-slate-300" aria-hidden="true"></span><div><strong class="block text-lg font-semibold leading-5 tabular-nums text-slate-950"><asp:Literal ID="litOtherOrders" runat="server" /></strong><span class="mt-1 block text-slate-600">Awaiting payment</span></div></asp:Panel></div>
            </section>
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
                <p class="mt-3 text-xs leading-5 text-slate-500">Downloads an Excel workbook with the overview, sales trend, products, categories, and payment methods.</p>
            </div>
            <div class="flex justify-end gap-2 border-t border-slate-200 px-5 py-4">
                <button type="button" class="rounded-md border border-slate-200 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50" data-modal-dismiss="true">Cancel</button>
                <asp:Button ID="btnExportAnalytics" runat="server" Text="Download Excel" OnClick="btnExportAnalytics_Click" CssClass="cursor-pointer rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-white hover:bg-slate-800" />
            </div>
        </div>
    </div>
</asp:Content>
