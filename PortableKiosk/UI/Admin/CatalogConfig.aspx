<%@ Page
    Title="Catalog Configuration"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="CatalogConfig.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.CatalogConfig" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <div class="container-fluid mt-4">

        <header class="page-heading mb-4 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <div>
                <h1>Catalog setup & configurations</h1>
                <p class="text-muted mb-0">Manage product categories and serving sizes in one unified workspace.</p>
            </div>
        </header>

        <!-- ========================================== -->
        <!-- 1. CATEGORIES SECTION (TOP, FULL WIDTH)   -->
        <!-- ========================================== -->
        <section class="mb-5" aria-labelledby="headingCategoriesSection">
            
            <!-- ADD CATEGORY CARD -->
            <div class="card shadow-sm mb-4 border-0">
                <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                    <strong id="headingCategoriesSection"><i class="bi bi-tag-fill me-1"></i> Add Category</strong>
                    <span class="badge bg-light text-primary">Catalog taxonomy</span>
                </div>

                <div class="card-body">

                    <asp:ValidationSummary
                        ID="validationSummaryCategory"
                        runat="server"
                        ValidationGroup="CategoryForm"
                        CssClass="alert alert-danger"
                        HeaderText="Please correct the following:"
                        DisplayMode="BulletList" />

                    <asp:Label
                        ID="lblCategoryMessage"
                        runat="server"
                        Visible="false">
                    </asp:Label>

                    <div class="row align-items-end g-3">
                        <!-- CATEGORY NAME -->
                        <div class="col-md-5">
                            <asp:Label
                                ID="lblCategoryName"
                                runat="server"
                                AssociatedControlID="txtCategoryName"
                                CssClass="form-label fw-bold"
                                Text="Category Name">
                            </asp:Label>

                            <asp:TextBox
                                ID="txtCategoryName"
                                runat="server"
                                CssClass="form-control"
                                MaxLength="100"
                                placeholder="e.g. Espresso Drinks">
                            </asp:TextBox>

                            <asp:RequiredFieldValidator
                                ID="requiredCategoryName"
                                runat="server"
                                ControlToValidate="txtCategoryName"
                                ValidationGroup="CategoryForm"
                                ErrorMessage="Category name is required."
                                CssClass="text-danger small"
                                Display="Dynamic">
                            </asp:RequiredFieldValidator>
                        </div>

                        <!-- STATUS -->
                        <div class="col-md-2">
                            <label class="form-label fw-bold d-block">Status</label>
                            <div class="form-check mt-2">
                                <asp:CheckBox
                                    ID="chkCategoryIsAvailable"
                                    runat="server"
                                    Checked="true"
                                    CssClass="form-check-input" />
                                <label class="form-check-label" for="<%= chkCategoryIsAvailable.ClientID %>">Available</label>
                            </div>
                        </div>

                        <!-- ADD BUTTON -->
                        <div class="col-md-2">
                            <asp:Button
                                ID="btnAddCategory"
                                runat="server"
                                Text="Add Category"
                                CssClass="btn btn-primary w-100"
                                ValidationGroup="CategoryForm"
                                OnClick="btnAddCategory_Click" />
                        </div>
                    </div>

                </div>
            </div>

            <!-- CATEGORIES TABLE (FULL WIDTH) -->
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                    <strong><i class="bi bi-list-ul me-1"></i> Category List</strong>
                    <asp:Label ID="lblCategoryCount" runat="server" CssClass="badge bg-secondary"></asp:Label>
                </div>

                <div class="card-body p-0">

                    <asp:Label
                        ID="lblCategoryLoadError"
                        runat="server"
                        Visible="false"
                        CssClass="alert alert-danger m-3 d-block">
                    </asp:Label>

                    <div class="table-responsive">
                        <asp:GridView
                            ID="gridCategories"
                            runat="server"
                            AutoGenerateColumns="false"
                            GridLines="None"
                            CssClass="table table-striped table-hover align-middle mb-0 w-100"
                            EmptyDataText="No categories have been created yet.">

                            <Columns>
                                <asp:BoundField DataField="CategoryID" HeaderText="ID" ItemStyle-Width="90px" />
                                <asp:BoundField DataField="CategoryName" HeaderText="Category Name" />
                                <asp:TemplateField HeaderText="Status" ItemStyle-Width="140px">
                                    <ItemTemplate>
                                        <span class='badge <%# (bool)Eval("IsAvailable") ? "bg-success" : "bg-secondary" %>'>
                                            <%# (bool)Eval("IsAvailable") ? "Active" : "Hidden" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="190px">
                                    <ItemTemplate>
                                        <div class="d-flex gap-2 flex-wrap">
                                            <button
                                                type="button"
                                                class="btn btn-sm btn-outline-primary"
                                                data-bs-toggle="modal"
                                                data-bs-target="#editCategoryModal"
                                                onclick='openEditCategoryModal(<%# Eval("CategoryID") %>, "<%# HttpUtility.HtmlAttributeEncode(HttpUtility.JavaScriptStringEncode(Eval("CategoryName").ToString())) %>", <%# (bool)Eval("IsAvailable") ? "true" : "false" %>);'>
                                                <i class="bi bi-pencil-square me-1"></i>Edit
                                            </button>
                                            <button
                                                type="button"
                                                class="btn btn-sm btn-outline-danger"
                                                data-bs-toggle="modal"
                                                data-bs-target="#deleteCategoryModal"
                                                onclick='openDeleteCategoryModal(<%# Eval("CategoryID") %>, "<%# HttpUtility.HtmlAttributeEncode(HttpUtility.JavaScriptStringEncode(Eval("CategoryName").ToString())) %>");'>
                                                <i class="bi bi-trash me-1"></i>Delete
                                            </button>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>

                            <HeaderStyle CssClass="table-light" />
                            <EmptyDataRowStyle CssClass="text-center text-muted p-4" />
                        </asp:GridView>
                    </div>

                </div>
            </div>

        </section>

        <!-- ========================================== -->
        <!-- 2. SIZES SECTION (BOTTOM, FULL WIDTH)     -->
        <!-- ========================================== -->
        <section class="mb-5" aria-labelledby="headingSizesSection">

            <!-- ADD SIZE CARD -->
            <div class="card shadow-sm mb-4 border-0">
                <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
                    <strong id="headingSizesSection"><i class="bi bi-aspect-ratio me-1"></i> Add Size</strong>
                    <span class="badge bg-light text-dark">Portion sizing</span>
                </div>

                <div class="card-body">

                    <asp:ValidationSummary
                        ID="validationSummarySize"
                        runat="server"
                        ValidationGroup="SizeForm"
                        CssClass="alert alert-danger"
                        HeaderText="Please correct the following:"
                        DisplayMode="BulletList" />

                    <asp:Label
                        ID="lblSizeMessage"
                        runat="server"
                        Visible="false">
                    </asp:Label>

                    <div class="row align-items-end g-3">
                        <!-- SIZE NAME -->
                        <div class="col-md-6">
                            <asp:Label
                                ID="lblSizeName"
                                runat="server"
                                AssociatedControlID="txtSizeName"
                                CssClass="form-label fw-bold"
                                Text="Size Name">
                            </asp:Label>

                            <asp:TextBox
                                ID="txtSizeName"
                                runat="server"
                                CssClass="form-control"
                                MaxLength="50"
                                placeholder="e.g. Regular, Large, 16oz">
                            </asp:TextBox>

                            <asp:RequiredFieldValidator
                                ID="requiredSizeName"
                                runat="server"
                                ControlToValidate="txtSizeName"
                                ValidationGroup="SizeForm"
                                ErrorMessage="Size name is required."
                                CssClass="text-danger small"
                                Display="Dynamic">
                            </asp:RequiredFieldValidator>
                        </div>

                        <!-- ADD BUTTON -->
                        <div class="col-md-2">
                            <asp:Button
                                ID="btnAddSize"
                                runat="server"
                                Text="Add Size"
                                CssClass="btn btn-dark w-100"
                                ValidationGroup="SizeForm"
                                OnClick="btnAddSize_Click" />
                        </div>
                    </div>

                </div>
            </div>

            <!-- SIZES TABLE (FULL WIDTH) -->
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                    <strong><i class="bi bi-list-ul me-1"></i> Size List</strong>
                    <asp:Label ID="lblSizeCount" runat="server" CssClass="badge bg-secondary"></asp:Label>
                </div>

                <div class="card-body p-0">

                    <asp:Label
                        ID="lblSizeLoadError"
                        runat="server"
                        Visible="false"
                        CssClass="alert alert-danger m-3 d-block">
                    </asp:Label>

                    <div class="table-responsive">
                        <asp:GridView
                            ID="gridSizes"
                            runat="server"
                            AutoGenerateColumns="false"
                            GridLines="None"
                            CssClass="table table-striped table-hover align-middle mb-0 w-100"
                            EmptyDataText="No sizes have been created yet.">

                            <Columns>
                                <asp:BoundField DataField="SizeID" HeaderText="ID" ItemStyle-Width="90px" />
                                <asp:BoundField DataField="SizeName" HeaderText="Size Name" />
                                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="190px">
                                    <ItemTemplate>
                                        <div class="d-flex gap-2 flex-wrap">
                                            <button
                                                type="button"
                                                class="btn btn-sm btn-outline-primary"
                                                data-bs-toggle="modal"
                                                data-bs-target="#editSizeModal"
                                                onclick='openEditSizeModal(<%# Eval("SizeID") %>, "<%# HttpUtility.HtmlAttributeEncode(HttpUtility.JavaScriptStringEncode(Eval("SizeName").ToString())) %>");'>
                                                <i class="bi bi-pencil-square me-1"></i>Edit
                                            </button>
                                            <button
                                                type="button"
                                                class="btn btn-sm btn-outline-danger"
                                                data-bs-toggle="modal"
                                                data-bs-target="#deleteSizeModal"
                                                onclick='openDeleteSizeModal(<%# Eval("SizeID") %>, "<%# HttpUtility.HtmlAttributeEncode(HttpUtility.JavaScriptStringEncode(Eval("SizeName").ToString())) %>");'>
                                                <i class="bi bi-trash me-1"></i>Delete
                                            </button>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>

                            <HeaderStyle CssClass="table-light" />
                            <EmptyDataRowStyle CssClass="text-center text-muted p-4" />
                        </asp:GridView>
                    </div>

                </div>
            </div>

        </section>

    </div>

    <!-- EDIT CATEGORY MODAL -->
    <div class="modal fade" id="editCategoryModal" tabindex="-1" aria-labelledby="editCategoryModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h2 class="modal-title h5" id="editCategoryModalLabel">
                        <i class="bi bi-pencil-square me-1"></i>Edit category
                    </h2>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <asp:ValidationSummary
                        ID="validationSummaryEditCategory"
                        runat="server"
                        ValidationGroup="EditCategoryForm"
                        CssClass="alert alert-danger"
                        HeaderText="Please correct the following:"
                        DisplayMode="BulletList" />

                    <asp:HiddenField ID="hfEditCategoryID" runat="server" />

                    <div class="mb-3">
                        <asp:Label
                            ID="lblEditCategoryName"
                            runat="server"
                            AssociatedControlID="txtEditCategoryName"
                            CssClass="form-label fw-bold"
                            Text="Category name">
                        </asp:Label>
                        <asp:TextBox
                            ID="txtEditCategoryName"
                            runat="server"
                            CssClass="form-control"
                            MaxLength="100">
                        </asp:TextBox>
                        <asp:RequiredFieldValidator
                            ID="requiredEditCategoryName"
                            runat="server"
                            ControlToValidate="txtEditCategoryName"
                            ValidationGroup="EditCategoryForm"
                            ErrorMessage="Category name is required."
                            CssClass="text-danger small"
                            Display="Dynamic" />
                    </div>

                    <div class="form-check">
                        <asp:CheckBox
                            ID="chkEditCategoryIsAvailable"
                            runat="server"
                            CssClass="form-check-input" />
                        <label class="form-check-label" for="<%= chkEditCategoryIsAvailable.ClientID %>">
                            Available in the catalog
                        </label>
                    </div>
                </div>

                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button
                        ID="btnUpdateCategory"
                        runat="server"
                        Text="Save category"
                        CssClass="btn btn-primary"
                        ValidationGroup="EditCategoryForm"
                        OnClick="btnUpdateCategory_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- DELETE CATEGORY CONFIRMATION -->
    <div class="modal fade" id="deleteCategoryModal" tabindex="-1" aria-labelledby="deleteCategoryModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h2 class="modal-title h5" id="deleteCategoryModalLabel">Delete category?</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfDeleteCategoryID" runat="server" />
                    <p class="mb-2">
                        You are about to delete <strong id="deleteCategoryName"></strong>.
                    </p>
                    <p class="text-muted small mb-0">
                        This cannot be undone. Categories that still contain products cannot be deleted.
                    </p>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Keep category</button>
                    <asp:Button
                        ID="btnDeleteCategory"
                        runat="server"
                        Text="Delete category"
                        CssClass="btn btn-danger"
                        CausesValidation="false"
                        OnClick="btnDeleteCategory_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- EDIT SIZE MODAL -->
    <div class="modal fade" id="editSizeModal" tabindex="-1" aria-labelledby="editSizeModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-dark text-white">
                    <h2 class="modal-title h5" id="editSizeModalLabel">
                        <i class="bi bi-pencil-square me-1"></i>Edit size
                    </h2>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <asp:ValidationSummary
                        ID="validationSummaryEditSize"
                        runat="server"
                        ValidationGroup="EditSizeForm"
                        CssClass="alert alert-danger"
                        HeaderText="Please correct the following:"
                        DisplayMode="BulletList" />

                    <asp:HiddenField ID="hfEditSizeID" runat="server" />

                    <div class="mb-3">
                        <asp:Label
                            ID="lblEditSizeName"
                            runat="server"
                            AssociatedControlID="txtEditSizeName"
                            CssClass="form-label fw-bold"
                            Text="Size name">
                        </asp:Label>
                        <asp:TextBox
                            ID="txtEditSizeName"
                            runat="server"
                            CssClass="form-control"
                            MaxLength="50">
                        </asp:TextBox>
                        <asp:RequiredFieldValidator
                            ID="requiredEditSizeName"
                            runat="server"
                            ControlToValidate="txtEditSizeName"
                            ValidationGroup="EditSizeForm"
                            ErrorMessage="Size name is required."
                            CssClass="text-danger small"
                            Display="Dynamic" />
                    </div>

                </div>

                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button
                        ID="btnUpdateSize"
                        runat="server"
                        Text="Save size"
                        CssClass="btn btn-dark"
                        ValidationGroup="EditSizeForm"
                        OnClick="btnUpdateSize_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- DELETE SIZE CONFIRMATION -->
    <div class="modal fade" id="deleteSizeModal" tabindex="-1" aria-labelledby="deleteSizeModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h2 class="modal-title h5" id="deleteSizeModalLabel">Delete size?</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfDeleteSizeID" runat="server" />
                    <p class="mb-2">
                        You are about to delete <strong id="deleteSizeName"></strong>.
                    </p>
                    <p class="text-muted small mb-0">
                        This cannot be undone. Sizes currently assigned to product variants cannot be deleted.
                    </p>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Keep size</button>
                    <asp:Button
                        ID="btnDeleteSize"
                        runat="server"
                        Text="Delete size"
                        CssClass="btn btn-danger"
                        CausesValidation="false"
                        OnClick="btnDeleteSize_Click" />
                </div>
            </div>
        </div>
    </div>

    <script src="<%= ResolveUrl("~/Scripts/app/admin/catalog-config.js") %>"></script>

</asp:Content>
