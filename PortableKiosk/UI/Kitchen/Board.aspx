<%@ Page Title="Kitchen Board" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Board.aspx.cs" Inherits="PortableKiosk.UI.Kitchen.Board" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <meta http-equiv="refresh" content="20" />
    <style>
        .body-content:has(.kitchen-board) { padding: 0; }
        .kitchen-board { box-sizing: border-box; display: grid; grid-template-rows: auto minmax(0, 1fr); width: 100%; height: 100dvh; overflow: hidden; background: #f3f5f8; color: #172033; font-family: system-ui, sans-serif; }
        .kitchen-toolbar { display: flex; align-items: center; justify-content: space-between; gap: 1rem; min-height: 72px; padding: .7rem clamp(1rem, 2vw, 2rem); }
        .kitchen-toolbar h1 { margin: 0; font-size: clamp(1.35rem, 2vw, 1.8rem); font-weight: 700; letter-spacing: -.02em; }
        .kitchen-profile { position: relative; z-index: 30; flex: none; }
        .kitchen-profile-trigger { display: inline-flex; align-items: center; gap: .5rem; min-height: 44px; padding: .25rem .75rem .25rem .25rem; border: 1px solid #dce1e8; border-radius: 999px; background: #fff; color: #334155; font-size: .875rem; font-weight: 650; cursor: pointer; list-style: none; box-shadow: 0 2px 8px rgba(23,32,51,.06); }
        .kitchen-profile-trigger::-webkit-details-marker { display: none; }
        .kitchen-profile-trigger:hover { background: #f8fafc; }
        .kitchen-profile-trigger:focus-visible, .kitchen-profile-menu a:focus-visible, .kitchen-status:focus-visible { outline: 3px solid #2458d3; outline-offset: 2px; }
        .kitchen-avatar { display: inline-flex; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: 50%; background: #f1f5f9; }
        .kitchen-avatar svg { width: 20px; height: 20px; fill: none; stroke: currentColor; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
        .kitchen-profile-name { display: block; max-width: 8rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .kitchen-chevron { width: 16px; height: 16px; fill: none; stroke: currentColor; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; transition: transform .2s ease; }
        .kitchen-profile[open] .kitchen-chevron { transform: rotate(180deg); }
        .kitchen-profile-menu { position: absolute; right: 0; top: calc(100% + .45rem); width: 180px; padding: .35rem; border: 1px solid #dce1e8; border-radius: .5rem; background: #fff; box-shadow: 0 8px 24px rgba(23,32,51,.14); }
        .kitchen-profile-menu a { display: flex; align-items: center; gap: .6rem; min-height: 44px; padding: .5rem .75rem; border-radius: .35rem; color: #334155; font-size: .875rem; font-weight: 600; text-decoration: none; }
        .kitchen-profile-menu a:hover { background: #f1f5f9; }
        .kitchen-profile-menu svg { width: 18px; height: 18px; fill: none; stroke: currentColor; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
        .kitchen-columns { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: clamp(.5rem, 1vw, 1rem); min-height: 0; padding: 0 clamp(.5rem, 1vw, 1rem) clamp(.5rem, 1vw, 1rem); }
        .kitchen-column { display: flex; flex-direction: column; min-width: 0; min-height: 0; border-radius: .5rem; background: #e6ebf2; }
        .kitchen-column-heading { display: flex; align-items: center; justify-content: space-between; gap: .5rem; margin: 0; padding: 1rem; font-size: 1.16rem; font-weight: 700; }
        .kitchen-count { min-width: 1.9rem; padding: .15rem .55rem; border-radius: 999px; background: #fff; color: #475569; font-size: .85rem; font-variant-numeric: tabular-nums; text-align: center; }
        .kitchen-card-list { min-height: 0; flex: 1; overflow-y: auto; padding: 0 .7rem .7rem; }
        .kitchen-card { margin-bottom: .7rem; padding: .9rem; border-radius: .45rem; background: #fff; box-shadow: 0 3px 12px rgba(23,32,51,.06); }
        .kitchen-card-head { display: flex; align-items: flex-start; justify-content: space-between; gap: .5rem; }
        .kitchen-card-head > div { display: flex; align-items: baseline; flex-wrap: wrap; column-gap: .6rem; row-gap: .15rem; min-width: 0; }
        .kitchen-order-number { display: block; color: #172033; font-size: 1.35rem; line-height: 1.2; font-weight: 750; font-variant-numeric: tabular-nums; letter-spacing: -.025em; }
        .kitchen-time { display: block; color: #64748b; font-size: .76rem; font-variant-numeric: tabular-nums; white-space: nowrap; }
        .kitchen-type { flex: none; display: inline-flex; align-items: center; min-height: 28px; padding: .25rem .65rem; border-radius: 999px; font-size: .76rem; font-weight: 700; white-space: nowrap; }
        .kitchen-type-dinein { background: #e0f2fe; color: #075985; }
        .kitchen-type-takeout { background: #fef3c7; color: #92400e; }
        .kitchen-fulfillment { margin: .6rem 0 .75rem; color: #475569; font-size: .875rem; font-weight: 600; }
        .kitchen-items { display: grid; gap: .55rem; margin: 0 0 .9rem; padding: .8rem 0 0; border-top: 1px solid #e2e8f0; list-style: none; }
        .kitchen-item { display: flex; align-items: center; gap: .65rem; min-width: 0; }
        .kitchen-item-image, .kitchen-item-placeholder { box-sizing: border-box; display: block; flex: none; width: 44px; height: 44px; border-radius: .25rem; object-fit: cover; background: #edf0f4; }
        .kitchen-item-copy { display: block; min-width: 0; }
        .kitchen-item-copy strong { display: block; font-size: .875rem; font-weight: 650; line-height: 1.3; }
        .kitchen-item-copy small { display: block; margin-top: .1rem; color: #64748b; font-size: .76rem; }
        .kitchen-status-row { display: flex; align-items: center; gap: .75rem; padding-top: .8rem; border-top: 1px solid #e2e8f0; }
        .kitchen-status-label { color: #475569; font-size: .85rem; font-weight: 600; }
        .kitchen-status { flex: 1; width: 100%; min-width: 0; min-height: 44px; padding: .5rem .7rem; border: 1px solid #cbd5e1; border-radius: .35rem; background: #fff; color: #172033; font: inherit; font-size: .875rem; font-weight: 650; cursor: pointer; }
        .kitchen-empty { margin: 0; padding: 2rem .5rem; color: #64748b; font-size: .9rem; text-align: center; }
        .kitchen-error { position: fixed; z-index: 40; top: .7rem; left: 50%; display: block; width: min(90vw, 640px); transform: translateX(-50%); padding: .8rem 1rem; border-radius: .6rem; background: #fef2f2; color: #991b1b; box-shadow: 0 6px 20px rgba(23,32,51,.13); }
        @media (max-width: 950px) { .kitchen-columns { grid-auto-flow: column; grid-auto-columns: minmax(280px, min(78vw, 390px)); grid-template-columns: none; overflow-x: auto; overscroll-behavior-inline: contain; scroll-snap-type: x proximity; } .kitchen-column { scroll-snap-align: start; } }
        @media (max-width: 600px) { .kitchen-toolbar { min-height: 64px; padding: .5rem 1rem; } .kitchen-columns { grid-auto-columns: minmax(280px, calc(100vw - 1.5rem)); padding: 0 .75rem .75rem; } }
    </style>
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
                <div class="kitchen-profile-menu"><a runat="server" href="~/UI/Account/SignOut.aspx"><svg aria-hidden="true" viewBox="0 0 24 24"><path d="M10 17l5-5-5-5m5 5H3" /><path d="M12 3h5a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-5" /></svg>Sign out</a></div>
            </details>
        </div>
        <asp:Label ID="lblError" runat="server" EnableViewState="false" Visible="false" CssClass="kitchen-error" role="alert" />
        <div class="kitchen-columns">
            <section class="kitchen-column" aria-labelledby="queuedHeading">
                <h2 id="queuedHeading" class="kitchen-column-heading">Queued <span class="kitchen-count"><asp:Literal ID="litQueuedCount" runat="server" /></span></h2>
                <div class="kitchen-card-list"><asp:Repeater ID="rptQueued" runat="server" OnItemDataBound="StatusItemDataBound"><ItemTemplate>
                    <article class="kitchen-card">
                        <div class="kitchen-card-head"><div><strong class="kitchen-order-number"><%#: Eval("OrderNumberDisplay") %></strong><small class="kitchen-time"><%#: Eval("TimeDisplay") %></small></div><span class='<%# Eval("OrderTypeClass") %>'><%#: Eval("OrderTypeDisplay") %></span></div>
                        <p class="kitchen-fulfillment"><%#: Eval("FulfillmentDisplay") %></p>
                        <ul class="kitchen-items"><asp:Repeater runat="server" DataSource='<%# Eval("Items") %>'><ItemTemplate><li class="kitchen-item"><asp:Image runat="server" Visible='<%# HasImage(Eval("ImagePath")) %>' ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>' AlternateText="" CssClass="kitchen-item-image" /><span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>' class="kitchen-item-placeholder" aria-hidden="true"></span><span class="kitchen-item-copy"><strong><%#: Eval("Quantity") %> × <%#: Eval("ProductName") %></strong><small><%#: Eval("DisplaySize") %></small></span></li></ItemTemplate></asp:Repeater></ul>
                        <div class="kitchen-status-row"><span class="kitchen-status-label">Status</span><asp:HiddenField ID="hidOrderID" runat="server" Value='<%# Eval("OrderID") %>' /><asp:HiddenField ID="hidCurrentStatus" runat="server" Value='<%# Eval("KitchenStatus") %>' /><asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="StatusChanged" CssClass="kitchen-status" aria-label='<%# "Status for order " + Eval("OrderNumberDisplay") %>'><asp:ListItem Text="Queued" Value="QUEUED" /><asp:ListItem Text="Preparing" Value="PREPARING" /><asp:ListItem Text="Serving" Value="READY" /></asp:DropDownList></div>
                    </article>
                </ItemTemplate></asp:Repeater><asp:PlaceHolder ID="emptyQueued" runat="server"><p class="kitchen-empty">No orders</p></asp:PlaceHolder></div>
            </section>
            <section class="kitchen-column" aria-labelledby="preparingHeading">
                <h2 id="preparingHeading" class="kitchen-column-heading">Preparing <span class="kitchen-count"><asp:Literal ID="litPreparingCount" runat="server" /></span></h2>
                <div class="kitchen-card-list"><asp:Repeater ID="rptPreparing" runat="server" OnItemDataBound="StatusItemDataBound"><ItemTemplate>
                    <article class="kitchen-card">
                        <div class="kitchen-card-head"><div><strong class="kitchen-order-number"><%#: Eval("OrderNumberDisplay") %></strong><small class="kitchen-time"><%#: Eval("TimeDisplay") %></small></div><span class='<%# Eval("OrderTypeClass") %>'><%#: Eval("OrderTypeDisplay") %></span></div>
                        <p class="kitchen-fulfillment"><%#: Eval("FulfillmentDisplay") %></p>
                        <ul class="kitchen-items"><asp:Repeater runat="server" DataSource='<%# Eval("Items") %>'><ItemTemplate><li class="kitchen-item"><asp:Image runat="server" Visible='<%# HasImage(Eval("ImagePath")) %>' ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>' AlternateText="" CssClass="kitchen-item-image" /><span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>' class="kitchen-item-placeholder" aria-hidden="true"></span><span class="kitchen-item-copy"><strong><%#: Eval("Quantity") %> × <%#: Eval("ProductName") %></strong><small><%#: Eval("DisplaySize") %></small></span></li></ItemTemplate></asp:Repeater></ul>
                        <div class="kitchen-status-row"><span class="kitchen-status-label">Status</span><asp:HiddenField ID="hidOrderID" runat="server" Value='<%# Eval("OrderID") %>' /><asp:HiddenField ID="hidCurrentStatus" runat="server" Value='<%# Eval("KitchenStatus") %>' /><asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="StatusChanged" CssClass="kitchen-status" aria-label='<%# "Status for order " + Eval("OrderNumberDisplay") %>'><asp:ListItem Text="Queued" Value="QUEUED" /><asp:ListItem Text="Preparing" Value="PREPARING" /><asp:ListItem Text="Serving" Value="READY" /></asp:DropDownList></div>
                    </article>
                </ItemTemplate></asp:Repeater><asp:PlaceHolder ID="emptyPreparing" runat="server"><p class="kitchen-empty">No orders</p></asp:PlaceHolder></div>
            </section>
            <section class="kitchen-column" aria-labelledby="servingHeading">
                <h2 id="servingHeading" class="kitchen-column-heading">Serving <span class="kitchen-count"><asp:Literal ID="litServingCount" runat="server" /></span></h2>
                <div class="kitchen-card-list"><asp:Repeater ID="rptServing" runat="server" OnItemDataBound="StatusItemDataBound"><ItemTemplate>
                    <article class="kitchen-card">
                        <div class="kitchen-card-head"><div><strong class="kitchen-order-number"><%#: Eval("OrderNumberDisplay") %></strong><small class="kitchen-time"><%#: Eval("TimeDisplay") %></small></div><span class='<%# Eval("OrderTypeClass") %>'><%#: Eval("OrderTypeDisplay") %></span></div>
                        <p class="kitchen-fulfillment"><%#: Eval("FulfillmentDisplay") %></p>
                        <ul class="kitchen-items"><asp:Repeater runat="server" DataSource='<%# Eval("Items") %>'><ItemTemplate><li class="kitchen-item"><asp:Image runat="server" Visible='<%# HasImage(Eval("ImagePath")) %>' ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>' AlternateText="" CssClass="kitchen-item-image" /><span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>' class="kitchen-item-placeholder" aria-hidden="true"></span><span class="kitchen-item-copy"><strong><%#: Eval("Quantity") %> × <%#: Eval("ProductName") %></strong><small><%#: Eval("DisplaySize") %></small></span></li></ItemTemplate></asp:Repeater></ul>
                        <div class="kitchen-status-row"><span class="kitchen-status-label">Status</span><asp:HiddenField ID="hidOrderID" runat="server" Value='<%# Eval("OrderID") %>' /><asp:HiddenField ID="hidCurrentStatus" runat="server" Value='<%# Eval("KitchenStatus") %>' /><asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="StatusChanged" CssClass="kitchen-status" aria-label='<%# "Status for order " + Eval("OrderNumberDisplay") %>'><asp:ListItem Text="Queued" Value="QUEUED" /><asp:ListItem Text="Preparing" Value="PREPARING" /><asp:ListItem Text="Serving" Value="READY" /></asp:DropDownList></div>
                    </article>
                </ItemTemplate></asp:Repeater><asp:PlaceHolder ID="emptyServing" runat="server"><p class="kitchen-empty">No orders</p></asp:PlaceHolder></div>
            </section>
        </div>
    </main>
    <script>
        (function () {
            var menu = document.getElementById('kitchenProfile');
            if (menu) {
                document.addEventListener('click', function (event) {
                    if (menu.open && !menu.contains(event.target)) menu.open = false;
                });
                document.addEventListener('keydown', function (event) {
                    if (event.key === 'Escape' && menu.open) {
                        menu.open = false;
                        menu.querySelector('summary').focus();
                    }
                });
            }

            var board = document.querySelector('.kitchen-columns');
            var lists = document.querySelectorAll('.kitchen-card-list');
            var key = 'kitchen-board-scroll';
            if (!board) return;
            try {
                var saved = JSON.parse(sessionStorage.getItem(key) || 'null');
                if (saved) {
                    board.scrollLeft = saved.left || 0;
                    for (var i = 0; i < lists.length; i++) lists[i].scrollTop = saved.tops[i] || 0;
                    sessionStorage.removeItem(key);
                }
            } catch (ignored) { }

            function saveScroll() {
                try {
                    var tops = [];
                    for (var i = 0; i < lists.length; i++) tops.push(lists[i].scrollTop);
                    sessionStorage.setItem(key, JSON.stringify({ left: board.scrollLeft, tops: tops }));
                } catch (ignored) { }
            }
            document.addEventListener('change', function (event) {
                if (event.target.classList.contains('kitchen-status')) saveScroll();
            }, true);
            window.addEventListener('pagehide', saveScroll);
        }());
    </script>
</asp:Content>
