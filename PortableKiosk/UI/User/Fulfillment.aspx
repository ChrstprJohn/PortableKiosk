<%@ Page
    Title="Get your order"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/User.Master"
    AutoEventWireup="true"
    CodeBehind="Fulfillment.aspx.cs"
    Inherits="PortableKiosk.UI.User.Fulfillment" %>

<asp:Content
    ID="FulfillmentContent"
    ContentPlaceHolderID="UserContent"
    runat="server">
    <main class="fulfillment-page" aria-labelledby="fulfillmentHeading">
        <h1 id="fulfillmentHeading">How would you like to get your order?</h1>

        <asp:Label
            ID="lblFulfillmentError"
            runat="server"
            Visible="false"
            CssClass="kiosk-alert kiosk-alert-error"
            role="alert" />

        <div class="fulfillment-options">
            <asp:LinkButton
                ID="btnTableService"
                runat="server"
                CssClass="fulfillment-option"
                OnClick="btnTableService_Click">
                <strong>Serve to My Table</strong>
                <svg class="flow-choice-art" viewBox="0 0 220 180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
                    <rect x="18" y="55" width="46" height="56" rx="8" fill="#e8c832"/><rect x="12" y="89" width="58" height="14" rx="6" fill="#d4b420"/>
                    <rect x="20" y="102" width="8" height="43" rx="4" fill="#9ca3af"/><rect x="48" y="102" width="8" height="43" rx="4" fill="#9ca3af"/>
                    <rect x="156" y="55" width="46" height="56" rx="8" fill="#e8c832"/><rect x="150" y="89" width="58" height="14" rx="6" fill="#d4b420"/>
                    <rect x="158" y="102" width="8" height="43" rx="4" fill="#9ca3af"/><rect x="186" y="102" width="8" height="43" rx="4" fill="#9ca3af"/>
                    <rect x="62" y="77" width="96" height="18" rx="8" fill="#d1d5db"/><rect x="99" y="94" width="22" height="44" rx="5" fill="#9ca3af"/>
                    <rect x="78" y="135" width="64" height="9" rx="4" fill="#9ca3af"/><rect x="88" y="57" width="15" height="22" rx="4" fill="#60a5fa"/>
                    <rect x="90" y="53" width="11" height="6" rx="3" fill="#93c5fd"/><rect x="110" y="63" width="20" height="16" rx="3" fill="#ef4444"/>
                    <rect x="113" y="47" width="5" height="20" rx="3" fill="#fbbf24"/><rect x="120" y="45" width="5" height="22" rx="3" fill="#fbbf24"/>
                    <rect x="127" y="49" width="5" height="18" rx="3" fill="#fbbf24"/>
                </svg>
            </asp:LinkButton>

            <asp:LinkButton
                ID="btnCounterPickup"
                runat="server"
                CssClass="fulfillment-option"
                OnClick="btnCounterPickup_Click">
                <strong>Pick Up at the Counter</strong>
                <svg class="flow-choice-art" viewBox="0 0 220 180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
                    <rect x="20" y="104" width="180" height="19" rx="6" fill="#d1d5db"/>
                    <rect x="29" y="122" width="162" height="40" rx="5" fill="#94a3b8"/>
                    <rect x="74" y="46" width="72" height="67" rx="5" fill="#d97706"/>
                    <path d="M81 47h58l7 66H74z" fill="#fbbf24"/>
                    <path d="M93 53V35a17 17 0 0 1 34 0v18" fill="none" stroke="#92400e" stroke-width="7" stroke-linecap="round"/>
                    <rect x="94" y="70" width="32" height="30" rx="5" fill="#fff7ed"/>
                    <path d="M99 83h22M103 90h14" stroke="#ef4444" stroke-width="5" stroke-linecap="round"/>
                    <path d="M164 73c0-11 18-11 18 0" fill="none" stroke="#64748b" stroke-width="5"/>
                    <path d="M159 94h28l-5-20h-18z" fill="#facc15"/><circle cx="173" cy="98" r="3" fill="#b45309"/>
                </svg>
            </asp:LinkButton>
        </div>

    </main>
    <footer id="fulfillmentBackFooter" runat="server" class="kiosk-flow-footer kiosk-cta-footer"><div class="kiosk-flow-footer-inner kiosk-cta-footer-inner">
        <a id="lnkBackToPayment" runat="server" href="~/UI/User/Payment.aspx" class="kiosk-cta-button kiosk-cta-button-secondary kiosk-flow-back">Back</a>
    </div></footer>
</asp:Content>
