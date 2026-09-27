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
    <main class="@container/cart relative mx-auto flex min-h-dvh w-full flex-col px-[clamp(0.75rem,3cqw,5rem)] pb-[clamp(9rem,22vh,24rem)] pt-[clamp(1rem,3cqw,4rem)] text-slate-900" aria-labelledby="cartHeading">
        <header class="mb-[clamp(1.25rem,3cqw,4rem)] flex w-full items-end justify-between gap-[clamp(0.75rem,2cqw,3rem)]">
            <div class="min-w-0">
                <p class="mb-[clamp(0.25rem,0.6cqw,0.75rem)] text-[clamp(0.7rem,0.9cqw,1.35rem)] font-extrabold uppercase tracking-[0.12em] text-amber-800">Review your order</p>
                <h1 id="cartHeading" class="m-0 text-[clamp(2rem,3.2cqw,5.5rem)] font-black leading-[1.05] tracking-[-0.04em] text-slate-900">Your cart</h1>
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
            CssClass="mx-auto flex w-full max-w-[72rem] flex-1 flex-col items-center justify-center rounded-[clamp(1rem,2cqw,3rem)] border border-dashed border-slate-300 bg-white px-[clamp(1.25rem,4cqw,6rem)] py-[clamp(2rem,7cqw,8rem)] text-center shadow-sm">
            <h2 class="mb-[clamp(0.35rem,0.8cqw,1rem)] text-[clamp(1.4rem,2.2cqw,3.5rem)] font-extrabold text-slate-900">Your cart is empty</h2>
            <p class="mb-[clamp(1rem,2cqw,3rem)] text-[clamp(0.95rem,1.2cqw,1.8rem)] text-slate-600">Choose something from the menu to get started.</p>
            <a runat="server" href="~/UI/User/Menu.aspx" class="inline-flex min-h-[clamp(2.75rem,5cqw,6rem)] items-center justify-center rounded-[clamp(0.75rem,1.1cqw,1.5rem)] bg-[linear-gradient(135deg,#f59e0b,#d97706)] px-[clamp(1rem,2.5cqw,3rem)] py-[clamp(0.65rem,1.3cqw,1.5rem)] text-[clamp(0.95rem,1.2cqw,1.8rem)] font-extrabold text-white no-underline shadow-[0_4px_14px_rgba(217,119,6,0.35)] transition hover:brightness-105 focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/40">Browse menu</a>
        </asp:Panel>

        <asp:Panel ID="pnlCart" runat="server" CssClass="flex flex-1 flex-col">
            <div class="grid content-start gap-[clamp(0.75rem,1.3cqw,2rem)]">
                <asp:Repeater
                    ID="rptCartItems"
                    runat="server"
                    OnItemCommand="rptCartItems_ItemCommand">
                    <ItemTemplate>
                        <article class="grid grid-cols-2 items-center gap-x-[clamp(0.65rem,1.3cqw,2rem)] gap-y-[clamp(0.65rem,1.2cqw,1.75rem)] rounded-[clamp(0.9rem,1.6cqw,2.5rem)] border border-slate-200 bg-white p-[clamp(0.75rem,1.6cqw,2.5rem)] shadow-[0_2px_8px_rgba(15,23,42,0.06),0_1px_2px_rgba(15,23,42,0.04)] min-[800px]:grid-cols-[clamp(4rem,7cqw,10rem)_minmax(0,1fr)_minmax(7rem,15cqw)_auto]">
                            <div class="col-span-2 flex min-w-0 items-center gap-[clamp(0.65rem,1.3cqw,2rem)] min-[800px]:contents">
                                <div class="flex h-[clamp(3.5rem,8cqw,10rem)] w-[clamp(3.5rem,8cqw,10rem)] shrink-0 items-center justify-center overflow-hidden rounded-[clamp(0.65rem,1cqw,1.5rem)] bg-slate-100">
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
                                        <span class="inline-flex h-full w-full items-center justify-center bg-amber-50 text-[clamp(1rem,2cqw,3rem)] font-black text-amber-600" aria-hidden="true">PK</span>
                                    </asp:PlaceHolder>
                                </div>

                                <div class="min-w-0 flex-1">
                                    <h2 class="mb-[clamp(0.15rem,0.3cqw,0.5rem)] break-words text-[clamp(1rem,1.45cqw,2.25rem)] font-extrabold leading-tight text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("ProductName"))) %></h2>
                                    <p class="mb-[clamp(0.15rem,0.3cqw,0.5rem)] text-[clamp(0.8rem,1cqw,1.5rem)] font-semibold text-slate-500"><%# Server.HtmlEncode(Convert.ToString(Eval("DisplaySize"))) %></p>
                                    <span class="text-[clamp(0.78rem,0.95cqw,1.4rem)] text-slate-600"><%# FormatMoney(Eval("UnitPrice")) %> each</span>
                                </div>
                            </div>

                            <div class="grid min-w-0 content-center justify-items-start gap-[clamp(0.25rem,0.45cqw,0.7rem)]">
                                <asp:Label
                                    runat="server"
                                    AssociatedControlID="txtItemQuantity"
                                    CssClass="text-[clamp(0.65rem,0.75cqw,1.1rem)] font-bold uppercase tracking-[0.06em] text-slate-500"
                                    Text="Quantity" />
                                <asp:TextBox
                                    ID="txtItemQuantity"
                                    runat="server"
                                    Text='<%# Eval("Quantity") %>'
                                    TextMode="Number"
                                    CssClass="min-h-[clamp(2.25rem,3.2cqw,4.5rem)] w-[clamp(4rem,7cqw,9rem)] rounded-[clamp(0.45rem,0.65cqw,0.9rem)] border border-slate-300 bg-white px-2 text-center text-[clamp(0.9rem,1.1cqw,1.65rem)] font-bold text-slate-900 focus:border-amber-500 focus:outline-none focus:ring-2 focus:ring-amber-500/20"
                                    min="1"
                                    max="99"
                                    inputmode="numeric" />
                                <asp:LinkButton
                                    ID="btnUpdateQuantity"
                                    runat="server"
                                    CssClass="text-[clamp(0.72rem,0.85cqw,1.25rem)] font-bold text-amber-700 no-underline hover:underline"
                                    CommandName="UpdateQuantity"
                                    CommandArgument='<%# Eval("ProductVariantID") %>'>
                                    Update
                                </asp:LinkButton>
                            </div>

                            <div class="grid justify-items-end gap-[clamp(0.35rem,0.6cqw,0.9rem)] text-right">
                                <strong class="whitespace-nowrap text-[clamp(1rem,1.5cqw,2.4rem)] font-black text-slate-900"><%# FormatMoney(Eval("LineTotal")) %></strong>
                                <asp:LinkButton
                                    ID="btnRemoveItem"
                                    runat="server"
                                    CssClass="text-[clamp(0.72rem,0.85cqw,1.25rem)] font-bold text-red-600 no-underline hover:underline"
                                    CommandName="RemoveItem"
                                    CommandArgument='<%# Eval("ProductVariantID") %>'
                                    CausesValidation="false">
                                    Remove
                                </asp:LinkButton>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <footer class="fixed inset-x-0 bottom-0 z-[1040] border-t border-slate-200 bg-white/95 px-[clamp(0.75rem,3cqw,4rem)] pb-[max(clamp(0.75rem,2cqw,2.5rem),env(safe-area-inset-bottom))] pt-[clamp(0.7rem,1.6cqw,2rem)] shadow-[0_-8px_24px_rgba(15,23,42,0.08)] backdrop-blur-[16px]" aria-label="Cart total and actions">
                <div class="mx-auto grid w-full max-w-[min(100%,144rem)] gap-[clamp(0.55rem,1.1cqw,1.75rem)]">
                    <div class="flex items-baseline justify-end gap-[clamp(0.8rem,2cqw,3rem)] pr-[clamp(0.25rem,1cqw,1.5rem)]">
                        <span class="text-[clamp(1rem,1.5cqw,2.25rem)] font-bold text-slate-700">Total</span>
                        <strong class="whitespace-nowrap text-[clamp(1.35rem,2.2cqw,3.5rem)] font-black tracking-tight text-amber-800"><asp:Literal ID="litTotalAmount" runat="server" /></strong>
                    </div>
                    <div class="grid grid-cols-[0.9fr_1.6fr] gap-[clamp(0.5rem,1cqw,1.5rem)]">
                        <a runat="server" href="~/UI/User/Menu.aspx" class="inline-flex min-h-[clamp(2.75rem,5cqw,6rem)] items-center justify-center rounded-[clamp(0.75rem,1cqw,1.5rem)] border border-slate-300 bg-white px-[clamp(0.65rem,1.8cqw,2.5rem)] text-center text-[clamp(0.9rem,1.2cqw,1.8rem)] font-extrabold text-slate-700 no-underline shadow-sm transition hover:border-slate-400 hover:bg-slate-50 focus-visible:outline focus-visible:outline-4 focus-visible:outline-slate-500/20">Order more</a>
                        <asp:Button
                            ID="btnProceedToCheckout"
                            runat="server"
                            Text="Proceed to checkout"
                            CssClass="inline-flex min-h-[clamp(2.75rem,5cqw,6rem)] w-full cursor-pointer items-center justify-center rounded-[clamp(0.75rem,1cqw,1.5rem)] bg-[linear-gradient(135deg,#f59e0b,#d97706)] px-[clamp(0.65rem,1.8cqw,2.5rem)] text-center text-[clamp(0.9rem,1.2cqw,1.8rem)] font-extrabold text-white shadow-[0_4px_14px_rgba(217,119,6,0.35)] transition hover:brightness-105 focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/40"
                            OnClick="btnProceedToCheckout_Click" />
                    </div>
                </div>
            </footer>
        </asp:Panel>
    </main>
</asp:Content>
