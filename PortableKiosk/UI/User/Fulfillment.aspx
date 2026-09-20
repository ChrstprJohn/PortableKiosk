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
        <header>
            <p class="kiosk-eyebrow">Almost finished</p>
            <h1 id="fulfillmentHeading">How would you like to get your order?</h1>
            <p><asp:Literal ID="litFulfillmentHint" runat="server" /></p>
        </header>

        <div class="fulfillment-options">
            <asp:Panel ID="pnlTableService" runat="server">
                <asp:LinkButton
                    ID="btnTableService"
                    runat="server"
                    CssClass="fulfillment-option"
                    OnClick="btnTableService_Click">
                    <strong>Bring it to my table or locator</strong>
                    <span>Enter the number printed on your locator.</span>
                </asp:LinkButton>
            </asp:Panel>

            <asp:LinkButton
                ID="btnCounterPickup"
                runat="server"
                CssClass="fulfillment-option"
                OnClick="btnCounterPickup_Click">
                <strong>Pick up at the counter</strong>
                <span>Wait for your order number to be called.</span>
            </asp:LinkButton>
        </div>

        <a runat="server" href="~/UI/User/Payment.aspx" class="kiosk-button">Back to payment</a>
    </main>
</asp:Content>
