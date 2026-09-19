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

                        <!-- DISPLAY ORDER -->
                        <div class="col-md-3">
                            <asp:Label
                                ID="lblCategoryDisplayOrder"
                                runat="server"
                                AssociatedControlID="txtCategoryDisplayOrder"
                                CssClass="form-label fw-bold"
                                Text="Display Order">
                            </asp:Label>

                            <asp:TextBox
                                ID="txtCategoryDisplayOrder"
                                runat="server"
                                CssClass="form-control"
                                TextMode="Number"
                                Text="0">
                            </asp:TextBox>

                            <asp:RequiredFieldValidator
                                ID="requiredCategoryDisplayOrder"
                                runat="server"
                                ControlToValidate="txtCategoryDisplayOrder"
                                ValidationGroup="CategoryForm"
                                ErrorMessage="Display order is required."
                                CssClass="text-danger small"
                                Display="Dynamic">
                            </asp:RequiredFieldValidator>

                            <asp:RangeValidator
                                ID="rangeCategoryDisplayOrder"
                                runat="server"
                                ControlToValidate="txtCategoryDisplayOrder"
                                ValidationGroup="CategoryForm"
                                Type="Integer"
                                MinimumValue="0"
                                MaximumValue="2147483647"
                                ErrorMessage="Order must be 0 or greater."
                                CssClass="text-danger small"
                                Display="Dynamic">
                            </asp:RangeValidator>
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
                                <asp:BoundField DataField="DisplayOrder" HeaderText="Display Order" ItemStyle-Width="140px" />
                                <asp:TemplateField HeaderText="Status" ItemStyle-Width="140px">
                                    <ItemTemplate>
                                        <span class='badge <%# (bool)Eval("IsAvailable") ? "bg-success" : "bg-secondary" %>'>
                                            <%# (bool)Eval("IsAvailable") ? "Active" : "Hidden" %>
                                        </span>
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

                        <!-- DISPLAY ORDER -->
                        <div class="col-md-4">
                            <asp:Label
                                ID="lblSizeDisplayOrder"
                                runat="server"
                                AssociatedControlID="txtSizeDisplayOrder"
                                CssClass="form-label fw-bold"
                                Text="Display Order">
                            </asp:Label>

                            <asp:TextBox
                                ID="txtSizeDisplayOrder"
                                runat="server"
                                CssClass="form-control"
                                TextMode="Number"
                                Text="0">
                            </asp:TextBox>

                            <asp:RequiredFieldValidator
                                ID="requiredSizeDisplayOrder"
                                runat="server"
                                ControlToValidate="txtSizeDisplayOrder"
                                ValidationGroup="SizeForm"
                                ErrorMessage="Display order is required."
                                CssClass="text-danger small"
                                Display="Dynamic">
                            </asp:RequiredFieldValidator>

                            <asp:RangeValidator
                                ID="rangeSizeDisplayOrder"
                                runat="server"
                                ControlToValidate="txtSizeDisplayOrder"
                                ValidationGroup="SizeForm"
                                Type="Integer"
                                MinimumValue="0"
                                MaximumValue="2147483647"
                                ErrorMessage="Order must be 0 or greater."
                                CssClass="text-danger small"
                                Display="Dynamic">
                            </asp:RangeValidator>
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
                                <asp:BoundField DataField="DisplayOrder" HeaderText="Display Order" ItemStyle-Width="140px" />
                            </Columns>

                            <HeaderStyle CssClass="table-light" />
                            <EmptyDataRowStyle CssClass="text-center text-muted p-4" />
                        </asp:GridView>
                    </div>

                </div>
            </div>

        </section>

    </div>

</asp:Content>
