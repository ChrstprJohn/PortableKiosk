<%@ Page Title="Menu" Language="C#" MasterPageFile="~/Shared/Layouts/User.Master" AutoEventWireup="true"
    CodeBehind="Menu.aspx.cs" Inherits="PortableKiosk.UI.User.Menu" %>

    <asp:Content ID="MenuContent" ContentPlaceHolderID="UserContent" runat="server">
        <main class="menu-layout grid h-full min-h-0 grid-cols-[clamp(6.5rem,17vw,18rem)_minmax(0,1fr)] overflow-hidden" aria-label="Customer menu">
            <aside class="menu-sidebar flex min-h-0 flex-col gap-[clamp(0.35rem,1.1vh,1rem)] overflow-y-auto overscroll-contain pb-[clamp(1rem,2vh,2.5rem)] pr-[clamp(0.25rem,0.8vw,1rem)] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden" aria-label="Menu categories">
                <div class="menu-sidebar-brand flex h-[clamp(4.5rem,8vh,12rem)] w-full shrink-0 items-center justify-center rounded-r-[clamp(0.875rem,1vw,1.5rem)] border border-l-0 border-slate-200/90 bg-white p-[clamp(0.5rem,1.5vw,1.5rem)] text-amber-500 shadow-sm select-none" aria-label="Portable Kiosk">
                    <span class="menu-brand-letter text-[clamp(2.1rem,4vw,5.5rem)] font-black leading-none tracking-tight" aria-hidden="true">P</span>
                </div>

                <div class="menu-home-card shrink-0 overflow-hidden rounded-r-[clamp(0.875rem,1vw,1.5rem)] border border-l-0 border-slate-200/90 bg-white shadow-sm">
                    <asp:LinkButton ID="btnHome" runat="server" CssClass="menu-nav-item flex w-full items-center gap-[clamp(0.3rem,0.8vw,1rem)] rounded-r-[clamp(0.875rem,1vw,1.5rem)] px-[clamp(0.4rem,1.2vw,1.5rem)] py-[clamp(0.45rem,1.2vh,1.5rem)] text-left text-[clamp(0.72rem,1.35vw,1.55rem)] font-semibold leading-tight text-slate-600 no-underline transition-colors hover:bg-slate-50 hover:text-slate-900 focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/30" CausesValidation="false"
                        OnClick="btnHome_Click">
                        <span class="menu-nav-icon menu-home-icon flex size-[clamp(1.5rem,2.2vw,3rem)] shrink-0 items-center justify-center text-amber-700 [&_svg]:size-[clamp(1rem,1.5vw,2rem)]" aria-hidden="true">
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="#f59e0b" stroke="#f59e0b" stroke-width="1.5"><path d="M3 9.5L12 3l9 6.5V20a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1V9.5z"/></svg>
                        </span>
                        <span class="menu-nav-label min-w-0 flex-1 break-words">Home</span>
                    </asp:LinkButton>
                </div>

                <div class="menu-categories-card flex shrink-0 flex-col gap-[clamp(0.1rem,0.3vh,0.4rem)] rounded-r-[clamp(0.875rem,1vw,1.5rem)] border border-l-0 border-slate-200/90 bg-white p-[clamp(0.25rem,0.65vw,0.85rem)] shadow-sm">
                    <asp:Repeater ID="rptCategories" runat="server" OnItemCommand="rptCategories_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnCategory" runat="server"
                                CssClass='<%# GetCategoryCss(Eval("CategoryID")) %>' CommandName="SelectCategory"
                                CommandArgument='<%# Eval("CategoryID") %>' CausesValidation="false">
                                <span class="menu-nav-icon flex size-[clamp(1.5rem,2.2vw,3rem)] shrink-0 items-center justify-center text-slate-500 transition-colors [&_svg]:size-[clamp(1rem,1.5vw,2rem)]" aria-hidden="true">
                                    <%# GetCategoryIconSvg(Eval("CategoryName")) %>
                                </span>
                                <span class="menu-nav-label min-w-0 flex-1 break-words"><%# Server.HtmlEncode(Convert.ToString(Eval("CategoryName"))) %></span>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </aside>

            <section class="menu-content min-h-0 min-w-0 overflow-y-auto overscroll-contain bg-slate-50 px-[clamp(1rem,3.75vw,5.5rem)] pt-[clamp(1rem,4vh,4.5rem)] pb-[clamp(7rem,12vh,18rem)]">
                <asp:Panel ID="pnlAddSuccess" runat="server" Visible="false" CssClass="kiosk-alert kiosk-alert-success"
                    role="status">
                    <strong>Added to cart.</strong>
                    <asp:Literal ID="litAddSuccess" runat="server" />
                </asp:Panel>

                <asp:Label ID="lblMenuError" runat="server" Visible="false" CssClass="kiosk-alert kiosk-alert-error"
                    role="alert" />

                <asp:Panel ID="pnlHome" runat="server">
                    <div class="menu-home min-h-full">
                        <header class="menu-home-heading mb-[clamp(1.25rem,3vh,3.5rem)]">
                            <h1 class="m-0 text-[clamp(2rem,5.5vw,7rem)] font-black leading-[1.02] tracking-[-0.045em] text-slate-900">Must-try Dinner</h1>
                        </header>

                        <section class="home-category-section mb-[clamp(2rem,4.5vh,4.5rem)]" aria-labelledby="discoverHeading">
                            <div class="home-section-header mb-[clamp(0.75rem,1.8vh,1.75rem)]">
                                <h2 id="discoverHeading" class="menu-home-subheading m-0 text-[clamp(1.25rem,3vw,3.75rem)] font-extrabold leading-tight tracking-[-0.035em] text-slate-900">Discover our Menu</h2>
                            </div>

                            <div class="home-category-grid grid grid-cols-2 gap-[clamp(0.55rem,1.25vw,1.75rem)] kiosk-mobile:grid-cols-2">
                                <asp:Repeater ID="rptHomeCategories" runat="server"
                                    OnItemCommand="rptCategories_ItemCommand">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnHomeCategory" runat="server" CssClass="home-category-card group flex min-h-[clamp(4.5rem,6.8vh,11rem)] items-center justify-between gap-3 rounded-[clamp(0.875rem,1vw,1.5rem)] border border-slate-200 bg-white px-[clamp(0.75rem,1.6vw,2rem)] py-[clamp(0.65rem,1.5vh,1.5rem)] text-slate-900 no-underline shadow-[0_2px_8px_rgba(15,23,42,0.04)] transition-[border-color,box-shadow,transform] hover:-translate-y-0.5 hover:border-slate-300 hover:shadow-[0_10px_24px_-4px_rgba(15,23,42,0.08)] focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/30 kiosk-mobile:flex-col kiosk-mobile:items-start kiosk-mobile:gap-1 kiosk-mobile:px-3 kiosk-mobile:py-2"
                                            CommandName="SelectCategory" CommandArgument='<%# Eval("CategoryID") %>'
                                            CausesValidation="false">
                                            <span class="home-category-name min-w-0 text-[clamp(0.85rem,1.65vw,2rem)] font-bold leading-tight tracking-tight kiosk-mobile:w-full kiosk-mobile:break-normal kiosk-mobile:text-[0.85rem]">
                                                <%# Server.HtmlEncode(Convert.ToString(Eval("CategoryName"))) %>
                                            </span>
                                            <span class="home-category-icon flex size-[clamp(2rem,3.6vw,5rem)] shrink-0 items-center justify-center self-end rounded-[clamp(0.6rem,0.8vw,1rem)] border border-amber-200 bg-amber-50 text-amber-700 transition-[background-color,transform] group-hover:scale-105 group-hover:border-transparent group-hover:bg-amber-500 group-hover:text-white [&_svg]:size-[clamp(1.1rem,2.4vw,2.75rem)] kiosk-mobile:size-7 kiosk-mobile:[&_svg]:size-5" aria-hidden="true">
                                                <%# GetCategoryIconSvg(Eval("CategoryName")) %>
                                            </span>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </section>

                        <section class="best-seller-section mt-[clamp(2rem,4.5vh,4.5rem)]" aria-labelledby="bestSellerHeading">
                            <div class="home-section-header best-seller-header mb-[clamp(0.75rem,1.8vh,1.75rem)]">
                                <h2 id="bestSellerHeading" class="m-0 text-[clamp(1.25rem,3vw,3.75rem)] font-extrabold leading-tight tracking-[-0.035em] text-slate-900">Best Seller</h2>
                            </div>
                            <div class="best-seller-grid grid grid-cols-3 gap-[clamp(0.45rem,1.1vw,1.5rem)] kiosk-mobile:grid-cols-2">
                                <asp:Repeater ID="rptBestSellers" runat="server"
                                    OnItemCommand="rptProducts_ItemCommand">
                                    <ItemTemplate>
                                        <article class="best-seller-card group h-full min-w-0 overflow-hidden rounded-[clamp(0.75rem,0.9vw,1.5rem)] border border-slate-200 bg-white shadow-[0_2px_8px_rgba(15,23,42,0.04)] transition-[border-color,box-shadow,transform] hover:-translate-y-1 hover:border-amber-400 hover:shadow-[0_10px_24px_-4px_rgba(15,23,42,0.08)]">
                                            <asp:LinkButton ID="btnBestSeller" runat="server"
                                                CssClass="best-seller-link group flex h-full flex-col p-[clamp(0.25rem,0.65vw,0.9rem)] text-slate-900 no-underline hover:text-slate-900 focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/30" CommandName="SelectProduct"
                                                CommandArgument='<%# Eval("ProductID") %>' CausesValidation="false">
                                                <span class="best-seller-media relative flex aspect-square w-full items-center justify-center overflow-hidden rounded-[clamp(0.5rem,0.65vw,1rem)] bg-slate-100">
                                                    <asp:Image runat="server"
                                                        Visible='<%# HasImage(Eval("ImagePath")) %>'
                                                        ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                                        CssClass="h-full w-full object-cover transition-transform duration-300 group-hover:scale-[1.04]"
                                                        AlternateText='<%# Convert.ToString(Eval("ProductName")) %>' />
                                                    <span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>'
                                                        class="product-image-placeholder">PK</span>
                                                </span>
                                                <span class="best-seller-info flex min-h-[clamp(3rem,5.5vh,8rem)] flex-1 flex-col justify-center px-[clamp(0.25rem,0.7vw,1rem)] py-[clamp(0.35rem,1vh,1.25rem)] text-center">
                                                    <strong class="best-seller-title break-words text-[clamp(0.78rem,1.3vw,1.7rem)] font-bold leading-tight text-slate-900">
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
                    <header class="menu-section-heading mb-[clamp(1.5rem,4vh,4rem)]">
                        <div>
                            <h1 class="m-0 text-[clamp(2rem,5.5vw,7rem)] font-black leading-[1.04] tracking-[-0.045em] text-slate-900">
                                <asp:Literal ID="litCategoryName" runat="server" />
                            </h1>
                        </div>
                    </header>

                    <asp:Panel ID="pnlNoProducts" runat="server" Visible="false" CssClass="menu-empty-state flex flex-col items-center justify-center rounded-[22px] border border-dashed border-slate-300 bg-white p-[clamp(2rem,4vw,5rem)] text-center shadow-sm">
                        <h2 class="mb-2 text-[clamp(1.25rem,2vw,2rem)] font-bold text-slate-900">No available products</h2>
                        <p class="m-0 text-[clamp(1rem,1.5vw,1.5rem)] text-slate-500">Please choose another category.</p>
                    </asp:Panel>

                    <div class="product-grid grid grid-cols-3 gap-[clamp(0.45rem,1.1vw,1.5rem)] kiosk-mobile:grid-cols-2">
                        <asp:Repeater ID="rptProducts" runat="server" OnItemCommand="rptProducts_ItemCommand">
                            <ItemTemplate>
                                <article class="product-card group min-w-0 overflow-hidden rounded-[clamp(0.75rem,0.9vw,1.5rem)] border border-slate-200 bg-white shadow-[0_2px_8px_rgba(15,23,42,0.04)] transition-[border-color,box-shadow,transform] hover:-translate-y-1 hover:border-amber-400 hover:shadow-[0_10px_24px_-4px_rgba(15,23,42,0.08)]">
                                    <asp:LinkButton ID="btnSelectProduct" runat="server" CssClass="product-card-link group flex h-full flex-col p-[clamp(0.25rem,0.65vw,0.9rem)] text-slate-900 no-underline hover:text-slate-900 focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/30"
                                        CommandName="SelectProduct" CommandArgument='<%# Eval("ProductID") %>'
                                        CausesValidation="false">
                                        <span class="product-card-media relative flex aspect-square w-full items-center justify-center overflow-hidden rounded-[clamp(0.5rem,0.65vw,1rem)] bg-slate-100">
                                            <asp:Image runat="server" Visible='<%# HasImage(Eval("ImagePath")) %>'
                                                ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                                CssClass="h-full w-full object-cover transition-transform duration-300 group-hover:scale-[1.04]"
                                                AlternateText='<%# Convert.ToString(Eval("ProductName")) %>' />
                                            <span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>'
                                                class="product-image-placeholder" aria-hidden="true">PK</span>
                                        </span>
                                        <span class="product-card-body flex min-h-[clamp(3rem,5.5vh,8rem)] flex-1 items-center justify-center px-[clamp(0.25rem,0.7vw,1rem)] py-[clamp(0.35rem,1vh,1.25rem)] text-center">
                                            <strong class="product-card-name break-words text-[clamp(0.78rem,1.3vw,1.7rem)] font-bold leading-tight text-slate-900">
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
