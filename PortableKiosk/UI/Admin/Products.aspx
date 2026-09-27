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

    <div class="w-full px-4 mt-4">

        <header class="page-heading mb-4 flex justify-between items-center flex-wrap gap-2">
            <div>
                <h1>Products & Variants Management</h1>
                <p class="text-slate-500 mb-0">Create base products and manage multiple serving sizes, prices, and images inside each product card.</p>
            </div>
            <div>
                <a href="<%= ResolveUrl("~/UI/Admin/CatalogConfig.aspx") %>" class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-slate-500 bg-transparent text-slate-700 hover:bg-slate-100 px-3 py-1.5 text-sm">
                    <i class="bi bi-gear-fill mr-1"></i> Configure Categories & Sizes
                </a>
            </div>
        </header>

        <!-- GLOBAL FEEDBACK MESSAGES -->
        <asp:Label
            ID="lblGlobalMessage"
            runat="server"
            Visible="false"
            CssClass="rounded-lg border px-4 py-3 border-sky-200 bg-sky-50 text-sky-800 block shadow-sm mb-4">
        </asp:Label>

        <!-- TOP BAR: ADD NEW PRODUCT FORM -->
        <div class="rounded-xl bg-white shadow-sm mb-4">
            <div class="border-b border-slate-200 px-5 py-4 bg-blue-700 text-white flex justify-between items-center">
                <strong><i class="bi bi-plus-circle-fill mr-1"></i> Add New Product</strong>
                <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold bg-slate-50 text-blue-700">Base catalog item</span>
            </div>

            <div class="p-5 bg-slate-50">

                <asp:ValidationSummary
                    ID="validationSummaryProduct"
                    runat="server"
                    ValidationGroup="ProductForm"
                    CssClass="rounded-lg border px-4 py-3 border-red-200 bg-red-50 text-red-800"
                    HeaderText="Please correct the following errors:"
                    DisplayMode="BulletList" />

                <div class="grid grid-cols-12 gap-3 items-end">

                    <!-- CATEGORY -->
                    <div class="col-span-12 md:col-span-3">
                        <asp:Label
                            ID="lblCategory"
                            runat="server"
                            AssociatedControlID="ddlCategory"
                            CssClass="mb-1 block text-sm font-semibold text-slate-700"
                            Text="Category">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlCategory"
                            runat="server"
                            CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200">
                        </asp:DropDownList>

                        <asp:RequiredFieldValidator
                            ID="requiredCategory"
                            runat="server"
                            ControlToValidate="ddlCategory"
                            InitialValue=""
                            ValidationGroup="ProductForm"
                            ErrorMessage="Category is required."
                            CssClass="text-red-700 text-sm"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- PRODUCT NAME -->
                    <div class="col-span-12 md:col-span-4">
                        <asp:Label
                            ID="lblProductName"
                            runat="server"
                            AssociatedControlID="txtProductName"
                            CssClass="mb-1 block text-sm font-semibold text-slate-700"
                            Text="Product name">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtProductName"
                            runat="server"
                            CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200"
                            MaxLength="100"
                            placeholder="e.g. Caramel Macchiato, Crispy Chicken">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredProductName"
                            runat="server"
                            ControlToValidate="txtProductName"
                            ValidationGroup="ProductForm"
                            ErrorMessage="Product name is required."
                            CssClass="text-red-700 text-sm"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- STATUS -->
                    <div class="col-span-12 md:col-span-1">
                        <label class="mb-1 block text-sm font-semibold text-slate-700">Status</label>
                        <div class="flex items-center gap-2 mt-2">
                            <asp:CheckBox
                                ID="chkIsAvailable"
                                runat="server"
                                Checked="true"
                                CssClass="h-4 w-4 accent-blue-700 [&_input]:h-4 [&_input]:w-4 [&_input]:accent-blue-700" />
                            <label class="text-sm text-slate-700 text-sm" for="<%= chkIsAvailable.ClientID %>">Active</label>
                        </div>
                    </div>

                    <!-- SUBMIT BUTTON -->
                    <div class="col-span-12 md:col-span-2">
                        <asp:Button
                            ID="btnAddProduct"
                            runat="server"
                            Text="+ Create Product"
                            CssClass="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-blue-700 bg-blue-700 text-white hover:bg-blue-800 w-full"
                            ValidationGroup="ProductForm"
                            OnClick="btnAddProduct_Click" />
                    </div>

                </div>

            </div>
        </div>

        <!-- PRODUCT CARDS SECTION -->
        <div class="flex justify-between items-center mb-3">
            <h4 class="mb-0">Product Catalog & Serving Variants</h4>
            <asp:Label ID="lblProductStats" runat="server" CssClass="text-slate-500 text-sm"></asp:Label>
        </div>

        <asp:Label
            ID="lblLoadError"
            runat="server"
            Visible="false"
            CssClass="rounded-lg border px-4 py-3 border-red-200 bg-red-50 text-red-800 block">
        </asp:Label>

        <!-- REPEATER OF PRODUCT CARDS -->
        <div class="grid grid-cols-12 gap-4">
            <asp:Repeater ID="rptProductCards" runat="server">
                <ItemTemplate>
                    <div class="col-span-12 xl:col-span-6">
                        <div
                            class="rounded-xl border border-slate-200 bg-white shadow-sm h-full border"
                            data-existing-size-keys='<%# Eval("ExistingSizeKeys") %>'>

                            <!-- CARD HEADER -->
                            <div class="border-b border-slate-200 px-5 py-4 bg-white flex justify-between items-center py-3">
                                <div>
                                    <span class="inline-flex items-center rounded-full bg-slate-600 px-2.5 py-0.5 text-xs font-semibold text-white mb-1"><%# Eval("CategoryName") %></span>
                                    <h5 class="mb-0 text-slate-900 font-bold" data-product-name><%# Eval("ProductName") %></h5>
                                    <small class="text-slate-500">ID: #<%# Eval("ProductID") %></small>
                                </div>
                                <div class="flex items-center gap-2">
                                    <span class='inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold text-white <%# (bool)Eval("IsAvailable") ? "bg-emerald-700" : "bg-slate-600" %>'>
                                        <%# (bool)Eval("IsAvailable") ? "Active" : "Hidden" %>
                                    </span>
                                    <button
                                        type="button"
                                        class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors px-3 py-1.5 text-sm border-blue-700 bg-transparent text-blue-700 hover:bg-blue-50"
                                        data-modal-toggle="true"
                                        data-modal-target="#addVariantModal"
                                        onclick='openAddVariantModal(<%# Eval("ProductID") %>, "<%# HttpUtility.JavaScriptStringEncode(Eval("ProductName").ToString()) %>", "<%# Eval("ExistingSizeKeys") %>");'>
                                        <i class="bi bi-plus"></i> Add Variants
                                    </button>
                                </div>
                            </div>

                            <!-- CARD BODY: NESTED VARIANTS TABLE -->
                            <div class="p-0">
                                <%# ((System.Collections.Generic.List<PortableKiosk.Core.Models.ProductVariant>)Eval("Variants")).Count == 0
                                    ? "<div class='p-4 text-center text-slate-500 bg-slate-50 text-sm'><i class='bi bi-info-circle mr-1'></i> No variants yet. Customers won't see this product in kiosk until you add at least one serving size & price.</div>"
                                    : "" %>

                                <asp:Repeater ID="rptInnerVariants" runat="server" DataSource='<%# Eval("Variants") %>'>
                                    <HeaderTemplate>
                                        <div class="w-full overflow-x-auto">
                                            <table class="w-full border-collapse text-left [&_th]:px-3 [&_th]:py-2 [&_td]:px-3 [&_td]:py-2 [&_tbody_tr]:border-b [&_tbody_tr]:border-slate-200 [&_tbody_tr:hover]:bg-slate-50 align-middle mb-0 text-sm">
                                                <thead class="bg-slate-100">
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
                                                    : "<span class='inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold bg-slate-50 text-slate-500 border'>No photo</span>" %>
                                            </td>
                                            <td class="font-semibold">
                                                <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeName"))) || Convert.ToString(Eval("SizeName")) == "No size"
                                                    ? "<span class='text-slate-600'>Regular / Standard</span>"
                                                    : Eval("SizeName") %>
                                            </td>
                                            <td class="text-blue-700 font-bold">
                                                ₱<%# string.Format("{0:N2}", Eval("Price")) %>
                                            </td>
                                            <td>
                                                <span class='inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold <%# (bool)Eval("IsAvailable") ? "bg-emerald-50 text-emerald-700" : "bg-slate-100 text-slate-600" %>'>
                                                    <%# (bool)Eval("IsAvailable") ? "Available" : "Unavailable" %>
                                                </span>
                                            </td>
                                            <td class="text-right whitespace-nowrap">
                                                <div class="inline-flex text-sm" role="group" aria-label="Variant actions">
                                                    <button
                                                        type="button"
                                                        class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-blue-700 bg-transparent text-blue-700 hover:bg-blue-50"
                                                        data-modal-toggle="true"
                                                        data-modal-target="#editVariantModal"
                                                        onclick='openEditVariantModal(this, <%# Eval("ProductVariantID") %>, "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "NONE" : Convert.ToString(Eval("SizeID")) %>", "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "Standard / No size" : HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("SizeName"))) %>", "<%# Convert.ToDecimal(Eval("Price")).ToString(System.Globalization.CultureInfo.InvariantCulture) %>", <%# (bool)Eval("IsAvailable") ? "true" : "false" %>, "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ImagePath"))) ? "" : HttpUtility.JavaScriptStringEncode(ResolveUrl(Convert.ToString(Eval("ImagePath")))) %>");'
                                                        aria-label="Edit <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "standard variant" : HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("SizeName"))) %>">
                                                        <i class="bi bi-pencil"></i>
                                                    </button>
                                                    <button
                                                        type="button"
                                                        class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-red-700 bg-transparent text-red-700 hover:bg-red-50"
                                                        data-modal-toggle="true"
                                                        data-modal-target="#deleteVariantModal"
                                                        onclick='openDeleteVariantModal(this, <%# Eval("ProductVariantID") %>, "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "Standard / No size" : HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("SizeName"))) %>");'
                                                        aria-label="Delete <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "standard variant" : HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("SizeName"))) %>">
                                                        <i class="bi bi-trash"></i>
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
        <asp:Panel ID="pnlNoProducts" runat="server" Visible="false" CssClass="rounded-xl border border-slate-200 bg-white shadow-sm p-5 text-center text-slate-500 mt-3">
            <h5>No products created yet.</h5>
            <p class="mb-0">Use the form above to add your first product.</p>
        </asp:Panel>

    </div>

    <!-- ADD VARIANTS MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/60 p-4" id="addVariantModal" tabindex="-1" aria-labelledby="addVariantModalLabel" aria-hidden="true">
        <div class="w-full max-w-3xl">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-xl bg-white shadow-xl">

                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4 bg-blue-700 text-white">
                    <h5 class="text-lg font-semibold" id="addVariantModalLabel">
                        <i class="bi bi-plus-square-fill mr-1"></i> Add Product Variants
                    </h5>
                    <button type="button" class="inline-flex h-8 w-8 items-center justify-center rounded-full text-2xl leading-none hover:bg-black/10 text-white" data-modal-dismiss="true" aria-label="Close">&times;</button>
                </div>

                <div class="overflow-y-auto p-5">

                    <asp:ValidationSummary
                        ID="validationSummaryVariant"
                        runat="server"
                        ValidationGroup="VariantModalForm"
                        CssClass="rounded-lg border px-4 py-3 border-red-200 bg-red-50 text-red-800"
                        HeaderText="Please correct the following errors:"
                        DisplayMode="BulletList" />

                    <!-- TARGET PRODUCT INFO -->
                    <div class="mb-3">
                        <label class="mb-1 block text-sm font-semibold text-slate-700 text-slate-500 text-sm">Target Product</label>
                        <div id="modalDisplayProductName" class="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200 bg-slate-50 font-bold text-blue-700"></div>
                        <asp:HiddenField ID="hfModalProductID" runat="server" />
                    </div>

                    <!-- PROGRESSIVE VARIANT ROWS -->
                    <fieldset class="mb-4">
                        <legend class="h6 mb-1">Set up each variant</legend>
                        <p class="text-slate-500 text-sm mb-3">
                            Start with one size. Add another row only when you need another variant.
                        </p>
                        <div
                            id="existingVariantNotice"
                            class="rounded-lg border px-4 py-3 border-slate-200 bg-slate-50 text-slate-700 border text-sm py-2 hidden"
                            role="status">
                            <i class="bi bi-info-circle mr-1"></i>
                            Sizes marked “already added” are unavailable for this product.
                        </div>

                        <div id="bulkVariantRows">
                            <asp:Repeater
                                ID="rptBulkVariantRows"
                                runat="server"
                                OnItemDataBound="rptBulkVariantRows_ItemDataBound">
                                <ItemTemplate>
                                    <div class='<%# Container.ItemIndex == 0 ? "bulk-variant-row border rounded-xl p-3 mb-3" : "bulk-variant-row border rounded-xl p-3 mb-3 hidden" %>'>
                                        <div class="flex items-center justify-between mb-3">
                                            <span class="text-sm font-semibold text-slate-600">
                                                Variant <span class="bulk-variant-number"><%# Container.ItemIndex + 1 %></span>
                                            </span>
                                            <button
                                                type="button"
                                                class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors px-3 py-1.5 text-sm border-red-700 bg-transparent text-red-700 hover:bg-red-50 bulk-variant-remove"
                                                aria-label="Remove this variant row">
                                                <i class="bi bi-trash mr-1"></i>Remove
                                            </button>
                                        </div>

                                        <div class="grid grid-cols-12 gap-3 items-end">
                                            <div class="col-span-12 col-span-12 md:col-span-4">
                                                <label class="mb-1 block text-sm font-semibold text-slate-700 text-sm font-semibold">Size / Serving</label>
                                                <asp:DropDownList
                                                    ID="ddlBulkSize"
                                                    runat="server"
                                                    CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200 bulk-variant-size">
                                                </asp:DropDownList>
                                            </div>

                                            <div class="col-span-12 col-span-12 md:col-span-3">
                                                <label class="mb-1 block text-sm font-semibold text-slate-700 text-sm font-semibold">Price</label>
                                                <div class="flex w-full">
                                                    <span class="inline-flex items-center rounded-l-lg border border-r-0 border-slate-300 bg-slate-100 px-3 text-slate-700">₱</span>
                                                    <asp:TextBox
                                                        ID="txtBulkPrice"
                                                        runat="server"
                                                        CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200 bulk-variant-price"
                                                        TextMode="Number"
                                                        step="0.01"
                                                        min="0"
                                                        max="99999999.99"
                                                        inputmode="decimal"
                                                        placeholder="0.00">
                                                    </asp:TextBox>
                                                </div>
                                            </div>

                                            <div class="col-span-12 col-span-12 md:col-span-5">
                                                <label class="mb-1 block text-sm font-semibold text-slate-700 text-sm font-semibold">Image <span class="fw-normal text-slate-500">(optional)</span></label>
                                                <asp:FileUpload
                                                    ID="uploadBulkImage"
                                                    runat="server"
                                                    CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200 bulk-variant-image"
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
                            class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-blue-700 bg-transparent text-blue-700 hover:bg-blue-50">
                            <i class="bi bi-plus-lg mr-1"></i>Add another size
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
                                CssClass="h-4 w-4 accent-blue-700 [&_input]:h-4 [&_input]:w-4 [&_input]:accent-blue-700" />
                            <label class="text-sm text-slate-700" for="<%= chkModalIsAvailable.ClientID %>">Make all new variants available for order</label>
                        </div>
                    </div>

                </div>

                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4 bg-slate-50">
                    <button type="button" class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-slate-600 bg-slate-600 text-white hover:bg-slate-700" data-modal-dismiss="true">Cancel</button>
                    <asp:Button
                        ID="btnSaveModalVariant"
                        runat="server"
                        Text="Save All Variants"
                        CssClass="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-blue-700 bg-blue-700 text-white hover:bg-blue-800"
                        ValidationGroup="VariantModalForm"
                        OnClick="btnSaveModalVariant_Click" />
                </div>

            </div>
        </div>
    </div>

    <!-- EDIT VARIANT MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/60 p-4" id="editVariantModal" tabindex="-1" aria-labelledby="editVariantModalLabel" aria-hidden="true">
        <div class="w-full max-w-lg">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-xl bg-white shadow-xl">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4 bg-blue-700 text-white">
                    <h5 class="text-lg font-semibold" id="editVariantModalLabel">
                        <i class="bi bi-pencil-square mr-1"></i>Edit Product Variant
                    </h5>
                    <button type="button" class="inline-flex h-8 w-8 items-center justify-center rounded-full text-2xl leading-none hover:bg-black/10 text-white" data-modal-dismiss="true" aria-label="Close">&times;</button>
                </div>

                <div class="overflow-y-auto p-5">
                    <asp:ValidationSummary
                        ID="validationSummaryEditVariant"
                        runat="server"
                        ValidationGroup="EditVariantForm"
                        CssClass="rounded-lg border px-4 py-3 border-red-200 bg-red-50 text-red-800"
                        HeaderText="Please correct the following errors:"
                        DisplayMode="BulletList" />

                    <asp:HiddenField ID="hfEditVariantID" runat="server" />

                    <div class="mb-3">
                        <label class="mb-1 block text-sm font-semibold text-slate-700 text-slate-500 text-sm">Product</label>
                        <div id="editVariantProductName" class="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200 bg-slate-50 font-semibold"></div>
                    </div>

                    <div class="mb-3">
                        <label class="mb-1 block text-sm font-semibold text-slate-700" for="<%= ddlEditVariantSize.ClientID %>">Size / Serving</label>
                        <asp:DropDownList
                            ID="ddlEditVariantSize"
                            runat="server"
                            CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200">
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
                            <span class="inline-flex items-center rounded-l-lg border border-r-0 border-slate-300 bg-slate-100 px-3 text-slate-700">₱</span>
                            <asp:TextBox
                                ID="txtEditVariantPrice"
                                runat="server"
                                CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200"
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
                            CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200"
                            accept=".jpg,.jpeg,.png,.webp" />
                        <div class="text-sm text-slate-500">Leave empty to keep the current image. JPG, PNG, or WebP; maximum 3 MB.</div>
                    </div>

                    <div class="flex items-center gap-2">
                        <asp:CheckBox
                            ID="chkEditVariantIsAvailable"
                            runat="server"
                            CssClass="h-4 w-4 accent-blue-700 [&_input]:h-4 [&_input]:w-4 [&_input]:accent-blue-700" />
                        <label class="text-sm text-slate-700" for="<%= chkEditVariantIsAvailable.ClientID %>">Available for ordering</label>
                    </div>
                </div>

                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4 bg-slate-50">
                    <button type="button" class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-slate-600 bg-slate-600 text-white hover:bg-slate-700" data-modal-dismiss="true">Cancel</button>
                    <asp:Button
                        ID="btnUpdateVariant"
                        runat="server"
                        Text="Save Changes"
                        CssClass="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-blue-700 bg-blue-700 text-white hover:bg-blue-800"
                        ValidationGroup="EditVariantForm"
                        OnClick="btnUpdateVariant_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- DELETE VARIANT MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/60 p-4" id="deleteVariantModal" tabindex="-1" aria-labelledby="deleteVariantModalLabel" aria-hidden="true">
        <div class="w-full max-w-lg">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-xl bg-white shadow-xl">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4 bg-red-700 text-white">
                    <h5 class="text-lg font-semibold" id="deleteVariantModalLabel">
                        <i class="bi bi-exclamation-triangle-fill mr-1"></i>Delete Product Variant
                    </h5>
                    <button type="button" class="inline-flex h-8 w-8 items-center justify-center rounded-full text-2xl leading-none hover:bg-black/10 text-white" data-modal-dismiss="true" aria-label="Close">&times;</button>
                </div>

                <div class="overflow-y-auto p-5">
                    <asp:HiddenField ID="hfDeleteVariantID" runat="server" />
                    <p class="mb-2">Delete <strong id="deleteVariantName"></strong>?</p>
                    <p class="text-slate-500 text-sm mb-0">This permanently removes the variant and its stored image. This action cannot be undone.</p>
                </div>

                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4 bg-slate-50">
                    <button type="button" class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-slate-600 bg-slate-600 text-white hover:bg-slate-700" data-modal-dismiss="true">Cancel</button>
                    <asp:Button
                        ID="btnDeleteVariant"
                        runat="server"
                        Text="Delete Variant"
                        CssClass="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-red-700 bg-red-700 text-white hover:bg-red-800"
                        CausesValidation="false"
                        OnClick="btnDeleteVariant_Click" />
                </div>
            </div>
        </div>
    </div>

    <script src="<%= ResolveUrl("~/Scripts/app/admin/products.js") %>"></script>

</asp:Content>
