<%@ Page Title="Menu" Language="C#" MasterPageFile="~/Shared/Layouts/User.Master" AutoEventWireup="true"
    CodeBehind="Menu.aspx.cs" Inherits="PortableKiosk.UI.User.Menu" %>

    <asp:Content ID="MenuContent" ContentPlaceHolderID="UserContent" runat="server">
        <main class="menu-layout grid h-full min-h-0 grid-cols-[clamp(4.25rem,20cqw,30rem)_minmax(0,1fr)] max-[420px]:grid-cols-[clamp(3.75rem,20vw,5.5rem)_minmax(0,1fr)] overflow-hidden" aria-label="Customer menu">
            <aside class="menu-sidebar flex min-h-0 flex-col gap-[clamp(0.35rem,1.6cqw,2.5rem)] overflow-y-auto overscroll-contain pb-[clamp(1rem,2vh,2.5rem)] pr-[clamp(0.2rem,0.8cqw,1rem)] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden" aria-label="Menu categories">
                <div class="menu-sidebar-brand flex h-[clamp(2.5rem,14cqw,24rem)] max-[420px]:h-10 w-full shrink-0 items-center justify-center rounded-r-[clamp(0.4rem,2.5cqw,4rem)] border border-l-0 border-slate-200/90 bg-white p-[clamp(0.35rem,2cqw,2.5rem)] text-amber-500 shadow-sm select-none" aria-label="Portable Kiosk">
                    <span class="menu-brand-letter text-[clamp(1.1rem,5.5cqw,8rem)] max-[420px]:text-lg font-black leading-none tracking-tight" aria-hidden="true">P</span>
                </div>

                <div class="menu-home-card shrink-0 overflow-hidden rounded-r-[clamp(0.4rem,2.5cqw,4rem)] border border-l-0 border-slate-200/90 bg-white shadow-sm">
                    <asp:LinkButton ID="btnHome" runat="server" CssClass="menu-nav-item flex w-full items-center gap-[clamp(0.2rem,1.3cqw,1.75rem)] rounded-r-[clamp(0.4rem,2.5cqw,4rem)] px-[clamp(0.2rem,1.5cqw,2.25rem)] py-[clamp(0.3rem,1.5cqw,2.5rem)] max-[420px]:px-1 max-[420px]:py-1.5 text-left text-[clamp(0.625rem,2.2cqw,4rem)] max-[420px]:text-[0.625rem] font-semibold leading-tight text-slate-600 no-underline transition-colors hover:bg-slate-50 hover:text-slate-900 focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/30" CausesValidation="false"
                        OnClick="btnHome_Click">
                        <span class="menu-nav-icon menu-home-icon flex size-[clamp(0.95rem,3.8cqw,5.5rem)] max-[420px]:size-4 shrink-0 items-center justify-center text-amber-700 [&_svg]:size-[clamp(0.85rem,3.2cqw,4.5rem)] max-[420px]:[&_svg]:size-3.5" aria-hidden="true">
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="#f59e0b" stroke="#f59e0b" stroke-width="1.5"><path d="M3 9.5L12 3l9 6.5V20a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1V9.5z"/></svg>
                        </span>
                        <span class="menu-nav-label min-w-0 flex-1 break-words">Home</span>
                    </asp:LinkButton>
                </div>

                <div class="menu-categories-card flex shrink-0 flex-col gap-[clamp(0.1rem,0.35vh,0.5rem)] rounded-r-[clamp(0.4rem,2.5cqw,4rem)] border border-l-0 border-slate-200/90 bg-white p-[clamp(0.2rem,1.1cqw,1.5rem)] max-[420px]:p-1 shadow-sm">
                    <asp:Repeater ID="rptCategories" runat="server" OnItemCommand="rptCategories_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnCategory" runat="server"
                                CssClass='<%# GetCategoryCss(Eval("CategoryID")) %>' CommandName="SelectCategory"
                                CommandArgument='<%# Eval("CategoryID") %>' CausesValidation="false">
                                    <span class="menu-nav-icon flex size-[clamp(0.95rem,3.8cqw,5.5rem)] max-[420px]:size-4 shrink-0 items-center justify-center text-slate-500 transition-colors [&_svg]:size-[clamp(0.85rem,3.2cqw,4.5rem)] max-[420px]:[&_svg]:size-3.5" aria-hidden="true">
                                    <%# GetCategoryIconSvg(Eval("CategoryName")) %>
                                </span>
                                <span class="menu-nav-label min-w-0 flex-1 break-words"><%# Server.HtmlEncode(Convert.ToString(Eval("CategoryName"))) %></span>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </aside>

            <section class="menu-content min-h-0 min-w-0 overflow-y-auto overscroll-contain bg-slate-50 px-[clamp(0.6rem,3.5cqw,6rem)] pt-[clamp(0.75rem,4vh,6rem)] pb-[clamp(5.5rem,14vh,28rem)] max-[480px]:px-2.5 max-[480px]:pt-3 max-[480px]:pb-24">
                <asp:Panel ID="pnlAddSuccess" runat="server" Visible="false" CssClass="kiosk-alert kiosk-alert-success"
                    role="status">
                    <strong>Added to cart.</strong>
                    <asp:Literal ID="litAddSuccess" runat="server" />
                </asp:Panel>

                <asp:Label ID="lblMenuError" runat="server" Visible="false" CssClass="kiosk-alert kiosk-alert-error"
                    role="alert" />

                <asp:Panel ID="pnlHome" runat="server">
                    <div class="menu-home min-h-full">
                        <header class="menu-home-heading mb-[clamp(0.75rem,2.5vh,3.5rem)] max-[480px]:mb-3">
                                <h1 class="m-0 text-[clamp(1.25rem,6.5cqw,10rem)] max-[480px]:text-[clamp(1.15rem,5.5vw,1.6rem)] font-black leading-[1.04] tracking-[-0.04em] text-slate-900">Must-try Dinner</h1>
                        </header>

                        <section class="home-category-section mb-[clamp(1.25rem,4vh,6rem)] max-[480px]:mb-4" aria-labelledby="discoverHeading">
                            <div class="home-section-header mb-[clamp(0.5rem,1.5vh,1.75rem)] max-[480px]:mb-2">
                                <h2 id="discoverHeading" class="menu-home-subheading m-0 text-[clamp(0.95rem,4cqw,6rem)] max-[480px]:text-[clamp(0.875rem,4vw,1.2rem)] font-extrabold leading-tight tracking-[-0.03em] text-slate-900">Discover our Menu</h2>
                            </div>

                            <div class="home-category-grid grid grid-cols-2 gap-[clamp(0.35rem,1.4cqw,2rem)] max-[480px]:gap-2 kiosk-mobile:grid-cols-2">
                                <asp:Repeater ID="rptHomeCategories" runat="server"
                                    OnItemCommand="rptCategories_ItemCommand">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnHomeCategory" runat="server" CssClass="home-category-card group flex min-h-[clamp(3.25rem,8vh,20rem)] max-[480px]:min-h-[3.25rem] items-center justify-between gap-[clamp(0.35rem,0.9cqw,1.25rem)] rounded-[clamp(0.5rem,2cqw,4rem)] max-[480px]:rounded-xl border border-slate-200 bg-white px-[clamp(0.4rem,1.6cqw,2.25rem)] py-[clamp(0.35rem,1.4vh,2rem)] max-[480px]:p-2 text-slate-900 no-underline shadow-[0_2px_8px_rgba(15,23,42,0.04)] transition-[border-color,box-shadow,transform] hover:-translate-y-0.5 hover:border-slate-300 hover:shadow-[0_10px_24px_-4px_rgba(15,23,42,0.08)] focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/30 max-[360px]:flex-col max-[360px]:items-start max-[360px]:gap-1"
                                            CommandName="SelectCategory" CommandArgument='<%# Eval("CategoryID") %>'
                                            CausesValidation="false">
                                            <span class="home-category-name min-w-0 break-words text-[clamp(0.75rem,3cqw,5rem)] max-[480px]:text-[0.75rem] font-bold leading-tight tracking-tight max-[360px]:w-full">
                                                <%# Server.HtmlEncode(Convert.ToString(Eval("CategoryName"))) %>
                                            </span>
                                            <span class="home-category-icon flex size-[clamp(1.25rem,4.5cqw,7rem)] max-[480px]:size-7 shrink-0 items-center justify-center self-end rounded-[clamp(0.4rem,1.8cqw,3rem)] max-[480px]:rounded-lg border border-amber-200 bg-amber-50 text-amber-700 transition-[background-color,transform] group-hover:scale-105 group-hover:border-transparent group-hover:bg-amber-500 group-hover:text-white [&_svg]:size-[clamp(0.75rem,3cqw,4.5rem)] max-[480px]:[&_svg]:size-3.5 max-[360px]:mt-1" aria-hidden="true">
                                                <%# GetCategoryIconSvg(Eval("CategoryName")) %>
                                            </span>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </section>

                        <section class="best-seller-section mt-[clamp(1.25rem,4vh,6rem)] max-[480px]:mt-4" aria-labelledby="bestSellerHeading">
                            <div class="home-section-header best-seller-header mb-[clamp(0.5rem,1.5vh,1.75rem)] max-[480px]:mb-2">
                                <h2 id="bestSellerHeading" class="m-0 text-[clamp(0.95rem,4cqw,6rem)] max-[480px]:text-[clamp(0.875rem,4vw,1.2rem)] font-extrabold leading-tight tracking-[-0.03em] text-slate-900">Best Seller</h2>
                            </div>
                            <div class="best-seller-grid grid grid-cols-3 gap-[clamp(0.35rem,1.4cqw,2rem)] max-[480px]:gap-2 kiosk-mobile:grid-cols-2">
                                <asp:Repeater ID="rptBestSellers" runat="server"
                                    OnItemCommand="rptProducts_ItemCommand">
                                    <ItemTemplate>
                                        <article class="best-seller-card group h-full min-w-0 overflow-hidden rounded-[clamp(0.5rem,2cqw,4rem)] max-[480px]:rounded-xl border border-slate-200 bg-white shadow-[0_2px_8px_rgba(15,23,42,0.04)] transition-[border-color,box-shadow,transform] hover:-translate-y-1 hover:border-amber-400 hover:shadow-[0_10px_24px_-4px_rgba(15,23,42,0.08)]">
                                            <asp:LinkButton ID="btnBestSeller" runat="server"
                                                CssClass="best-seller-link group flex h-full flex-col p-[clamp(0.2rem,0.8cqw,1.25rem)] max-[480px]:p-1.5 text-slate-900 no-underline hover:text-slate-900 focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/30" CommandName="SelectProduct"
                                                CommandArgument='<%# Eval("ProductID") %>' CausesValidation="false">
                                                <span class="best-seller-media relative flex aspect-square w-full items-center justify-center overflow-hidden rounded-[clamp(0.4rem,1.6cqw,3rem)] max-[480px]:rounded-lg bg-slate-100">
                                                    <asp:Image runat="server"
                                                        Visible='<%# HasImage(Eval("ImagePath")) %>'
                                                        ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                                        CssClass="h-full w-full object-cover transition-transform duration-300 group-hover:scale-[1.04]"
                                                        AlternateText='<%# Convert.ToString(Eval("ProductName")) %>' />
                                                    <span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>'
                                                        class="product-image-placeholder">PK</span>
                                                </span>
                                                <span class="best-seller-info flex min-h-[clamp(2.25rem,8cqw,16rem)] max-[480px]:min-h-[2.2rem] flex-1 flex-col justify-center px-[clamp(0.2rem,0.8cqw,1.25rem)] py-[clamp(0.25rem,1vh,1.5rem)] max-[480px]:py-1 text-center">
                                                    <strong class="best-seller-title break-words text-[clamp(0.75rem,2.7cqw,4rem)] max-[480px]:text-[0.75rem] font-bold leading-tight text-slate-900">
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
                    <header class="menu-section-heading mb-[clamp(0.75rem,3vh,5rem)] max-[480px]:mb-3">
                        <div>
                            <h1 class="m-0 text-[clamp(1.25rem,6.5cqw,10rem)] max-[480px]:text-[clamp(1.15rem,5.5vw,1.6rem)] font-black leading-[1.04] tracking-[-0.04em] text-slate-900">
                                <asp:Literal ID="litCategoryName" runat="server" />
                            </h1>
                        </div>
                    </header>

                    <asp:Panel ID="pnlNoProducts" runat="server" Visible="false" CssClass="menu-empty-state flex flex-col items-center justify-center rounded-[18px] border border-dashed border-slate-300 bg-white p-[clamp(1.5rem,4cqw,5rem)] max-[480px]:p-4 text-center shadow-sm">
                        <h2 class="mb-1.5 text-[clamp(1rem,2cqw,2rem)] max-[480px]:text-sm font-bold text-slate-900">No available products</h2>
                        <p class="m-0 text-[clamp(0.85rem,1.5cqw,1.5rem)] max-[480px]:text-xs text-slate-500">Please choose another category.</p>
                    </asp:Panel>

                    <div class="product-grid grid grid-cols-3 gap-[clamp(0.35rem,1.4cqw,2rem)] max-[480px]:gap-2 kiosk-mobile:grid-cols-2">
                        <asp:Repeater ID="rptProducts" runat="server" OnItemCommand="rptProducts_ItemCommand">
                            <ItemTemplate>
                                <article class="product-card group min-w-0 overflow-hidden rounded-[clamp(0.5rem,2cqw,4rem)] max-[480px]:rounded-xl border border-slate-200 bg-white shadow-[0_2px_8px_rgba(15,23,42,0.04)] transition-[border-color,box-shadow,transform] hover:-translate-y-1 hover:border-amber-400 hover:shadow-[0_10px_24px_-4px_rgba(15,23,42,0.08)]">
                                    <asp:LinkButton ID="btnSelectProduct" runat="server" CssClass="product-card-link group flex h-full flex-col p-[clamp(0.2rem,0.8cqw,1.25rem)] max-[480px]:p-1.5 text-slate-900 no-underline hover:text-slate-900 focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/30"
                                        CommandName="SelectProduct" CommandArgument='<%# Eval("ProductID") %>'
                                        CausesValidation="false">
                                        <span class="product-card-media relative flex aspect-square w-full items-center justify-center overflow-hidden rounded-[clamp(0.4rem,1.6cqw,3rem)] max-[480px]:rounded-lg bg-slate-100">
                                            <asp:Image runat="server" Visible='<%# HasImage(Eval("ImagePath")) %>'
                                                ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                                CssClass="h-full w-full object-cover transition-transform duration-300 group-hover:scale-[1.04]"
                                                AlternateText='<%# Convert.ToString(Eval("ProductName")) %>' />
                                            <span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>'
                                                class="product-image-placeholder" aria-hidden="true">PK</span>
                                        </span>
                                        <span class="product-card-body flex min-h-[clamp(2.25rem,8cqw,16rem)] max-[480px]:min-h-[2.2rem] flex-1 items-center justify-center px-[clamp(0.2rem,0.8cqw,1.25rem)] py-[clamp(0.25rem,1vh,1.5rem)] max-[480px]:py-1 text-center">
                                            <strong class="product-card-name break-words text-[clamp(0.75rem,2.7cqw,4rem)] max-[480px]:text-[0.75rem] font-bold leading-tight text-slate-900">
                                                <%# Server.HtmlEncode(Convert.ToString(Eval("ProductName"))) %>
                                            </strong>
                                        </span>
                                    </asp:LinkButton>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlProductDetail" runat="server" Visible="false" CssClass="product-detail-page min-h-full w-full">
                    <header class="product-detail-heading mb-[clamp(0.75rem,2.5cqw,4rem)] max-[480px]:mb-3">
                        <h1 class="m-0 text-[clamp(1.25rem,6.5cqw,10rem)] max-[480px]:text-[clamp(1.15rem,5.5vw,1.6rem)] font-black leading-[1.04] tracking-[-0.04em] text-slate-900">Sizes</h1>
                    </header>

                    <div class="product-detail-layout w-full">
                        <div class="product-detail-options w-full">
                            <asp:HiddenField ID="hfSelectedProductID" runat="server" />
                            <asp:HiddenField ID="hfSelectedVariantID" runat="server" ClientIDMode="Static" />

                            <fieldset>
                                <legend class="mb-[clamp(0.5rem,1.5vh,1.75rem)] max-[480px]:mb-2 block text-[clamp(0.95rem,4cqw,6rem)] max-[480px]:text-[clamp(0.875rem,4vw,1.2rem)] font-extrabold leading-tight tracking-[-0.03em] text-slate-900">Choose one size</legend>
                                <div class="variant-options grid grid-cols-3 gap-[clamp(0.35rem,1.4cqw,2rem)] max-[480px]:gap-2 kiosk-mobile:grid-cols-2">
                                    <asp:Repeater ID="rptVariants" runat="server">
                                        <ItemTemplate>
                                            <label class="variant-card group relative flex h-full min-w-0 cursor-pointer flex-col overflow-hidden rounded-[clamp(0.5rem,2cqw,4rem)] max-[480px]:rounded-xl border border-slate-200 bg-white p-[clamp(0.2rem,0.8cqw,1.25rem)] max-[480px]:p-1.5 shadow-[0_2px_8px_rgba(15,23,42,0.04)] transition-[border-color,box-shadow,transform] hover:-translate-y-0.5 hover:border-amber-400 hover:shadow-[0_10px_24px_-4px_rgba(15,23,42,0.08)] has-checked:border-amber-500 has-checked:bg-amber-50 has-checked:shadow-[0_0_0_1px_#f59e0b,0_6px_16px_rgba(245,158,11,0.28)]">
                                                <input type="radio" name="variantChoice"
                                                    value='<%# Eval("ProductVariantID") %>'
                                                    data-variant-choice="true"
                                                    class="absolute right-[clamp(0.35rem,1.4cqw,2.5rem)] top-[clamp(0.35rem,1.4cqw,2.5rem)] max-[480px]:right-1.5 max-[480px]:top-1.5 z-[2] m-0 size-[clamp(0.875rem,2cqw,3.5rem)] max-[480px]:size-3.5 accent-amber-600" />
                                                <span class="variant-card-content flex h-full min-h-0 w-full flex-col gap-[clamp(0.25rem,1cqw,1.5rem)]">
                                                    <asp:Image runat="server"
                                                        Visible='<%# HasImage(Eval("ImagePath")) %>'
                                                        CssClass="variant-image aspect-square h-auto w-full rounded-[clamp(0.4rem,1.6cqw,3rem)] max-[480px]:rounded-lg bg-slate-100 object-cover"
                                                        ImageUrl='<%# ResolveProductImage(Eval("ImagePath")) %>'
                                                        AlternateText='<%# Convert.ToString(Eval("SizeName")) %>' />
                                                    <span runat="server" visible='<%# !HasImage(Eval("ImagePath")) %>'
                                                        class="variant-image-placeholder flex aspect-square w-full items-center justify-center overflow-hidden rounded-[clamp(0.4rem,1.6cqw,3rem)] max-[480px]:rounded-lg bg-slate-100 text-[clamp(1.1rem,4.5cqw,7rem)] max-[480px]:text-lg font-black text-amber-500" aria-hidden="true">PK</span>
                                                    <strong class="variant-name break-words px-[clamp(0.2rem,0.8cqw,1.25rem)] py-[clamp(0.2rem,1vh,1.5rem)] max-[480px]:py-0.5 text-center text-[clamp(0.75rem,2.7cqw,4rem)] max-[480px]:text-[0.75rem] font-bold leading-tight text-slate-900">
                                                        <%# Server.HtmlEncode(GetVariantSizeName(Eval("SizeName"))) %>
                                                    </strong>
                                                    <span class="variant-price px-[clamp(0.2rem,0.8cqw,1.25rem)] pb-[clamp(0.2rem,1vh,1.5rem)] max-[480px]:pb-0.5 text-center text-[clamp(0.75rem,2.5cqw,3.75rem)] max-[480px]:text-[0.75rem] font-extrabold text-amber-800">
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
                        <div class="product-purchase-actions fixed inset-x-0 bottom-0 z-[1041] grid min-h-[clamp(3.5rem,9vh,26rem)] max-[480px]:min-h-[3.5rem] w-full grid-cols-1 gap-[clamp(0.35rem,1.2cqw,2rem)] max-[480px]:gap-2 border-t border-slate-200 bg-white/95 px-[clamp(0.5rem,3.5cqw,6rem)] py-[clamp(0.45rem,1.8vh,2.5rem)] max-[480px]:px-3 max-[480px]:py-2 shadow-[0_-1px_6px_rgba(15,23,42,0.05)] backdrop-blur-[16px]">
                            <div class="quantity-field flex items-center justify-between gap-[clamp(0.35rem,1.5cqw,2rem)]">
                                <label class="text-[clamp(0.75rem,2.4cqw,3.75rem)] max-[480px]:text-xs font-bold text-slate-900" for="<%= txtQuantity.ClientID %>">Quantity</label>
                                <div class="quantity-control inline-grid grid-cols-[clamp(2.2rem,5.5cqw,8rem)_clamp(2.5rem,6.5cqw,10rem)_clamp(2.2rem,5.5cqw,8rem)] max-[480px]:grid-cols-[2rem_2.5rem_2rem] overflow-hidden rounded-[clamp(0.4rem,1.4cqw,2.5rem)] max-[480px]:rounded-lg border border-slate-200 bg-white shadow-sm">
                                    <button class="flex h-[clamp(2.25rem,5.2vh,12rem)] max-[480px]:h-8 items-center justify-center bg-slate-100 text-[clamp(1rem,2.8cqw,4rem)] max-[480px]:text-sm font-bold text-slate-900 transition-colors hover:bg-slate-200" type="button" data-quantity-action="decrease"
                                        aria-label="Decrease quantity">−</button>
                                    <asp:TextBox ID="txtQuantity" runat="server" Text="1" TextMode="Number" min="1"
                                        max="99" inputmode="numeric" CssClass="h-[clamp(2.25rem,5.2vh,12rem)] max-[480px]:h-8 w-full border-x border-slate-200 bg-white p-0 text-center text-[clamp(0.875rem,2.6cqw,4rem)] max-[480px]:text-xs font-bold text-slate-900" />
                                    <button class="flex h-[clamp(2.25rem,5.2vh,12rem)] max-[480px]:h-8 items-center justify-center bg-slate-100 text-[clamp(1rem,2.8cqw,4rem)] max-[480px]:text-sm font-bold text-slate-900 transition-colors hover:bg-slate-200" type="button" data-quantity-action="increase"
                                        aria-label="Increase quantity">+</button>
                                </div>
                            </div>
                            <div class="product-purchase-buttons grid grid-cols-[minmax(0,1fr)_minmax(0,1.8fr)] gap-[clamp(0.35rem,1.2cqw,2rem)] max-[480px]:gap-2">
                                <asp:LinkButton ID="btnBackToMenu" runat="server" CssClass="inline-flex min-h-[clamp(2.4rem,5.2vh,12rem)] max-[480px]:min-h-[2.4rem] items-center justify-center whitespace-nowrap rounded-[clamp(0.5rem,1.8cqw,3rem)] max-[480px]:rounded-lg border border-slate-300 bg-white px-[clamp(0.5rem,2.4cqw,3.5rem)] max-[480px]:px-2.5 text-[clamp(0.75rem,2.4cqw,3.75rem)] max-[480px]:text-xs font-bold text-slate-700 shadow-sm transition-colors hover:border-slate-400 hover:bg-slate-50"
                                    CausesValidation="false" OnClick="btnBackToMenu_Click">
                                    Back
                                </asp:LinkButton>
                                <asp:Button ID="btnAddToCart" runat="server" Text="Add to cart"
                                    CssClass="inline-flex min-h-[clamp(2.4rem,5.2vh,12rem)] max-[480px]:min-h-[2.4rem] items-center justify-center whitespace-nowrap rounded-[clamp(0.5rem,1.8cqw,3rem)] max-[480px]:rounded-lg bg-[linear-gradient(135deg,#f59e0b,#d97706)] px-[clamp(0.5rem,2.8cqw,4rem)] max-[480px]:px-2.5 text-[clamp(0.75rem,2.6cqw,4rem)] max-[480px]:text-xs font-bold tracking-tight text-white shadow-[0_4px_14px_rgba(217,119,6,0.35)] transition-[filter,transform] hover:-translate-y-0.5 hover:brightness-105" OnClick="btnAddToCart_Click" />
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
