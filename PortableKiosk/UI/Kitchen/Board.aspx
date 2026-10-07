<%@ Page Title="Kitchen Board" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Board.aspx.cs" Inherits="PortableKiosk.UI.Kitchen.Board" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <meta http-equiv="refresh" content="20" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/css/kitchen-board.css") %>?v=5" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="kitchen-board">
        <div class="kitchen-toolbar">
            <h1>Kitchen</h1>
            <details id="kitchenProfile" class="kitchen-profile">
                <summary class="kitchen-profile-trigger" aria-label="Profile menu">
                    <span class="kitchen-avatar" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="3.25" /><path d="M5.5 20a6.5 6.5 0 0 1 13 0" /></svg></span>
                    <span class="kitchen-profile-name"><%: ProfileName %></span>
                    <svg class="kitchen-chevron" aria-hidden="true" viewBox="0 0 20 20"><path d="m5 7.5 5 5 5-5" /></svg>
                </summary>
                <div class="kitchen-profile-menu">
                    <a runat="server" href="~/UI/Account/AdminLogin.aspx"><svg aria-hidden="true" viewBox="0 0 24 24"><path d="m12 5-7 7 7 7M5 12h14" /></svg>Choose workspace</a>
                    <a runat="server" href="~/UI/Account/SignOut.aspx"><svg aria-hidden="true" viewBox="0 0 24 24"><path d="M10 17l5-5-5-5m5 5H3" /><path d="M12 3h5a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-5" /></svg>Sign out</a>
                </div>
            </details>
        </div>
        <asp:Label ID="lblError" runat="server" EnableViewState="false" Visible="false" CssClass="kitchen-error" role="alert" />
        <div class="kitchen-columns">
            <section class="kitchen-column" aria-labelledby="queuedHeading">
                <h2 id="queuedHeading" class="kitchen-column-heading">Queued <span class="kitchen-count"><asp:Literal ID="litQueuedCount" runat="server" /></span></h2>
                <div class="kitchen-card-list"><asp:Repeater ID="rptQueued" runat="server" OnItemDataBound="StatusItemDataBound"><ItemTemplate>
                    <details class="kitchen-card kitchen-collapsible-card" data-order-id='<%# Eval("OrderID") %>'>
                    <summary class="kitchen-card-summary">
                        <span class="kitchen-card-info"><strong class="kitchen-order-number"><%#: Eval("OrderNumberDisplay") %></strong><small class="kitchen-time">Ordered at <%#: Eval("TimeDisplay") %></small><small class="kitchen-time">Paid at <%#: Eval("PaidTimeDisplay") %></small></span>
                        <span class="kitchen-card-toggle"><span class='<%# Eval("OrderTypeClass") %>'><%#: Eval("OrderTypeDisplay") %></span><span class="kitchen-card-hint">Details <svg class="kitchen-chevron" aria-hidden="true" viewBox="0 0 20 20"><path d="m5 7.5 5 5 5-5" /></svg></span></span>
                    </summary>
                    <div class="kitchen-card-content">
                    <p class="kitchen-fulfillment"><%#: Eval("FulfillmentDisplay") %></p>
                    <ul class="kitchen-items"><asp:Repeater runat="server" DataSource='<%# Eval("Items") %>'><ItemTemplate><li class="kitchen-item"><asp:Image runat="server" Visible='<%# HasImage(Eval("ImagePath")) %>' ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>' AlternateText="" CssClass="kitchen-item-image" /><span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>' class="kitchen-item-placeholder" aria-hidden="true"></span><span class="kitchen-item-copy"><strong><%#: Eval("Quantity") %> × <%#: Eval("ProductName") %></strong><small><%#: Eval("DisplaySize") %></small></span></li></ItemTemplate></asp:Repeater></ul>
                    <div class="kitchen-status-row"><span class="kitchen-status-label">Status</span><asp:HiddenField ID="hidOrderID" runat="server" Value='<%# Eval("OrderID") %>' /><asp:HiddenField ID="hidCurrentStatus" runat="server" Value='<%# Eval("KitchenStatus") %>' /><asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="StatusChanged" CssClass="kitchen-status" aria-label='<%# "Status for order " + Eval("OrderNumberDisplay") %>'><asp:ListItem Text="Queued" Value="QUEUED" /><asp:ListItem Text="Preparing" Value="PREPARING" /><asp:ListItem Text="Serving" Value="SERVING" /></asp:DropDownList></div>
                    </div>
                </details>
                </ItemTemplate></asp:Repeater><asp:PlaceHolder ID="emptyQueued" runat="server"><p class="kitchen-empty">No orders</p></asp:PlaceHolder></div>
            </section>
            <section class="kitchen-column" aria-labelledby="preparingHeading">
                <h2 id="preparingHeading" class="kitchen-column-heading">Preparing <span class="kitchen-count"><asp:Literal ID="litPreparingCount" runat="server" /></span></h2>
                <div class="kitchen-card-list"><asp:Repeater ID="rptPreparing" runat="server" OnItemDataBound="StatusItemDataBound"><ItemTemplate>
                    <details class="kitchen-card kitchen-collapsible-card" data-order-id='<%# Eval("OrderID") %>'>
                    <summary class="kitchen-card-summary">
                        <span class="kitchen-card-info"><strong class="kitchen-order-number"><%#: Eval("OrderNumberDisplay") %></strong><small class="kitchen-time">Ordered at <%#: Eval("TimeDisplay") %></small><small class="kitchen-time">Paid at <%#: Eval("PaidTimeDisplay") %></small></span>
                        <span class="kitchen-card-toggle"><span class='<%# Eval("OrderTypeClass") %>'><%#: Eval("OrderTypeDisplay") %></span><span class="kitchen-card-hint">Details <svg class="kitchen-chevron" aria-hidden="true" viewBox="0 0 20 20"><path d="m5 7.5 5 5 5-5" /></svg></span></span>
                    </summary>
                    <div class="kitchen-card-content">
                    <p class="kitchen-fulfillment"><%#: Eval("FulfillmentDisplay") %></p>
                    <ul class="kitchen-items"><asp:Repeater runat="server" DataSource='<%# Eval("Items") %>'><ItemTemplate><li class="kitchen-item"><asp:Image runat="server" Visible='<%# HasImage(Eval("ImagePath")) %>' ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>' AlternateText="" CssClass="kitchen-item-image" /><span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>' class="kitchen-item-placeholder" aria-hidden="true"></span><span class="kitchen-item-copy"><strong><%#: Eval("Quantity") %> × <%#: Eval("ProductName") %></strong><small><%#: Eval("DisplaySize") %></small></span></li></ItemTemplate></asp:Repeater></ul>
                    <div class="kitchen-status-row"><span class="kitchen-status-label">Status</span><asp:HiddenField ID="hidOrderID" runat="server" Value='<%# Eval("OrderID") %>' /><asp:HiddenField ID="hidCurrentStatus" runat="server" Value='<%# Eval("KitchenStatus") %>' /><asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="StatusChanged" CssClass="kitchen-status" aria-label='<%# "Status for order " + Eval("OrderNumberDisplay") %>'><asp:ListItem Text="Queued" Value="QUEUED" /><asp:ListItem Text="Preparing" Value="PREPARING" /><asp:ListItem Text="Serving" Value="SERVING" /></asp:DropDownList></div>
                    </div>
                </details>
                </ItemTemplate></asp:Repeater><asp:PlaceHolder ID="emptyPreparing" runat="server"><p class="kitchen-empty">No orders</p></asp:PlaceHolder></div>
            </section>
            <section class="kitchen-column" aria-labelledby="servingHeading">
                <h2 id="servingHeading" class="kitchen-column-heading">Serving <span class="kitchen-count"><asp:Literal ID="litServingCount" runat="server" /></span></h2>
                <div class="kitchen-card-list"><asp:Repeater ID="rptServing" runat="server" OnItemDataBound="StatusItemDataBound"><ItemTemplate>
                    <details class="kitchen-card kitchen-collapsible-card" data-order-id='<%# Eval("OrderID") %>'>
                    <summary class="kitchen-card-summary">
                        <span class="kitchen-card-info"><strong class="kitchen-order-number"><%#: Eval("OrderNumberDisplay") %></strong><small class="kitchen-time">Ordered at <%#: Eval("TimeDisplay") %></small><small class="kitchen-time">Paid at <%#: Eval("PaidTimeDisplay") %></small></span>
                        <span class="kitchen-card-toggle"><span class='<%# Eval("OrderTypeClass") %>'><%#: Eval("OrderTypeDisplay") %></span><span class="kitchen-card-hint">Details <svg class="kitchen-chevron" aria-hidden="true" viewBox="0 0 20 20"><path d="m5 7.5 5 5 5-5" /></svg></span></span>
                    </summary>
                    <div class="kitchen-card-content">
                    <p class="kitchen-fulfillment"><%#: Eval("FulfillmentDisplay") %></p>
                    <ul class="kitchen-items"><asp:Repeater runat="server" DataSource='<%# Eval("Items") %>'><ItemTemplate><li class="kitchen-item"><asp:Image runat="server" Visible='<%# HasImage(Eval("ImagePath")) %>' ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>' AlternateText="" CssClass="kitchen-item-image" /><span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>' class="kitchen-item-placeholder" aria-hidden="true"></span><span class="kitchen-item-copy"><strong><%#: Eval("Quantity") %> × <%#: Eval("ProductName") %></strong><small><%#: Eval("DisplaySize") %></small></span></li></ItemTemplate></asp:Repeater></ul>
                    <div class="kitchen-status-row"><span class="kitchen-status-label">Status</span><asp:HiddenField ID="hidOrderID" runat="server" Value='<%# Eval("OrderID") %>' /><asp:HiddenField ID="hidCurrentStatus" runat="server" Value='<%# Eval("KitchenStatus") %>' /><asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="StatusChanged" CssClass="kitchen-status" aria-label='<%# "Status for order " + Eval("OrderNumberDisplay") %>'><asp:ListItem Text="Queued" Value="QUEUED" /><asp:ListItem Text="Preparing" Value="PREPARING" /><asp:ListItem Text="Serving" Value="SERVING" /></asp:DropDownList></div>
                    </div>
                </details>
                </ItemTemplate></asp:Repeater><asp:PlaceHolder ID="emptyServing" runat="server"><p class="kitchen-empty">No orders</p></asp:PlaceHolder></div>
            </section>
            <section class="kitchen-column" aria-labelledby="completedHeading">
                <h2 id="completedHeading" class="kitchen-column-heading">Completed <span class="kitchen-count"><asp:Literal ID="litCompletedCount" runat="server" /></span></h2>
                <div class="kitchen-card-list"><asp:Repeater ID="rptCompleted" runat="server" OnItemDataBound="StatusItemDataBound"><ItemTemplate>
                <details class="kitchen-card kitchen-collapsible-card" data-order-id='<%# Eval("OrderID") %>'>
                    <summary class="kitchen-card-summary">
                        <span class="kitchen-card-info"><strong class="kitchen-order-number"><%#: Eval("OrderNumberDisplay") %></strong><small class="kitchen-time">Ordered at <%#: Eval("TimeDisplay") %></small><small class="kitchen-time">Paid at <%#: Eval("PaidTimeDisplay") %></small></span>
                        <span class="kitchen-card-toggle"><span class='<%# Eval("OrderTypeClass") %>'><%#: Eval("OrderTypeDisplay") %></span><span class="kitchen-card-hint">Details <svg class="kitchen-chevron" aria-hidden="true" viewBox="0 0 20 20"><path d="m5 7.5 5 5 5-5" /></svg></span></span>
                    </summary>
                    <div class="kitchen-card-content">
                    <p class="kitchen-fulfillment"><%#: Eval("FulfillmentDisplay") %></p>
                    <ul class="kitchen-items"><asp:Repeater runat="server" DataSource='<%# Eval("Items") %>'><ItemTemplate><li class="kitchen-item"><asp:Image runat="server" Visible='<%# HasImage(Eval("ImagePath")) %>' ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>' AlternateText="" CssClass="kitchen-item-image" /><span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>' class="kitchen-item-placeholder" aria-hidden="true"></span><span class="kitchen-item-copy"><strong><%#: Eval("Quantity") %> × <%#: Eval("ProductName") %></strong><small><%#: Eval("DisplaySize") %></small></span></li></ItemTemplate></asp:Repeater></ul>
                    <div class="kitchen-status-row"><span class="kitchen-status-label">Status</span><asp:HiddenField ID="hidOrderID" runat="server" Value='<%# Eval("OrderID") %>' /><asp:HiddenField ID="hidCurrentStatus" runat="server" Value='<%# Eval("KitchenStatus") %>' /><asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="StatusChanged" CssClass="kitchen-status" aria-label='<%# "Status for order " + Eval("OrderNumberDisplay") %>'><asp:ListItem Text="Queued" Value="QUEUED" /><asp:ListItem Text="Preparing" Value="PREPARING" /><asp:ListItem Text="Serving" Value="SERVING" /></asp:DropDownList></div>
                    </div>
                </details>
                </ItemTemplate></asp:Repeater><asp:PlaceHolder ID="emptyCompleted" runat="server"><p class="kitchen-empty">No completed orders yet</p></asp:PlaceHolder></div>
            </section>
        </div>
    </main>

</asp:Content>

<asp:Content ID="ScriptsContent" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src="<%= ResolveUrl("~/Scripts/app/kitchen/board.js") %>?v=3"></script>
</asp:Content>
