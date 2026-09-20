<%@ Page
    Title="Online payment example"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/User.Master"
    AutoEventWireup="true"
    CodeBehind="OnlinePayment.aspx.cs"
    Inherits="PortableKiosk.UI.User.OnlinePayment" %>

<asp:Content
    ID="OnlinePaymentContent"
    ContentPlaceHolderID="UserContent"
    runat="server">
    <main class="online-payment-page" aria-labelledby="onlinePaymentHeading">
        <section class="mock-payment-card">
            <p class="kiosk-eyebrow">Online payment example</p>
            <h1 id="onlinePaymentHeading">Mock cashless payment</h1>
            <p>
                This page represents the future payment-provider screen.
                No card, wallet, or real payment information is collected.
            </p>

            <div class="mock-payment-preview" aria-label="Example payment details">
                <div>
                    <span>Payment amount</span>
                    <strong><asp:Literal ID="litPaymentTotal" runat="server" /></strong>
                </div>
                <div>
                    <span>Example method</span>
                    <strong>Demo cashless payment</strong>
                </div>
            </div>

            <div class="mock-payment-actions">
                <a runat="server" href="~/UI/User/Payment.aspx" class="kiosk-button">Back</a>
                <asp:Button
                    ID="btnConfirmMockPayment"
                    runat="server"
                    Text="Simulate successful payment"
                    CssClass="kiosk-button kiosk-button-primary"
                    OnClick="btnConfirmMockPayment_Click" />
            </div>
        </section>
    </main>
</asp:Content>
