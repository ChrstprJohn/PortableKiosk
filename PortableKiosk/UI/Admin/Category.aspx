<%@ Page
    Title="Categories"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="Category.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.CategoryList" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <div class="container mt-4">

        <header class="page-heading">
            <div>
                <h1>Category management</h1>
                <p>Organize the menu categories shown across kiosk and POS.</p>
            </div>
        </header>

        <!-- ADD CATEGORY FORM -->
        <div class="card shadow-sm mb-4">
            <div class="card-header">
                <strong>Add Category</strong>
            </div>

            <div class="card-body">

                <asp:ValidationSummary
                    ID="validationSummary"
                    runat="server"
                    ValidationGroup="CategoryForm"
                    CssClass="alert alert-danger"
                    HeaderText="Please correct the following:"
                    DisplayMode="BulletList" />

                <asp:Label
                    ID="lblMessage"
                    runat="server"
                    Visible="false">
                </asp:Label>

                <div class="row">

                    <div class="col-md-5 mb-3">
                        <asp:Label
                            ID="lblCategoryName"
                            runat="server"
                            AssociatedControlID="txtCategoryName"
                            CssClass="form-label"
                            Text="Category name">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtCategoryName"
                            runat="server"
                            CssClass="form-control"
                            MaxLength="100"
                            placeholder="Example: Beverages">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredCategoryName"
                            runat="server"
                            ControlToValidate="txtCategoryName"
                            ValidationGroup="CategoryForm"
                            ErrorMessage="Category name is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <div class="col-md-3 mb-3">
                        <asp:Label
                            ID="lblDisplayOrder"
                            runat="server"
                            AssociatedControlID="txtDisplayOrder"
                            CssClass="form-label"
                            Text="Display order">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtDisplayOrder"
                            runat="server"
                            CssClass="form-control"
                            TextMode="Number"
                            Text="0">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredDisplayOrder"
                            runat="server"
                            ControlToValidate="txtDisplayOrder"
                            ValidationGroup="CategoryForm"
                            ErrorMessage="Display order is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>

                        <asp:RangeValidator
                            ID="rangeDisplayOrder"
                            runat="server"
                            ControlToValidate="txtDisplayOrder"
                            ValidationGroup="CategoryForm"
                            Type="Integer"
                            MinimumValue="0"
                            MaximumValue="2147483647"
                            ErrorMessage="Display order must be zero or greater."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RangeValidator>
                    </div>

                    <div class="col-md-2 mb-3">
                        <label class="form-label d-block">
                            Status
                        </label>

                        <asp:CheckBox
                            ID="chkIsAvailable"
                            runat="server"
                            Checked="true"
                            Text=" Available" />
                    </div>

                    <div class="col-md-2 mb-3 d-flex align-items-end">
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

        <!-- CATEGORY TABLE -->
        <div class="card shadow-sm">
            <div class="card-header">
                <strong>Category List</strong>
            </div>

            <div class="card-body">

                <asp:Label
                    ID="lblLoadError"
                    runat="server"
                    Visible="false"
                    CssClass="alert alert-danger d-block">
                </asp:Label>

                <div class="table-responsive">
                    <asp:GridView
                        ID="gridCategories"
                        runat="server"
                        AutoGenerateColumns="false"
                        GridLines="None"
                        CssClass="table table-striped table-hover align-middle"
                        EmptyDataText="No categories have been created.">

                        <Columns>
                            <asp:BoundField
                                DataField="CategoryID"
                                HeaderText="ID" />

                            <asp:BoundField
                                DataField="CategoryName"
                                HeaderText="Category Name" />

                            <asp:BoundField
                                DataField="DisplayOrder"
                                HeaderText="Display Order" />

                            <asp:CheckBoxField
                                DataField="IsAvailable"
                                HeaderText="Available"
                                ReadOnly="true" />
                        </Columns>

                        <HeaderStyle CssClass="table-dark" />

                        <EmptyDataRowStyle
                            CssClass="text-center text-muted" />

                    </asp:GridView>
                </div>

            </div>
        </div>

    </div>

</asp:Content>
