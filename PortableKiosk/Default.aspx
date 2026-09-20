<%@ Page Title="Welcome" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PortableKiosk._Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/Content/css/user-kiosk.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="kiosk-attract-page" aria-label="Welcome to Portable Kiosk">
        <div class="kiosk-attract-hero">
            <img src="<%= ResolveUrl("~/Content/images/kiosk-attract.jpg") %>" alt="Portable Kiosk Menu" class="kiosk-attract-img" />
            <span class="kiosk-attract-logo" aria-label="Portable Kiosk">P</span>
        </div>

        <div class="kiosk-attract-bottom">
            <asp:Button
                ID="btnStartOrder"
                runat="server"
                Text="Start order"
                CssClass="kiosk-attract-start-btn"
                OnClick="btnStartOrder_Click" />
        </div>
    </main>
</asp:Content>
