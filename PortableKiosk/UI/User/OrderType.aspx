<%@ Page
    Title="Choose order type"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/User.Master"
    AutoEventWireup="true"
    CodeBehind="OrderType.aspx.cs"
    Inherits="PortableKiosk.UI.User.OrderType" %>

<asp:Content
    ID="OrderTypeContent"
    ContentPlaceHolderID="UserContent"
    runat="server">
    <main class="order-type-page" aria-labelledby="orderTypeHeading">
        <section class="order-type-intro">
            <p class="kiosk-eyebrow">Start your order</p>
            <h1 id="orderTypeHeading">Where will you enjoy your meal?</h1>
            <p>Choose one option to continue to the menu.</p>
        </section>

        <div class="order-type-options">
            <asp:Button
                ID="btnDineIn"
                runat="server"
                Text="Dine in"
                CssClass="order-type-card order-type-card-primary"
                OnClick="btnDineIn_Click" />

            <asp:Button
                ID="btnTakeout"
                runat="server"
                Text="Takeout"
                CssClass="order-type-card"
                OnClick="btnTakeout_Click" />
        </div>
    </main>
</asp:Content>
