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

    <div class="container-fluid mt-4">

        <header class="page-heading mb-4 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <div>
                <h1>Products & Variants Management</h1>
                <p class="text-muted mb-0">Create base products and manage multiple serving sizes, prices, and images inside each product card.</p>
            </div>
            <div>
                <a href="<%= ResolveUrl("~/UI/Admin/CatalogConfig.aspx") %>" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-gear-fill me-1"></i> Configure Categories & Sizes
                </a>
            </div>
        </header>

        <!-- GLOBAL FEEDBACK MESSAGES -->
        <asp:Label
            ID="lblGlobalMessage"
            runat="server"
            Visible="false"
            CssClass="alert alert-info d-block shadow-sm mb-4">
        </asp:Label>

        <!-- TOP BAR: ADD NEW PRODUCT FORM -->
        <div class="card shadow-sm mb-4 border-0">
            <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                <strong><i class="bi bi-plus-circle-fill me-1"></i> Add New Product</strong>
                <span class="badge bg-light text-primary">Base catalog item</span>
            </div>

            <div class="card-body bg-light">

                <asp:ValidationSummary
                    ID="validationSummaryProduct"
                    runat="server"
                    ValidationGroup="ProductForm"
                    CssClass="alert alert-danger"
                    HeaderText="Please correct the following errors:"
                    DisplayMode="BulletList" />

                <div class="row g-3 align-items-end">

                    <!-- CATEGORY -->
                    <div class="col-md-3">
                        <asp:Label
                            ID="lblCategory"
                            runat="server"
                            AssociatedControlID="ddlCategory"
                            CssClass="form-label"
                            Text="Category">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlCategory"
                            runat="server"
                            CssClass="form-select">
                        </asp:DropDownList>

                        <asp:RequiredFieldValidator
                            ID="requiredCategory"
                            runat="server"
                            ControlToValidate="ddlCategory"
                            InitialValue=""
                            ValidationGroup="ProductForm"
                            ErrorMessage="Category is required."
                            CssClass="text-danger small"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- PRODUCT NAME -->
                    <div class="col-md-4">
                        <asp:Label
                            ID="lblProductName"
                            runat="server"
                            AssociatedControlID="txtProductName"
                            CssClass="form-label"
                            Text="Product name">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtProductName"
                            runat="server"
                            CssClass="form-control"
                            MaxLength="100"
                            placeholder="e.g. Caramel Macchiato, Crispy Chicken">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredProductName"
                            runat="server"
                            ControlToValidate="txtProductName"
                            ValidationGroup="ProductForm"
                            ErrorMessage="Product name is required."
                            CssClass="text-danger small"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- STATUS -->
                    <div class="col-md-1">
                        <label class="form-label d-block">Status</label>
                        <div class="form-check mt-2">
                            <asp:CheckBox
                                ID="chkIsAvailable"
                                runat="server"
                                Checked="true"
                                CssClass="form-check-input" />
                            <label class="form-check-label small" for="<%= chkIsAvailable.ClientID %>">Active</label>
                        </div>
                    </div>

                    <!-- SUBMIT BUTTON -->
                    <div class="col-md-2">
                        <asp:Button
                            ID="btnAddProduct"
                            runat="server"
                            Text="+ Create Product"
                            CssClass="btn btn-primary w-100"
                            ValidationGroup="ProductForm"
                            OnClick="btnAddProduct_Click" />
                    </div>

                </div>

            </div>
        </div>

        <!-- PRODUCT CARDS SECTION -->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="mb-0">Product Catalog & Serving Variants</h4>
            <asp:Label ID="lblProductStats" runat="server" CssClass="text-muted small"></asp:Label>
        </div>

        <asp:Label
            ID="lblLoadError"
            runat="server"
            Visible="false"
            CssClass="alert alert-danger d-block">
        </asp:Label>

        <!-- REPEATER OF PRODUCT CARDS -->
        <div class="row g-4">
            <asp:Repeater ID="rptProductCards" runat="server">
                <ItemTemplate>
                    <div class="col-12 col-xl-6">
                        <div
                            class="card shadow-sm h-100 border-1"
                            data-existing-size-keys='<%# Eval("ExistingSizeKeys") %>'>
                            
                            <!-- CARD HEADER -->
                            <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                                <div>
                                    <span class="badge bg-secondary mb-1"><%# Eval("CategoryName") %></span>
                                    <h5 class="mb-0 text-dark fw-bold"><%# Eval("ProductName") %></h5>
                                    <small class="text-muted">ID: #<%# Eval("ProductID") %></small>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <span class='badge <%# (bool)Eval("IsAvailable") ? "bg-success" : "bg-secondary" %>'>
                                        <%# (bool)Eval("IsAvailable") ? "Active" : "Hidden" %>
                                    </span>
                                    <button
                                        type="button"
                                        class="btn btn-sm btn-outline-primary"
                                        data-bs-toggle="modal"
                                        data-bs-target="#addVariantModal"
                                        onclick='openAddVariantModal(<%# Eval("ProductID") %>, "<%# HttpUtility.JavaScriptStringEncode(Eval("ProductName").ToString()) %>", "<%# Eval("ExistingSizeKeys") %>");'>
                                        <i class="bi bi-plus"></i> Add Variants
                                    </button>
                                </div>
                            </div>

                            <!-- CARD BODY: NESTED VARIANTS TABLE -->
                            <div class="card-body p-0">
                                <%# ((System.Collections.Generic.List<PortableKiosk.Core.Models.ProductVariant>)Eval("Variants")).Count == 0 
                                    ? "<div class='p-4 text-center text-muted bg-light-subtle small'><i class='bi bi-info-circle me-1'></i> No variants yet. Customers won't see this product in kiosk until you add at least one serving size & price.</div>" 
                                    : "" %>

                                <asp:Repeater ID="rptInnerVariants" runat="server" DataSource='<%# Eval("Variants") %>'>
                                    <HeaderTemplate>
                                        <div class="table-responsive">
                                            <table class="table table-hover align-middle mb-0 small">
                                                <thead class="table-light">
                                                    <tr>
                                                        <th style="width: 50px;">Photo</th>
                                                        <th>Size / Serving</th>
                                                        <th>Price</th>
                                                        <th>Status</th>
                                                        <th class="text-end">Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <%# !string.IsNullOrWhiteSpace(Convert.ToString(Eval("ImagePath"))) 
                                                    ? "<img src='" + ResolveUrl(Convert.ToString(Eval("ImagePath"))) + "' class='rounded' style='width: 36px; height: 36px; object-fit: cover;' alt='Variant' />" 
                                                    : "<span class='badge bg-light text-muted border'>No photo</span>" %>
                                            </td>
                                            <td class="fw-semibold">
                                                <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeName"))) || Convert.ToString(Eval("SizeName")) == "No size" 
                                                    ? "<span class='text-secondary'>Regular / Standard</span>" 
                                                    : Eval("SizeName") %>
                                            </td>
                                            <td class="text-primary fw-bold">
                                                ₱<%# string.Format("{0:N2}", Eval("Price")) %>
                                            </td>
                                            <td>
                                                <span class='badge <%# (bool)Eval("IsAvailable") ? "bg-success-subtle text-success" : "bg-secondary-subtle text-secondary" %>'>
                                                    <%# (bool)Eval("IsAvailable") ? "Available" : "Unavailable" %>
                                                </span>
                                            </td>
                                            <td class="text-end text-nowrap">
                                                <div class="btn-group btn-group-sm" role="group" aria-label="Variant actions">
                                                    <button
                                                        type="button"
                                                        class="btn btn-outline-primary"
                                                        data-bs-toggle="modal"
                                                        data-bs-target="#editVariantModal"
                                                        onclick='openEditVariantModal(this, <%# Eval("ProductVariantID") %>, "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "NONE" : Convert.ToString(Eval("SizeID")) %>", "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "Standard / No size" : HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("SizeName"))) %>", "<%# Convert.ToDecimal(Eval("Price")).ToString(System.Globalization.CultureInfo.InvariantCulture) %>", <%# (bool)Eval("IsAvailable") ? "true" : "false" %>, "<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ImagePath"))) ? "" : HttpUtility.JavaScriptStringEncode(ResolveUrl(Convert.ToString(Eval("ImagePath")))) %>");'
                                                        aria-label="Edit <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("SizeID"))) ? "standard variant" : HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("SizeName"))) %>">
                                                        <i class="bi bi-pencil"></i>
                                                    </button>
                                                    <button
                                                        type="button"
                                                        class="btn btn-outline-danger"
                                                        data-bs-toggle="modal"
                                                        data-bs-target="#deleteVariantModal"
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
        <asp:Panel ID="pnlNoProducts" runat="server" Visible="false" CssClass="card shadow-sm p-5 text-center text-muted mt-3">
            <h5>No products created yet.</h5>
            <p class="mb-0">Use the form above to add your first product.</p>
        </asp:Panel>

    </div>

    <!-- ADD VARIANTS MODAL -->
    <div class="modal fade" id="addVariantModal" tabindex="-1" aria-labelledby="addVariantModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">

                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="addVariantModalLabel">
                        <i class="bi bi-plus-square-fill me-1"></i> Add Product Variants
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">

                    <asp:ValidationSummary
                        ID="validationSummaryVariant"
                        runat="server"
                        ValidationGroup="VariantModalForm"
                        CssClass="alert alert-danger"
                        HeaderText="Please correct the following errors:"
                        DisplayMode="BulletList" />

                    <!-- TARGET PRODUCT INFO -->
                    <div class="mb-3">
                        <label class="form-label text-muted small">Target Product</label>
                        <div id="modalDisplayProductName" class="form-control bg-light fw-bold text-primary"></div>
                        <asp:HiddenField ID="hfModalProductID" runat="server" />
                    </div>

                    <!-- PROGRESSIVE VARIANT ROWS -->
                    <fieldset class="mb-4">
                        <legend class="h6 mb-1">Set up each variant</legend>
                        <p class="text-muted small mb-3">
                            Start with one size. Add another row only when you need another variant.
                        </p>
                        <div
                            id="existingVariantNotice"
                            class="alert alert-light border small py-2 d-none"
                            role="status">
                            <i class="bi bi-info-circle me-1"></i>
                            Sizes marked “already added” are unavailable for this product.
                        </div>

                        <div id="bulkVariantRows">
                            <asp:Repeater
                                ID="rptBulkVariantRows"
                                runat="server"
                                OnItemDataBound="rptBulkVariantRows_ItemDataBound">
                                <ItemTemplate>
                                    <div class='<%# Container.ItemIndex == 0
                                        ? "bulk-variant-row border rounded-3 p-3 mb-3"
                                        : "bulk-variant-row border rounded-3 p-3 mb-3 d-none" %>'>
                                        <div class="d-flex align-items-center justify-content-between mb-3">
                                            <span class="small fw-semibold text-secondary">
                                                Variant <span class="bulk-variant-number"><%# Container.ItemIndex + 1 %></span>
                                            </span>
                                            <button
                                                type="button"
                                                class="btn btn-sm btn-outline-danger bulk-variant-remove"
                                                aria-label="Remove this variant row">
                                                <i class="bi bi-trash me-1"></i>Remove
                                            </button>
                                        </div>

                                        <div class="row g-3 align-items-end">
                                            <div class="col-12 col-md-4">
                                                <label class="form-label small fw-semibold">Size / Serving</label>
                                                <asp:DropDownList
                                                    ID="ddlBulkSize"
                                                    runat="server"
                                                    CssClass="form-select bulk-variant-size">
                                                </asp:DropDownList>
                                            </div>

                                            <div class="col-12 col-md-3">
                                                <label class="form-label small fw-semibold">Price</label>
                                                <div class="input-group">
                                                    <span class="input-group-text">₱</span>
                                                    <asp:TextBox
                                                        ID="txtBulkPrice"
                                                        runat="server"
                                                        CssClass="form-control bulk-variant-price"
                                                        TextMode="Number"
                                                        step="0.01"
                                                        min="0"
                                                        max="99999999.99"
                                                        inputmode="decimal"
                                                        placeholder="0.00">
                                                    </asp:TextBox>
                                                </div>
                                            </div>

                                            <div class="col-12 col-md-5">
                                                <label class="form-label small fw-semibold">Image <span class="fw-normal text-muted">(optional)</span></label>
                                                <asp:FileUpload
                                                    ID="uploadBulkImage"
                                                    runat="server"
                                                    CssClass="form-control bulk-variant-image"
                                                    accept=".jpg,.jpeg,.png,.webp" />
                                                <div class="form-text">JPG, PNG, or WebP; maximum 3 MB.</div>
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <button
                            type="button"
                            id="btnAddAnotherVariant"
                            class="btn btn-outline-primary">
                            <i class="bi bi-plus-lg me-1"></i>Add another size
                        </button>
                    </fieldset>

                    <!-- STATUS -->
                    <div class="mb-3">
                        <label class="form-label d-block">Status</label>
                        <div class="form-check">
                            <asp:CheckBox
                                ID="chkModalIsAvailable"
                                runat="server"
                                Checked="true"
                                CssClass="form-check-input" />
                            <label class="form-check-label" for="<%= chkModalIsAvailable.ClientID %>">Make all new variants available for order</label>
                        </div>
                    </div>

                </div>

                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button
                        ID="btnSaveModalVariant"
                        runat="server"
                        Text="Save All Variants"
                        CssClass="btn btn-primary"
                        ValidationGroup="VariantModalForm"
                        OnClick="btnSaveModalVariant_Click" />
                </div>

            </div>
        </div>
    </div>

    <!-- EDIT VARIANT MODAL -->
    <div class="modal fade" id="editVariantModal" tabindex="-1" aria-labelledby="editVariantModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="editVariantModalLabel">
                        <i class="bi bi-pencil-square me-1"></i>Edit Product Variant
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <asp:ValidationSummary
                        ID="validationSummaryEditVariant"
                        runat="server"
                        ValidationGroup="EditVariantForm"
                        CssClass="alert alert-danger"
                        HeaderText="Please correct the following errors:"
                        DisplayMode="BulletList" />

                    <asp:HiddenField ID="hfEditVariantID" runat="server" />

                    <div class="mb-3">
                        <label class="form-label text-muted small">Product</label>
                        <div id="editVariantProductName" class="form-control bg-light fw-semibold"></div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="<%= ddlEditVariantSize.ClientID %>">Size / Serving</label>
                        <asp:DropDownList
                            ID="ddlEditVariantSize"
                            runat="server"
                            CssClass="form-select">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator
                            ID="requiredEditVariantSize"
                            runat="server"
                            ControlToValidate="ddlEditVariantSize"
                            InitialValue=""
                            ValidationGroup="EditVariantForm"
                            ErrorMessage="Choose a size or serving."
                            CssClass="text-danger small"
                            Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="<%= txtEditVariantPrice.ClientID %>">Price</label>
                        <div class="input-group">
                            <span class="input-group-text">₱</span>
                            <asp:TextBox
                                ID="txtEditVariantPrice"
                                runat="server"
                                CssClass="form-control"
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
                            CssClass="text-danger small"
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
                            CssClass="text-danger small"
                            Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="<%= uploadEditVariantImage.ClientID %>">Replace image <span class="text-muted">(optional)</span></label>
                        <div id="editVariantImagePreview" class="d-none mb-2">
                            <img id="editVariantCurrentImage" class="rounded border" style="width: 72px; height: 72px; object-fit: cover;" alt="Current variant" />
                            <span class="small text-muted ms-2">Current image</span>
                        </div>
                        <asp:FileUpload
                            ID="uploadEditVariantImage"
                            runat="server"
                            CssClass="form-control"
                            accept=".jpg,.jpeg,.png,.webp" />
                        <div class="form-text">Leave empty to keep the current image. JPG, PNG, or WebP; maximum 3 MB.</div>
                    </div>

                    <div class="form-check">
                        <asp:CheckBox
                            ID="chkEditVariantIsAvailable"
                            runat="server"
                            CssClass="form-check-input" />
                        <label class="form-check-label" for="<%= chkEditVariantIsAvailable.ClientID %>">Available for ordering</label>
                    </div>
                </div>

                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button
                        ID="btnUpdateVariant"
                        runat="server"
                        Text="Save Changes"
                        CssClass="btn btn-primary"
                        ValidationGroup="EditVariantForm"
                        OnClick="btnUpdateVariant_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- DELETE VARIANT MODAL -->
    <div class="modal fade" id="deleteVariantModal" tabindex="-1" aria-labelledby="deleteVariantModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title" id="deleteVariantModalLabel">
                        <i class="bi bi-exclamation-triangle-fill me-1"></i>Delete Product Variant
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <asp:HiddenField ID="hfDeleteVariantID" runat="server" />
                    <p class="mb-2">Delete <strong id="deleteVariantName"></strong>?</p>
                    <p class="text-muted small mb-0">This permanently removes the variant and its stored image. This action cannot be undone.</p>
                </div>

                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button
                        ID="btnDeleteVariant"
                        runat="server"
                        Text="Delete Variant"
                        CssClass="btn btn-danger"
                        CausesValidation="false"
                        OnClick="btnDeleteVariant_Click" />
                </div>
            </div>
        </div>
    </div>

    <script src="<%= ResolveUrl("~/Scripts/app/admin/products.js") %>"></script>

</asp:Content>
