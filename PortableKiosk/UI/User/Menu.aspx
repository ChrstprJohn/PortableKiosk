<%@ Page
    Title="Menu"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/User.Master"
    AutoEventWireup="true"
    CodeBehind="Menu.aspx.cs"
    Inherits="PortableKiosk.UI.User.Menu" %>

<asp:Content
    ID="MenuContent"
    ContentPlaceHolderID="UserContent"
    runat="server">
    <main class="menu-layout" aria-label="Customer menu">
        <aside class="menu-sidebar" aria-label="Menu categories">
            <p class="menu-sidebar-label">Discover our menu</p>

            <asp:LinkButton
                ID="btnHome"
                runat="server"
                CssClass="menu-nav-item"
                CausesValidation="false"
                OnClick="btnHome_Click">
                Home
            </asp:LinkButton>

            <asp:Repeater
                ID="rptCategories"
                runat="server"
                OnItemCommand="rptCategories_ItemCommand">
                <ItemTemplate>
                    <asp:LinkButton
                        ID="btnCategory"
                        runat="server"
                        CssClass='<%# GetCategoryCss(Eval("CategoryID")) %>'
                        CommandName="SelectCategory"
                        CommandArgument='<%# Eval("CategoryID") %>'
                        CausesValidation="false">
                        <%# Server.HtmlEncode(Convert.ToString(Eval("CategoryName"))) %>
                    </asp:LinkButton>
                </ItemTemplate>
            </asp:Repeater>
        </aside>

        <section class="menu-content">
            <asp:Panel
                ID="pnlAddSuccess"
                runat="server"
                Visible="false"
                CssClass="kiosk-alert kiosk-alert-success"
                role="status">
                <strong>Added to cart.</strong>
                <asp:Literal ID="litAddSuccess" runat="server" />
            </asp:Panel>

            <asp:Label
                ID="lblMenuError"
                runat="server"
                Visible="false"
                CssClass="kiosk-alert kiosk-alert-error"
                role="alert" />

            <asp:Panel ID="pnlHome" runat="server">
                <div class="menu-home">
                    <p class="kiosk-eyebrow">Menu home</p>
                    <h1>What would you like today?</h1>
                    <p>
                        Choose a category from the left to start browsing.
                        This home area is ready for promotions and featured
                        items later.
                    </p>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlProducts" runat="server" Visible="false">
                <header class="menu-section-heading">
                    <div>
                        <p class="kiosk-eyebrow">Browse products</p>
                        <h1><asp:Literal ID="litCategoryName" runat="server" /></h1>
                    </div>
                    <span>Tap a product to choose its size</span>
                </header>

                <asp:Panel
                    ID="pnlNoProducts"
                    runat="server"
                    Visible="false"
                    CssClass="menu-empty-state">
                    <h2>No available products</h2>
                    <p>Please choose another category.</p>
                </asp:Panel>

                <div class="product-grid">
                    <asp:Repeater
                        ID="rptProducts"
                        runat="server"
                        OnItemCommand="rptProducts_ItemCommand">
                        <ItemTemplate>
                            <article class="product-card">
                                <div class="product-card-media">
                                    <asp:PlaceHolder
                                        runat="server"
                                        Visible='<%# HasImage(Eval("ImagePath")) %>'>
                                        <img
                                            src='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                            alt='<%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("ProductName"))) %>' />
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder
                                        runat="server"
                                        Visible='<%# !HasImage(Eval("ImagePath")) %>'>
                                        <span class="product-image-placeholder" aria-hidden="true">PK</span>
                                    </asp:PlaceHolder>
                                </div>

                                <div class="product-card-body">
                                    <p class="product-card-category">
                                        <%# Server.HtmlEncode(Convert.ToString(Eval("CategoryName"))) %>
                                    </p>
                                    <h2><%# Server.HtmlEncode(Convert.ToString(Eval("ProductName"))) %></h2>
                                    <p class="product-card-description">
                                        <%# Server.HtmlEncode(GetProductDescription(Eval("ProductDescription"))) %>
                                    </p>
                                    <div class="product-card-footer">
                                        <strong><%# FormatStartingPrice(Eval("StartingPrice")) %></strong>
                                        <asp:LinkButton
                                            ID="btnSelectProduct"
                                            runat="server"
                                            CssClass="kiosk-button kiosk-button-primary"
                                            CommandName="SelectProduct"
                                            CommandArgument='<%# Eval("ProductID") %>'
                                            CausesValidation="false">
                                            View options
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
        </section>
    </main>

    <div
        class="modal fade kiosk-product-modal"
        id="productModal"
        tabindex="-1"
        aria-labelledby="productModalTitle"
        aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <div>
                        <p class="kiosk-eyebrow">Choose your option</p>
                        <h2 class="modal-title" id="productModalTitle">
                            <asp:Literal ID="litSelectedProductName" runat="server" />
                        </h2>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Back to menu"></button>
                </div>

                <div class="modal-body product-detail-layout">
                    <div class="product-detail-media">
                        <asp:Image
                            ID="imgSelectedProduct"
                            runat="server"
                            AlternateText="Selected product" />
                        <asp:Panel
                            ID="pnlSelectedProductPlaceholder"
                            runat="server"
                            CssClass="product-image-placeholder product-image-placeholder-large">
                            PK
                        </asp:Panel>
                    </div>

                    <div class="product-detail-options">
                        <p class="product-detail-description">
                            <asp:Literal ID="litSelectedProductDescription" runat="server" />
                        </p>

                        <asp:HiddenField ID="hfSelectedProductID" runat="server" />

                        <fieldset>
                            <legend>Size</legend>
                            <asp:RadioButtonList
                                ID="rblVariants"
                                runat="server"
                                CssClass="variant-options"
                                RepeatLayout="Flow" />
                        </fieldset>

                        <div class="quantity-field">
                            <label for="<%= txtQuantity.ClientID %>">Quantity</label>
                            <div class="quantity-control">
                                <button type="button" data-quantity-action="decrease" aria-label="Decrease quantity">−</button>
                                <asp:TextBox
                                    ID="txtQuantity"
                                    runat="server"
                                    Text="1"
                                    TextMode="Number"
                                    min="1"
                                    max="99"
                                    inputmode="numeric" />
                                <button type="button" data-quantity-action="increase" aria-label="Increase quantity">+</button>
                            </div>
                        </div>

                        <asp:Label
                            ID="lblProductError"
                            runat="server"
                            Visible="false"
                            CssClass="kiosk-alert kiosk-alert-error"
                            role="alert" />
                    </div>
                </div>

                <div class="modal-footer product-detail-actions">
                    <button type="button" class="kiosk-button" data-bs-dismiss="modal">Back</button>
                    <asp:Button
                        ID="btnAddToCart"
                        runat="server"
                        Text="Add to cart"
                        CssClass="kiosk-button kiosk-button-primary"
                        OnClick="btnAddToCart_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content
    ID="MenuScripts"
    ContentPlaceHolderID="UserScriptsContent"
    runat="server">
    <script src="<%= ResolveUrl("~/Scripts/app/user/menu.js") %>"></script>
</asp:Content>
