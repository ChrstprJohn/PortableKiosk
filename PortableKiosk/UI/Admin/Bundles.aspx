<%@ Page
    Title="Bundles"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="Bundles.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.BundleManagement" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <div class="container mt-4">

        <header class="page-heading">
            <div>
                <h1>Bundle management</h1>
                <p>Manage the bundles shown across kiosk and POS.</p>
            </div>
        </header>

        <!-- ADD BUNDLE FORM -->
        <div class="card shadow-sm mb-4">
            <div class="card-header">
                <strong>Add Bundle</strong>
            </div>

            <div class="card-body">

                <asp:ValidationSummary
                    ID="validationSummary"
                    runat="server"
                    ValidationGroup="BundleForm"
                    CssClass="alert alert-danger"
                    HeaderText="Please correct the following:"
                    DisplayMode="BulletList" />

                <asp:Label
                    ID="lblMessage"
                    runat="server"
                    Visible="false">
                </asp:Label>

                <div class="row">

                    <!-- BUNDLE NAME -->
                    <div class="col-md-3 mb-3">
                        <asp:Label
                            ID="lblBundleName"
                            runat="server"
                            AssociatedControlID="txtBundleName"
                            CssClass="form-label"
                            Text="Bundle name">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtBundleName"
                            runat="server"
                            CssClass="form-control"
                            MaxLength="100"
                            placeholder="Example: Family Meal">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredBundleName"
                            runat="server"
                            ControlToValidate="txtBundleName"
                            ValidationGroup="BundleForm"
                            ErrorMessage="Bundle name is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- BASE PRICE -->
                    <div class="col-md-2 mb-3">
                        <asp:Label
                            ID="lblBasePrice"
                            runat="server"
                            AssociatedControlID="txtBasePrice"
                            CssClass="form-label"
                            Text="Base price">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtBasePrice"
                            runat="server"
                            CssClass="form-control"
                            TextMode="Number"
                            min="0"
                            step="0.01"
                            placeholder="0.00">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredBasePrice"
                            runat="server"
                            ControlToValidate="txtBasePrice"
                            ValidationGroup="BundleForm"
                            ErrorMessage="Base price is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>

                        <asp:RangeValidator
                            ID="rangeBasePrice"
                            runat="server"
                            ControlToValidate="txtBasePrice"
                            ValidationGroup="BundleForm"
                            Type="Double"
                            MinimumValue="0"
                            MaximumValue="99999999.99"
                            ErrorMessage="Base price must be zero or greater."
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
                            Text="Bundle image">
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
                            ValidationGroup="BundleForm"
                            ErrorMessage="Display order is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>

                        <asp:RangeValidator
                            ID="rangeDisplayOrder"
                            runat="server"
                            ControlToValidate="txtDisplayOrder"
                            ValidationGroup="BundleForm"
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
                            ID="btnAddBundle"
                            runat="server"
                            Text="Add Bundle"
                            CssClass="btn btn-primary w-100"
                            ValidationGroup="BundleForm"
                            OnClick="btnAddBundle_Click" />
                    </div>

                </div>
            </div>
        </div>

        <!-- BUNDLE TABLE -->
        <div class="card shadow-sm">
            <div class="card-header">
                <strong>Bundle List</strong>
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
                        ID="gridBundles"
                        runat="server"
                        AutoGenerateColumns="false"
                        GridLines="None"
                        CssClass="table table-striped table-hover align-middle"
                        EmptyDataText="No bundles have been created.">

                        <Columns>
                            <asp:BoundField
                                DataField="BundleID"
                                HeaderText="ID" />

                            <asp:TemplateField HeaderText="Image">
                                <ItemTemplate>
                                    <asp:Image
                                        ID="imgBundle"
                                        runat="server"
                                        ImageUrl='<%# Eval("ImagePath") %>'
                                        Visible='<%# !string.IsNullOrWhiteSpace(Convert.ToString(Eval("ImagePath"))) %>'
                                        AlternateText="Bundle"
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
                                DataField="BundleName"
                                HeaderText="Bundle Name" />

                            <asp:BoundField
                                DataField="BasePrice"
                                HeaderText="Base Price"
                                DataFormatString="₱{0:N2}"
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

                        <EmptyDataRowStyle
                            CssClass="text-center text-muted" />

                    </asp:GridView>

                </div>
            </div>
        </div>

    </div>

</asp:Content>