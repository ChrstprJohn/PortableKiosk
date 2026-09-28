<%@ Page
    Title="Pay online"
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
        <section class="online-payment-panel">
            <h1 id="onlinePaymentHeading">Scan to pay</h1>
            <div class="payment-qr-frame">
                <svg class="payment-qr" viewBox="0 0 25 25" role="img" aria-label="Example payment QR code" shape-rendering="crispEdges" xmlns="http://www.w3.org/2000/svg">
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
                </svg>
            </div>
            <strong class="online-payment-total"><asp:Literal ID="litPaymentTotal" runat="server" /></strong>

        </section>
    </main>
    <footer class="kiosk-flow-footer kiosk-cta-footer"><div class="kiosk-flow-footer-inner kiosk-cta-footer-inner">
        <a runat="server" href="~/UI/User/Payment.aspx" class="kiosk-cta-button kiosk-cta-button-secondary kiosk-flow-back">Back</a>
        <asp:Button ID="btnConfirmMockPayment" runat="server" Text="Simulate Success"
            CssClass="kiosk-cta-button kiosk-cta-button-primary kiosk-flow-primary"
            OnClick="btnConfirmMockPayment_Click" />
    </div></footer>
</asp:Content>
