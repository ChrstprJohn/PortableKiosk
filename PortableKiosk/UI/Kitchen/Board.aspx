<%@ Page Title="Kitchen Board" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Board.aspx.cs" Inherits="PortableKiosk.UI.Kitchen.Board" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/css/kitchen-board.css") %>?v=6" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="kitchen-board">
        <div class="kitchen-toolbar">
            <h1>Kitchen</h1>
            <div class="kitchen-toolbar-actions">
            <details id="kitchenSettings" class="kitchen-settings" <%= CompletedFilter.Error != null ? "open" : string.Empty %>>
                <summary class="kitchen-settings-trigger"><svg aria-hidden="true" viewBox="0 0 24 24"><path d="m9 3-.5 2-2 1-2-.5-2 3.5L4 10v3l-1.5 1L4.5 18l2-.5 2 1 .5 2h4l.5-2 2-1 2 .5 2-3.5-1.5-1v-3l1.5-1-2-3.5-2 .5-2-1-.5-2Z" /><circle cx="11" cy="11.5" r="3" /></svg>Settings</summary>
                <div class="kitchen-settings-panel" role="region" aria-labelledby="kitchenSettingsHeading">
                    <h2 id="kitchenSettingsHeading">Completed orders</h2>
                    <p id="completedDateHint" class="kitchen-settings-hint">Filter by order date in Philippine time. Active orders always stay visible.</p>
                    <label for="completedPeriod" class="kitchen-settings-label">Order date</label>
                    <select id="completedPeriod" class="kitchen-settings-input" aria-describedby="completedDateHint">
                        <option value="today" <%= CompletedFilter.Period == "today" ? "selected" : string.Empty %>>Today</option>
                        <option value="yesterday" <%= CompletedFilter.Period == "yesterday" ? "selected" : string.Empty %>>Yesterday</option>
                        <option value="custom" <%= CompletedFilter.Period == "custom" ? "selected" : string.Empty %>>Custom date range</option>
                        <option value="all" <%= CompletedFilter.Period == "all" ? "selected" : string.Empty %>>All time</option>
                    </select>
                    <div id="completedDateRange" class="kitchen-settings-dates" <%= CompletedFilter.Period != "custom" ? "hidden" : string.Empty %>>
                        <label for="completedFrom" class="kitchen-settings-label">From</label>
                        <input id="completedFrom" class="kitchen-settings-input" type="date" min="1753-01-01" max="9999-12-30" value="<%: CompletedFilter.FromDate %>" aria-describedby="completedFilterError" />
                        <label for="completedTo" class="kitchen-settings-label">To</label>
                        <input id="completedTo" class="kitchen-settings-input" type="date" min="1753-01-01" max="9999-12-30" value="<%: CompletedFilter.ToDate %>" aria-describedby="completedFilterError" />
                    </div>
                    <p id="completedFilterError" class="kitchen-settings-error" role="alert" <%= CompletedFilter.Error == null ? "hidden" : string.Empty %>><%: CompletedFilter.Error %></p>
                    <button id="applyKitchenSettings" class="kitchen-settings-apply" type="button">Apply</button>
                </div>
            </details>
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
                </ItemTemplate></asp:Repeater><asp:PlaceHolder ID="emptyCompleted" runat="server"><p class="kitchen-empty"><%: CompletedFilter.EmptyMessage %></p></asp:PlaceHolder></div>
            </section>
        </div>
    </main>

</asp:Content>

<asp:Content ID="ScriptsContent" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src="<%= ResolveUrl("~/Scripts/app/kitchen/board.js") %>?v=4"></script>
</asp:Content>
