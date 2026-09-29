<%@ Page Title="Order Status" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OrderStatus.aspx.cs" Inherits="PortableKiosk.UI.OrderStatus" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <meta http-equiv="refresh" content="10" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/css/order-status.css") %>" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="order-status-board">
        <header class="order-status-header">
            <h1>Order status</h1>
            <span>Updates every 10 seconds</span>
        </header>
        <asp:Label ID="lblError" runat="server" Visible="false" EnableViewState="false" CssClass="order-status-error" role="alert" />
        <div class="order-status-columns">
            <section class="order-status-column" aria-labelledby="preparingHeading">
                <h2 id="preparingHeading">Preparing</h2>
                <div class="order-status-numbers">
                    <asp:Repeater ID="rptPreparing" runat="server"><ItemTemplate><div class="order-status-number"><%#: Eval("OrderNumberDisplay") %></div></ItemTemplate></asp:Repeater>
                    <asp:PlaceHolder ID="emptyPreparing" runat="server"><p class="order-status-empty">No orders preparing</p></asp:PlaceHolder>
                </div>
            </section>
            <section class="order-status-column" aria-labelledby="servingHeading">
                <h2 id="servingHeading">Serving</h2>
                <div class="order-status-numbers">
                    <asp:Repeater ID="rptServing" runat="server"><ItemTemplate><div class="order-status-number"><%#: Eval("OrderNumberDisplay") %></div></ItemTemplate></asp:Repeater>
                    <asp:PlaceHolder ID="emptyServing" runat="server"><p class="order-status-empty">No orders serving</p></asp:PlaceHolder>
                </div>
            </section>
        </div>
    </main>
</asp:Content>
