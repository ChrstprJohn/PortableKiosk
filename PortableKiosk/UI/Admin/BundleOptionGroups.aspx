<%@ Page
    Title="Bundle Option Groups"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="BundleOptionGroups.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.BundleOptionGroupManagement" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <div class="container mt-4">

        <header class="page-heading">
            <div>
                <h1>Bundle option group management</h1>
                <p>
                    Create reusable groups such as Standard Drinks
                    and Standard Sides.
                </p>
            </div>
        </header>

        <!-- ADD OPTION GROUP FORM -->
        <div class="card shadow-sm mb-4">
            <div class="card-header">
                <strong>Add Option Group</strong>
            </div>

            <div class="card-body">

                <asp:ValidationSummary
                    ID="validationSummary"
                    runat="server"
                    ValidationGroup="OptionGroupForm"
                    CssClass="alert alert-danger"
                    HeaderText="Please correct the following:"
                    DisplayMode="BulletList" />

                <asp:Label
                    ID="lblMessage"
                    runat="server"
                    Visible="false">
                </asp:Label>

                <div class="row">

                    <!-- OPTION GROUP NAME -->
                    <div class="col-md-5 mb-3">
                        <asp:Label
                            ID="lblOptionGroupName"
                            runat="server"
                            AssociatedControlID="txtOptionGroupName"
                            CssClass="form-label"
                            Text="Option group name">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtOptionGroupName"
                            runat="server"
                            CssClass="form-control"
                            MaxLength="100"
                            placeholder="Example: Standard Drinks">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredOptionGroupName"
                            runat="server"
                            ControlToValidate="txtOptionGroupName"
                            ValidationGroup="OptionGroupForm"
                            ErrorMessage="Option group name is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- DISPLAY ORDER -->
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
                            ValidationGroup="OptionGroupForm"
                            ErrorMessage="Display order is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>

                        <asp:RangeValidator
                            ID="rangeDisplayOrder"
                            runat="server"
                            ControlToValidate="txtDisplayOrder"
                            ValidationGroup="OptionGroupForm"
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
                            ID="btnAddOptionGroup"
                            runat="server"
                            Text="Add Group"
                            CssClass="btn btn-primary w-100"
                            ValidationGroup="OptionGroupForm"
                            OnClick="btnAddOptionGroup_Click" />
                    </div>

                </div>
            </div>
        </div>

        <!-- OPTION GROUP TABLE -->
        <div class="card shadow-sm">
            <div class="card-header">
                <strong>Option Group List</strong>
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
                        ID="gridOptionGroups"
                        runat="server"
                        AutoGenerateColumns="false"
                        GridLines="None"
                        CssClass="table table-striped table-hover align-middle"
                        EmptyDataText="No option groups have been created.">

                        <Columns>
                            <asp:BoundField
                                DataField="OptionGroupID"
                                HeaderText="ID" />

                            <asp:BoundField
                                DataField="OptionGroupName"
                                HeaderText="Option Group Name" />

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