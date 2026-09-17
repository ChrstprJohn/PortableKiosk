<%@ Page
    Title="Bundle Slots"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="BundleSlots.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.BundleSlotManagement" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <div class="container mt-4">

        <header class="page-heading">
            <div>
                <h1>Bundle slot management</h1>
                <p>Configure fixed products and reusable choices for each bundle.</p>
            </div>
        </header>

        <!-- ADD BUNDLE SLOT FORM -->
        <div class="card shadow-sm mb-4">
            <div class="card-header">
                <strong>Add Bundle Slot</strong>
            </div>

            <div class="card-body">

                <asp:ValidationSummary
                    ID="validationSummary"
                    runat="server"
                    ValidationGroup="BundleSlotForm"
                    CssClass="alert alert-danger"
                    HeaderText="Please correct the following:"
                    DisplayMode="BulletList" />

                <asp:Label
                    ID="lblMessage"
                    runat="server"
                    Visible="false">
                </asp:Label>

                <div class="row">

                    <!-- BUNDLE -->
                    <div class="col-md-4 mb-3">
                        <asp:Label
                            ID="lblBundle"
                            runat="server"
                            AssociatedControlID="ddlBundle"
                            CssClass="form-label"
                            Text="Bundle">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlBundle"
                            runat="server"
                            CssClass="form-select">
                        </asp:DropDownList>

                        <asp:RequiredFieldValidator
                            ID="requiredBundle"
                            runat="server"
                            ControlToValidate="ddlBundle"
                            InitialValue=""
                            ValidationGroup="BundleSlotForm"
                            ErrorMessage="Bundle is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- SLOT NAME -->
                    <div class="col-md-4 mb-3">
                        <asp:Label
                            ID="lblSlotName"
                            runat="server"
                            AssociatedControlID="txtSlotName"
                            CssClass="form-label"
                            Text="Slot name">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtSlotName"
                            runat="server"
                            CssClass="form-control"
                            MaxLength="100"
                            placeholder="Example: Drink">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredSlotName"
                            runat="server"
                            ControlToValidate="txtSlotName"
                            ValidationGroup="BundleSlotForm"
                            ErrorMessage="Slot name is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- SLOT TYPE -->
                    <div class="col-md-4 mb-3">
                        <asp:Label
                            ID="lblSlotType"
                            runat="server"
                            AssociatedControlID="ddlSlotType"
                            CssClass="form-label"
                            Text="Slot type">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlSlotType"
                            runat="server"
                            CssClass="form-select"
                            AutoPostBack="true"
                            CausesValidation="false"
                            OnSelectedIndexChanged="ddlSlotType_SelectedIndexChanged">

                            <asp:ListItem
                                Text="Fixed product"
                                Value="FIXED"
                                Selected="true" />

                            <asp:ListItem
                                Text="Choice group"
                                Value="CHOICE" />
                        </asp:DropDownList>
                    </div>

                </div>

                <div class="row">

                    <!-- FIXED PRODUCT -->
                    <asp:Panel
                        ID="pnlFixedProduct"
                        runat="server"
                        CssClass="col-md-6 mb-3">

                        <asp:Label
                            ID="lblFixedProductVariant"
                            runat="server"
                            AssociatedControlID="ddlFixedProductVariant"
                            CssClass="form-label"
                            Text="Fixed product variant">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlFixedProductVariant"
                            runat="server"
                            CssClass="form-select">
                        </asp:DropDownList>

                        <asp:RequiredFieldValidator
                            ID="requiredFixedProductVariant"
                            runat="server"
                            ControlToValidate="ddlFixedProductVariant"
                            InitialValue=""
                            ValidationGroup="BundleSlotForm"
                            ErrorMessage="Fixed product variant is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </asp:Panel>

                    <!-- OPTION GROUP -->
                    <asp:Panel
                        ID="pnlOptionGroup"
                        runat="server"
                        CssClass="col-md-6 mb-3"
                        Visible="false">

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
                            CssClass="form-select"
                            AutoPostBack="true"
                            CausesValidation="false"
                            OnSelectedIndexChanged="ddlOptionGroup_SelectedIndexChanged">
                        </asp:DropDownList>

                        <asp:RequiredFieldValidator
                            ID="requiredOptionGroup"
                            runat="server"
                            ControlToValidate="ddlOptionGroup"
                            InitialValue=""
                            ValidationGroup="BundleSlotForm"
                            ErrorMessage="Option group is required."
                            CssClass="text-danger"
                            Display="Dynamic"
                            Enabled="false">
                        </asp:RequiredFieldValidator>
                    </asp:Panel>

                    <!-- DEFAULT CHOICE -->
                    <asp:Panel
                        ID="pnlDefaultProductVariant"
                        runat="server"
                        CssClass="col-md-6 mb-3"
                        Visible="false">

                        <asp:Label
                            ID="lblDefaultProductVariant"
                            runat="server"
                            AssociatedControlID="ddlDefaultProductVariant"
                            CssClass="form-label"
                            Text="Default choice">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlDefaultProductVariant"
                            runat="server"
                            CssClass="form-select"
                            Enabled="false">
                        </asp:DropDownList>

                        <small class="text-muted d-block">
                            Only available choices with a ₱0.00 upgrade price can be defaults.
                        </small>

                        <asp:RequiredFieldValidator
                            ID="requiredDefaultProductVariant"
                            runat="server"
                            ControlToValidate="ddlDefaultProductVariant"
                            InitialValue=""
                            ValidationGroup="BundleSlotForm"
                            ErrorMessage="Default choice is required."
                            CssClass="text-danger"
                            Display="Dynamic"
                            Enabled="false">
                        </asp:RequiredFieldValidator>
                    </asp:Panel>

                </div>

                <div class="row">

                    <!-- QUANTITY -->
                    <div class="col-md-2 mb-3">
                        <asp:Label
                            ID="lblQuantity"
                            runat="server"
                            AssociatedControlID="txtQuantity"
                            CssClass="form-label"
                            Text="Quantity">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtQuantity"
                            runat="server"
                            CssClass="form-control"
                            TextMode="Number"
                            Text="1"
                            min="1">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredQuantity"
                            runat="server"
                            ControlToValidate="txtQuantity"
                            ValidationGroup="BundleSlotForm"
                            ErrorMessage="Quantity is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>

                        <asp:RangeValidator
                            ID="rangeQuantity"
                            runat="server"
                            ControlToValidate="txtQuantity"
                            ValidationGroup="BundleSlotForm"
                            Type="Integer"
                            MinimumValue="1"
                            MaximumValue="2147483647"
                            ErrorMessage="Quantity must be greater than zero."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RangeValidator>
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
                            ValidationGroup="BundleSlotForm"
                            ErrorMessage="Display order is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>

                        <asp:RangeValidator
                            ID="rangeDisplayOrder"
                            runat="server"
                            ControlToValidate="txtDisplayOrder"
                            ValidationGroup="BundleSlotForm"
                            Type="Integer"
                            MinimumValue="0"
                            MaximumValue="2147483647"
                            ErrorMessage="Display order must be zero or greater."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RangeValidator>
                    </div>

                    <!-- REQUIRED -->
                    <div class="col-md-3 mb-3">
                        <label class="form-label d-block">
                            Selection
                        </label>

                        <asp:CheckBox
                            ID="chkIsRequired"
                            runat="server"
                            Checked="true"
                            Text=" Required" />
                    </div>

                    <!-- BUTTON -->
                    <div class="col-md-3 mb-3 d-flex align-items-end">
                        <asp:Button
                            ID="btnAddSlot"
                            runat="server"
                            Text="Add Bundle Slot"
                            CssClass="btn btn-primary w-100"
                            ValidationGroup="BundleSlotForm"
                            OnClick="btnAddSlot_Click" />
                    </div>

                </div>
            </div>
        </div>

        <!-- BUNDLE SLOT TABLE -->
        <div class="card shadow-sm">
            <div class="card-header">
                <strong>Bundle Slot List</strong>
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
                        ID="gridSlots"
                        runat="server"
                        AutoGenerateColumns="false"
                        GridLines="None"
                        CssClass="table table-striped table-hover align-middle"
                        EmptyDataText="No bundle slots have been created.">

                        <Columns>
                            <asp:BoundField
                                DataField="BundleSlotID"
                                HeaderText="ID" />

                            <asp:BoundField
                                DataField="BundleName"
                                HeaderText="Bundle" />

                            <asp:BoundField
                                DataField="SlotName"
                                HeaderText="Slot" />

                            <asp:BoundField
                                DataField="SlotType"
                                HeaderText="Type" />

                            <asp:BoundField
                                DataField="ConfigurationDescription"
                                HeaderText="Configuration" />

                            <asp:BoundField
                                DataField="Quantity"
                                HeaderText="Quantity" />

                            <asp:CheckBoxField
                                DataField="IsRequired"
                                HeaderText="Required"
                                ReadOnly="true" />

                            <asp:BoundField
                                DataField="DisplayOrder"
                                HeaderText="Display Order" />
                        </Columns>

                        <HeaderStyle CssClass="table-dark" />
                        <EmptyDataRowStyle CssClass="text-center text-muted" />
                    </asp:GridView>
                </div>

            </div>
        </div>

    </div>

</asp:Content>
