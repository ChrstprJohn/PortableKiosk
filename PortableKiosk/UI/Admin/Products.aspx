<%@ Page
    Title="Products & Variants"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="Products.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.ProductManagement" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <main class="mx-auto w-full max-w-7xl">

        <header class="mb-7 flex flex-col items-start justify-between gap-3 sm:flex-row sm:items-end">
            <div>
                <h1 class="text-2xl font-semibold tracking-tight text-slate-950 sm:text-3xl">Products &amp; variants</h1>
                <p class="mt-1 max-w-3xl text-sm text-slate-500">Create products and manage their serving sizes, prices, and images.</p>
            </div>
            <button type="button" class="inline-flex min-h-9 items-center justify-center gap-2 rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-toggle="true" data-modal-target="#addProductModal">
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg>
                Add product
            </button>
        </header>

        <!-- GLOBAL FEEDBACK MESSAGES -->
        <asp:Label
            ID="lblGlobalMessage"
            runat="server"
            Visible="false"
            CssClass="mb-4 block rounded-md border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700">
        </asp:Label>

        <!-- PRODUCT CARDS SECTION -->
        <div class="mb-3 flex flex-wrap items-center justify-between gap-2">
            <h2 class="text-sm font-semibold text-slate-950">Product catalog</h2>
            <asp:Label ID="lblProductStats" runat="server" CssClass="text-sm text-slate-500"></asp:Label>
        </div>

        <asp:Label
            ID="lblLoadError"
            runat="server"
            Visible="false"
            CssClass="mb-4 block rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800">
        </asp:Label>

        <!-- REPEATER OF PRODUCT CARDS -->
        <div class="grid grid-cols-12 gap-4">
            <asp:Repeater ID="rptProductCards" runat="server">
                <ItemTemplate>
                    <div class="col-span-12 xl:col-span-6">
                        <div
                            class="h-full overflow-hidden rounded-lg border border-slate-200 bg-white"
                            data-existing-size-keys='<%# Eval("ExistingSizeKeys") %>'
                            data-product-id='<%# Eval("ProductID") %>'
                            data-category-id='<%# Eval("CategoryID") %>'
                            data-product-description='<%# HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("ProductDescription"))) %>'>

                            <!-- CARD HEADER -->
                            <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-4 py-3 sm:px-5">
                                <div>
                                    <span data-product-category class="inline-flex items-center rounded-md bg-slate-100 px-2 py-0.5 text-xs font-medium text-slate-600"><%# Eval("CategoryName") %></span>
                                    <h3 class="mt-1 text-sm font-semibold text-slate-950" data-product-name><%# Eval("ProductName") %></h3>
                                </div>
                                <div class="flex shrink-0 items-center gap-2">
                                    <span data-product-status class='inline-flex items-center rounded-md px-2 py-0.5 text-xs font-medium <%# (bool)Eval("IsAvailable") ? "bg-emerald-50 text-emerald-700" : "bg-slate-100 text-slate-600" %>'>
                                        <%# (bool)Eval("IsAvailable") ? "Active" : "Hidden" %>
                                    </span>
                                    <button
                                        type="button"
                                        class="inline-flex min-h-8 min-w-[104px] shrink-0 items-center justify-center gap-1.5 whitespace-nowrap rounded-md border border-slate-200 bg-white px-2.5 py-1 text-xs font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400"
                                        data-modal-toggle="true"
                                        data-modal-target="#addVariantModal"
                                        onclick='openAddVariantModal(<%# Eval("ProductID") %>, "<%# HttpUtility.JavaScriptStringEncode(Eval("ProductName").ToString()) %>", "<%# Eval("ExistingSizeKeys") %>");'>
                                        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg> Add variant
                                    </button>
                                </div>
                            </div>

                            <!-- CARD BODY: NESTED VARIANTS TABLE -->
                            <div class="p-0">
                                <%# ((System.Collections.Generic.List<PortableKiosk.Core.Models.ProductVariant>)Eval("Variants")).Count == 0
                                    ? "<div class='p-4 text-center text-slate-500 bg-slate-50 text-sm'>No variants yet. Add a size and price to make this product available.</div>"
                                    : "" %>

                                <asp:Repeater ID="rptInnerVariants" runat="server" DataSource='<%# Eval("Variants") %>'>
                                    <HeaderTemplate>
                                        <div class="w-full overflow-x-auto">
                                            <table class="w-full min-w-[600px] border-collapse text-left text-sm [&_th]:border-b [&_th]:border-slate-200 [&_th]:bg-slate-50 [&_th]:px-3 [&_th]:py-2.5 [&_th]:text-xs [&_th]:font-medium [&_th]:text-slate-500 [&_td]:px-3 [&_td]:py-2.5 [&_td]:text-slate-700 [&_tbody_tr]:border-b [&_tbody_tr]:border-slate-100 [&_tbody_tr:hover]:bg-slate-50 [&_tbody_tr:last-child]:border-b-0">
                                                <thead>
                                                    <tr>
                                                        <th class="w-[50px]">Photo</th>
                                                        <th>Size / Serving</th>
                                                        <th>Price</th>
                                                        <th>Status</th>
                                                        <th class="text-right">Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <%# !string.IsNullOrWhiteSpace(Convert.ToString(Eval("ImagePath")))
                                                    ? "<img src='" + ResolveUrl(Convert.ToString(Eval("ImagePath"))) + "' class='h-9 w-9 rounded object-cover' alt='Variant' />"
                                                    : "<span class='inline-flex items-center rounded-md px-2 py-0.5 text-xs font-medium bg-slate-50 text-slate-500 border'>No photo</span>" %>
                                            </td>
                                            <td class="font-semibold">
                                                <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeName"))) || Convert.ToString(Eval("SizeName")) == "No size"
                                                    ? "<span class='text-slate-600'>Regular / Standard</span>"
                                                    : Eval("SizeName") %>
                                            </td>
                                            <td class="font-medium tabular-nums text-slate-950">
                                                ₱<%# string.Format("{0:N2}", Eval("Price")) %>
                                            </td>
                                            <td>
                                                <span class='inline-flex items-center rounded-md px-2 py-0.5 text-xs font-medium <%# (bool)Eval("IsAvailable") ? "bg-emerald-50 text-emerald-700" : "bg-slate-100 text-slate-600" %>'>
                                                    <%# (bool)Eval("IsAvailable") ? "Available" : "Unavailable" %>
                                                </span>
                                            </td>
                                            <td class="text-right whitespace-nowrap">
                                                <div class="inline-flex items-center gap-1" role="group" aria-label="Variant actions">
                                                    <button
                                                        type="button"
                                                        class="inline-flex size-8 shrink-0 items-center justify-center rounded-md border border-slate-200 bg-white text-slate-700 transition-colors hover:bg-slate-50 hover:text-slate-950 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400"
                                                        data-modal-toggle="true"
                                                        data-modal-target="#viewVariantModal"
                                                        onclick='openViewVariantModal(this, <%# Eval("ProductVariantID") %>, "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "" : Convert.ToString(Eval("SizeID")) %>", "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "Standard / No size" : HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("SizeName"))) %>", "<%# Convert.ToDecimal(Eval("Price")).ToString("N2") %>", <%# (bool)Eval("IsAvailable") ? "true" : "false" %>, "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ImagePath"))) ? "" : HttpUtility.JavaScriptStringEncode(ResolveUrl(Convert.ToString(Eval("ImagePath")))) %>");'
                                                        aria-label="View <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "standard variant" : HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("SizeName"))) %>"
                                                        title="View variant">
                                                        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2.5 12s3.3-6 9.5-6 9.5 6 9.5 6-3.3 6-9.5 6-9.5-6-9.5-6Z" /><circle cx="12" cy="12" r="2.5" /></svg>
                                                    </button>
                                                    <button
                                                        type="button"
                                                        class="inline-flex size-8 shrink-0 items-center justify-center rounded-md border border-slate-200 bg-white text-slate-700 transition-colors hover:bg-slate-50 hover:text-slate-950 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400"
                                                        data-modal-toggle="true"
                                                        data-modal-target="#editVariantModal"
                                                        onclick='openEditVariantModal(this, <%# Eval("ProductVariantID") %>, "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "NONE" : Convert.ToString(Eval("SizeID")) %>", "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "Standard / No size" : HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("SizeName"))) %>", "<%# Convert.ToDecimal(Eval("Price")).ToString(System.Globalization.CultureInfo.InvariantCulture) %>", <%# (bool)Eval("IsAvailable") ? "true" : "false" %>, "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ImagePath"))) ? "" : HttpUtility.JavaScriptStringEncode(ResolveUrl(Convert.ToString(Eval("ImagePath")))) %>");'
                                                        aria-label="Edit <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "standard variant" : HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("SizeName"))) %>"
                                                        title="Edit variant">
                                                        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20h9" /><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z" /></svg>
                                                    </button>
                                                    <button
                                                        type="button"
                                                        class="inline-flex size-8 shrink-0 items-center justify-center rounded-md border border-slate-200 bg-white text-slate-600 transition-colors hover:bg-red-50 hover:text-red-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400"
                                                        data-modal-toggle="true"
                                                        data-modal-target="#deleteVariantModal"
                                                        onclick='openDeleteVariantModal(this, <%# Eval("ProductVariantID") %>, "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "Standard / No size" : HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("SizeName"))) %>");'
                                                        aria-label="Delete <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "standard variant" : HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("SizeName"))) %>"
                                                        title="Delete variant">
                                                        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 6h18" /><path d="M8 6V4h8v2" /><path d="m19 6-1 14H6L5 6" /><path d="M10 11v5M14 11v5" /></svg>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                                </tbody>
                                            </table>
                                        </div>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>

                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- EMPTY STATE IF NO PRODUCTS -->
        <asp:Panel ID="pnlNoProducts" runat="server" Visible="false" CssClass="mt-3 rounded-lg border border-slate-200 bg-white p-8 text-center text-slate-500">
            <h3 class="text-sm font-semibold text-slate-900">No products yet</h3>
            <p class="mb-0 text-sm">Add your first product to get started.</p>
        </asp:Panel>

    </main>

    <!-- ADD PRODUCT MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="addProductModal" tabindex="-1" aria-labelledby="addProductModalLabel" aria-hidden="true">
        <div class="w-full max-w-md">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-base font-semibold text-slate-950" id="addProductModalLabel">Add product</h2>
                    <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close">
                        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg>
                    </button>
                </div>
                <div class="space-y-4 overflow-y-auto p-5">
                    <asp:ValidationSummary ID="validationSummaryProduct" runat="server" ValidationGroup="ProductForm" CssClass="rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800" HeaderText="Please correct the following:" DisplayMode="BulletList" />
                    <div class="grid grid-cols-1 gap-4">
                        <div>
                            <asp:Label ID="lblCategory" runat="server" AssociatedControlID="ddlCategory" CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Category"></asp:Label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200"></asp:DropDownList>
                            <asp:RequiredFieldValidator ID="requiredCategory" runat="server" ControlToValidate="ddlCategory" InitialValue="" ValidationGroup="ProductForm" ErrorMessage="Category is required." CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                        </div>
                        <div>
                            <asp:Label ID="lblProductName" runat="server" AssociatedControlID="txtProductName" CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Product name"></asp:Label>
                            <asp:TextBox ID="txtProductName" runat="server" CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" MaxLength="100" placeholder="e.g. Caramel Macchiato" autofocus="autofocus"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="requiredProductName" runat="server" ControlToValidate="txtProductName" ValidationGroup="ProductForm" ErrorMessage="Product name is required." CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <asp:CheckBox ID="chkIsAvailable" runat="server" Checked="true" CssClass="[&_input]:size-4 [&_input]:accent-slate-900" />
                        <label class="text-sm text-slate-700" for="<%= chkIsAvailable.ClientID %>">Available for ordering</label>
                    </div>
                </div>
                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4">
                    <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Cancel</button>
                    <asp:Button ID="btnAddProduct" runat="server" Text="Add product" CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" ValidationGroup="ProductForm" OnClick="btnAddProduct_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- ADD VARIANTS MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="addVariantModal" tabindex="-1" aria-labelledby="addVariantModalLabel" aria-hidden="true">
        <div class="w-full max-w-3xl">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">

                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-base font-semibold text-slate-950" id="addVariantModalLabel">Add variants</h2>
                    <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close"><svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
                </div>

                <div class="overflow-y-auto p-5">

                    <asp:ValidationSummary
                        ID="validationSummaryVariant"
                        runat="server"
                        ValidationGroup="VariantModalForm"
                        CssClass="rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800"
                        HeaderText="Please correct the following errors:"
                        DisplayMode="BulletList" />

                    <!-- TARGET PRODUCT INFO -->
                    <div class="mb-3">
                        <label class="mb-1.5 block text-sm font-medium text-slate-700">Target product</label>
                        <div id="modalDisplayProductName" class="rounded-md border border-slate-200 bg-slate-50 px-3 py-2 text-sm font-medium text-slate-900"></div>
                        <asp:HiddenField ID="hfModalProductID" runat="server" />
                    </div>

                    <!-- PROGRESSIVE VARIANT ROWS -->
                    <fieldset class="mb-4">
                        <legend class="mb-1 text-sm font-medium text-slate-900">Set up each variant</legend>
                        <p class="mb-3 text-sm text-slate-500">Add a size, price, and optional image.</p>
                        <div
                            id="existingVariantNotice"
                            class="hidden rounded-md border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700"
                            role="status">
                            Sizes marked “already added” are unavailable.
                        </div>

                        <div id="bulkVariantRows">
                            <asp:Repeater
                                ID="rptBulkVariantRows"
                                runat="server"
                                OnItemDataBound="rptBulkVariantRows_ItemDataBound">
                                <ItemTemplate>
                                    <div class='<%# Container.ItemIndex == 0 ? "bulk-variant-row mb-3 rounded-md border border-slate-200 bg-white p-3" : "bulk-variant-row mb-3 rounded-md border border-slate-200 bg-white p-3 hidden" %>'>
                                        <div class="flex items-center justify-between mb-3">
                                            <span class="text-sm font-semibold text-slate-600">
                                                Variant <span class="bulk-variant-number"><%# Container.ItemIndex + 1 %></span>
                                            </span>
                                            <button
                                                type="button"
                                                class="inline-flex min-h-8 items-center justify-center gap-1.5 rounded-md border border-slate-200 bg-white px-2.5 py-1 text-xs font-medium text-slate-600 transition-colors hover:bg-red-50 hover:text-red-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400 bulk-variant-remove"
                                                aria-label="Remove this variant row">
                                                Remove
                                            </button>
                                        </div>

                                        <div class="grid grid-cols-12 gap-3 items-end">
                                            <div class="col-span-12 md:col-span-4">
                                                <label class="mb-1.5 block text-sm font-medium text-slate-700">Size / serving</label>
                                                <asp:DropDownList
                                                    ID="ddlBulkSize"
                                                    runat="server"
                                                    CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200 bulk-variant-size">
                                                </asp:DropDownList>
                                            </div>

                                            <div class="col-span-12 md:col-span-3">
                                                <label class="mb-1.5 block text-sm font-medium text-slate-700">Price</label>
                                                <div class="flex w-full">
                                                    <span class="inline-flex items-center rounded-l-md border border-r-0 border-slate-200 bg-slate-50 px-3 text-sm text-slate-600">₱</span>
                                                    <asp:TextBox
                                                        ID="txtBulkPrice"
                                                        runat="server"
                                                        CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200 bulk-variant-price"
                                                        TextMode="Number"
                                                        step="0.01"
                                                        min="0"
                                                        max="99999999.99"
                                                        inputmode="decimal"
                                                        placeholder="0.00">
                                                    </asp:TextBox>
                                                </div>
                                            </div>

                                            <div class="col-span-12 md:col-span-5">
                                                <label class="mb-1.5 block text-sm font-medium text-slate-700">Image <span class="font-normal text-slate-500">(optional)</span></label>
                                                <asp:FileUpload
                                                    ID="uploadBulkImage"
                                                    runat="server"
                                                    CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200 bulk-variant-image"
                                                    accept=".jpg,.jpeg,.png,.webp" />
                                                <div class="text-sm text-slate-500">JPG, PNG, or WebP; maximum 3 MB.</div>
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <button
                            type="button"
                            id="btnAddAnotherVariant"
                            class="inline-flex min-h-9 items-center justify-center gap-2 rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400">
                            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg>Add another size
                        </button>
                    </fieldset>

                    <!-- STATUS -->
                    <div class="mb-3">
                        <label class="mb-1 block text-sm font-semibold text-slate-700">Status</label>
                        <div class="flex items-center gap-2">
                            <asp:CheckBox
                                ID="chkModalIsAvailable"
                                runat="server"
                                Checked="true"
                                CssClass="[&_input]:size-4 [&_input]:accent-slate-900" />
                            <label class="text-sm text-slate-700" for="<%= chkModalIsAvailable.ClientID %>">Make all new variants available for order</label>
                        </div>
                    </div>

                </div>

                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4">
                    <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Cancel</button>
                    <asp:Button
                        ID="btnSaveModalVariant"
                        runat="server"
                        Text="Save variants"
                        CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800"
                        ValidationGroup="VariantModalForm"
                        OnClick="btnSaveModalVariant_Click" />
                </div>

            </div>
        </div>
    </div>

    <!-- VIEW VARIANT MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="viewVariantModal" tabindex="-1" aria-labelledby="viewVariantModalLabel" aria-hidden="true">
        <div class="w-full max-w-md">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-base font-semibold text-slate-950" id="viewVariantModalLabel">Variant details</h2>
                    <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close"><svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
                </div>
                <div class="overflow-y-auto p-5">
                    <div class="mb-4">
                        <h3 class="mb-2 text-sm font-medium text-slate-700">Variant image</h3>
                        <div id="viewVariantImageWrap" class="hidden overflow-hidden rounded-md border border-slate-200 bg-slate-50">
                            <img id="viewVariantImage" class="max-h-56 w-full object-contain" alt="Variant image" />
                        </div>
                        <p id="viewVariantNoImage" class="mb-0 rounded-md border border-dashed border-slate-200 bg-slate-50 px-3 py-5 text-center text-sm text-slate-500">No image</p>
                    </div>
                    <dl class="divide-y divide-slate-100">
                        <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3 first:pt-0">
                            <dt class="text-sm text-slate-500">Product</dt>
                            <dd id="viewVariantProduct" class="m-0 text-sm font-medium text-slate-900"></dd>
                        </div>
                        <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3">
                            <dt class="text-sm text-slate-500">Product ID</dt>
                            <dd id="viewVariantProductId" class="m-0 text-sm font-medium tabular-nums text-slate-900"></dd>
                        </div>
                        <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3">
                            <dt class="text-sm text-slate-500">Category</dt>
                            <dd id="viewVariantCategory" class="m-0 text-sm font-medium text-slate-900"></dd>
                        </div>
                        <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3">
                            <dt class="text-sm text-slate-500">Category ID</dt>
                            <dd id="viewVariantCategoryId" class="m-0 text-sm font-medium tabular-nums text-slate-900"></dd>
                        </div>
                        <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3">
                            <dt class="text-sm text-slate-500">Description</dt>
                            <dd id="viewVariantDescription" class="m-0 break-words whitespace-pre-wrap text-sm text-slate-700"></dd>
                        </div>
                        <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3">
                            <dt class="text-sm text-slate-500">Product status</dt>
                            <dd id="viewVariantProductStatus" class="m-0 text-sm font-medium text-slate-900"></dd>
                        </div>
                        <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3">
                            <dt class="text-sm text-slate-500">Size / serving</dt>
                            <dd id="viewVariantSize" class="m-0 text-sm font-medium text-slate-900"></dd>
                        </div>
                        <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3">
                            <dt class="text-sm text-slate-500">Size ID</dt>
                            <dd id="viewVariantSizeId" class="m-0 text-sm font-medium tabular-nums text-slate-900"></dd>
                        </div>
                        <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3">
                            <dt class="text-sm text-slate-500">Variant ID</dt>
                            <dd id="viewVariantId" class="m-0 text-sm font-medium tabular-nums text-slate-900"></dd>
                        </div>
                        <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3">
                            <dt class="text-sm text-slate-500">Price</dt>
                            <dd id="viewVariantPrice" class="m-0 text-sm font-medium tabular-nums text-slate-900"></dd>
                        </div>
                        <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3 last:pb-0">
                            <dt class="text-sm text-slate-500">Status</dt>
                            <dd class="m-0"><span id="viewVariantStatus" class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-medium"></span></dd>
                        </div>
                    </dl>
                </div>
                <div class="flex justify-end border-t border-slate-200 px-5 py-4">
                    <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- EDIT VARIANT MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="editVariantModal" tabindex="-1" aria-labelledby="editVariantModalLabel" aria-hidden="true">
        <div class="w-full max-w-lg">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-base font-semibold text-slate-950" id="editVariantModalLabel">Edit variant</h2>
                    <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close"><svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
                </div>

                <div class="overflow-y-auto p-5">
                    <asp:ValidationSummary
                        ID="validationSummaryEditVariant"
                        runat="server"
                        ValidationGroup="EditVariantForm"
                        CssClass="rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800"
                        HeaderText="Please correct the following errors:"
                        DisplayMode="BulletList" />

                    <asp:HiddenField ID="hfEditVariantID" runat="server" />

                    <div class="mb-3">
                        <label class="mb-1.5 block text-sm font-medium text-slate-700">Product</label>
                        <div id="editVariantProductName" class="rounded-md border border-slate-200 bg-slate-50 px-3 py-2 text-sm font-medium text-slate-900"></div>
                    </div>

                    <div class="mb-3">
                        <label class="mb-1 block text-sm font-semibold text-slate-700" for="<%= ddlEditVariantSize.ClientID %>">Size / Serving</label>
                        <asp:DropDownList
                            ID="ddlEditVariantSize"
                            runat="server"
                            CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator
                            ID="requiredEditVariantSize"
                            runat="server"
                            ControlToValidate="ddlEditVariantSize"
                            InitialValue=""
                            ValidationGroup="EditVariantForm"
                            ErrorMessage="Choose a size or serving."
                            CssClass="text-red-700 text-sm"
                            Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label class="mb-1 block text-sm font-semibold text-slate-700" for="<%= txtEditVariantPrice.ClientID %>">Price</label>
                        <div class="flex w-full">
                            <span class="inline-flex items-center rounded-l-md border border-r-0 border-slate-200 bg-slate-50 px-3 text-sm text-slate-600">₱</span>
                            <asp:TextBox
                                ID="txtEditVariantPrice"
                                runat="server"
                                CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200"
                                TextMode="Number"
                                step="0.01"
                                min="0"
                                max="99999999.99"
                                inputmode="decimal">
                            </asp:TextBox>
                        </div>
                        <asp:RequiredFieldValidator
                            ID="requiredEditVariantPrice"
                            runat="server"
                            ControlToValidate="txtEditVariantPrice"
                            ValidationGroup="EditVariantForm"
                            ErrorMessage="Enter a price."
                            CssClass="text-red-700 text-sm"
                            Display="Dynamic" />
                        <asp:RangeValidator
                            ID="rangeEditVariantPrice"
                            runat="server"
                            ControlToValidate="txtEditVariantPrice"
                            ValidationGroup="EditVariantForm"
                            Type="Currency"
                            MinimumValue="0"
                            MaximumValue="99999999.99"
                            ErrorMessage="Price must be between 0 and 99,999,999.99."
                            CssClass="text-red-700 text-sm"
                            Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label class="mb-1 block text-sm font-semibold text-slate-700" for="<%= uploadEditVariantImage.ClientID %>">Replace image <span class="text-slate-500">(optional)</span></label>
                        <div id="editVariantImagePreview" class="hidden mb-2">
                            <img id="editVariantCurrentImage" class="h-[72px] w-[72px] rounded border object-cover" alt="Current variant" />
                            <span class="text-sm text-slate-500 ml-2">Current image</span>
                        </div>
                        <asp:FileUpload
                            ID="uploadEditVariantImage"
                            runat="server"
                            CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200"
                            accept=".jpg,.jpeg,.png,.webp" />
                        <div class="text-sm text-slate-500">Leave empty to keep the current image. JPG, PNG, or WebP; maximum 3 MB.</div>
                    </div>

                    <div class="flex items-center gap-2">
                        <asp:CheckBox
                            ID="chkEditVariantIsAvailable"
                            runat="server"
                            CssClass="[&_input]:size-4 [&_input]:accent-slate-900" />
                        <label class="text-sm text-slate-700" for="<%= chkEditVariantIsAvailable.ClientID %>">Available for ordering</label>
                    </div>
                </div>

                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4">
                    <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Cancel</button>
                    <asp:Button
                        ID="btnUpdateVariant"
                        runat="server"
                        Text="Save changes"
                        CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800"
                        ValidationGroup="EditVariantForm"
                        OnClick="btnUpdateVariant_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- DELETE VARIANT MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="deleteVariantModal" tabindex="-1" aria-labelledby="deleteVariantModalLabel" aria-hidden="true">
        <div class="w-full max-w-lg">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-base font-semibold text-slate-950" id="deleteVariantModalLabel">Delete variant?</h2>
                    <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close"><svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
                </div>

                <div class="overflow-y-auto p-5">
                    <asp:HiddenField ID="hfDeleteVariantID" runat="server" />
                    <p class="mb-2">Delete <strong id="deleteVariantName"></strong>?</p>
                    <p class="text-sm text-slate-500">This also deletes its stored image. This cannot be undone.</p>
                </div>

                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4">
                    <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Cancel</button>
                    <asp:Button
                        ID="btnDeleteVariant"
                        runat="server"
                        Text="Delete variant"
                        CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-red-600 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-red-700"
                        CausesValidation="false"
                        OnClick="btnDeleteVariant_Click" />
                </div>
            </div>
        </div>
    </div>

    <script src="<%= ResolveUrl("~/Scripts/app/admin/products.js") %>"></script>

</asp:Content>
