<%@ Page
    Title="Order complete"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/User.Master"
    AutoEventWireup="true"
    CodeBehind="Complete.aspx.cs"
    Inherits="PortableKiosk.UI.User.Complete" %>

<asp:Content
    ID="CompleteContent"
    ContentPlaceHolderID="UserContent"
    runat="server">
    <main class="complete-page" aria-labelledby="completeHeading">
        <section class="receipt-card">
            <p class="kiosk-eyebrow">Order received</p>
            <h1 id="completeHeading">Your order number</h1>
            <div class="receipt-order-number">
                #<asp:Literal ID="litOrderNumber" runat="server" />
            </div>
            <p class="receipt-instruction">
                <asp:Literal ID="litInstruction" runat="server" />
            </p>

            <div class="receipt-meta">
                <div>
                    <span>Order type</span>
                    <strong><asp:Literal ID="litOrderType" runat="server" /></strong>
                </div>
                <div>
                    <span>Payment</span>
                    <strong><asp:Literal ID="litPaymentMethod" runat="server" /></strong>
                </div>
                <asp:Panel ID="pnlTableNumber" runat="server">
                    <span>Locator number</span>
                    <strong><asp:Literal ID="litTableNumber" runat="server" /></strong>
                </asp:Panel>
            </div>

            <div class="receipt-items">
                <asp:Repeater ID="rptReceiptItems" runat="server">
                    <ItemTemplate>
                        <div class="receipt-item">
                            <span>
                                <%# Eval("Quantity") %> ×
                                <%# Server.HtmlEncode(Convert.ToString(Eval("ProductName"))) %>
                                (<%# Server.HtmlEncode(Convert.ToString(Eval("DisplaySize"))) %>)
                            </span>
                            <strong><%# FormatMoney(Eval("LineTotal")) %></strong>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <div class="receipt-total">
                    <span>Total</span>
                    <strong><asp:Literal ID="litReceiptTotal" runat="server" /></strong>
                </div>
            </div>

            <p class="receipt-preview-note">
                Checkout persistence and receipt printing will be connected
                in the next backend phase.
            </p>

            <asp:Button
                ID="btnFinish"
                runat="server"
                Text="Finish"
                CssClass="kiosk-button kiosk-button-primary kiosk-button-block"
                OnClick="btnFinish_Click" />
        </section>
    </main>
</asp:Content>
