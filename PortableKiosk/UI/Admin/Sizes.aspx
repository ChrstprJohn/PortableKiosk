<%@ Page
    Title="Sizes"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="Sizes.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.SizeManagement" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <div class="container mt-4">

        <header class="page-heading">
            <div>
                <h1>Size management</h1>
                <p>Manage the product sizes available across kiosk and POS.</p>
            </div>
        </header>

        <!-- ADD SIZE FORM -->
        <div class="card shadow-sm mb-4">
            <div class="card-header">
                <strong>Add Size</strong>
            </div>

            <div class="card-body">

                <asp:ValidationSummary
                    ID="validationSummary"
                    runat="server"
                    ValidationGroup="SizeForm"
                    CssClass="alert alert-danger"
                    HeaderText="Please correct the following:"
                    DisplayMode="BulletList" />

                <asp:Label
                    ID="lblMessage"
                    runat="server"
                    Visible="false">
                </asp:Label>

                <div class="row">

                    <div class="col-md-7 mb-3">
                        <asp:Label
                            ID="lblSizeName"
                            runat="server"
                            AssociatedControlID="txtSizeName"
                            CssClass="form-label"
                            Text="Size name">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtSizeName"
                            runat="server"
                            CssClass="form-control"
                            MaxLength="50"
                            placeholder="Example: Large">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredSizeName"
                            runat="server"
                            ControlToValidate="txtSizeName"
                            ValidationGroup="SizeForm"
                            ErrorMessage="Size name is required."
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
                            ValidationGroup="SizeForm"
                            ErrorMessage="Display order is required."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>

                        <asp:RangeValidator
                            ID="rangeDisplayOrder"
                            runat="server"
                            ControlToValidate="txtDisplayOrder"
                            ValidationGroup="SizeForm"
                            Type="Integer"
                            MinimumValue="0"
                            MaximumValue="2147483647"
                            ErrorMessage="Display order must be zero or greater."
                            CssClass="text-danger"
                            Display="Dynamic">
                        </asp:RangeValidator>
                    </div>

                    <div class="col-md-2 mb-3 d-flex align-items-end">
                        <asp:Button
                            ID="btnAddSize"
                            runat="server"
                            Text="Add Size"
                            CssClass="btn btn-primary w-100"
                            ValidationGroup="SizeForm"
                            OnClick="btnAddSize_Click" />
                    </div>

                </div>
            </div>
        </div>

        <!-- SIZE TABLE -->
        <div class="card shadow-sm">
            <div class="card-header">
                <strong>Size List</strong>
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
                        ID="gridSizes"
                        runat="server"
                        AutoGenerateColumns="false"
                        GridLines="None"
                        CssClass="table table-striped table-hover align-middle"
                        EmptyDataText="No sizes have been created.">

                        <Columns>
                            <asp:BoundField
                                DataField="SizeID"
                                HeaderText="ID" />

                            <asp:BoundField
                                DataField="SizeName"
                                HeaderText="Size Name" />

                            <asp:BoundField
                                DataField="DisplayOrder"
                                HeaderText="Display Order" />
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