<%@ Page
    Title="Product Variants"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="ProductVariants.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.ProductVariantManagement" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <div class="container mt-4">

        <header class="page-heading">
            <div>
                <h1>Product variant management</h1>
                <p>Manage product sizes, prices, images, and availability.</p>
            </div>
        </header>

        <!-- ADD PRODUCT VARIANT FORM -->
        <div class="card shadow-sm mb-4">
            <div class="card-header">
                <strong>Add Product Variant</strong>
            </div>

            <div class="card-body">

                <asp:ValidationSummary
                    ID="validationSummary"
                    runat="server"
                    ValidationGroup="VariantForm"
                    CssClass="alert alert-danger"
                    HeaderText="Please correct the following:"
                    DisplayMode="BulletList" />

                <asp:Label
                    ID="lblMessage"
                    runat="server"
                    Visible="false">
                </asp:Label>

                <div class="row">

                    <!-- PRODUCT -->
                    <div class="col-md-3 mb-3">
                        <asp:Label
                            ID="lblProduct"
                            runat="server"
                            AssociatedControlID="ddlProduct"
                            CssClass="form-label"
                            Text="Product">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlProduct"
                            runat="server"
                            CssClass="form-select">
                        </asp:DropDownList>

                        <asp:RequiredFieldValidator
                            ID="requiredProduct"
                            runat="server"
                            ControlToValidate="ddlProduct"
                            InitialValue=""
                            ValidationGroup="VariantForm"
                            ErrorMessage="Product is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- SIZE -->
                    <div class="col-md-2 mb-3">
                        <asp:Label
                            ID="lblSize"
                            runat="server"
                            AssociatedControlID="ddlSize"
                            CssClass="form-label"
                            Text="Size">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlSize"
                            runat="server"
                            CssClass="form-select">
                        </asp:DropDownList>

                        <small class="text-muted">
                            Optional
                        </small>
                    </div>

                    <!-- PRICE -->
                    <div class="col-md-2 mb-3">
                        <asp:Label
                            ID="lblPrice"
                            runat="server"
                            AssociatedControlID="txtPrice"
                            CssClass="form-label"
                            Text="Price">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtPrice"
                            runat="server"
                            CssClass="form-control"
                            TextMode="Number"
                            min="0"
                            step="0.01"
                            placeholder="0.00">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredPrice"
                            runat="server"
                            ControlToValidate="txtPrice"
                            ValidationGroup="VariantForm"
                            ErrorMessage="Price is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>

                        <asp:RangeValidator
                            ID="rangePrice"
                            runat="server"
                            ControlToValidate="txtPrice"
                            ValidationGroup="VariantForm"
                            Type="Double"
                            MinimumValue="0"
                            MaximumValue="99999999.99"
                            ErrorMessage="Price must be zero or greater."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RangeValidator>
                    </div>

                    <!-- IMAGE -->
                    <div class="col-md-3 mb-3">
                        <asp:Label
                            ID="lblImage"
                            runat="server"
                            AssociatedControlID="uploadImage"
                            CssClass="form-label"
                            Text="Variant image">
                        </asp:Label>

                        <asp:FileUpload
                            ID="uploadImage"
                            runat="server"
                            CssClass="form-control"
                            accept=".jpg,.jpeg,.png,.webp" />

                        <small class="text-muted">
                            Optional. JPG, PNG, or WebP. Maximum 3 MB.
                        </small>
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
                            ID="btnAddVariant"
                            runat="server"
                            Text="Add Variant"
                            CssClass="btn btn-primary w-100"
                            ValidationGroup="VariantForm"
                            OnClick="btnAddVariant_Click" />
                    </div>

                </div>
            </div>
        </div>

        <!-- PRODUCT VARIANT TABLE -->
        <div class="card shadow-sm">
            <div class="card-header">
                <strong>Product Variant List</strong>
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
                        ID="gridVariants"
                        runat="server"
                        AutoGenerateColumns="false"
                        GridLines="None"
                        CssClass="table table-striped table-hover align-middle"
                        EmptyDataText="No product variants have been created.">

                        <Columns>
                            <asp:BoundField
                                DataField="ProductVariantID"
                                HeaderText="ID" />

                            <asp:TemplateField HeaderText="Image">
                                <ItemTemplate>
                                    <asp:Image
                                        ID="imgVariant"
                                        runat="server"
                                        ImageUrl='<%# Eval("ImagePath") %>'
                                        Visible='<%# !string.IsNullOrWhiteSpace(Convert.ToString(Eval("ImagePath"))) %>'
                                        AlternateText="Product variant"
                                        Width="70"
                                        Height="70"
                                        Style="object-fit: cover; border-radius: 6px;" />

                                    <asp:Label
                                        ID="lblNoImage"
                                        runat="server"
                                        Text="No image"
                                        CssClass="text-muted"
                                        Visible='<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ImagePath"))) %>'>
                                    </asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>

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
                                DataField="Price"
                                HeaderText="Price"
                                DataFormatString="₱{0:N2}"
                                HtmlEncode="false" />

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