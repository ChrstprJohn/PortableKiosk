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
    <main class="@container/cart relative mx-auto flex min-h-dvh w-full flex-col px-[clamp(0.75rem,3.5cqw,4rem)] pb-[clamp(7rem,15vh,18rem)] pt-[clamp(1.25rem,3.5vh,2.5rem)] kiosk-portrait:px-[clamp(2rem,5vw,6rem)] kiosk-portrait:pt-[clamp(2rem,4vh,5rem)] kiosk-portrait:pb-[clamp(12rem,18vh,30rem)] kiosk-4k:px-[clamp(6rem,3vw,10rem)] kiosk-4k:pt-[clamp(3rem,4vh,6rem)] kiosk-4k:pb-[clamp(20rem,18vh,28rem)] max-[480px]:px-3 max-[480px]:pt-6 max-[480px]:pb-28 text-slate-900" aria-labelledby="cartHeading">
        <header class="mb-[clamp(1rem,3vh,2.5rem)] kiosk-portrait:mb-[clamp(2rem,4vh,6rem)] kiosk-4k:mb-[clamp(3rem,4vh,6rem)] max-[480px]:mb-3 flex w-full items-center gap-[clamp(0.75rem,2cqw,2rem)]">
            <div class="min-w-0">
                <h1 id="cartHeading" class="m-0 text-[clamp(2rem,5vw,4rem)] font-black leading-[1.04] tracking-[-0.05em] text-slate-900 kiosk-portrait:text-[clamp(2.75rem,min(10vw,7vh),12rem)] kiosk-4k:text-[clamp(4rem,min(8vw,8vh),12rem)] kiosk-mobile:text-[clamp(1.65rem,8vw,2.75rem)]">Your cart</h1>
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
            CssClass="mx-auto flex w-full max-w-[min(100%,96rem)] flex-1 flex-col items-center justify-center rounded-[clamp(0.75rem,1.5cqw,1.5rem)] kiosk-portrait:rounded-[clamp(1rem,1.5cqw,2rem)] kiosk-4k:rounded-[clamp(1.5rem,1.5cqw,2.5rem)] max-[480px]:rounded-xl border border-dashed border-slate-300 bg-white px-[clamp(1rem,3cqw,3rem)] kiosk-4k:px-[clamp(3rem,4cqw,6rem)] py-[clamp(1.5rem,6vh,6rem)] kiosk-4k:py-[clamp(4rem,8vh,10rem)] text-center shadow-sm">
            <h2 class="mb-[clamp(0.35rem,1vh,1.25rem)] text-[clamp(1.25rem,2.2cqw,2.75rem)] kiosk-portrait:text-[clamp(1.75rem,3vw,4rem)] kiosk-4k:text-[clamp(2.5rem,3vw,4.5rem)] kiosk-mobile:text-[clamp(1.15rem,5vw,1.5rem)] font-extrabold text-slate-900">Your cart is empty</h2>
            <p class="mb-[clamp(0.75rem,2.5vh,2rem)] text-[clamp(0.95rem,1.2cqw,1.5rem)] kiosk-portrait:text-[clamp(1.125rem,1.8vw,2rem)] kiosk-4k:text-[clamp(1.5rem,1.6vw,2.5rem)] kiosk-mobile:text-[clamp(0.875rem,3.6vw,1rem)] text-slate-600">Choose something from the menu to get started.</p>
            <a runat="server" href="~/UI/User/Menu.aspx" class="inline-flex min-h-[clamp(2.75rem,5.5vh,4rem)] kiosk-portrait:min-h-[clamp(3.5rem,6vh,5.5rem)] kiosk-4k:min-h-[clamp(5rem,6vh,8rem)] kiosk-mobile:min-h-[clamp(2.75rem,10vw,3.125rem)] items-center justify-center rounded-[clamp(0.5rem,1.2cqw,1rem)] max-[480px]:rounded-lg bg-[linear-gradient(135deg,#f59e0b,#d97706)] px-[clamp(0.75rem,2cqw,2rem)] kiosk-4k:px-[clamp(2rem,2vw,3.5rem)] py-[clamp(0.5rem,1.5vh,1rem)] text-[clamp(0.9rem,1.2cqw,1.5rem)] kiosk-portrait:text-[clamp(1rem,1.7vw,1.75rem)] kiosk-4k:text-[clamp(1.5rem,1.6vw,2.25rem)] kiosk-mobile:text-[clamp(0.8rem,3.4vw,1rem)] font-extrabold text-white no-underline shadow-[0_4px_14px_rgba(217,119,6,0.35)] transition hover:brightness-105 focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/40">Browse menu</a>
        </asp:Panel>

        <asp:Panel ID="pnlCart" runat="server" CssClass="flex flex-1 flex-col">
            <div class="grid content-start gap-[clamp(0.6rem,1.2cqw,1.5rem)] max-[480px]:gap-2.5">
                <asp:Repeater
                    ID="rptCartItems"
                    runat="server"
                    OnItemCommand="rptCartItems_ItemCommand">
                    <ItemTemplate>
                        <article class="flex flex-col min-[640px]:flex-row min-[640px]:items-center justify-between gap-[clamp(0.65rem,1.6cqw,2rem)] kiosk-portrait:gap-[clamp(1.5rem,3vw,4rem)] kiosk-4k:gap-[clamp(2.5rem,3vw,5rem)] rounded-[clamp(0.75rem,1.25cqw,1.5rem)] kiosk-portrait:rounded-[clamp(1rem,1.5cqw,2rem)] kiosk-4k:rounded-[clamp(1.5rem,1.5cqw,2.5rem)] max-[480px]:rounded-xl border border-slate-200 bg-white p-[clamp(0.65rem,1.4cqw,1.75rem)] kiosk-portrait:p-[clamp(1.25rem,2.4cqw,3.5rem)] kiosk-4k:p-[clamp(2rem,2.4cqw,3.5rem)] kiosk-mobile:p-[clamp(0.625rem,3vw,0.85rem)] shadow-[0_2px_8px_rgba(15,23,42,0.05)] transition-all">
                            <!-- Left Section: Image + Info -->
                            <div class="flex items-center gap-[clamp(0.75rem,2cqw,3rem)] kiosk-portrait:gap-[clamp(1rem,2.4cqw,3rem)] kiosk-4k:gap-[clamp(2rem,2.4cqw,3rem)] min-w-0 flex-1">
                                <!-- Image -->
                                <div class="relative flex aspect-square h-[clamp(3.25rem,5cqw,7rem)] w-[clamp(3.25rem,5cqw,7rem)] kiosk-portrait:h-[clamp(6rem,12cqw,18rem)] kiosk-portrait:w-[clamp(6rem,12cqw,18rem)] kiosk-4k:h-[clamp(8rem,10cqw,18rem)] kiosk-4k:w-[clamp(8rem,10cqw,18rem)] kiosk-mobile:h-[clamp(3rem,15vw,4.5rem)] kiosk-mobile:w-[clamp(3rem,15vw,4.5rem)] shrink-0 items-center justify-center overflow-hidden rounded-[clamp(0.5rem,0.9cqw,1rem)] max-[480px]:rounded-lg bg-slate-100">
                                    <asp:PlaceHolder
                                        runat="server"
                                        Visible='<%# HasImage(Eval("ImagePath")) %>'>
                                        <img
                                            class="h-full w-full object-cover"
                                            src='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                            alt='<%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("ProductName"))) %>' />
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder
                                        runat="server"
                                        Visible='<%# !HasImage(Eval("ImagePath")) %>'>
                                        <span class="inline-flex h-full w-full items-center justify-center bg-amber-50 text-[clamp(1.1rem,2.2cqw,2.25rem)] kiosk-portrait:text-[clamp(2rem,5vw,5rem)] kiosk-4k:text-[clamp(2.5rem,4vw,5rem)] kiosk-mobile:text-[clamp(1rem,6vw,1.75rem)] font-black text-amber-600" aria-hidden="true">PK</span>
                                    </asp:PlaceHolder>
                                </div>

                                <!-- Product Info -->
                                <div class="min-w-0 flex-1">
                                    <h2 class="m-0 mb-[clamp(0.15rem,0.35vh,0.5rem)] break-words text-[clamp(1rem,1.8cqw,2rem)] kiosk-portrait:text-[clamp(1.5rem,3vw,5rem)] kiosk-4k:text-[clamp(2rem,2.6vw,4.5rem)] kiosk-mobile:text-[clamp(0.9rem,4vw,1.1rem)] font-extrabold leading-snug text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("ProductName"))) %></h2>
                                    <p class="m-0 mb-[clamp(0.15rem,0.35vh,0.5rem)] text-[clamp(0.85rem,1.2cqw,1.25rem)] kiosk-portrait:text-[clamp(1.125rem,2vw,2.5rem)] kiosk-4k:text-[clamp(1.375rem,1.6vw,2.75rem)] kiosk-mobile:text-[clamp(0.75rem,3.2vw,0.95rem)] font-semibold text-slate-500"><%# Server.HtmlEncode(Convert.ToString(Eval("DisplaySize"))) %></p>
                                    <span class="text-[clamp(0.75rem,1.05cqw,1.125rem)] kiosk-portrait:text-[clamp(1rem,1.7vw,2.125rem)] kiosk-4k:text-[clamp(1.25rem,1.3vw,2rem)] kiosk-mobile:text-[clamp(0.6875rem,2.8vw,0.875rem)] text-slate-500 font-medium"><%# FormatMoney(Eval("UnitPrice")) %> each</span>
                                </div>
                            </div>

                            <!-- Right Section: Top Row (Stepper + Price), Bottom Row (Remove Button) -->
                            <div class="flex flex-col items-end gap-[clamp(0.4rem,0.9vh,1rem)] kiosk-portrait:gap-[clamp(0.75rem,1.5vh,2rem)] kiosk-4k:gap-[clamp(1.5rem,1.5vh,2.5rem)] shrink-0 max-[639px]:pt-2 max-[639px]:border-t max-[639px]:border-slate-100 max-[639px]:w-full">
                                <!-- Top Row: Stepper and Price -->
                                <div class="flex items-center justify-between min-[640px]:justify-end gap-[clamp(0.75rem,1.5cqw,1.5rem)] w-full min-[640px]:w-auto">
                                    <!-- Stepper -->
                                    <div class="quantity-control inline-flex items-center overflow-hidden rounded-[clamp(0.4rem,1.4cqw,2.5rem)] max-[480px]:rounded-lg border border-slate-200 bg-white shadow-sm">
                                        <asp:LinkButton ID="btnDecrease" runat="server"
                                            CssClass="flex h-[clamp(2.5rem,5.2vh,5rem)] w-[clamp(2rem,3.5cqw,3rem)] kiosk-portrait:h-[clamp(3.5rem,5.5vh,6rem)] kiosk-portrait:w-[clamp(3rem,4cqw,5rem)] kiosk-4k:h-[clamp(5rem,5.5vh,9rem)] kiosk-4k:w-[clamp(4rem,4.2cqw,7rem)] kiosk-mobile:h-[clamp(2.125rem,8vw,2.75rem)] kiosk-mobile:w-[clamp(1.75rem,8vw,2.25rem)] items-center justify-center bg-slate-100 text-[clamp(1rem,1.5cqw,1.25rem)] kiosk-portrait:text-[clamp(1.25rem,2.3vw,2rem)] kiosk-4k:text-[clamp(1.5rem,1.5vw,2.5rem)] kiosk-mobile:text-[clamp(0.85rem,3.6vw,1.05rem)] font-bold text-slate-700 no-underline transition-colors hover:bg-slate-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-amber-500"
                                            CommandName="DecreaseQuantity"
                                            CommandArgument='<%# Eval("ProductVariantID") %>'
                                            CausesValidation="false"
                                            aria-label="Decrease quantity">−</asp:LinkButton>

                                        <span class="flex h-[clamp(2.5rem,5.2vh,5rem)] min-w-[clamp(2.25rem,3.5cqw,3rem)] kiosk-portrait:h-[clamp(3.5rem,5.5vh,6rem)] kiosk-portrait:min-w-[clamp(3.25rem,4cqw,5.5rem)] kiosk-4k:h-[clamp(5rem,5.5vh,9rem)] kiosk-4k:min-w-[clamp(4rem,4.2cqw,7rem)] kiosk-mobile:h-[clamp(2.125rem,8vw,2.75rem)] kiosk-mobile:min-w-[clamp(2rem,8.5vw,2.375rem)] items-center justify-center border-x border-slate-200 bg-white px-2 text-center text-[clamp(0.875rem,1.35cqw,1.25rem)] kiosk-portrait:text-[clamp(1.125rem,2vw,1.75rem)] kiosk-4k:text-[clamp(1.5rem,1.5vw,2.5rem)] kiosk-mobile:text-[clamp(0.85rem,3.6vw,1.05rem)] font-bold text-slate-900">
                                            <%# Eval("Quantity") %>
                                        </span>

                                        <asp:LinkButton ID="btnIncrease" runat="server"
                                            CssClass="flex h-[clamp(2.5rem,5.2vh,5rem)] w-[clamp(2rem,3.5cqw,3rem)] kiosk-portrait:h-[clamp(3.5rem,5.5vh,6rem)] kiosk-portrait:w-[clamp(3rem,4cqw,5rem)] kiosk-4k:h-[clamp(5rem,5.5vh,9rem)] kiosk-4k:w-[clamp(4rem,4.2cqw,7rem)] kiosk-mobile:h-[clamp(2.125rem,8vw,2.75rem)] kiosk-mobile:w-[clamp(1.75rem,8vw,2.25rem)] items-center justify-center bg-slate-100 text-[clamp(1rem,1.5cqw,1.25rem)] kiosk-portrait:text-[clamp(1.25rem,2.3vw,2rem)] kiosk-4k:text-[clamp(1.5rem,1.5vw,2.5rem)] kiosk-mobile:text-[clamp(0.85rem,3.6vw,1.05rem)] font-bold text-slate-700 no-underline transition-colors hover:bg-slate-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-amber-500"
                                            CommandName="IncreaseQuantity"
                                            CommandArgument='<%# Eval("ProductVariantID") %>'
                                            CausesValidation="false"
                                            aria-label="Increase quantity">+</asp:LinkButton>
                                    </div>

                                    <!-- Total Price -->
                                    <strong class="whitespace-nowrap text-[clamp(1rem,1.8cqw,2.25rem)] kiosk-portrait:text-[clamp(1.5rem,3vw,3.25rem)] kiosk-4k:text-[clamp(2.25rem,3vw,4.5rem)] kiosk-mobile:text-[clamp(0.95rem,4vw,1.15rem)] font-black text-slate-900 tracking-tight">
                                        <%# FormatMoney(Eval("LineTotal")) %>
                                    </strong>
                                </div>

                                <!-- Bottom Row: Remove Button -->
                                <div class="flex justify-end w-full">
                                    <asp:LinkButton
                                        ID="btnRemoveItem"
                                        runat="server"
                                        CssClass="inline-flex min-h-[clamp(2.25rem,4vh,3rem)] kiosk-portrait:min-h-[clamp(3rem,4.5vh,4.5rem)] kiosk-4k:min-h-[clamp(4rem,4.5vh,6rem)] kiosk-mobile:min-h-[clamp(2rem,7vw,2.4rem)] items-center justify-center rounded-[clamp(0.4rem,0.8cqw,0.75rem)] max-[480px]:rounded-md border border-slate-200 bg-white px-[clamp(0.6rem,1.25cqw,1.25rem)] kiosk-4k:px-[clamp(1.5rem,1.25cqw,2.5rem)] max-[480px]:px-2.5 py-[clamp(0.2rem,0.5vh,0.5rem)] text-[clamp(0.75rem,1cqw,1rem)] kiosk-portrait:text-[clamp(1rem,1.5vw,1.5rem)] kiosk-4k:text-[clamp(1.25rem,1.2vw,1.75rem)] kiosk-mobile:text-[clamp(0.75rem,3vw,0.875rem)] font-bold text-red-600 no-underline shadow-sm transition-colors hover:border-red-200 hover:bg-red-50 focus-visible:outline focus-visible:outline-2 focus-visible:outline-red-500/30"
                                        CommandName="RemoveItem"
                                        CommandArgument='<%# Eval("ProductVariantID") %>'
                                        CausesValidation="false">
                                        Remove
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <footer class="fixed inset-x-0 bottom-0 z-[1040] border-t border-slate-200 bg-white/95 px-[clamp(0.75rem,3.5cqw,4rem)] pb-[max(clamp(0.65rem,1.5vh,1.5rem),env(safe-area-inset-bottom))] pt-[clamp(0.65rem,1.5vh,1.5rem)] kiosk-portrait:px-[clamp(2rem,5vw,6rem)] kiosk-portrait:pt-[clamp(1rem,2vh,2.5rem)] kiosk-portrait:pb-[max(clamp(1rem,2vh,2.5rem),env(safe-area-inset-bottom))] kiosk-4k:px-[clamp(6rem,3vw,10rem)] kiosk-4k:pt-[clamp(2rem,2vh,4rem)] kiosk-4k:pb-[max(clamp(2rem,2vh,4rem),env(safe-area-inset-bottom))] max-[480px]:px-3 max-[480px]:py-2 shadow-[0_-8px_24px_rgba(15,23,42,0.08)] backdrop-blur-[16px]" aria-label="Cart total and actions">
                <div class="mx-auto grid w-full max-w-none gap-[clamp(0.5rem,1.1cqw,1.25rem)] kiosk-portrait:gap-[clamp(0.75rem,1.5cqw,1.5rem)] kiosk-4k:gap-[clamp(1.5rem,1.5cqw,2rem)] max-[480px]:gap-2">
                    <div class="flex items-baseline justify-end gap-[clamp(0.5rem,1.2cqw,1.5rem)] pr-[clamp(0.25rem,0.75cqw,0.75rem)]">
                        <span class="text-[clamp(0.875rem,1.1cqw,1.25rem)] kiosk-portrait:text-[clamp(1.125rem,1.6vw,1.75rem)] kiosk-4k:text-[clamp(1.5rem,1.6vw,2.25rem)] kiosk-mobile:text-[clamp(0.75rem,3.1vw,0.95rem)] font-bold text-slate-700">Total</span>
                        <strong class="whitespace-nowrap text-[clamp(1.2rem,2cqw,2.25rem)] kiosk-portrait:text-[clamp(1.75rem,3.8vw,4.5rem)] kiosk-4k:text-[clamp(2.5rem,3vw,4.5rem)] kiosk-mobile:text-[clamp(1.125rem,4.5vw,1.375rem)] font-black tracking-tight text-amber-800"><asp:Literal ID="litTotalAmount" runat="server" /></strong>
                    </div>
                    <div class="grid grid-cols-[0.9fr_1.6fr] gap-[clamp(0.35rem,1cqw,1rem)] max-[480px]:gap-2">
                        <a runat="server" href="~/UI/User/Menu.aspx" class="inline-flex min-h-[clamp(2.75rem,5.5vh,4rem)] kiosk-portrait:min-h-[clamp(3.5rem,6vh,5.5rem)] kiosk-4k:min-h-[clamp(5rem,6vh,8rem)] kiosk-mobile:min-h-[clamp(2.75rem,10vw,3.125rem)] items-center justify-center rounded-[clamp(0.5rem,1cqw,1rem)] max-[480px]:rounded-lg border border-slate-300 bg-white px-[clamp(0.5rem,1.25cqw,1.25rem)] kiosk-portrait:px-[clamp(1rem,2vw,2rem)] kiosk-4k:px-[clamp(2rem,2vw,3.5rem)] max-[480px]:px-2.5 text-center text-[clamp(0.85rem,1.2cqw,1.25rem)] kiosk-portrait:text-[clamp(1rem,1.7vw,1.75rem)] kiosk-4k:text-[clamp(1.5rem,1.6vw,2.25rem)] kiosk-mobile:text-[clamp(0.72rem,3vw,0.9rem)] font-extrabold text-slate-700 no-underline shadow-sm transition hover:border-slate-400 hover:bg-slate-50 focus-visible:outline focus-visible:outline-4 focus-visible:outline-slate-500/20">Order more</a>
                        <asp:Button
                            ID="btnProceedToCheckout"
                            runat="server"
                            Text="Proceed to checkout"
                            CssClass="inline-flex min-h-[clamp(2.75rem,5.5vh,4rem)] kiosk-portrait:min-h-[clamp(3.5rem,6vh,5.5rem)] kiosk-4k:min-h-[clamp(5rem,6vh,8rem)] kiosk-mobile:min-h-[clamp(2.75rem,10vw,3.125rem)] w-full cursor-pointer items-center justify-center rounded-[clamp(0.5rem,1cqw,1rem)] max-[480px]:rounded-lg bg-[linear-gradient(135deg,#f59e0b,#d97706)] px-[clamp(0.5rem,1.25cqw,1.25rem)] kiosk-portrait:px-[clamp(1rem,2vw,2rem)] kiosk-4k:px-[clamp(2rem,2vw,3.5rem)] max-[480px]:px-2.5 text-center text-[clamp(0.85rem,1.2cqw,1.25rem)] kiosk-portrait:text-[clamp(1rem,1.7vw,1.75rem)] kiosk-4k:text-[clamp(1.5rem,1.6vw,2.25rem)] kiosk-mobile:text-[clamp(0.72rem,3vw,0.9rem)] font-extrabold text-white shadow-[0_4px_14px_rgba(217,119,6,0.35)] transition hover:brightness-105 focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/40"
                            OnClick="btnProceedToCheckout_Click" />
                    </div>
                </div>
            </footer>
        </asp:Panel>
    </main>
</asp:Content>
