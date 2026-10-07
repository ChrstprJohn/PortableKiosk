<%@ Page Title="Welcome" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PortableKiosk._Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/css/welcome-hero.css") %>?v=2" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="kiosk-attract-page" aria-labelledby="welcomeHeading">
        <picture class="kiosk-attract-art" aria-hidden="true">
            <source media="(min-aspect-ratio: 6/5)" srcset="<%= ResolveUrl("~/Content/images/hero/kiosk-hero-desktop.webp") %>" type="image/webp" width="1536" height="1024" />
            <img src="<%= ResolveUrl("~/Content/images/hero/kiosk-hero-mobile.webp") %>" alt="" width="1024" height="1536" fetchpriority="high" decoding="async" />
        </picture>

        <header class="kiosk-attract-brand">
            <img src="<%= ResolveUrl("~/Content/images/portable-kiosk-logo.png") %>" alt="" width="48" height="48" />
            <span>Portable Kiosk</span>
        </header>

        <div class="kiosk-attract-content">
            <div class="kiosk-attract-copy">
                <h1 id="welcomeHeading">Welcome to<br />Portable Kiosk.</h1>
                <p>Choose your meal to get started.</p>
            </div>

            <div class="kiosk-attract-actions">
                <asp:Panel ID="pnlUnavailable" runat="server" Visible="false" CssClass="kiosk-attract-unavailable" role="status">
                    <h2>Kiosk temporarily unavailable</h2>
                    <p>Please place your order with a crew member at the counter.</p>
                </asp:Panel>
                <asp:Button
                    ID="btnStartOrder"
                    runat="server"
                    Text="Start order"
                    CssClass="kiosk-start-order"
                    OnClick="btnStartOrder_Click" />
            </div>
        </div>
    </main>
</asp:Content>
