<%@ Page
    Title="Products"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="Products.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.ProductManagement" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <div class="container mt-4">

        <header class="page-heading">
            <div>
                <h1>Product management</h1>
                <p>Manage the products shown across kiosk and POS.</p>
            </div>
        </header>

        <!-- ADD PRODUCT FORM -->
        <div class="card shadow-sm mb-4">
            <div class="card-header">
                <strong>Add Product</strong>
            </div>

            <div class="card-body">

                <asp:ValidationSummary
                    ID="validationSummary"
                    runat="server"
                    ValidationGroup="ProductForm"
                    CssClass="alert alert-danger"
                    HeaderText="Please correct the following:"
                    DisplayMode="BulletList" />

                <asp:Label
                    ID="lblMessage"
                    runat="server"
                    Visible="false">
                </asp:Label>

                <div class="row">

                    <!-- CATEGORY -->
                    <div class="col-md-3 mb-3">
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
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- PRODUCT NAME -->
                    <div class="col-md-3 mb-3">
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
                            placeholder="Example: Iced Coffee">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredProductName"
                            runat="server"
                            ControlToValidate="txtProductName"
                            ValidationGroup="ProductForm"
                            ErrorMessage="Product name is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- DISPLAY ORDER -->
                    <div class="col-md-2 mb-3">
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
                            ValidationGroup="ProductForm"
                            ErrorMessage="Display order is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>

                        <asp:RangeValidator
                            ID="rangeDisplayOrder"
                            runat="server"
                            ControlToValidate="txtDisplayOrder"
                            ValidationGroup="ProductForm"
                            Type="Integer"
                            MinimumValue="0"
                            MaximumValue="2147483647"
                            ErrorMessage="Display order must be zero or greater."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RangeValidator>
                    </div>

                    <!-- STATUS -->
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

                    <!-- BUTTON -->
                    <div class="col-md-2 mb-3 d-flex align-items-end">
                        <asp:Button
                            ID="btnAddProduct"
                            runat="server"
                            Text="Add Product"
                            CssClass="btn btn-primary w-100"
                            ValidationGroup="ProductForm"
                            OnClick="btnAddProduct_Click" />
                    </div>

                </div>
            </div>
        </div>

        <!-- PRODUCT TABLE -->
        <div class="card shadow-sm">
            <div class="card-header">
                <strong>Product List</strong>
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
                        ID="gridProducts"
                        runat="server"
                        AutoGenerateColumns="false"
                        GridLines="None"
                        CssClass="table table-striped table-hover align-middle"
                        EmptyDataText="No products have been created.">

                        <Columns>
                            <asp:BoundField
                                DataField="ProductID"
                                HeaderText="ID" />

                            <asp:BoundField
                                DataField="ProductName"
                                HeaderText="Product Name" />

                            <asp:BoundField
                                DataField="CategoryName"
                                HeaderText="Category" />

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