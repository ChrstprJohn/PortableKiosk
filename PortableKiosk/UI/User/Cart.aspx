<%@ Page
    Title="Your cart"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/User.Master"
    AutoEventWireup="true"
    CodeBehind="Cart.aspx.cs"
    Inherits="PortableKiosk.UI.User.CartPage" %>

<asp:Content
    ID="CartContent"
    ContentPlaceHolderID="UserContent"
    runat="server">
    <main class="cart-fluid @container/cart relative mx-auto flex min-h-dvh w-full flex-col px-[clamp(0.75rem,3.5cqw,4rem)] pb-[clamp(10rem,22vh,26rem)] pt-[clamp(1.25rem,3.5vh,2.5rem)] kiosk-portrait:px-[clamp(2rem,5vw,6rem)] kiosk-portrait:pt-[clamp(2rem,4vh,5rem)] kiosk-portrait:pb-[clamp(16rem,24vh,34rem)] kiosk-4k:px-[clamp(6rem,3vw,10rem)] kiosk-4k:pt-[clamp(3rem,4vh,6rem)] kiosk-4k:pb-[clamp(24rem,24vh,36rem)] max-[480px]:px-3.5 max-[480px]:pt-5 max-[480px]:pb-40 text-slate-900" aria-labelledby="cartHeading">
        <header class="cart-fluid-header mb-[clamp(1.25rem,3.5vh,3rem)] kiosk-portrait:mb-[clamp(2rem,4vh,6rem)] kiosk-4k:mb-[clamp(3rem,4vh,6rem)] max-[480px]:mb-4 flex w-full items-center justify-between gap-[clamp(0.75rem,2cqw,2rem)]">
            <div class="min-w-0">
                <h1 id="cartHeading" class="cart-fluid-heading m-0 font-black leading-[1.04] tracking-[-0.05em] text-slate-900">Your cart</h1>

            </div>
        </header>

        <asp:Label
            ID="lblCartMessage"
            runat="server"
            Visible="false"
            CssClass="kiosk-alert kiosk-alert-error"
            role="alert" />

        <asp:Panel
            ID="pnlEmptyCart"
            runat="server"
            Visible="false"
            CssClass="cart-fluid-empty mx-auto flex w-full max-w-[min(100%,96rem)] flex-1 flex-col items-center justify-center rounded-[clamp(1rem,2cqw,2rem)] kiosk-portrait:rounded-[clamp(1.5rem,2cqw,3rem)] kiosk-4k:rounded-[clamp(2rem,2cqw,4rem)] max-[480px]:rounded-2xl border-2 border-dashed border-slate-300 bg-white px-[clamp(1.5rem,4cqw,4rem)] kiosk-4k:px-[clamp(4rem,5cqw,8rem)] py-[clamp(2.5rem,8vh,8rem)] kiosk-4k:py-[clamp(5rem,10vh,12rem)] text-center shadow-sm">
            <div class="cart-fluid-empty-icon mb-[clamp(1rem,2vh,2rem)] flex size-[clamp(4rem,8cqw,8rem)] kiosk-portrait:size-[clamp(6rem,12vw,10rem)] kiosk-4k:size-[clamp(8rem,10vw,14rem)] items-center justify-center rounded-full bg-amber-50 border border-amber-200/80 text-amber-600">
                <svg class="h-1/2 w-1/2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
                    <line x1="3" y1="6" x2="21" y2="6"></line>
                    <path d="M16 10a4 4 0 0 1-8 0"></path>
                </svg>
            </div>
            <h2 class="cart-fluid-empty-heading mb-[clamp(0.5rem,1vh,1.25rem)] text-[clamp(1.35rem,2.5cqw,3rem)] kiosk-portrait:text-[clamp(1.85rem,3.5vw,4.5rem)] kiosk-4k:text-[clamp(2.75rem,3.2vw,5rem)] kiosk-mobile:text-[clamp(1.2rem,5vw,1.6rem)] font-black tracking-tight text-slate-900">Your cart is empty</h2>
            <p class="cart-fluid-empty-copy mb-[clamp(1.25rem,3vh,2.5rem)] max-w-md text-[clamp(0.95rem,1.3cqw,1.5rem)] kiosk-portrait:text-[clamp(1.15rem,2vw,2.25rem)] kiosk-4k:text-[clamp(1.6rem,1.8vw,2.75rem)] kiosk-mobile:text-[clamp(0.875rem,3.8vw,1.05rem)] font-medium text-slate-500">Choose your favorite meals and drinks from the menu to get started.</p>
            <a runat="server" href="~/UI/User/Menu.aspx" class="cart-fluid-action-button inline-flex min-h-[clamp(3.25rem,6.8vh,5.5rem)] kiosk-portrait:min-h-[clamp(4.25rem,7.5vh,7rem)] kiosk-4k:min-h-[clamp(6.5rem,8.5vh,11rem)] kiosk-mobile:min-h-[3.25rem] items-center justify-center rounded-[clamp(0.65rem,1.4cqw,1.5rem)] max-[480px]:rounded-xl bg-[linear-gradient(135deg,#f59e0b,#d97706)] px-[clamp(1.5rem,3.5cqw,4rem)] kiosk-4k:px-[clamp(3.5rem,3vw,6rem)] py-[clamp(0.75rem,1.8vh,1.5rem)] text-[clamp(1.05rem,1.6cqw,1.75rem)] kiosk-portrait:text-[clamp(1.35rem,2.4vw,2.5rem)] kiosk-4k:text-[clamp(2rem,2.2vw,3.25rem)] kiosk-mobile:text-sm font-black text-white no-underline shadow-[0_6px_20px_rgba(217,119,6,0.38)] transition-all hover:brightness-105 hover:shadow-[0_8px_25px_rgba(217,119,6,0.48)] active:scale-[0.99] focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/40">Browse menu</a>
        </asp:Panel>

        <asp:Panel ID="pnlCart" runat="server" CssClass="flex flex-1 flex-col">
            <div class="cart-fluid-items grid content-start gap-[clamp(0.75rem,1.5cqw,1.75rem)] max-[480px]:gap-3">
                <asp:Repeater
                    ID="rptCartItems"
                    runat="server"
                    OnItemCommand="rptCartItems_ItemCommand">
                    <ItemTemplate>
                        <article class="cart-fluid-item group relative flex flex-col sm:flex-row sm:items-center justify-between gap-[clamp(0.85rem,2cqw,2.25rem)] kiosk-portrait:gap-[clamp(1.5rem,3vw,4rem)] kiosk-4k:gap-[clamp(2.5rem,3vw,5rem)] rounded-[clamp(0.875rem,1.5cqw,1.75rem)] kiosk-portrait:rounded-[clamp(1.25rem,2cqw,2.5rem)] kiosk-4k:rounded-[clamp(1.75rem,2cqw,3rem)] max-[480px]:rounded-2xl border border-slate-200/90 bg-white p-[clamp(0.85rem,2cqw,2rem)] kiosk-portrait:p-[clamp(1.5rem,2.8cqw,4rem)] kiosk-4k:p-[clamp(2.5rem,2.8cqw,4.5rem)] kiosk-mobile:p-3.5 shadow-[0_4px_16px_rgba(15,23,42,0.04)] transition-all hover:border-amber-300/80 hover:shadow-[0_8px_24px_rgba(15,23,42,0.07)]">
                            <!-- Left Section: Image + Info -->
                            <div class="cart-fluid-item-info flex items-center gap-[clamp(0.85rem,2.2cqw,3rem)] kiosk-portrait:gap-[clamp(1.25rem,2.5cqw,3.5rem)] kiosk-4k:gap-[clamp(2rem,2.5cqw,4rem)] min-w-0 flex-1">
                                <!-- Image -->
                                <div class="cart-fluid-image relative flex aspect-square h-[clamp(4.25rem,7.5cqw,8.5rem)] w-[clamp(4.25rem,7.5cqw,8.5rem)] kiosk-portrait:h-[clamp(6.5rem,13cqw,18rem)] kiosk-portrait:w-[clamp(6.5rem,13cqw,18rem)] kiosk-4k:h-[clamp(9rem,11cqw,20rem)] kiosk-4k:w-[clamp(9rem,11cqw,20rem)] kiosk-mobile:h-[clamp(3.75rem,18vw,5rem)] kiosk-mobile:w-[clamp(3.75rem,18vw,5rem)] shrink-0 items-center justify-center overflow-hidden rounded-[clamp(0.65rem,1.2cqw,1.25rem)] max-[480px]:rounded-xl border border-slate-100 bg-slate-50 shadow-inner">
                                    <asp:PlaceHolder
                                        runat="server"
                                        Visible='<%# HasImage(Eval("ImagePath")) %>'>
                                        <img
                                            class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                                            src='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                            alt='<%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("ProductName"))) %>' />
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder
                                        runat="server"
                                        Visible='<%# !HasImage(Eval("ImagePath")) %>'>
                                        <span class="inline-flex h-full w-full items-center justify-center bg-gradient-to-br from-amber-50 to-amber-100 text-[clamp(1.35rem,2.5cqw,2.75rem)] kiosk-portrait:text-[clamp(2.25rem,5vw,5.5rem)] kiosk-4k:text-[clamp(3rem,4vw,6rem)] kiosk-mobile:text-[clamp(1.25rem,7vw,2rem)] font-black text-amber-600" aria-hidden="true">PK</span>
                                    </asp:PlaceHolder>
                                </div>

                                <!-- Product Info -->
                                <div class="cart-fluid-product min-w-0 flex-1 flex flex-col justify-center gap-1">
                                    <h2 class="cart-fluid-product-name m-0 break-words text-[clamp(1.05rem,2cqw,2.25rem)] kiosk-portrait:text-[clamp(1.6rem,3.2vw,5.5rem)] kiosk-4k:text-[clamp(2.25rem,2.8vw,5rem)] kiosk-mobile:text-[clamp(0.95rem,4.2vw,1.2rem)] font-extrabold leading-snug tracking-tight text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("ProductName"))) %></h2>
                                    <div class="flex flex-wrap items-center gap-2 pt-0.5">
                                        <span class="cart-fluid-variant inline-flex items-center rounded-md bg-amber-50/90 border border-amber-200/80 px-2 py-0.5 text-[clamp(0.75rem,1.1cqw,1.2rem)] kiosk-portrait:text-[clamp(1rem,1.8vw,2.25rem)] kiosk-4k:text-[clamp(1.25rem,1.4vw,2.25rem)] kiosk-mobile:text-[clamp(0.7rem,3vw,0.85rem)] font-bold text-amber-900">
                                            <%# Server.HtmlEncode(Convert.ToString(Eval("DisplaySize"))) %>
                                        </span>
                                        <span class="cart-fluid-detail text-[clamp(0.8rem,1.1cqw,1.2rem)] kiosk-portrait:text-[clamp(1rem,1.7vw,2.125rem)] kiosk-4k:text-[clamp(1.25rem,1.3vw,2rem)] kiosk-mobile:text-[clamp(0.72rem,3vw,0.875rem)] text-slate-500 font-medium">
                                            <%# FormatMoney(Eval("UnitPrice")) %> each
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <!-- Right Section: Stepper + Price + Remove Button -->
                            <div class="cart-fluid-controls flex sm:flex-col items-center sm:items-end justify-between sm:justify-center gap-[clamp(0.6rem,1.2vh,1.25rem)] kiosk-portrait:gap-[clamp(1rem,1.8vh,2.5rem)] kiosk-4k:gap-[clamp(1.75rem,2vh,3rem)] shrink-0 pt-3 sm:pt-0 border-t border-slate-100 sm:border-t-0 w-full sm:w-auto">
                                <div class="flex items-center gap-[clamp(0.85rem,1.8cqw,2rem)]">
                                    <!-- Stepper -->
                                    <div class="cart-fluid-stepper quantity-control inline-flex items-center overflow-hidden rounded-[clamp(0.5rem,1.2cqw,1.75rem)] max-[480px]:rounded-xl border border-slate-200 bg-slate-50 shadow-sm">
                                        <asp:LinkButton ID="btnDecrease" runat="server"
                                            CssClass="flex h-[clamp(2.5rem,5.2vh,4.75rem)] w-[clamp(2.25rem,3.8cqw,4rem)] kiosk-portrait:h-[clamp(3.5rem,5.5vh,6rem)] kiosk-portrait:w-[clamp(3.25rem,4.2cqw,5.5rem)] kiosk-4k:h-[clamp(5rem,5.5vh,9rem)] kiosk-4k:w-[clamp(4.5rem,4.5cqw,7.5rem)] kiosk-mobile:h-[2.35rem] kiosk-mobile:w-[2rem] items-center justify-center bg-white text-[clamp(1.1rem,1.6cqw,1.5rem)] kiosk-portrait:text-[clamp(1.35rem,2.4vw,2.25rem)] kiosk-4k:text-[clamp(1.75rem,1.6vw,2.75rem)] kiosk-mobile:text-sm font-black text-slate-700 no-underline transition-colors hover:bg-amber-50 hover:text-amber-800 active:scale-95 focus-visible:outline focus-visible:outline-2 focus-visible:outline-amber-500"
                                            CommandName="DecreaseQuantity"
                                            CommandArgument='<%# Eval("ProductVariantID") %>'
                                            CausesValidation="false"
                                            aria-label="Decrease quantity">−</asp:LinkButton>

                                        <span class="flex h-[clamp(2.5rem,5.2vh,4.75rem)] min-w-[clamp(2.5rem,3.8cqw,4rem)] kiosk-portrait:h-[clamp(3.5rem,5.5vh,6rem)] kiosk-portrait:min-w-[clamp(3.5rem,4.2cqw,5.5rem)] kiosk-4k:h-[clamp(5rem,5.5vh,9rem)] kiosk-4k:min-w-[clamp(4.5rem,4.5cqw,7.5rem)] kiosk-mobile:h-[2.35rem] kiosk-mobile:min-w-[2.25rem] items-center justify-center border-x border-slate-200 bg-white px-2 text-center text-[clamp(0.95rem,1.4cqw,1.4rem)] kiosk-portrait:text-[clamp(1.25rem,2.2vw,2rem)] kiosk-4k:text-[clamp(1.6rem,1.6vw,2.75rem)] kiosk-mobile:text-sm font-extrabold text-slate-900 select-none">
                                            <%# Eval("Quantity") %>
                                        </span>

                                        <asp:LinkButton ID="btnIncrease" runat="server"
                                            CssClass="flex h-[clamp(2.5rem,5.2vh,4.75rem)] w-[clamp(2.25rem,3.8cqw,4rem)] kiosk-portrait:h-[clamp(3.5rem,5.5vh,6rem)] kiosk-portrait:w-[clamp(3.25rem,4.2cqw,5.5rem)] kiosk-4k:h-[clamp(5rem,5.5vh,9rem)] kiosk-4k:w-[clamp(4.5rem,4.5cqw,7.5rem)] kiosk-mobile:h-[2.35rem] kiosk-mobile:w-[2rem] items-center justify-center bg-white text-[clamp(1.1rem,1.6cqw,1.5rem)] kiosk-portrait:text-[clamp(1.35rem,2.4vw,2.25rem)] kiosk-4k:text-[clamp(1.75rem,1.6vw,2.75rem)] kiosk-mobile:text-sm font-black text-slate-700 no-underline transition-colors hover:bg-amber-50 hover:text-amber-800 active:scale-95 focus-visible:outline focus-visible:outline-2 focus-visible:outline-amber-500"
                                            CommandName="IncreaseQuantity"
                                            CommandArgument='<%# Eval("ProductVariantID") %>'
                                            CausesValidation="false"
                                            aria-label="Increase quantity">+</asp:LinkButton>
                                    </div>

                                    <!-- Total Price -->
                                    <strong class="cart-fluid-line-total min-w-[4.5rem] text-right whitespace-nowrap text-[clamp(1.15rem,2.2cqw,2.5rem)] kiosk-portrait:text-[clamp(1.65rem,3.2vw,3.5rem)] kiosk-4k:text-[clamp(2.5rem,3.2vw,4.75rem)] kiosk-mobile:text-[clamp(1.05rem,4.5vw,1.3rem)] font-black text-slate-900 tracking-tight">
                                        <%# FormatMoney(Eval("LineTotal")) %>
                                    </strong>
                                </div>

                                <!-- Remove Button -->
                                <div class="flex justify-end">
                                    <asp:LinkButton
                                        ID="btnRemoveItem"
                                        runat="server"
                                        CssClass="cart-fluid-remove inline-flex items-center gap-1.5 rounded-[clamp(0.4rem,0.8cqw,0.75rem)] max-[480px]:rounded-lg border border-transparent bg-transparent px-[clamp(0.5rem,1.2cqw,1.25rem)] py-[clamp(0.3rem,0.6vh,0.6rem)] text-[clamp(0.8rem,1.1cqw,1.1rem)] kiosk-portrait:text-[clamp(1.05rem,1.6vw,1.75rem)] kiosk-4k:text-[clamp(1.35rem,1.3vw,2rem)] kiosk-mobile:text-xs font-bold text-red-600 no-underline transition-all hover:border-red-200 hover:bg-red-50 hover:text-red-700 active:bg-red-100 focus-visible:outline focus-visible:outline-2 focus-visible:outline-red-500/30"
                                        CommandName="RemoveItem"
                                        CommandArgument='<%# Eval("ProductVariantID") %>'
                                        CausesValidation="false">
                                        <svg class="h-[clamp(0.9rem,1.2cqw,1.25rem)] w-[clamp(0.9rem,1.2cqw,1.25rem)] kiosk-portrait:h-5 kiosk-portrait:w-5 kiosk-4k:h-7 kiosk-4k:w-7" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                                        <span>Remove</span>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <footer class="cart-fluid-footer fixed inset-x-0 bottom-0 z-[1040] border-t border-slate-200/90 bg-white/95 px-[clamp(1rem,4cqw,5rem)] pb-[max(clamp(0.85rem,2vh,2rem),env(safe-area-inset-bottom))] pt-[clamp(0.85rem,2vh,2rem)] kiosk-portrait:px-[clamp(2.5rem,6vw,7rem)] kiosk-portrait:pt-[clamp(1.5rem,2.5vh,3.5rem)] kiosk-portrait:pb-[max(clamp(1.5rem,2.5vh,3.5rem),env(safe-area-inset-bottom))] kiosk-4k:px-[clamp(7rem,4vw,12rem)] kiosk-4k:pt-[clamp(2.5rem,3vh,5rem)] kiosk-4k:pb-[max(clamp(2.5rem,3vh,5rem),env(safe-area-inset-bottom))] max-[480px]:px-3.5 max-[480px]:py-3 shadow-[0_-12px_36px_rgba(15,23,42,0.1)] backdrop-blur-[16px]" aria-label="Cart total and actions">
                <div class="cart-fluid-footer-inner mx-auto grid w-full max-w-none gap-[clamp(0.75rem,1.5cqw,1.75rem)] kiosk-portrait:gap-[clamp(1rem,2cqw,2.25rem)] kiosk-4k:gap-[clamp(2rem,2cqw,3rem)] max-[480px]:gap-2.5">
                    <div class="flex items-center justify-between px-1">
                        <span class="cart-fluid-total-label text-[clamp(1rem,1.4cqw,1.5rem)] kiosk-portrait:text-[clamp(1.35rem,2vw,2.25rem)] kiosk-4k:text-[clamp(1.85rem,1.8vw,3rem)] kiosk-mobile:text-sm font-bold text-slate-600">Total amount</span>
                        <strong class="cart-fluid-total whitespace-nowrap text-[clamp(1.5rem,2.8cqw,3.25rem)] kiosk-portrait:text-[clamp(2.25rem,4.5vw,5.5rem)] kiosk-4k:text-[clamp(3.25rem,3.5vw,6rem)] kiosk-mobile:text-[clamp(1.35rem,5.5vw,1.75rem)] font-black tracking-tight text-amber-900"><asp:Literal ID="litTotalAmount" runat="server" /></strong>
                    </div>
                    <div class="cart-fluid-footer-actions grid grid-cols-[1fr_1.8fr] gap-[clamp(0.5rem,1.4cqw,1.5rem)] kiosk-portrait:gap-[clamp(0.75rem,2cqw,2rem)] kiosk-4k:gap-[clamp(1.5rem,2cqw,3rem)] max-[480px]:gap-2.5">
                        <a runat="server" href="~/UI/User/Menu.aspx" class="cart-fluid-action-button inline-flex min-h-[clamp(3.25rem,6.8vh,5.5rem)] kiosk-portrait:min-h-[clamp(4.25rem,7.5vh,7rem)] kiosk-4k:min-h-[clamp(6.5rem,8.5vh,11rem)] kiosk-mobile:min-h-[3.25rem] items-center justify-center rounded-[clamp(0.65rem,1.4cqw,1.5rem)] max-[480px]:rounded-xl border-2 border-slate-300 bg-white px-[clamp(0.75rem,2cqw,2.5rem)] kiosk-portrait:px-[clamp(1.25rem,2.5vw,3rem)] kiosk-4k:px-[clamp(2.5rem,2.5vw,5rem)] max-[480px]:px-3 text-center text-[clamp(1rem,1.5cqw,1.6rem)] kiosk-portrait:text-[clamp(1.25rem,2.2vw,2.25rem)] kiosk-4k:text-[clamp(1.85rem,2vw,3rem)] kiosk-mobile:text-sm font-black text-slate-700 no-underline shadow-sm transition-all hover:border-slate-400 hover:bg-slate-50 hover:text-slate-900 active:scale-[0.99] focus-visible:outline focus-visible:outline-4 focus-visible:outline-slate-500/20">Order more</a>
                        <asp:Button
                            ID="btnProceedToCheckout"
                            runat="server"
                            Text="Proceed to checkout"
                            CssClass="cart-fluid-action-button inline-flex min-h-[clamp(3.25rem,6.8vh,5.5rem)] kiosk-portrait:min-h-[clamp(4.25rem,7.5vh,7rem)] kiosk-4k:min-h-[clamp(6.5rem,8.5vh,11rem)] kiosk-mobile:min-h-[3.25rem] w-full cursor-pointer items-center justify-center rounded-[clamp(0.65rem,1.4cqw,1.5rem)] max-[480px]:rounded-xl bg-[linear-gradient(135deg,#f59e0b,#d97706)] px-[clamp(1rem,2.5cqw,3.5rem)] kiosk-portrait:px-[clamp(1.5rem,3vw,4.5rem)] kiosk-4k:px-[clamp(3rem,3vw,6rem)] max-[480px]:px-3.5 text-center text-[clamp(1.05rem,1.6cqw,1.75rem)] kiosk-portrait:text-[clamp(1.35rem,2.4vw,2.5rem)] kiosk-4k:text-[clamp(2rem,2.2vw,3.25rem)] kiosk-mobile:text-[clamp(0.95rem,3.8vw,1.15rem)] font-black tracking-tight text-white shadow-[0_6px_20px_rgba(217,119,6,0.38)] transition-all hover:brightness-105 hover:shadow-[0_8px_25px_rgba(217,119,6,0.48)] active:scale-[0.99] focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/40"
                            OnClick="btnProceedToCheckout_Click" />
                    </div>
                </div>
            </footer>
        </asp:Panel>
    </main>
</asp:Content>
