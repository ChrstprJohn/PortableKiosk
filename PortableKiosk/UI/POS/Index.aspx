<%@ Page Title="Point of Sale" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Index.aspx.cs"
    Inherits="PortableKiosk.UI.POS.Index" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .receipt-preview { width: min(100%, 500px); margin: 0 auto; padding-top: 2rem; }
        .receipt-printer { position: relative; height: 74px; margin: 0 0 -40px; border: 2px solid #8d9299; border-radius: 19px; background: linear-gradient(#d8d9dc, #a5a8ad 72%, #8e9298); box-shadow: inset 0 3px 5px #fff9, inset 0 -5px 7px #5558, 0 8px 18px #18233326; }
        .receipt-printer::before { content: ""; position: absolute; inset: 28px 14px 18px; border-radius: 7px; background: #42464d; box-shadow: inset 0 2px 4px #20232988; }
        .receipt-paper { position: relative; margin: 0 18px; padding: 24px; background: #fff; color: #222; box-shadow: 0 9px 20px #18233326; }
        .receipt-paper::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 8px; background: linear-gradient(#20232926, transparent); }
        .receipt-paper::after { content: ""; position: absolute; bottom: 0; left: 0; right: 0; height: 5px; background: radial-gradient(circle at 4px 5px, #e2e8f0 4px, transparent 4.5px) repeat-x; background-size: 8px 5px; }
        .receipt-paper pre { width: max-content; max-width: 100%; margin: 0 auto; font-family: Courier, "Courier New", monospace; font-size: 16px; line-height: 22px; font-weight: 400; letter-spacing: 0; white-space: pre; overflow-x: auto; }
        .receipt-actions { display: flex; gap: 12px; width: min(100%, 500px); margin: 32px auto 0; }
        .receipt-actions > input { flex: 1; min-width: 0; }
        .cash-receipt-preview { padding-top: 1rem; }
        @media (min-width: 1024px) {
            .receipt-paper pre { font-size: 18px; line-height: 24px; }
            .pos-cash-layout { align-items: stretch; align-content: center; }
            .pos-cash-receipt { position: relative; min-height: 0; }
            .cash-receipt-preview { position: absolute; inset: 0; display: flex; flex-direction: column; height: 100%; padding-top: 0; }
            .cash-receipt-preview .receipt-printer { flex-shrink: 0; }
            .cash-receipt-preview .receipt-paper { flex: 1; min-height: 0; overflow-y: auto; }
        }
        .pos-keypad { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px; }
        .pos-keypad button { display: flex; align-items: center; justify-content: center; gap: 8px; min-height: 60px; border: 1px solid #cbd5e1; border-radius: 12px; background: #f8fafc; color: #0f172a; font-size: 24px; font-weight: 600; transition: background-color 120ms; }
        .pos-keypad button:hover { background: #e2e8f0; }
        .pos-keypad button:active { background: #cbd5e1; }
        .pos-keypad .pos-keypad-action { background: #e2e8f0; font-size: 14px; }
        .pos-keypad .pos-keypad-action:hover { background: #cbd5e1; }
        .pos-keypad button:focus-visible, .pos-quick-cash button:focus-visible { outline: 2px solid #1d4ed8; outline-offset: 2px; }
        .pos-quick-cash button { min-height: 44px; border: 1px solid #bfdbfe; border-radius: 8px; background: #eff6ff; color: #1e3a8a; font-size: 13px; font-weight: 600; }
        .pos-quick-cash button:hover { background: #dbeafe; }
        .pos-quick-cash button:active { background: #bfdbfe; }
        @media (max-width: 440px) { .receipt-actions { flex-direction: column; } .receipt-printer::before { left: 6px; right: 6px; } .receipt-paper { margin-inline: 10px; padding: 20px 14px; } .receipt-paper pre { font-size: 14px; line-height: 20px; } }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="-mx-3 -my-3 min-h-dvh bg-slate-100 text-slate-900 md:-mx-6 md:-my-4">
        <asp:Label ID="lblError" runat="server" ClientIDMode="Static" EnableViewState="false" Visible="false" role="alert"
            CssClass="fixed left-1/2 top-2 z-50 block w-[calc(100%-1rem)] max-w-2xl -translate-x-1/2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-800 shadow-lg transition-opacity duration-200" />

        <asp:Panel ID="pnlIdle" runat="server">
            <main class="relative mx-auto flex min-h-dvh max-w-5xl flex-col justify-center px-5 py-12 sm:px-8">
                <details data-pos-profile-menu class="group absolute right-5 top-5 z-20 sm:right-8 sm:top-8">
                    <summary aria-label="Profile menu" class="inline-flex min-h-11 cursor-pointer list-none items-center gap-2 rounded-full border border-slate-200 bg-white py-1 pl-1 pr-3 text-sm font-semibold text-slate-700 shadow-sm transition-colors hover:border-slate-300 hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700 [&::-webkit-details-marker]:hidden">
                        <span class="flex size-9 items-center justify-center rounded-full bg-slate-100 text-slate-700" aria-hidden="true">
                            <svg viewBox="0 0 24 24" class="size-5 fill-none stroke-current" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="3.25" /><path d="M5.5 20a6.5 6.5 0 0 1 13 0" /></svg>
                        </span>
                        <span id="posProfileLastName" data-last-name='<%: System.Convert.ToString(Session["StaffLastName"]) %>' data-display-name='<%: System.Convert.ToString(Session["StaffDisplayName"]) %>' class="max-w-28 truncate"><asp:Literal ID="litProfileLastName" runat="server" /></span>
                        <svg aria-hidden="true" viewBox="0 0 20 20" class="size-4 fill-none stroke-current transition-transform group-open:rotate-180" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="m5 7.5 5 5 5-5" /></svg>
                    </summary>
                    <div class="absolute right-0 mt-2 w-48 overflow-hidden rounded-xl border border-slate-200 bg-white p-1.5 shadow-lg">
                        <a runat="server" href="~/UI/Account/SignOut.aspx"
                            class="flex min-h-11 items-center gap-2.5 rounded-lg px-3 text-sm font-medium text-slate-700 no-underline transition-colors hover:bg-slate-100 hover:text-slate-950 focus-visible:outline-2 focus-visible:outline-offset-[-2px] focus-visible:outline-blue-700">
                            <svg aria-hidden="true" viewBox="0 0 24 24" class="size-4 fill-none stroke-current" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10 17l5-5-5-5m5 5H3" /><path d="M12 3h5a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-5" /></svg>
                            <span>Sign out</span>
                        </a>
                    </div>
                </details>
                <h1 class="max-w-[calc(100%-4rem)] text-3xl font-semibold tracking-tight text-slate-950 sm:max-w-none sm:text-4xl">Ready for the next sale</h1>
                <div class="mt-8 grid gap-4 md:grid-cols-2">
                    <asp:LinkButton ID="btnOpenKiosk" runat="server" OnClick="btnOpenKiosk_Click" CausesValidation="false"
                        CssClass="group flex min-h-60 flex-col items-center justify-between rounded-2xl border border-slate-200 bg-white px-6 py-6 text-center no-underline shadow-sm transition-[border-color,background-color,box-shadow,transform] duration-200 hover:-translate-y-0.5 hover:border-blue-300 hover:bg-blue-50 hover:shadow-md focus-visible:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700">
                        <span class="text-xl font-semibold text-slate-950">Take kiosk order</span>
                        <span aria-hidden="true" class="flex size-32 items-center justify-center rounded-3xl bg-blue-50 text-blue-800 transition-colors group-hover:bg-blue-100">
                            <svg viewBox="0 0 24 24" class="size-24 fill-none stroke-current" stroke-width="0.75" stroke-linecap="round" stroke-linejoin="round"><rect x="3.5" y="4" width="17" height="13" rx="2" /><path d="M8 20h8m-4-3v3" /></svg>
                        </span>
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnNewSale" runat="server" OnClick="btnNewSale_Click" CausesValidation="false"
                        CssClass="group flex min-h-60 flex-col items-center justify-between rounded-2xl border border-slate-200 bg-white px-6 py-6 text-center no-underline shadow-sm transition-[border-color,background-color,box-shadow,transform] duration-200 hover:-translate-y-0.5 hover:border-blue-300 hover:bg-blue-50 hover:shadow-md focus-visible:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700">
                        <span class="text-xl font-semibold text-slate-950">Create new order</span>
                        <span aria-hidden="true" class="flex size-32 items-center justify-center rounded-3xl bg-blue-50 text-blue-800 transition-colors group-hover:bg-blue-100">
                            <svg viewBox="0 0 24 24" class="size-24 fill-none stroke-current" stroke-width="0.75" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="8.5" /><path d="M12 8v8m-4-4h8" /></svg>
                        </span>
                    </asp:LinkButton>
                </div>
            </main>
        </asp:Panel>

        <asp:Panel ID="pnlQueue" runat="server" Visible="false" DefaultButton="btnSearchOrders">
            <main class="flex min-h-dvh items-center justify-center px-5 py-8 sm:px-8">
                <section aria-labelledby="kioskOrderHeading" class="w-full max-w-md rounded-xl border border-slate-200 bg-white p-6 shadow-sm sm:p-7">
                    <div class="mb-5">
                        <h1 id="kioskOrderHeading" class="text-xl font-semibold tracking-tight text-slate-950">Enter kiosk order number</h1>
                    </div>
                    <asp:TextBox ID="txtOrderSearch" runat="server" ClientIDMode="Static" MaxLength="21" inputmode="none" autocomplete="off" placeholder="# Order number" aria-label="Kiosk order number"
                        CssClass="h-16 w-full rounded-xl border border-slate-300 bg-slate-50 px-4 text-center text-2xl font-semibold tabular-nums text-slate-950 placeholder:text-slate-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                    <div class="pos-keypad mt-4" role="group" aria-label="Order number keypad">
                        <button type="button" data-pos-order-key="1">1</button><button type="button" data-pos-order-key="2">2</button><button type="button" data-pos-order-key="3">3</button>
                        <button type="button" data-pos-order-key="4">4</button><button type="button" data-pos-order-key="5">5</button><button type="button" data-pos-order-key="6">6</button>
                        <button type="button" data-pos-order-key="7">7</button><button type="button" data-pos-order-key="8">8</button><button type="button" data-pos-order-key="9">9</button>
                        <button type="button" data-pos-order-key="clear" class="pos-keypad-action">Clear</button><button type="button" data-pos-order-key="0">0</button><button type="button" data-pos-order-key="back" class="pos-keypad-action" aria-label="Delete last digit"><svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 5h11v14H9l-7-7 7-7Z"/><path d="m12 9 6 6m0-6-6 6"/></svg></button>
                    </div>
                    <div class="mt-5 grid grid-cols-[minmax(0,0.8fr)_minmax(0,1.2fr)] gap-3">
                        <asp:Button ID="btnQueueBack" runat="server" OnClick="btnBackToIdle_Click" Text="Back"
                            CssClass="min-h-14 cursor-pointer rounded-lg border border-slate-300 bg-white px-4 text-base font-semibold text-slate-700 hover:bg-slate-100 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                        <asp:Button ID="btnSearchOrders" runat="server" OnClick="btnSearchOrders_Click" Text="Open order"
                            CssClass="min-h-14 cursor-pointer rounded-lg bg-blue-700 px-5 text-base font-semibold text-white hover:bg-blue-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                    </div>
                </section>
            </main>
        </asp:Panel>

        <asp:Panel ID="pnlRegister" runat="server" Visible="false">
            <main class="grid min-h-dvh w-full grid-rows-[42dvh_58dvh] lg:h-dvh lg:grid-cols-[minmax(370px,36%)_minmax(0,1fr)] lg:grid-rows-1 lg:overflow-hidden">
                <section aria-labelledby="saleReceiptHeading" class="grid min-h-0 min-w-0 grid-rows-[auto_minmax(0,1fr)_auto] border-b border-slate-300 bg-white lg:border-b-0 lg:border-r">
                    <div class="border-b border-slate-200 px-3 py-2 sm:px-4">
                        <div class="flex items-center justify-between gap-2">
                            <h1 id="saleReceiptHeading" class="text-lg font-semibold text-slate-950">Order summary</h1>
                            <asp:Panel ID="pnlOrderTypeToolbar" runat="server" CssClass="flex shrink-0 items-center justify-end">
                            <asp:Panel ID="pnlNewOrderType" runat="server" CssClass="relative inline-flex h-10 w-48 items-center rounded-full bg-slate-200 p-1" role="group" aria-label="Order type">
                                    <span id="orderTypeSlider" runat="server" aria-hidden="true"
                                        class="pointer-events-none absolute inset-y-1 left-1 w-[calc(50%-0.25rem)] rounded-full bg-white shadow-sm transition-transform duration-200 ease-out"></span>
                                    <asp:Button ID="btnDineIn" runat="server" OnClick="btnDineIn_Click" Text="Dine in" aria-pressed="true"
                                        CssClass="relative z-10 min-h-8 flex-1 cursor-pointer rounded-full px-3 text-sm font-semibold text-slate-950 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                                    <asp:Button ID="btnTakeout" runat="server" OnClick="btnTakeout_Click" Text="Takeout" aria-pressed="false"
                                        CssClass="relative z-10 min-h-8 flex-1 cursor-pointer rounded-full px-3 text-sm font-semibold text-slate-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                                </asp:Panel>
                            </asp:Panel>
                        </div>
                        <asp:Panel ID="pnlKioskDetails" runat="server" Visible="false"><p class="mt-2 text-sm text-slate-600"><asp:Literal ID="litKioskDetails" runat="server" /></p></asp:Panel>
                    </div>
                    <div class="min-h-0 overflow-y-auto px-3 py-2 sm:px-4 sm:py-3">
                        <asp:Panel ID="pnlCartEmpty" runat="server" CssClass="py-8 text-center">
                            <p class="text-base font-medium text-slate-800">No items yet</p>
                            <p class="mt-2 text-sm text-slate-600">Choose a product to add it to the receipt.</p>
                        </asp:Panel>
                        <div class="divide-y divide-slate-100">
                            <asp:Repeater ID="rptCartItems" runat="server">
                                <ItemTemplate>
                                    <div class="grid grid-cols-[52px_minmax(0,1fr)_auto] items-center gap-2 py-2 first:pt-0 sm:grid-cols-[60px_minmax(0,1fr)_auto] sm:gap-3">
                                        <span class="flex size-[52px] items-center justify-center overflow-hidden rounded-md bg-slate-100 sm:size-[60px]">
                                            <asp:Image runat="server" Visible='<%# HasImage(Eval("ImagePath")) %>' ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                                AlternateText="" CssClass="h-full w-full object-cover" />
                                            <span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>' class="text-[9px] font-medium text-slate-500">No image</span>
                                        </span>
                                        <div class="min-w-0">
                                            <strong class="block break-words text-sm font-semibold leading-5 text-slate-950"><%#: Eval("ProductName") %></strong>
                                            <span class="mt-0.5 block text-xs text-slate-600"><%#: Eval("DisplaySize") %> · <%# FormatMoney(Eval("UnitPrice")) %> each</span>
                                            <div class="mt-1 inline-flex items-center rounded-md border border-slate-300" aria-label="Quantity controls">
                                                <button type="button" data-pos-line-action="decrease" data-pos-variant="<%# Eval("ProductVariantID") %>"
                                                    aria-label="Decrease quantity of <%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("ProductName"))) %>"
                                                    class="inline-flex size-7 items-center justify-center text-lg text-slate-700 hover:bg-slate-100 focus-visible:outline-2 focus-visible:outline-blue-700">&minus;</button>
                                                <span class="min-w-8 text-center text-sm font-semibold tabular-nums"><%# Eval("Quantity") %></span>
                                                <button type="button" data-pos-line-action="increase" data-pos-variant="<%# Eval("ProductVariantID") %>"
                                                    aria-label="Increase quantity of <%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("ProductName"))) %>"
                                                    class="inline-flex size-7 items-center justify-center text-lg text-slate-700 hover:bg-slate-100 focus-visible:outline-2 focus-visible:outline-blue-700">+</button>
                                            </div>
                                        </div>
                                        <div class="flex flex-col items-end gap-1">
                                            <strong class="text-sm font-semibold tabular-nums text-slate-950"><%# FormatMoney(Eval("LineTotal")) %></strong>
                                            <button type="button" data-pos-line-action="remove" data-pos-variant="<%# Eval("ProductVariantID") %>"
                                                aria-label="Remove <%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("ProductName"))) %> from order"
                                                class="inline-flex size-8 items-center justify-center rounded-md text-slate-500 hover:bg-red-50 hover:text-red-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700">
                                                <svg aria-hidden="true" viewBox="0 0 24 24" class="size-4 fill-none stroke-current" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7h16M10 11v6m4-6v6M5 7l1 14h12l1-14M9 7V4h6v3" /></svg>
                                            </button>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                    <div class="border-t border-slate-200 px-3 py-2 sm:px-4 sm:py-3">
                        <div class="flex items-baseline justify-between gap-3"><span class="text-sm font-medium text-slate-700">Total due</span>
                            <strong class="text-2xl font-semibold tabular-nums text-slate-950"><asp:Literal ID="litCartTotal" runat="server" /></strong></div>
                        <div class="mt-2 grid grid-cols-[minmax(0,0.8fr)_minmax(0,1.2fr)] gap-2">
                            <asp:Button ID="btnCancelSale" runat="server" OnClick="btnBackToIdle_Click" Text="Cancel order"
                                CssClass="min-h-11 cursor-pointer rounded-lg border border-slate-300 bg-white px-3 text-sm font-semibold text-slate-700 hover:bg-slate-100 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                            <asp:Button ID="btnProceed" runat="server" OnClick="btnProceed_Click" Text="Proceed to payment"
                                CssClass="min-h-11 cursor-pointer rounded-lg bg-blue-700 px-3 text-sm font-semibold text-white hover:bg-blue-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700 disabled:cursor-not-allowed disabled:bg-slate-300 disabled:text-slate-600" />
                        </div>
                    </div>
                </section>

                <section aria-label="Product menu" class="relative grid min-h-0 min-w-0 grid-rows-[auto_minmax(0,1fr)] bg-slate-50">
                    <div class="flex min-h-14 min-w-0 items-center gap-2 border-b border-slate-200 bg-white p-2 sm:gap-3 sm:p-3">
                        <nav aria-label="Product categories" class="flex min-w-0 flex-1 items-center gap-1.5 overflow-x-auto sm:gap-2">
                            <asp:Repeater ID="rptCategories" runat="server" OnItemDataBound="rptCategories_ItemDataBound"><ItemTemplate>
                                <button type="button" data-pos-category="<%# Eval("CategoryID") %>"
                                    class="inline-flex min-h-10 shrink-0 items-center gap-1.5 rounded-md bg-slate-100 px-2.5 text-left text-xs font-semibold leading-4 text-slate-700 hover:bg-slate-200 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700 sm:min-h-11 sm:gap-2 sm:px-3 sm:text-sm">
                                    <asp:Literal ID="litCategoryIcon" runat="server" /><span><%#: Eval("CategoryName") %></span>
                                </button>
                            </ItemTemplate></asp:Repeater>
                        </nav>
                    </div>
                    <asp:Panel ID="pnlCatalogEmpty" runat="server" Visible="false"
                        CssClass="absolute inset-0 z-10 flex items-center justify-center bg-slate-50 px-5 py-12 text-center text-sm text-slate-600">No products are available right now.</asp:Panel>
                    <div class="min-h-0 min-w-0 overflow-y-auto p-2 sm:p-3" id="posProductRows">
                            <asp:Repeater ID="rptProducts" runat="server" OnItemDataBound="rptProducts_ItemDataBound"><ItemTemplate>
                                <section data-pos-size-row="<%# Eval("SizeKey") %>" class="mb-2 grid min-w-0 grid-cols-[58px_minmax(0,1fr)] gap-2 border-b border-slate-200 pb-2 last:border-b-0 sm:grid-cols-[78px_minmax(0,1fr)] sm:gap-3">
                                    <h2 class="flex min-h-24 items-center justify-center rounded-md border border-slate-200 bg-white px-1 text-center text-xs font-semibold text-slate-800 sm:min-h-28 sm:text-sm"><%#: Eval("SizeName") %></h2>
                                    <div class="grid grid-cols-[repeat(auto-fill,minmax(118px,1fr))] content-start gap-2 sm:grid-cols-[repeat(auto-fill,minmax(146px,1fr))]">
                                        <asp:Repeater ID="rptProductTiles" runat="server"><ItemTemplate>
                                            <button type="button" data-pos-add-product="<%# Eval("ProductVariantID") %>"
                                                data-pos-category-id="<%# Eval("CategoryID") %>"
                                                aria-label="<%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("ProductName")) + " " + Convert.ToString(Eval("SizeName")) + " " + FormatMoney(Eval("Price"))) %>"
                                                class="group flex min-w-0 flex-col overflow-hidden rounded-lg border border-slate-200 bg-white text-left transition-colors hover:border-blue-400 hover:bg-blue-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700">
                                                <span class="aspect-square w-full overflow-hidden bg-slate-100">
                                                    <asp:Image runat="server" Visible='<%# HasImage(Eval("ImagePath")) %>' ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                                        AlternateText="" CssClass="h-full w-full object-cover transition-transform duration-200 group-hover:scale-105" />
                                                    <span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>' class="flex h-full w-full items-center justify-center text-xs font-medium text-slate-500">No image</span>
                                                </span>
                                                <span class="flex w-full flex-col items-start gap-0.5 border-t border-slate-100 px-2 py-2 text-left sm:px-3">
                                                    <strong class="line-clamp-2 w-full break-words text-left text-xs font-semibold leading-4 text-slate-950 sm:text-sm"><%#: Eval("ProductName") %></strong>
                                                    <span class="text-left text-xs font-semibold tabular-nums text-blue-800 sm:text-sm"><%# FormatMoney(Eval("Price")) %></span>
                                                </span>
                                            </button>
                                        </ItemTemplate></asp:Repeater>
                                    </div>
                                </section>
                            </ItemTemplate></asp:Repeater>
                        <p id="posFilterEmpty" class="hidden rounded-lg border border-dashed border-slate-300 bg-white px-4 py-8 text-center text-sm text-slate-600">No products in this category.</p>
                    </div>
                </section>
            </main>
        </asp:Panel>

        <asp:Panel ID="pnlPaymentChoice" runat="server" Visible="false">
            <main class="mx-auto flex min-h-dvh max-w-3xl flex-col justify-center px-5 py-10">
                <h1 class="text-center text-3xl font-semibold tracking-tight text-slate-950">Choose a payment method</h1>
                <div class="mt-8 grid gap-4 sm:grid-cols-2">
                    <asp:LinkButton ID="btnChooseCash" runat="server" OnClick="btnChooseCash_Click" CssClass="group flex min-h-60 flex-col items-center justify-between gap-6 rounded-2xl border border-slate-200 bg-white px-6 py-6 text-center text-slate-950 no-underline shadow-sm transition-[border-color,background-color,box-shadow,transform] duration-200 hover:-translate-y-0.5 hover:border-blue-300 hover:bg-blue-50 hover:shadow-md focus-visible:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700">
                        <span class="text-xl font-semibold">Cash</span>
                        <span class="flex size-32 items-center justify-center rounded-3xl bg-blue-50 text-blue-800 transition-colors group-hover:bg-blue-100" aria-hidden="true"><svg class="size-24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="0.75" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><circle cx="12" cy="12" r="3"/><path d="M6 9H5v6h1m12-6h1v6h-1"/></svg></span>
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnChooseCashless" runat="server" OnClick="btnChooseCashless_Click" CssClass="group flex min-h-60 flex-col items-center justify-between gap-6 rounded-2xl border border-slate-200 bg-white px-6 py-6 text-center text-slate-950 no-underline shadow-sm transition-[border-color,background-color,box-shadow,transform] duration-200 hover:-translate-y-0.5 hover:border-blue-300 hover:bg-blue-50 hover:shadow-md focus-visible:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700">
                        <span class="text-xl font-semibold">Cashless <span class="block text-sm font-normal text-slate-600">Mock QR payment</span></span>
                        <span class="flex size-32 items-center justify-center rounded-3xl bg-blue-50 text-blue-800 transition-colors group-hover:bg-blue-100" aria-hidden="true"><svg class="size-24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="0.75" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="6" height="6" rx="1"/><rect x="15" y="3" width="6" height="6" rx="1"/><rect x="3" y="15" width="6" height="6" rx="1"/><path d="M15 15h3v3h3m-6 0v3h3m3-8v2M12 3v3m0 5v2M3 12h3m5 8v1"/></svg></span>
                    </asp:LinkButton>
                </div>
                <asp:Button ID="btnChoiceBackToSale" runat="server" OnClick="btnChoiceBackToSale_Click" Text="Back to sale" CssClass="mt-6 min-h-12 cursor-pointer self-start rounded-lg border border-slate-300 bg-white px-5 text-sm font-semibold text-slate-700 hover:bg-slate-100 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
            </main>
        </asp:Panel>

        <asp:Panel ID="pnlCashless" runat="server" Visible="false">
            <main class="mx-auto flex min-h-dvh max-w-lg flex-col items-center justify-center px-5 py-10 text-center">
                <h1 class="text-3xl font-semibold tracking-tight text-slate-950">Scan to pay</h1>
                <p class="mt-2 text-sm text-slate-600">Example QR code for simulated payment</p>
                <div class="mt-6 rounded-xl bg-white p-5 shadow-sm"><svg class="size-56" viewBox="0 0 25 25" role="img" aria-label="Example payment QR code" shape-rendering="crispEdges" xmlns="http://www.w3.org/2000/svg">
                    <rect width="25" height="25" fill="#fff" />
                    <path fill="#0f172a" d="
                        M2 2h7v1h-7zM11 2h2v1h-2zM16 2h7v1h-7z
                        M2 3h1v1h-1zM8 3h1v1h-1zM10 3h1v1h-1zM13 3h2v1h-2zM16 3h1v1h-1zM22 3h1v1h-1z
                        M2 4h1v1h-1zM4 4h3v1h-3zM8 4h1v1h-1zM10 4h1v1h-1zM12 4h2v1h-2zM16 4h1v1h-1zM18 4h3v1h-3zM22 4h1v1h-1z
                        M2 5h1v1h-1zM4 5h3v1h-3zM8 5h1v1h-1zM11 5h2v1h-2zM16 5h1v1h-1zM18 5h3v1h-3zM22 5h1v1h-1z
                        M2 6h1v1h-1zM4 6h3v1h-3zM8 6h1v1h-1zM13 6h1v1h-1zM16 6h1v1h-1zM18 6h3v1h-3zM22 6h1v1h-1z
                        M2 7h1v1h-1zM8 7h1v1h-1zM11 7h4v1h-4zM16 7h1v1h-1zM22 7h1v1h-1z
                        M2 8h7v1h-7zM10 8h1v1h-1zM12 8h1v1h-1zM14 8h1v1h-1zM16 8h7v1h-7z
                        M10 9h1v1h-1zM12 9h1v1h-1zM14 9h1v1h-1z
                        M2 10h3v1h-3zM8 10h2v1h-2zM11 10h1v1h-1zM14 10h2v1h-2z
                        M3 11h1v1h-1zM5 11h1v1h-1zM13 11h2v1h-2zM17 11h3v1h-3zM22 11h1v1h-1z
                        M3 12h1v1h-1zM6 12h1v1h-1zM8 12h1v1h-1zM10 12h3v1h-3zM15 12h2v1h-2zM18 12h1v1h-1zM20 12h1v1h-1z
                        M5 13h1v1h-1zM10 13h2v1h-2zM15 13h2v1h-2zM19 13h4v1h-4z
                        M3 14h1v1h-1zM5 14h2v1h-2zM8 14h3v1h-3zM12 14h2v1h-2zM15 14h2v1h-2zM18 14h3v1h-3zM22 14h1v1h-1z
                        M11 15h1v1h-1zM15 15h1v1h-1zM17 15h1v1h-1z
                        M2 16h7v1h-7zM10 16h1v1h-1zM12 16h1v1h-1zM16 16h1v1h-1zM18 16h3v1h-3zM22 16h1v1h-1z
                        M2 17h1v1h-1zM8 17h1v1h-1zM12 17h1v1h-1zM14 17h1v1h-1zM16 17h1v1h-1zM19 17h2v1h-2z
                        M2 18h1v1h-1zM4 18h3v1h-3zM8 18h1v1h-1zM10 18h3v1h-3zM14 18h2v1h-2zM21 18h1v1h-1z
                        M2 19h1v1h-1zM4 19h3v1h-3zM8 19h1v1h-1zM11 19h7v1h-7zM21 19h2v1h-2z
                        M2 20h1v1h-1zM4 20h3v1h-3zM8 20h1v1h-1zM12 20h2v1h-2zM15 20h1v1h-1zM20 20h1v1h-1z
                        M2 21h1v1h-1zM8 21h1v1h-1zM11 21h1v1h-1zM14 21h2v1h-2zM18 21h2v1h-2z
                        M2 22h7v1h-7zM10 22h2v1h-2zM16 22h1v1h-1zM18 22h1v1h-1zM21 22h2v1h-2z" />
                </svg></div>
                <strong class="mt-5 text-2xl font-semibold tabular-nums text-slate-950"><asp:Literal ID="litCashlessTotal" runat="server" /></strong>
                <div class="mt-8 grid w-full grid-cols-2 gap-3">
                    <asp:Button ID="btnCashlessBack" runat="server" OnClick="btnBackToChoice_Click" Text="Back" CssClass="min-h-12 cursor-pointer rounded-lg border border-slate-300 bg-white px-4 text-sm font-semibold text-slate-700 hover:bg-slate-100 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                    <asp:Button ID="btnSimulatePayment" runat="server" OnClick="btnSimulatePayment_Click" Text="Simulate payment" CssClass="min-h-12 cursor-pointer rounded-lg bg-blue-700 px-4 text-sm font-semibold text-white hover:bg-blue-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                </div>
            </main>
        </asp:Panel>

        <asp:Panel ID="pnlPayment" runat="server" Visible="false" DefaultButton="btnCompletePayment">
            <main class="pos-cash-layout mx-auto grid min-h-dvh w-full max-w-6xl items-start gap-6 px-4 py-6 sm:px-6 lg:grid-cols-[minmax(0,1fr)_minmax(0,1.15fr)] lg:gap-10">
                    <section aria-label="Receipt preview" class="pos-cash-receipt min-w-0">
                            <div class="receipt-preview cash-receipt-preview"><div class="receipt-printer" aria-hidden="true"></div>
                                <div class="receipt-paper"><pre aria-label="Unpaid order receipt preview"><asp:Literal ID="litPaymentReceiptPreview" runat="server" /><span id="posReceiptTendered">Cash received           PHP 0.00</span>&#10;<span id="posReceiptChange">Change                  PHP 0.00</span>&#10;--------------------------------&#10;Awaiting payment.</pre></div>
                            </div>
                    </section>
                    <section aria-labelledby="cashKeypadHeading" class="pos-cash-input min-w-0 rounded-xl border border-slate-200 bg-white p-5 sm:p-6">
                        <div class="flex flex-wrap items-center justify-between gap-3 border-b border-slate-200 pb-4">
                            <h1 id="cashKeypadHeading" class="text-xl font-semibold text-slate-950">Cash payment</h1>
                            <div class="text-right"><p class="text-xs font-medium text-slate-500">Total due</p><strong class="mt-1 block text-xl font-semibold tabular-nums text-slate-950"><asp:Literal ID="litPaymentTotal" runat="server" /></strong></div>
                        </div>
                        <label for="txtTendered" class="mt-5 block text-sm font-medium text-slate-700">Cash received</label>
                        <div class="relative mt-2">
                            <span class="pointer-events-none absolute inset-y-0 left-4 flex items-center text-xl font-medium text-slate-500" aria-hidden="true">₱</span>
                            <asp:TextBox ID="txtTendered" runat="server" ClientIDMode="Static" inputmode="decimal" autocomplete="off" aria-describedby="posTenderedHint"
                                placeholder="0.00" MaxLength="11"
                                CssClass="h-16 w-full rounded-xl border border-slate-300 bg-slate-50 pl-10 pr-16 text-right text-2xl font-semibold tabular-nums text-slate-950 placeholder:text-slate-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700 sm:text-3xl" />
                            <button type="button" data-pos-cash-key="back" class="absolute right-1 top-1 flex size-14 items-center justify-center rounded-lg text-slate-500 hover:bg-slate-200 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-blue-700" aria-label="Delete last cash digit"><svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 5h11v14H9l-7-7 7-7Z"/><path d="m12 9 6 6m0-6-6 6"/></svg></button>
                        </div>
                        <p id="posTenderedHint" class="mt-2 min-h-5 text-xs text-slate-600" aria-live="polite">Enter the amount handed to you.</p>
                        <div class="mt-4 space-y-4">
                            <div role="group" aria-label="Quick cash amounts" class="pos-quick-cash grid grid-cols-4 gap-2">
                                <button type="button" data-pos-cash-quick="10">₱10</button>
                                <button type="button" data-pos-cash-quick="20">₱20</button>
                                <button type="button" data-pos-cash-quick="50">₱50</button>
                                <button type="button" data-pos-cash-quick="100">₱100</button>
                                <button type="button" data-pos-cash-quick="500">₱500</button>
                                <button type="button" data-pos-cash-quick="1000">₱1,000</button>
                                <button type="button" data-pos-cash-quick="exact" aria-label="Set exact amount due" class="col-span-2">Exact amount</button>
                            </div>
                            <div class="pos-keypad" role="group" aria-label="Cash amount keypad">
                                <button type="button" data-pos-cash-key="1">1</button><button type="button" data-pos-cash-key="2">2</button><button type="button" data-pos-cash-key="3">3</button>
                                <button type="button" data-pos-cash-key="4">4</button><button type="button" data-pos-cash-key="5">5</button><button type="button" data-pos-cash-key="6">6</button>
                                <button type="button" data-pos-cash-key="7">7</button><button type="button" data-pos-cash-key="8">8</button><button type="button" data-pos-cash-key="9">9</button>
                                <button type="button" data-pos-cash-key="clear" class="pos-keypad-action">Clear</button><button type="button" data-pos-cash-key="0">0</button><button type="button" data-pos-cash-key="." aria-label="Decimal point">.</button>
                            </div>
                        </div>
                        <div class="mt-5 flex items-baseline justify-between gap-3 rounded-lg bg-slate-50 px-4 py-3 text-sm">
                            <span class="font-medium text-slate-700">Change to return</span>
                            <strong id="posChangePreview" data-total="<%= PaymentTotalValue %>"
                                class="text-2xl font-semibold tabular-nums text-slate-950">₱0.00</strong>
                        </div>
                        <div class="mt-5 grid grid-cols-[minmax(0,2fr)_minmax(0,3fr)] gap-3">
                            <asp:Button ID="btnBackToSale" runat="server" OnClick="btnBackToChoice_Click" Text="Back"
                                CssClass="min-h-12 cursor-pointer rounded-lg border border-slate-300 bg-white px-3 text-sm font-semibold text-slate-700 hover:bg-slate-100 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                            <asp:Button ID="btnCompletePayment" runat="server" OnClick="btnCompletePayment_Click" Text="Complete cash payment"
                                CssClass="min-h-12 cursor-pointer rounded-lg bg-blue-700 px-3 text-sm font-semibold text-white hover:bg-blue-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700 disabled:cursor-not-allowed disabled:bg-slate-300" />
                        </div>
                    </section>
            </main>
        </asp:Panel>

        <asp:Panel ID="pnlReceipt" runat="server" Visible="false">
            <main class="mx-auto max-w-2xl px-5 pb-10 pt-4 sm:px-8">
                <div class="receipt-preview"><div class="receipt-printer" aria-hidden="true"></div>
                <section aria-label="Receipt preview" class="receipt-paper"><pre><asp:Literal ID="litReceiptPreview" runat="server" /></pre></section>
                </div>
                <div class="receipt-actions">
                    <asp:Button ID="btnDownloadReceipt" runat="server" OnClick="btnDownloadReceipt_Click" Text="Download PDF"
                        CssClass="min-h-12 flex-1 cursor-pointer rounded-lg bg-blue-700 px-4 text-sm font-semibold text-white hover:bg-blue-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                    <asp:Button ID="btnCloseReceipt" runat="server" OnClick="btnCloseReceipt_Click" Text="Next sale"
                        CssClass="min-h-12 flex-1 cursor-pointer rounded-lg border border-slate-300 bg-white px-4 text-sm font-semibold text-slate-900 hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                </div>
            </main>
        </asp:Panel>
    </div>

    <asp:HiddenField ID="hdnProductVariantID" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hdnLineAction" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hdnCategory" runat="server" ClientIDMode="Static" Value="all" />
    <asp:Button ID="btnAddProduct" runat="server" ClientIDMode="Static" OnClick="btnAddProduct_Click" CssClass="hidden" />
    <asp:Button ID="btnLineAction" runat="server" ClientIDMode="Static" OnClick="btnLineAction_Click" CssClass="hidden" />
</asp:Content>

<asp:Content ID="ScriptsContent" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src="<%= ResolveUrl("~/Scripts/app/pos/register.js?v=5") %>"></script>
</asp:Content>
