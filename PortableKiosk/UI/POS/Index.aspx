<%@ Page Title="Point of Sale" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Index.aspx.cs"
    Inherits="PortableKiosk.UI.POS.Index" %>

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
                        CssClass="h-16 w-full rounded-md border border-slate-300 bg-white px-4 text-center text-3xl font-semibold tabular-nums tracking-widest text-slate-950 placeholder:text-slate-400 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                    <div class="mt-5 grid grid-cols-3 gap-3 [&_button]:min-h-14 [&_button]:rounded-md [&_button]:border [&_button]:border-slate-200 [&_button]:bg-white [&_button]:text-xl [&_button]:font-semibold [&_button]:text-slate-800 [&_button:hover]:bg-slate-100 [&_button:focus-visible]:outline-2 [&_button:focus-visible]:outline-blue-700">
                        <button type="button" data-pos-order-key="1">1</button><button type="button" data-pos-order-key="2">2</button><button type="button" data-pos-order-key="3">3</button>
                        <button type="button" data-pos-order-key="4">4</button><button type="button" data-pos-order-key="5">5</button><button type="button" data-pos-order-key="6">6</button>
                        <button type="button" data-pos-order-key="7">7</button><button type="button" data-pos-order-key="8">8</button><button type="button" data-pos-order-key="9">9</button>
                        <button type="button" data-pos-order-key="clear" class="text-base">Clear</button><button type="button" data-pos-order-key="0">0</button><button type="button" data-pos-order-key="back" class="text-base">Delete</button>
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
                    <asp:Button ID="btnChooseCash" runat="server" OnClick="btnChooseCash_Click" Text="Cash" CssClass="min-h-32 cursor-pointer rounded-xl border border-slate-200 bg-white p-6 text-xl font-semibold text-slate-950 shadow-sm hover:border-blue-400 hover:bg-blue-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                    <asp:Button ID="btnChooseCashless" runat="server" OnClick="btnChooseCashless_Click" Text="Cashless (mock QR)" CssClass="min-h-32 cursor-pointer rounded-xl border border-slate-200 bg-white p-6 text-xl font-semibold text-slate-950 shadow-sm hover:border-blue-400 hover:bg-blue-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
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
            <main class="grid min-h-dvh w-full gap-4 px-3 py-4 sm:px-5 sm:py-5 lg:h-dvh lg:min-h-0 lg:grid-cols-[minmax(0,2fr)_minmax(0,3fr)] lg:overflow-hidden">
                    <section aria-labelledby="paymentSummaryHeading" class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6 lg:grid lg:min-h-0 lg:grid-rows-[auto_minmax(0,1fr)_auto] lg:overflow-hidden">
                        <div class="border-b border-slate-200 pb-4">
                            <h2 id="paymentSummaryHeading" class="text-lg font-semibold text-slate-950">Order summary</h2>
                            <p class="mt-1 text-sm text-slate-600"><asp:Literal ID="litPaymentContext" runat="server" /></p>
                        </div>
                        <div class="mt-5 divide-y divide-slate-100 lg:mt-0 lg:min-h-0 lg:overflow-y-auto lg:pt-4">
                            <asp:Repeater ID="rptPaymentItems" runat="server"><ItemTemplate>
                                <div class="flex items-start justify-between gap-4 py-3 text-sm">
                                    <span class="text-slate-700"><strong class="font-medium text-slate-950"><%# Eval("Quantity") %> × <%#: Eval("ProductName") %></strong><br /><span class="text-xs"><%#: Eval("DisplaySize") %></span></span>
                                    <strong class="shrink-0 font-semibold tabular-nums text-slate-950"><%# FormatMoney(Eval("LineTotal")) %></strong>
                                </div>
                            </ItemTemplate></asp:Repeater>
                        </div>
                        <div class="mt-4 flex items-baseline justify-between border-t border-slate-200 pt-5 lg:mt-0">
                            <span class="font-medium text-slate-700">Total due</span>
                            <strong class="text-2xl font-semibold tabular-nums text-slate-950"><asp:Literal ID="litPaymentTotal" runat="server" /></strong>
                        </div>
                    </section>
                    <section aria-labelledby="cashKeypadHeading" class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6 lg:min-h-0 lg:overflow-y-auto">
                        <h2 id="cashKeypadHeading" class="text-lg font-semibold text-slate-950">Cash received</h2>
                        <p id="posTenderedHint" class="mt-1 text-xs text-slate-600" aria-live="polite">Enter the amount handed to you.</p>
                        <label for="txtTendered" class="mt-4 block text-sm font-medium text-slate-700">Amount tendered</label>
                        <asp:TextBox ID="txtTendered" runat="server" ClientIDMode="Static" inputmode="decimal" autocomplete="off"
                            placeholder="0.00" MaxLength="11"
                            CssClass="mt-2 h-14 w-full rounded-md border border-slate-300 bg-white px-4 text-right text-2xl font-semibold tabular-nums text-slate-950 placeholder:text-slate-400 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                        <div class="mt-4 grid grid-cols-[minmax(76px,0.9fr)_repeat(3,minmax(0,1fr))] gap-2">
                            <div role="group" aria-label="Quick cash amounts" class="grid content-start gap-2 [&_button]:min-h-9 [&_button]:rounded-md [&_button]:border [&_button]:border-blue-200 [&_button]:bg-blue-50 [&_button]:px-1 [&_button]:text-xs [&_button]:font-semibold [&_button]:text-blue-900 [&_button:hover]:bg-blue-100 [&_button:focus-visible]:outline-2 [&_button:focus-visible]:outline-blue-700">
                                <button type="button" data-pos-cash-quick="10">₱10</button>
                                <button type="button" data-pos-cash-quick="20">₱20</button>
                                <button type="button" data-pos-cash-quick="50">₱50</button>
                                <button type="button" data-pos-cash-quick="100">₱100</button>
                                <button type="button" data-pos-cash-quick="500">₱500</button>
                                <button type="button" data-pos-cash-quick="1000">₱1,000</button>
                                <button type="button" data-pos-cash-quick="exact" aria-label="Set exact amount due" class="text-[11px]">Exact amount</button>
                            </div>
                            <div class="col-span-3 grid grid-cols-3 content-start gap-x-2 gap-y-1 [&_button]:min-h-[72px] [&_button]:rounded-md [&_button]:border [&_button]:border-slate-200 [&_button]:bg-white [&_button]:text-lg [&_button]:font-semibold [&_button]:text-slate-800 [&_button:hover]:bg-slate-100 [&_button:focus-visible]:outline-2 [&_button:focus-visible]:outline-blue-700">
                                <button type="button" data-pos-cash-key="1">1</button><button type="button" data-pos-cash-key="2">2</button><button type="button" data-pos-cash-key="3">3</button>
                                <button type="button" data-pos-cash-key="4">4</button><button type="button" data-pos-cash-key="5">5</button><button type="button" data-pos-cash-key="6">6</button>
                                <button type="button" data-pos-cash-key="7">7</button><button type="button" data-pos-cash-key="8">8</button><button type="button" data-pos-cash-key="9">9</button>
                                <button type="button" data-pos-cash-key="clear">Clear</button><button type="button" data-pos-cash-key="0">0</button><button type="button" data-pos-cash-key=".">.</button>
                            </div>
                        </div>
                        <div class="mt-5 flex items-baseline justify-between border-t border-slate-200 pt-4 text-sm">
                            <span class="font-medium text-slate-700">Change</span>
                            <strong id="posChangePreview" data-total="<%= PaymentTotalValue %>"
                                class="text-lg font-semibold tabular-nums text-slate-950">₱0.00</strong>
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
            <main class="mx-auto max-w-xl px-5 py-10 sm:px-8">
                <div class="text-center">
                    <span class="mx-auto inline-flex size-12 items-center justify-center rounded-full bg-emerald-100 text-emerald-800" aria-hidden="true">
                        <svg class="size-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12 4 4L19 6" /></svg>
                    </span>
                    <h1 class="mt-4 text-2xl font-semibold tracking-tight text-slate-950 sm:text-3xl">Payment complete</h1>
                    <p class="mt-2 text-sm text-slate-600">The order has been sent to the kitchen queue.</p>
                </div>
                <section aria-labelledby="finalReceiptHeading" class="mt-8 rounded-xl border border-slate-200 bg-white p-5 sm:p-7">
                    <div class="flex items-start justify-between gap-4 border-b border-slate-200 pb-5">
                        <div><h2 id="finalReceiptHeading" class="text-lg font-semibold text-slate-950">Receipt</h2>
                            <p class="mt-1 text-sm text-slate-600"><asp:Literal ID="litReceiptDate" runat="server" /></p></div>
                        <strong class="text-lg font-semibold text-slate-950">#<asp:Literal ID="litReceiptNumber" runat="server" /></strong>
                    </div>
                    <p class="mt-4 text-sm text-slate-600"><asp:Literal ID="litReceiptOrderDetails" runat="server" /></p>
                    <div class="mt-5 divide-y divide-slate-100">
                        <asp:Repeater ID="rptReceiptItems" runat="server"><ItemTemplate>
                            <div class="flex items-start justify-between gap-4 py-3 text-sm">
                                <span><strong class="font-medium text-slate-950"><%# Eval("Quantity") %> × <%#: Eval("ProductName") %></strong><br />
                                    <span class="text-xs text-slate-600"><%#: Eval("DisplaySize") %> · <%# FormatMoney(Eval("UnitPrice")) %> each</span></span>
                                <strong class="shrink-0 font-semibold tabular-nums text-slate-950"><%# FormatMoney(Eval("LineTotal")) %></strong>
                            </div>
                        </ItemTemplate></asp:Repeater>
                    </div>
                    <dl class="mt-5 space-y-3 border-t border-slate-200 pt-5 text-sm">
                        <div class="flex justify-between"><dt class="text-slate-600">Total</dt><dd class="font-semibold tabular-nums text-slate-950"><asp:Literal ID="litReceiptTotal" runat="server" /></dd></div>
                        <asp:Panel ID="pnlReceiptCash" runat="server"><div class="flex justify-between"><dt class="text-slate-600">Cash received</dt><dd class="font-medium tabular-nums text-slate-950"><asp:Literal ID="litReceiptTendered" runat="server" /></dd></div>
                        <div class="mt-3 flex justify-between border-t border-slate-200 pt-3"><dt class="font-semibold text-slate-950">Change</dt><dd class="font-semibold tabular-nums text-slate-950"><asp:Literal ID="litReceiptChange" runat="server" /></dd></div></asp:Panel>
                        <asp:Panel ID="pnlReceiptCashless" runat="server" Visible="false"><div class="flex justify-between"><dt class="text-slate-600">Payment method</dt><dd class="font-medium text-slate-950">Cashless (simulated)</dd></div></asp:Panel>
                    </dl>
                </section>
                <asp:Button ID="btnCloseReceipt" runat="server" OnClick="btnCloseReceipt_Click" Text="Close and start next sale"
                    CssClass="mt-6 min-h-12 w-full cursor-pointer rounded-lg bg-blue-700 px-4 text-sm font-semibold text-white hover:bg-blue-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
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
    <script src="<%= ResolveUrl("~/Scripts/app/pos/register.js?v=3") %>"></script>
</asp:Content>
