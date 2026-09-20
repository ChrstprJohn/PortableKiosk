<%@ Page Title="Menu" Language="C#" MasterPageFile="~/Shared/Layouts/User.Master" AutoEventWireup="true"
    CodeBehind="Menu.aspx.cs" Inherits="PortableKiosk.UI.User.Menu" %>

    <asp:Content ID="MenuContent" ContentPlaceHolderID="UserContent" runat="server">
        <main class="menu-layout" aria-label="Customer menu">
            <aside class="menu-sidebar" aria-label="Menu categories">
                <div class="menu-sidebar-brand" aria-label="Portable Kiosk">
                    <span aria-hidden="true">P</span>
                </div>

                <asp:LinkButton ID="btnHome" runat="server" CssClass="menu-nav-item" CausesValidation="false"
                    OnClick="btnHome_Click">
                    Home
                </asp:LinkButton>

                <asp:Repeater ID="rptCategories" runat="server" OnItemCommand="rptCategories_ItemCommand">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnCategory" runat="server"
                            CssClass='<%# GetCategoryCss(Eval("CategoryID")) %>' CommandName="SelectCategory"
                            CommandArgument='<%# Eval("CategoryID") %>' CausesValidation="false">
                            <%# Server.HtmlEncode(Convert.ToString(Eval("CategoryName"))) %>
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>
            </aside>

            <section class="menu-content">
                <asp:Panel ID="pnlAddSuccess" runat="server" Visible="false" CssClass="kiosk-alert kiosk-alert-success"
                    role="status">
                    <strong>Added to cart.</strong>
                    <asp:Literal ID="litAddSuccess" runat="server" />
                </asp:Panel>

                <asp:Label ID="lblMenuError" runat="server" Visible="false" CssClass="kiosk-alert kiosk-alert-error"
                    role="alert" />

                <asp:Panel ID="pnlHome" runat="server">
                    <div class="menu-home">
                        <header class="menu-home-heading">
                            <h1>Must-try Dinner</h1>
                            <h2 class="menu-home-subheading">Discover our Menu</h2>
                        </header>

                        <div class="home-category-grid">
                            <asp:Repeater ID="rptHomeCategories" runat="server"
                                OnItemCommand="rptCategories_ItemCommand">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnHomeCategory" runat="server" CssClass="home-category-card"
                                        CommandName="SelectCategory" CommandArgument='<%# Eval("CategoryID") %>'
                                        CausesValidation="false">
                                        <span class="home-category-name">
                                            <%# Server.HtmlEncode(Convert.ToString(Eval("CategoryName"))) %>
                                        </span>
                                        <span class="home-category-icon" aria-hidden="true">
                                            <%# GetCategoryIconSvg(Eval("CategoryName")) %>
                                        </span>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <section class="best-seller-section" aria-labelledby="bestSellerHeading">
                            <div class="best-seller-header">
                                <h2 id="bestSellerHeading">Best Seller</h2>
                            </div>
                            <div class="best-seller-grid">
                                <asp:Repeater ID="rptBestSellers" runat="server"
                                    OnItemCommand="rptProducts_ItemCommand">
                                    <ItemTemplate>
                                        <article class="best-seller-card">
                                            <asp:LinkButton ID="btnBestSeller" runat="server"
                                                CssClass="best-seller-link" CommandName="SelectProduct"
                                                CommandArgument='<%# Eval("ProductID") %>' CausesValidation="false">
                                                <span class="best-seller-media">
                                                    <asp:Image runat="server"
                                                        Visible='<%# HasImage(Eval("ImagePath")) %>'
                                                        ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                                        AlternateText='<%# Convert.ToString(Eval("ProductName")) %>' />
                                                    <span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>'
                                                        class="product-image-placeholder">PK</span>
                                                </span>
                                                <span class="best-seller-info">
                                                    <strong class="best-seller-title">
                                                        <%# Server.HtmlEncode(Convert.ToString(Eval("ProductName"))) %>
                                                    </strong>
                                                </span>
                                            </asp:LinkButton>
                                        </article>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </section>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlProducts" runat="server" Visible="false">
                    <header class="menu-section-heading">
                        <div>
                            <h1>
                                <asp:Literal ID="litCategoryName" runat="server" />
                            </h1>
                        </div>
                    </header>

                    <asp:Panel ID="pnlNoProducts" runat="server" Visible="false" CssClass="menu-empty-state">
                        <h2>No available products</h2>
                        <p>Please choose another category.</p>
                    </asp:Panel>

                    <div class="product-grid">
                        <asp:Repeater ID="rptProducts" runat="server" OnItemCommand="rptProducts_ItemCommand">
                            <ItemTemplate>
                                <article class="product-card">
                                    <asp:LinkButton ID="btnSelectProduct" runat="server" CssClass="product-card-link"
                                        CommandName="SelectProduct" CommandArgument='<%# Eval("ProductID") %>'
                                        CausesValidation="false">
                                        <span class="product-card-media">
                                            <asp:Image runat="server" Visible='<%# HasImage(Eval("ImagePath")) %>'
                                                ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                                AlternateText='<%# Convert.ToString(Eval("ProductName")) %>' />
                                            <span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>'
                                                class="product-image-placeholder" aria-hidden="true">PK</span>
                                        </span>
                                        <span class="product-card-body">
                                            <strong class="product-card-name">
                                                <%# Server.HtmlEncode(Convert.ToString(Eval("ProductName"))) %>
                                            </strong>
                                        </span>
                                    </asp:LinkButton>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlProductDetail" runat="server" Visible="false" CssClass="product-detail-page">
                    <header class="product-detail-heading">
                        <h1>Sizes</h1>
                    </header>

                    <div class="product-detail-layout">
                        <div class="product-detail-options">
                            <asp:HiddenField ID="hfSelectedProductID" runat="server" />
                            <asp:HiddenField ID="hfSelectedVariantID" runat="server" ClientIDMode="Static" />

                            <fieldset>
                                <legend class="visually-hidden">Choose one size</legend>
                                <div class="variant-options">
                                    <asp:Repeater ID="rptVariants" runat="server">
                                        <ItemTemplate>
                                            <label class="variant-card">
                                                <input type="radio" name="variantChoice"
                                                    value='<%# Eval("ProductVariantID") %>'
                                                    data-variant-choice="true" />
                                                <span class="variant-card-content">
                                                    <asp:Image runat="server"
                                                        Visible='<%# HasImage(Eval("ImagePath")) %>'
                                                        CssClass="variant-image"
                                                        ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                                        AlternateText='<%# Convert.ToString(Eval("SizeName")) %>' />
                                                    <span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>'
                                                        class="variant-image-placeholder" aria-hidden="true">PK</span>
                                                    <strong class="variant-name">
                                                        <%# Server.HtmlEncode(GetVariantSizeName(Eval("SizeName"))) %>
                                                    </strong>
                                                    <span class="variant-price">
                                                        <%# FormatVariantPrice(Eval("Price")) %>
                                                    </span>
                                                </span>
                                            </label>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </fieldset>

                            <asp:Label ID="lblProductError" runat="server" Visible="false"
                                CssClass="kiosk-alert kiosk-alert-error" role="alert" />
                        </div>
                    </div>

                    <div class="product-detail-actions">
                        <div class="product-purchase-actions">
                            <div class="quantity-field">
                                <label for="<%= txtQuantity.ClientID %>">Quantity</label>
                                <div class="quantity-control">
                                    <button type="button" data-quantity-action="decrease"
                                        aria-label="Decrease quantity">−</button>
                                    <asp:TextBox ID="txtQuantity" runat="server" Text="1" TextMode="Number" min="1"
                                        max="99" inputmode="numeric" />
                                    <button type="button" data-quantity-action="increase"
                                        aria-label="Increase quantity">+</button>
                                </div>
                            </div>
                            <div class="product-purchase-buttons">
                                <asp:LinkButton ID="btnBackToMenu" runat="server" CssClass="kiosk-button"
                                    CausesValidation="false" OnClick="btnBackToMenu_Click">
                                    Back
                                </asp:LinkButton>
                                <asp:Button ID="btnAddToCart" runat="server" Text="Add to cart"
                                    CssClass="kiosk-button kiosk-button-primary" OnClick="btnAddToCart_Click" />
                            </div>
                        </div>
                    </div>
                </asp:Panel>
            </section>
        </main>
    </asp:Content>

    <asp:Content ID="MenuScripts" ContentPlaceHolderID="UserScriptsContent" runat="server">
        <script src="<%= ResolveUrl("~/Scripts/app/user/menu.js") %>"></script>
    </asp:Content>