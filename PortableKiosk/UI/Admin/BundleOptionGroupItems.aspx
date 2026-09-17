<%@ Page
    Title="Bundle Option Group Items"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="BundleOptionGroupItems.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.BundleOptionGroupItemManagement" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <div class="container mt-4">

        <header class="page-heading">
            <div>
                <h1>Bundle option group item management</h1>
                <p>Add product choices and bundle upgrade prices to reusable option groups.</p>
            </div>
        </header>

        <!-- ADD OPTION GROUP ITEM FORM -->
        <div class="card shadow-sm mb-4">
            <div class="card-header">
                <strong>Add Option Group Item</strong>
            </div>

            <div class="card-body">

                <asp:ValidationSummary
                    ID="validationSummary"
                    runat="server"
                    ValidationGroup="OptionGroupItemForm"
                    CssClass="alert alert-danger"
                    HeaderText="Please correct the following:"
                    DisplayMode="BulletList" />

                <asp:Label
                    ID="lblMessage"
                    runat="server"
                    Visible="false">
                </asp:Label>

                <div class="row">

                    <!-- OPTION GROUP -->
                    <div class="col-md-3 mb-3">
                        <asp:Label
                            ID="lblOptionGroup"
                            runat="server"
                            AssociatedControlID="ddlOptionGroup"
                            CssClass="form-label"
                            Text="Option group">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlOptionGroup"
                            runat="server"
                            CssClass="form-select">
                        </asp:DropDownList>

                        <asp:RequiredFieldValidator
                            ID="requiredOptionGroup"
                            runat="server"
                            ControlToValidate="ddlOptionGroup"
                            InitialValue=""
                            ValidationGroup="OptionGroupItemForm"
                            ErrorMessage="Option group is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- PRODUCT VARIANT -->
                    <div class="col-md-4 mb-3">
                        <asp:Label
                            ID="lblProductVariant"
                            runat="server"
                            AssociatedControlID="ddlProductVariant"
                            CssClass="form-label"
                            Text="Product variant">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlProductVariant"
                            runat="server"
                            CssClass="form-select">
                        </asp:DropDownList>

                        <asp:RequiredFieldValidator
                            ID="requiredProductVariant"
                            runat="server"
                            ControlToValidate="ddlProductVariant"
                            InitialValue=""
                            ValidationGroup="OptionGroupItemForm"
                            ErrorMessage="Product variant is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- ADDITIONAL PRICE -->
                    <div class="col-md-2 mb-3">
                        <asp:Label
                            ID="lblAdditionalPrice"
                            runat="server"
                            AssociatedControlID="txtAdditionalPrice"
                            CssClass="form-label"
                            Text="Upgrade price">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtAdditionalPrice"
                            runat="server"
                            CssClass="form-control"
                            TextMode="Number"
                            Text="0.00"
                            min="0"
                            step="0.01">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredAdditionalPrice"
                            runat="server"
                            ControlToValidate="txtAdditionalPrice"
                            ValidationGroup="OptionGroupItemForm"
                            ErrorMessage="Upgrade price is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>

                        <asp:RangeValidator
                            ID="rangeAdditionalPrice"
                            runat="server"
                            ControlToValidate="txtAdditionalPrice"
                            ValidationGroup="OptionGroupItemForm"
                            Type="Double"
                            MinimumValue="0"
                            MaximumValue="99999999.99"
                            ErrorMessage="Upgrade price must be zero or greater."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RangeValidator>
                    </div>

                    <!-- DISPLAY ORDER -->
                    <div class="col-md-1 mb-3">
                        <asp:Label
                            ID="lblDisplayOrder"
                            runat="server"
                            AssociatedControlID="txtDisplayOrder"
                            CssClass="form-label"
                            Text="Order">
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
                            ValidationGroup="OptionGroupItemForm"
                            ErrorMessage="Display order is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>

                        <asp:RangeValidator
                            ID="rangeDisplayOrder"
                            runat="server"
                            ControlToValidate="txtDisplayOrder"
                            ValidationGroup="OptionGroupItemForm"
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
                    <div class="col-md-2 mb-3">
                        <asp:Button
                            ID="btnAddItem"
                            runat="server"
                            Text="Add Item"
                            CssClass="btn btn-primary w-100"
                            ValidationGroup="OptionGroupItemForm"
                            OnClick="btnAddItem_Click" />
                    </div>

                </div>
            </div>
        </div>

        <!-- OPTION GROUP ITEM TABLE -->
        <div class="card shadow-sm">
            <div class="card-header">
                <strong>Option Group Item List</strong>
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
                        ID="gridItems"
                        runat="server"
                        AutoGenerateColumns="false"
                        GridLines="None"
                        CssClass="table table-striped table-hover align-middle"
                        EmptyDataText="No option group items have been created.">

                        <Columns>
                            <asp:BoundField
                                DataField="OptionGroupName"
                                HeaderText="Option Group" />

                            <asp:BoundField
                                DataField="ProductName"
                                HeaderText="Product" />

                            <asp:BoundField
                                DataField="CategoryName"
                                HeaderText="Category" />

                            <asp:BoundField
                                DataField="SizeName"
                                HeaderText="Size" />

                            <asp:BoundField
                                DataField="ProductVariantPrice"
                                HeaderText="Standalone Price"
                                DataFormatString="₱{0:N2}"
                                HtmlEncode="false" />

                            <asp:BoundField
                                DataField="AdditionalPrice"
                                HeaderText="Bundle Upgrade"
                                DataFormatString="+₱{0:N2}"
                                HtmlEncode="false" />

                            <asp:BoundField
                                DataField="DisplayOrder"
                                HeaderText="Display Order" />

                            <asp:CheckBoxField
                                DataField="IsAvailable"
                                HeaderText="Available"
                                ReadOnly="true" />
                        </Columns>

                        <HeaderStyle CssClass="table-dark" />
                        <EmptyDataRowStyle CssClass="text-center text-muted" />
                    </asp:GridView>
                </div>

            </div>
        </div>

    </div>

</asp:Content>
