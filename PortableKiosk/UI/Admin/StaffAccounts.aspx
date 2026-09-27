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
                CssClass="rounded-lg border px-4 py-3 border-red-200 bg-red-50 text-red-800"
                HeaderText="Check the following:"
                DisplayMode="BulletList" />

            <asp:Label
                ID="lblMessage"
                runat="server"
                Visible="false">
            </asp:Label>

            <div class="grid grid-cols-12 gap-3">
                <div class="col-span-12 md:col-span-4">
                    <asp:Label ID="lblFirstName" runat="server"
                        AssociatedControlID="txtFirstName"
                        CssClass="mb-1 block text-sm font-semibold text-slate-700" Text="First name *" />
                    <asp:TextBox ID="txtFirstName" runat="server"
                        CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200" MaxLength="50"
                        autocomplete="off" />
                    <asp:RequiredFieldValidator ID="requiredFirstName"
                        runat="server" ControlToValidate="txtFirstName"
                        ValidationGroup="StaffForm"
                        ErrorMessage="First name is required."
                        CssClass="field-error" Display="Dynamic" />
                </div>

                <div class="col-span-12 md:col-span-4">
                    <asp:Label ID="lblMiddleName" runat="server"
                        AssociatedControlID="txtMiddleName"
                        CssClass="mb-1 block text-sm font-semibold text-slate-700" Text="Middle name" />
                    <asp:TextBox ID="txtMiddleName" runat="server"
                        CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200" MaxLength="50"
                        autocomplete="off" />
                </div>

                <div class="col-span-12 md:col-span-3">
                    <asp:Label ID="lblLastName" runat="server"
                        AssociatedControlID="txtLastName"
                        CssClass="mb-1 block text-sm font-semibold text-slate-700" Text="Last name *" />
                    <asp:TextBox ID="txtLastName" runat="server"
                        CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200" MaxLength="50"
                        autocomplete="off" />
                    <asp:RequiredFieldValidator ID="requiredLastName"
                        runat="server" ControlToValidate="txtLastName"
                        ValidationGroup="StaffForm"
                        ErrorMessage="Last name is required."
                        CssClass="field-error" Display="Dynamic" />
                </div>

                <div class="col-span-12 md:col-span-1">
                    <asp:Label ID="lblSuffix" runat="server"
                        AssociatedControlID="txtSuffix"
                        CssClass="mb-1 block text-sm font-semibold text-slate-700" Text="Suffix" />
                    <asp:TextBox ID="txtSuffix" runat="server"
                        CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200" MaxLength="20"
                        placeholder="Jr." autocomplete="off" />
                </div>

                <div class="col-span-12 md:col-span-6">
                    <asp:Label ID="lblEmail" runat="server"
                        AssociatedControlID="txtEmail"
                        CssClass="mb-1 block text-sm font-semibold text-slate-700" Text="Email address *" />
                    <asp:TextBox ID="txtEmail" runat="server"
                        CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200" TextMode="Email"
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

                <div class="col-span-12 md:col-span-3">
                    <asp:Label ID="lblRole" runat="server"
                        AssociatedControlID="ddlRole"
                        CssClass="mb-1 block text-sm font-semibold text-slate-700" Text="Workspace role *" />
                    <asp:DropDownList ID="ddlRole" runat="server"
                        CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200">
                        <asp:ListItem Text="Crew — POS access" Value="CREW" />
                        <asp:ListItem Text="Admin — management access" Value="ADMIN" />
                    </asp:DropDownList>
                </div>

                <div class="col-span-12 md:col-span-3 flex items-end pb-2">
                    <asp:CheckBox ID="chkIsActive" runat="server"
                        Checked="true" Text=" Active account"
                        CssClass="flex items-center gap-2" />
                </div>

                <div class="col-span-12 md:col-span-6">
                    <asp:Label ID="lblPassword" runat="server"
                        AssociatedControlID="txtPassword"
                        CssClass="mb-1 block text-sm font-semibold text-slate-700" Text="Temporary password *" />
                    <asp:TextBox ID="txtPassword" runat="server"
                        CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200" TextMode="Password"
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

                <div class="col-span-12 md:col-span-6">
                    <asp:Label ID="lblConfirmPassword" runat="server"
                        AssociatedControlID="txtConfirmPassword"
                        CssClass="mb-1 block text-sm font-semibold text-slate-700" Text="Confirm password *" />
                    <asp:TextBox ID="txtConfirmPassword" runat="server"
                        CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200" TextMode="Password"
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
                    CssClass="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-blue-700 bg-blue-700 text-white hover:bg-blue-800"
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
                Visible="false" CssClass="rounded-lg border px-4 py-3 border-red-200 bg-red-50 text-red-800 block" />

            <div class="w-full overflow-x-auto">
                <asp:GridView ID="gridStaff" runat="server"
                    AutoGenerateColumns="false" GridLines="None"
                    CssClass="w-full border-collapse text-left [&_th]:px-3 [&_th]:py-2 [&_td]:px-3 [&_td]:py-2 [&_tbody_tr]:border-b [&_tbody_tr]:border-slate-200 staff-table align-middle"
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
