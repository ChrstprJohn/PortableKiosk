<%@ Page
    Title="Checkout"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/User.Master"
    AutoEventWireup="true"
    CodeBehind="Payment.aspx.cs"
    Inherits="PortableKiosk.UI.User.Payment" %>

<asp:Content
    ID="PaymentContent"
    ContentPlaceHolderID="UserContent"
    runat="server">
    <main class="payment-choice-page" aria-labelledby="paymentHeading">
        <h1 id="paymentHeading">How would you like<br />to pay?</h1>

        <div class="payment-choice-options">
            <asp:LinkButton
                ID="btnCashless"
                runat="server"
                CssClass="payment-choice-option"
                OnClick="btnCashless_Click">
                <strong>Pay Online (Cashless)</strong>
                <svg class="flow-choice-art" viewBox="0 0 220 180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
                    <rect x="58" y="8" width="104" height="156" rx="17" fill="#334155"/>
                    <rect x="66" y="17" width="88" height="130" rx="9" fill="#e0f2fe"/>
                    <rect x="92" y="153" width="36" height="5" rx="2.5" fill="#cbd5e1"/>
                    <rect x="80" y="30" width="60" height="60" rx="5" fill="#fff"/>
                    <path d="M87 37h16v16H87zM117 37h16v16h-16zM87 67h16v16H87z" fill="#1e293b"/>
                    <path d="M91 41h8v8h-8zM121 41h8v8h-8zM91 71h8v8h-8z" fill="#fff"/>
                    <path d="M107 38h5v8h-5zM109 50h6v6h-6zM118 59h13v5h-13zM108 67h6v6h-6zM119 70h5v13h-5zM128 70h5v6h-5zM108 79h8v5h-8z" fill="#1e293b"/>
                    <rect x="78" y="102" width="64" height="31" rx="8" fill="#fbbf24"/>
                    <path d="m94 117 10 9 21-21" fill="none" stroke="#fff" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            </asp:LinkButton>

            <asp:LinkButton
                ID="btnCashCounter"
                runat="server"
                CssClass="payment-choice-option"
                OnClick="btnCashCounter_Click">
                <strong>Pay at the Counter (Cash)</strong>
                <svg class="flow-choice-art" viewBox="0 0 220 180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
                    <rect x="20" y="45" width="150" height="91" rx="10" fill="#65a30d"/>
                    <rect x="30" y="54" width="150" height="91" rx="10" fill="#a3e635"/>
                    <rect x="39" y="63" width="150" height="91" rx="10" fill="#d9f99d" stroke="#65a30d" stroke-width="4"/>
                    <path d="M49 78c9 0 13-4 13-9M166 69c0 7 5 11 13 11M49 138c9 0 13 4 13 9M166 147c0-7 5-11 13-11" fill="none" stroke="#65a30d" stroke-width="5"/>
                    <circle cx="114" cy="108" r="30" fill="#84cc16"/>
                    <text x="114" y="120" text-anchor="middle" font-size="33" font-weight="800" fill="#fff">₱</text>
                    <circle cx="176" cy="139" r="28" fill="#d97706"/>
                    <circle cx="176" cy="133" r="28" fill="#fbbf24" stroke="#d97706" stroke-width="4"/>
                    <text x="176" y="145" text-anchor="middle" font-size="33" font-weight="800" fill="#fff">₱</text>
                </svg>
            </asp:LinkButton>
        </div>

    </main>
    <footer class="kiosk-flow-footer"><div class="kiosk-flow-footer-inner">
        <a runat="server" href="~/UI/User/Cart.aspx" class="kiosk-button kiosk-flow-back">Back</a>
    </div></footer>
</asp:Content>
