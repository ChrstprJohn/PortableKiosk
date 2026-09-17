<%@ Page
    Title="Staff Accounts"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="StaffAccounts.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.StaffAccounts" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <main class="staff-shell" aria-labelledby="staffHeading">
        <header class="page-heading">
            <div>
                <h1 id="staffHeading">Staff accounts</h1>
                <p>Create role-based access for managers and counter crew.</p>
            </div>
        </header>

        <section class="staff-create-panel" aria-labelledby="createStaffHeading">
            <div class="section-heading">
                <h2 id="createStaffHeading">Add staff member</h2>
                <p>Required fields are marked. Middle name and suffix are optional.</p>
            </div>

            <asp:ValidationSummary
                ID="validationSummary"
                runat="server"
                ValidationGroup="StaffForm"
                CssClass="alert alert-danger"
                HeaderText="Check the following:"
                DisplayMode="BulletList" />

            <asp:Label
                ID="lblMessage"
                runat="server"
                Visible="false">
            </asp:Label>

            <div class="row g-3">
                <div class="col-md-4">
                    <asp:Label ID="lblFirstName" runat="server"
                        AssociatedControlID="txtFirstName"
                        CssClass="form-label" Text="First name *" />
                    <asp:TextBox ID="txtFirstName" runat="server"
                        CssClass="form-control" MaxLength="50"
                        autocomplete="off" />
                    <asp:RequiredFieldValidator ID="requiredFirstName"
                        runat="server" ControlToValidate="txtFirstName"
                        ValidationGroup="StaffForm"
                        ErrorMessage="First name is required."
                        CssClass="field-error" Display="Dynamic" />
                </div>

                <div class="col-md-4">
                    <asp:Label ID="lblMiddleName" runat="server"
                        AssociatedControlID="txtMiddleName"
                        CssClass="form-label" Text="Middle name" />
                    <asp:TextBox ID="txtMiddleName" runat="server"
                        CssClass="form-control" MaxLength="50"
                        autocomplete="off" />
                </div>

                <div class="col-md-3">
                    <asp:Label ID="lblLastName" runat="server"
                        AssociatedControlID="txtLastName"
                        CssClass="form-label" Text="Last name *" />
                    <asp:TextBox ID="txtLastName" runat="server"
                        CssClass="form-control" MaxLength="50"
                        autocomplete="off" />
                    <asp:RequiredFieldValidator ID="requiredLastName"
                        runat="server" ControlToValidate="txtLastName"
                        ValidationGroup="StaffForm"
                        ErrorMessage="Last name is required."
                        CssClass="field-error" Display="Dynamic" />
                </div>

                <div class="col-md-1">
                    <asp:Label ID="lblSuffix" runat="server"
                        AssociatedControlID="txtSuffix"
                        CssClass="form-label" Text="Suffix" />
                    <asp:TextBox ID="txtSuffix" runat="server"
                        CssClass="form-control" MaxLength="20"
                        placeholder="Jr." autocomplete="off" />
                </div>

                <div class="col-md-6">
                    <asp:Label ID="lblEmail" runat="server"
                        AssociatedControlID="txtEmail"
                        CssClass="form-label" Text="Email address *" />
                    <asp:TextBox ID="txtEmail" runat="server"
                        CssClass="form-control" TextMode="Email"
                        MaxLength="256" autocomplete="off" />
                    <asp:RequiredFieldValidator ID="requiredEmail"
                        runat="server" ControlToValidate="txtEmail"
                        ValidationGroup="StaffForm"
                        ErrorMessage="Email address is required."
                        CssClass="field-error" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="validEmail"
                        runat="server" ControlToValidate="txtEmail"
                        ValidationGroup="StaffForm"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                        ErrorMessage="Enter a valid email address."
                        CssClass="field-error" Display="Dynamic" />
                </div>

                <div class="col-md-3">
                    <asp:Label ID="lblRole" runat="server"
                        AssociatedControlID="ddlRole"
                        CssClass="form-label" Text="Workspace role *" />
                    <asp:DropDownList ID="ddlRole" runat="server"
                        CssClass="form-select">
                        <asp:ListItem Text="Crew — POS access" Value="CREW" />
                        <asp:ListItem Text="Admin — management access" Value="ADMIN" />
                    </asp:DropDownList>
                </div>

                <div class="col-md-3 d-flex align-items-end pb-2">
                    <asp:CheckBox ID="chkIsActive" runat="server"
                        Checked="true" Text=" Active account"
                        CssClass="form-check" />
                </div>

                <div class="col-md-6">
                    <asp:Label ID="lblPassword" runat="server"
                        AssociatedControlID="txtPassword"
                        CssClass="form-label" Text="Temporary password *" />
                    <asp:TextBox ID="txtPassword" runat="server"
                        CssClass="form-control" TextMode="Password"
                        MaxLength="100" autocomplete="new-password" />
                    <asp:RequiredFieldValidator ID="requiredPassword"
                        runat="server" ControlToValidate="txtPassword"
                        ValidationGroup="StaffForm"
                        ErrorMessage="Password is required."
                        CssClass="field-error" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="validPasswordLength"
                        runat="server" ControlToValidate="txtPassword"
                        ValidationGroup="StaffForm"
                        ValidationExpression="^.{8,100}$"
                        ErrorMessage="Password must contain at least 8 characters."
                        CssClass="field-error" Display="Dynamic" />
                </div>

                <div class="col-md-6">
                    <asp:Label ID="lblConfirmPassword" runat="server"
                        AssociatedControlID="txtConfirmPassword"
                        CssClass="form-label" Text="Confirm password *" />
                    <asp:TextBox ID="txtConfirmPassword" runat="server"
                        CssClass="form-control" TextMode="Password"
                        MaxLength="100" autocomplete="new-password" />
                    <asp:RequiredFieldValidator ID="requiredConfirmPassword"
                        runat="server" ControlToValidate="txtConfirmPassword"
                        ValidationGroup="StaffForm"
                        ErrorMessage="Confirm the password."
                        CssClass="field-error" Display="Dynamic" />
                    <asp:CompareValidator ID="passwordsMatch"
                        runat="server" ControlToValidate="txtConfirmPassword"
                        ControlToCompare="txtPassword"
                        ValidationGroup="StaffForm"
                        ErrorMessage="Passwords do not match."
                        CssClass="field-error" Display="Dynamic" />
                </div>
            </div>

            <div class="form-actions">
                <p>The selected role controls the workspace shown after sign-in.</p>
                <asp:Button ID="btnCreateStaff" runat="server"
                    Text="Create staff account"
                    CssClass="btn btn-primary"
                    ValidationGroup="StaffForm"
                    OnClick="btnCreateStaff_Click" />
            </div>
        </section>

        <section class="staff-list-panel" aria-labelledby="staffListHeading">
            <div class="section-heading">
                <h2 id="staffListHeading">Current staff</h2>
                <p>Inactive accounts remain visible for audit continuity.</p>
            </div>

            <asp:Label ID="lblLoadError" runat="server"
                Visible="false" CssClass="alert alert-danger d-block" />

            <div class="table-responsive">
                <asp:GridView ID="gridStaff" runat="server"
                    AutoGenerateColumns="false" GridLines="None"
                    CssClass="table staff-table align-middle"
                    EmptyDataText="No staff accounts have been created.">
                    <Columns>
                        <asp:BoundField DataField="DisplayName" HeaderText="Staff member" />
                        <asp:BoundField DataField="Email" HeaderText="Email" />
                        <asp:TemplateField HeaderText="Role">
                            <ItemTemplate>
                                <span class='<%# GetRoleCss(Eval("StaffRole")) %>'>
                                    <%#: Eval("StaffRole") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='<%# GetStatusCss(Eval("IsActive")) %>'>
                                    <%# GetStatusText(Eval("IsActive")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="CreatedAt" HeaderText="Created"
                            DataFormatString="{0:MMM d, yyyy}" />
                    </Columns>
                </asp:GridView>
            </div>
        </section>
    </main>

</asp:Content>
