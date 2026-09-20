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
    <main class="cart-page" aria-labelledby="cartHeading">
        <header class="cart-heading">
            <div>
                <p class="kiosk-eyebrow">Review your order</p>
                <h1 id="cartHeading">Your cart</h1>
            </div>
            <a runat="server" href="~/UI/User/Menu.aspx" class="kiosk-button">Order more</a>
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
            CssClass="cart-empty-state">
            <h2>Your cart is empty</h2>
            <p>Choose something from the menu to get started.</p>
            <a runat="server" href="~/UI/User/Menu.aspx" class="kiosk-button kiosk-button-primary">Browse menu</a>
        </asp:Panel>

        <asp:Panel ID="pnlCart" runat="server">
            <div class="cart-items">
                <asp:Repeater
                    ID="rptCartItems"
                    runat="server"
                    OnItemCommand="rptCartItems_ItemCommand">
                    <ItemTemplate>
                        <article class="cart-item">
                            <div class="cart-item-media">
                                <asp:PlaceHolder
                                    runat="server"
                                    Visible='<%# HasImage(Eval("ImagePath")) %>'>
                                    <img
                                        src='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                        alt='<%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("ProductName"))) %>' />
                                </asp:PlaceHolder>
                                <asp:PlaceHolder
                                    runat="server"
                                    Visible='<%# !HasImage(Eval("ImagePath")) %>'>
                                    <span class="product-image-placeholder" aria-hidden="true">PK</span>
                                </asp:PlaceHolder>
                            </div>

                            <div class="cart-item-details">
                                <h2><%# Server.HtmlEncode(Convert.ToString(Eval("ProductName"))) %></h2>
                                <p><%# Server.HtmlEncode(Convert.ToString(Eval("DisplaySize"))) %></p>
                                <span><%# FormatMoney(Eval("UnitPrice")) %> each</span>
                            </div>

                            <div class="cart-item-quantity">
                                <label for='<%# "quantity-" + Eval("ProductVariantID") %>'>Quantity</label>
                                <asp:TextBox
                                    ID="txtItemQuantity"
                                    runat="server"
                                    Text='<%# Eval("Quantity") %>'
                                    TextMode="Number"
                                    min="1"
                                    max="99"
                                    inputmode="numeric" />
                                <asp:LinkButton
                                    ID="btnUpdateQuantity"
                                    runat="server"
                                    CssClass="cart-text-action"
                                    CommandName="UpdateQuantity"
                                    CommandArgument='<%# Eval("ProductVariantID") %>'>
                                    Update
                                </asp:LinkButton>
                            </div>

                            <div class="cart-item-total">
                                <strong><%# FormatMoney(Eval("LineTotal")) %></strong>
                                <asp:LinkButton
                                    ID="btnRemoveItem"
                                    runat="server"
                                    CssClass="cart-remove-action"
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

            <aside class="cart-summary" aria-label="Order total">
                <div>
                    <span>Items</span>
                    <strong><asp:Literal ID="litTotalQuantity" runat="server" /></strong>
                </div>
                <div class="cart-summary-total">
                    <span>Total</span>
                    <strong><asp:Literal ID="litTotalAmount" runat="server" /></strong>
                </div>
                <asp:Button
                    ID="btnProceedToCheckout"
                    runat="server"
                    Text="Proceed to checkout"
                    CssClass="kiosk-button kiosk-button-primary kiosk-button-block"
                    OnClick="btnProceedToCheckout_Click" />
            </aside>
        </asp:Panel>
    </main>
</asp:Content>
