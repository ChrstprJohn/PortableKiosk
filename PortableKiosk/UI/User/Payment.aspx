<%@ Page
    Title="Payment"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/User.Master"
    AutoEventWireup="true"
    CodeBehind="Payment.aspx.cs"
    Inherits="PortableKiosk.UI.User.Payment" %>

<asp:Content
    ID="PaymentContent"
    ContentPlaceHolderID="UserContent"
    runat="server">
    <main class="payment-placeholder-page" aria-labelledby="paymentHeading">
        <header>
            <p class="kiosk-eyebrow">Checkout preview</p>
            <h1 id="paymentHeading">How would you like to pay?</h1>
            <p>Choose a payment method to continue.</p>
        </header>

        <div class="payment-placeholder-options">
            <asp:LinkButton
                ID="btnCashless"
                runat="server"
                CssClass="payment-option"
                OnClick="btnCashless_Click">
                <strong>Pay online</strong>
                <span>Cashless processing will be connected later.</span>
            </asp:LinkButton>

            <asp:LinkButton
                ID="btnCashCounter"
                runat="server"
                CssClass="payment-option"
                OnClick="btnCashCounter_Click">
                <strong>Cash at the counter</strong>
                <span>Receive an order number and pay at the counter.</span>
            </asp:LinkButton>
        </div>

        <div class="payment-placeholder-total">
            <span>Current total</span>
            <strong><asp:Literal ID="litCheckoutTotal" runat="server" /></strong>
        </div>

        <a runat="server" href="~/UI/User/Cart.aspx" class="kiosk-button">Back to cart</a>
        <p class="payment-placeholder-note">
            This screen records the selected option only. No payment is
            processed in this phase.
        </p>
    </main>
</asp:Content>
