<%@ Page
    Title="Orders"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="Orders.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.Orders" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <main class="mx-auto w-full max-w-7xl" aria-labelledby="ordersHeading">
        <header class="mb-7">
            <h1 id="ordersHeading" class="text-2xl font-semibold tracking-tight text-slate-950 sm:text-3xl">Orders</h1>
            <p class="mt-1 text-sm text-slate-500">Review kiosk orders and payment information.</p>
        </header>

        <div class="mb-5 grid gap-3 sm:grid-cols-2">
            <div class="rounded-lg border border-slate-200 bg-white p-4" aria-label="Search orders">
                <asp:Label ID="lblOrderSearch" runat="server" AssociatedControlID="txtOrderSearch" Text="Search by order number" CssClass="mb-1.5 block text-xs font-medium text-slate-600" />
                <div class="flex gap-2">
                    <asp:TextBox ID="txtOrderSearch" runat="server" MaxLength="20" CssClass="block min-h-9 min-w-0 flex-1 rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm placeholder:text-slate-400 focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" placeholder="Enter order number" />
                    <asp:Button ID="btnSearchOrders" runat="server" Text="Search" CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" OnClick="btnSearchOrders_Click" />
                </div>
            </div>

            <div class="rounded-lg border border-slate-200 bg-white p-4" aria-label="Filter orders by payment status">
                <asp:Label ID="lblPaymentStatus" runat="server" AssociatedControlID="ddlPaymentStatus" Text="Payment status" CssClass="mb-1.5 block text-xs font-medium text-slate-600" />
                <div>
                    <asp:DropDownList ID="ddlPaymentStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPaymentStatus_SelectedIndexChanged" CssClass="block min-h-9 w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200">
                        <asp:ListItem Text="All payment statuses" Value="" />
                        <asp:ListItem Text="Paid" Value="PAID" />
                        <asp:ListItem Text="Pending" Value="PENDING" />
                        <asp:ListItem Text="Expired" Value="EXPIRED" />
                        <asp:ListItem Text="Failed" Value="FAILED" />
                        <asp:ListItem Text="Cancelled" Value="CANCELLED" />
                        <asp:ListItem Text="Not recorded" Value="NOT_RECORDED" />
                    </asp:DropDownList>
                </div>
            </div>
        </div>

        <section class="overflow-hidden rounded-lg border border-slate-200 bg-white" aria-labelledby="ordersTableHeading">
            <div class="flex flex-wrap items-center justify-between gap-3 border-b border-slate-200 px-4 py-3">
                <h2 id="ordersTableHeading" class="text-sm font-semibold text-slate-950">Orders</h2>
                <asp:Label ID="lblOrderCount" runat="server" CssClass="text-xs text-slate-500" />
            </div>

            <div class="w-full overflow-x-auto">
                <asp:GridView
                    ID="gridOrders"
                    runat="server"
                    AutoGenerateColumns="false"
                    GridLines="None"
                    AllowPaging="true"
                    PageSize="25"
                    DataKeyNames="OrderID"
                    OnRowCommand="gridOrders_RowCommand"
                    OnPageIndexChanging="gridOrders_PageIndexChanging"
                    CssClass="w-full min-w-[1240px] table-auto border-collapse text-left text-sm [&_th]:border-b [&_th]:border-slate-200 [&_th]:bg-white [&_th]:px-4 [&_th]:py-2.5 [&_th]:text-xs [&_th]:font-medium [&_th]:text-slate-500 [&_td]:break-words [&_td]:px-4 [&_td]:py-2.5 [&_td]:text-slate-700 [&_tbody_tr]:border-b [&_tbody_tr]:border-slate-100 [&_tbody_tr:hover]:bg-slate-50 [&_tbody_tr:last-child]:border-b-0"
                    EmptyDataText="No orders match these filters.">
                    <PagerStyle CssClass="border-t border-slate-200 bg-white px-4 py-3 text-sm text-slate-600 [&_a]:rounded [&_a]:px-2 [&_a]:py-1 [&_a]:text-slate-700 [&_a:hover]:bg-slate-100 [&_span]:font-semibold [&_span]:text-slate-950" />
                    <Columns>
                        <asp:TemplateField HeaderText="Order number" ItemStyle-Width="1%" HeaderStyle-Width="1%" ItemStyle-CssClass="whitespace-nowrap" HeaderStyle-CssClass="whitespace-nowrap">
                            <ItemTemplate>
                                <span class="font-medium tabular-nums text-slate-950"><%#: Eval("OrderNumber") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Placed" ItemStyle-Width="160px">
                            <ItemTemplate>
                                <span class="block text-slate-800"><%#: Eval("CreatedAtDisplay") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Expires at" ItemStyle-Width="160px">
                            <ItemTemplate>
                                <span class="block text-slate-800"><%#: Eval("ExpiresAtDisplay") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Type" ItemStyle-Width="90px">
                            <ItemTemplate><%#: Eval("OrderTypeDisplay") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Fulfillment" ItemStyle-Width="145px">
                            <ItemTemplate><%#: Eval("FulfillmentDisplay") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Kitchen" ItemStyle-Width="140px">
                            <ItemTemplate>
                                <span class='inline-flex whitespace-nowrap rounded-full px-2.5 py-1 text-xs font-medium <%# KitchenStatusCss(Eval("KitchenStatusDisplay")) %>'><%#: Eval("KitchenStatusDisplay") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Payment status" ItemStyle-Width="125px">
                            <ItemTemplate>
                                <span class='inline-flex items-center rounded-md px-2 py-0.5 text-xs font-medium <%# PaymentStatusCss(Eval("PaymentStatus")) %>'><%#: Eval("PaymentStatusDisplay") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Payment method" ItemStyle-Width="150px">
                            <ItemTemplate><span class="text-slate-800"><%#: Eval("PaymentMethodDisplay") %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Total" ItemStyle-Width="110px" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                            <ItemTemplate><span class="whitespace-nowrap font-medium tabular-nums text-slate-900"><%#: Eval("AmountDisplay") %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Action" ItemStyle-Width="72px" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnViewOrder" runat="server" Text="" ToolTip='<%# "View details for order #" + Eval("OrderNumber") %>' aria-label='<%# "View details for order #" + Eval("OrderNumber") %>' CommandName="ViewDetails" CommandArgument='<%# Eval("OrderID") %>' CausesValidation="false" CssClass="inline-flex size-8 items-center justify-center rounded-md border border-slate-200 bg-white text-slate-600 transition-colors hover:bg-slate-50 hover:text-slate-950 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400">
                                    <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2.5 12s3.2-6 9.5-6 9.5 6 9.5 6-3.2 6-9.5 6-9.5-6-9.5-6Z" /><circle cx="12" cy="12" r="2.5" /></svg>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="px-5 py-12 text-center">
                            <p class="text-sm font-medium text-slate-800">No orders found</p>
                            <p class="mt-1 text-sm text-slate-500">Try another order number or choose a different payment status.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </section>
    </main>

    <div id="orderDetailsModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" tabindex="-1" aria-labelledby="orderDetailsModalLabel" aria-hidden="true" role="dialog" aria-modal="true">
        <div class="w-full max-w-md">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                <div class="flex items-start justify-between gap-3 border-b border-dashed border-slate-300 px-5 py-4">
                    <div>
                        <h2 class="text-base font-semibold text-slate-950" id="orderDetailsModalLabel">Order details</h2>
                        <p class="mt-0.5 text-sm text-slate-500">#<asp:Literal ID="litDetailsOrderNumber" runat="server" /></p>
                    </div>
                    <button type="button" class="-mt-1 inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close order details">
                        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg>
                    </button>
                </div>

                <div class="overflow-y-auto px-5 py-4">
                    <div class="grid grid-cols-2 gap-4 border-b border-dashed border-slate-300 py-3">
                        <div class="flex flex-col items-start gap-1">
                            <span class="text-xs font-medium text-slate-500">Kitchen</span>
                            <asp:Label ID="lblDetailsKitchenStatus" runat="server" />
                        </div>
                        <div class="flex flex-col items-start gap-1">
                            <span class="text-xs font-medium text-slate-500">Payment</span>
                            <asp:Label ID="lblDetailsPaymentStatus" runat="server" />
                        </div>
                    </div>

                    <dl class="grid grid-cols-1 gap-x-6 gap-y-3 border-b border-dashed border-slate-300 py-4 sm:grid-cols-2">
                        <div><dt class="text-xs font-medium text-slate-500">Placed</dt><dd class="mt-1 text-sm font-medium leading-5 text-slate-900"><asp:Literal ID="litDetailsCreatedAt" runat="server" /></dd></div>
                        <div><dt class="text-xs font-medium text-slate-500">Expires at</dt><dd class="mt-1 text-sm font-medium leading-5 text-slate-900"><asp:Literal ID="litDetailsExpiresAt" runat="server" /></dd></div>
                        <div><dt class="text-xs font-medium text-slate-500">Order type</dt><dd class="mt-1 text-sm font-medium leading-5 text-slate-900"><asp:Literal ID="litDetailsOrderType" runat="server" /></dd></div>
                        <div><dt class="text-xs font-medium text-slate-500">Fulfillment</dt><dd class="mt-1 break-words text-sm font-medium leading-5 text-slate-900"><asp:Literal ID="litDetailsFulfillment" runat="server" /></dd></div>
                        <div><dt class="text-xs font-medium text-slate-500">Payment method</dt><dd class="mt-1 text-sm font-medium leading-5 text-slate-900"><asp:Literal ID="litDetailsPayment" runat="server" /></dd></div>
                    </dl>

                    <div class="pt-4">
                        <h3 class="text-sm font-semibold text-slate-950">Items</h3>
                        <asp:Panel ID="pnlOrderItems" runat="server" CssClass="mt-2">
                            <div class="divide-y divide-dashed divide-slate-300 border-t border-dashed border-slate-300">
                                <asp:Repeater ID="rptOrderItems" runat="server">
                                    <ItemTemplate>
                                        <div class="flex items-center gap-3 py-3">
                                            <asp:Image runat="server"
                                                Visible='<%# HasImage(Eval("ImagePath")) %>'
                                                ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                                AlternateText='<%# Convert.ToString(Eval("ProductName")) %>'
                                                CssClass="size-10 shrink-0 rounded-md object-cover" />
                                            <span runat="server"
                                                visible='<%# !HasImage(Eval("ImagePath")) %>'
                                                class="inline-flex size-10 shrink-0 items-center justify-center rounded-md bg-slate-100 text-slate-400"
                                                aria-hidden="true">
                                                <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3.5" y="4.5" width="17" height="15" rx="2" /><circle cx="9" cy="10" r="1.5" /><path d="m5 17 4.5-4.5a1.5 1.5 0 0 1 2.1 0L14 15l1.5-1.5a1.5 1.5 0 0 1 2.1 0L20 16" /></svg>
                                            </span>
                                            <div class="min-w-0 flex-1">
                                                <div class="flex flex-wrap items-baseline gap-x-2 gap-y-1">
                                                    <p class="text-sm font-medium text-slate-900"><%#: Eval("ProductName") %></p>
                                                    <span class="text-xs text-slate-500"><%#: Eval("DisplaySize") %></span>
                                                </div>
                                                <p class="mt-1 text-xs text-slate-500"><%#: Eval("Quantity") %> × <%#: FormatAmount((decimal)Eval("UnitPrice")) %></p>
                                            </div>
                                            <div class="shrink-0 text-right">
                                                <p class="text-sm font-semibold tabular-nums text-slate-900"><%#: FormatAmount((decimal)Eval("LineTotal")) %></p>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </asp:Panel>
                        <asp:Panel ID="pnlNoOrderItems" runat="server" Visible="false" CssClass="mt-2 border-t border-dashed border-slate-300 py-3 text-sm text-slate-600">
                            No item details were recorded for this order.
                        </asp:Panel>
                    </div>

                    <div class="mt-4 border-t border-dashed border-slate-300 pt-3">
                        <div class="flex items-baseline justify-between gap-4">
                            <h3 class="text-sm font-semibold text-slate-950">TOTAL AMOUNT</h3>
                            <p class="text-xl font-semibold tabular-nums tracking-tight text-slate-950"><asp:Literal ID="litDetailsTotal" runat="server" /></p>
                        </div>
                    </div>
                </div>

                <div class="flex justify-end border-t border-dashed border-slate-300 px-5 py-3">
                    <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Close</button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
