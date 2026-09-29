<%@ Page Title="Order Status" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OrderStatus.aspx.cs" Inherits="PortableKiosk.UI.OrderStatus" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <meta http-equiv="refresh" content="10" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/css/order-status.css") %>" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="order-status-board">
        <asp:Label ID="lblError" runat="server" Visible="false" EnableViewState="false" CssClass="order-status-error" role="alert" />
        <div class="order-status-columns">
            <section class="order-status-column" aria-labelledby="preparingHeading">
                <h2 id="preparingHeading">Now Preparing</h2>
                <div class="order-status-numbers">
                    <asp:Repeater ID="rptPreparing" runat="server"><ItemTemplate><div class="order-status-number"><%#: Eval("OrderNumberDisplay") %></div></ItemTemplate></asp:Repeater>
                    <asp:PlaceHolder ID="emptyPreparing" runat="server"><p class="order-status-empty">No orders preparing</p></asp:PlaceHolder>
                </div>
            </section>
            <section class="order-status-column" aria-labelledby="servingHeading">
                <h2 id="servingHeading">Now Serving</h2>
                <div class="order-status-numbers">
                    <asp:Repeater ID="rptServing" runat="server"><ItemTemplate><div class="order-status-number"><%#: Eval("OrderNumberDisplay") %></div></ItemTemplate></asp:Repeater>
                    <asp:PlaceHolder ID="emptyServing" runat="server"><p class="order-status-empty">No orders serving</p></asp:PlaceHolder>
                </div>
            </section>
            <aside class="order-status-image" aria-label="Welcome illustration">
                <img src="<%= ResolveUrl("~/Content/images/order-status-mascot.png") %>" alt="Straight from the kitchen: smiling stick figure holding fries" />
            </aside>
        </div>
        <footer class="order-status-greeting">Welcome and thank you for waiting!</footer>
    </main>
</asp:Content>
