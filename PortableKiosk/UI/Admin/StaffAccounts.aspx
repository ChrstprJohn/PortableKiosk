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

    <main class="mx-auto w-full max-w-7xl" aria-labelledby="staffHeading">
        <header class="mb-7 flex flex-col items-start justify-between gap-3 sm:flex-row sm:items-end">
            <div>
                <h1 id="staffHeading" class="text-2xl font-semibold tracking-tight text-slate-950 sm:text-3xl">Staff accounts</h1>
            </div>
            <button type="button" class="inline-flex min-h-9 items-center justify-center gap-2 rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-toggle="true" data-modal-target="#addStaffModal">
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg>
                Add staff
            </button>
        </header>

        <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="mb-4 block rounded-md border px-4 py-3 text-sm" role="status" aria-live="polite"></asp:Label>

        <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="addStaffModal" tabindex="-1" aria-labelledby="createStaffHeading" aria-hidden="true">
            <div class="w-full max-w-3xl">
                <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                    <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                        <h2 id="createStaffHeading" class="text-base font-semibold text-slate-950">Add staff account</h2>
                        <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close">
                            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg>
                        </button>
                    </div>
                    <div class="space-y-5 overflow-y-auto p-5">
            <asp:ValidationSummary
                ID="validationSummary"
                runat="server"
                ValidationGroup="StaffForm"
                CssClass="rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800"
                HeaderText="Please correct the following:"
                DisplayMode="BulletList" />

            <section aria-labelledby="staffDetailsHeading">
                <h3 id="staffDetailsHeading" class="mb-3 text-sm font-semibold text-slate-900">Staff details</h3>
                <div class="flex flex-col gap-4">
                <div class="w-full">
                    <asp:Label ID="lblFirstName" runat="server"
                        AssociatedControlID="txtFirstName"
                        CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="First name *" />
                    <asp:TextBox ID="txtFirstName" runat="server"
                        CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" MaxLength="50"
                        autocomplete="off" autofocus="autofocus" />
                    <asp:RequiredFieldValidator ID="requiredFirstName"
                        runat="server" ControlToValidate="txtFirstName"
                        ValidationGroup="StaffForm"
                        ErrorMessage="First name is required."
                        CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                </div>

                <div class="w-full">
                    <asp:Label ID="lblMiddleName" runat="server"
                        AssociatedControlID="txtMiddleName"
                        CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Middle name" />
                    <asp:TextBox ID="txtMiddleName" runat="server"
                        CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" MaxLength="50"
                        autocomplete="off" />
                </div>

                <div class="w-full">
                    <asp:Label ID="lblLastName" runat="server"
                        AssociatedControlID="txtLastName"
                        CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Last name *" />
                    <asp:TextBox ID="txtLastName" runat="server"
                        CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" MaxLength="50"
                        autocomplete="off" />
                    <asp:RequiredFieldValidator ID="requiredLastName"
                        runat="server" ControlToValidate="txtLastName"
                        ValidationGroup="StaffForm"
                        ErrorMessage="Last name is required."
                        CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                </div>

                <div class="w-full">
                    <asp:Label ID="lblSuffix" runat="server"
                        AssociatedControlID="txtSuffix"
                        CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Suffix" />
                    <asp:TextBox ID="txtSuffix" runat="server"
                        CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" MaxLength="20"
                        placeholder="Jr." autocomplete="off" />
                </div>

                <div class="w-full">
                    <asp:Label ID="lblEmail" runat="server"
                        AssociatedControlID="txtEmail"
                        CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Email address *" />
                    <asp:TextBox ID="txtEmail" runat="server"
                        CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" TextMode="Email"
                        MaxLength="256" autocomplete="off" />
                    <asp:RequiredFieldValidator ID="requiredEmail"
                        runat="server" ControlToValidate="txtEmail"
                        ValidationGroup="StaffForm"
                        ErrorMessage="Email address is required."
                        CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="validEmail"
                        runat="server" ControlToValidate="txtEmail"
                        ValidationGroup="StaffForm"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                        ErrorMessage="Enter a valid email address."
                        CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                </div>

                </div>
            </section>

            <section class="border-t border-slate-100 pt-4" aria-labelledby="staffAccessHeading">
                <h3 id="staffAccessHeading" class="mb-3 text-sm font-semibold text-slate-900">Account access</h3>
                <div class="flex flex-col gap-4">

                <div class="w-full">
                    <asp:Label ID="lblRole" runat="server"
                        AssociatedControlID="ddlRole"
                        CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Workspace role *" />
                    <asp:DropDownList ID="ddlRole" runat="server"
                        CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200">
                        <asp:ListItem Text="Crew — POS access" Value="CREW" />
                        <asp:ListItem Text="Admin — management access" Value="ADMIN" />
                    </asp:DropDownList>
                </div>

                <div class="flex min-h-10 w-full items-center">
                    <asp:CheckBox ID="chkIsActive" runat="server"
                        Checked="true" Text=" Active account"
                        CssClass="inline-flex items-center gap-2 text-sm text-slate-700 [&_input]:size-4 [&_input]:accent-slate-900" />
                </div>

                <div class="w-full">
                    <asp:Label ID="lblPassword" runat="server"
                        AssociatedControlID="txtPassword"
                        CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Temporary password *" />
                    <asp:TextBox ID="txtPassword" runat="server"
                        CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" TextMode="Password"
                        MaxLength="100" autocomplete="new-password" />
                    <asp:RequiredFieldValidator ID="requiredPassword"
                        runat="server" ControlToValidate="txtPassword"
                        ValidationGroup="StaffForm"
                        ErrorMessage="Password is required."
                        CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="validPasswordLength"
                        runat="server" ControlToValidate="txtPassword"
                        ValidationGroup="StaffForm"
                        ValidationExpression="^.{8,100}$"
                        ErrorMessage="Password must contain at least 8 characters."
                        CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                </div>

                <div class="w-full">
                    <asp:Label ID="lblConfirmPassword" runat="server"
                        AssociatedControlID="txtConfirmPassword"
                        CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Confirm password *" />
                    <asp:TextBox ID="txtConfirmPassword" runat="server"
                        CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" TextMode="Password"
                        MaxLength="100" autocomplete="new-password" />
                    <asp:RequiredFieldValidator ID="requiredConfirmPassword"
                        runat="server" ControlToValidate="txtConfirmPassword"
                        ValidationGroup="StaffForm"
                        ErrorMessage="Confirm the password."
                        CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                    <asp:CompareValidator ID="passwordsMatch"
                        runat="server" ControlToValidate="txtConfirmPassword"
                        ControlToCompare="txtPassword"
                        ValidationGroup="StaffForm"
                        ErrorMessage="Passwords do not match."
                        CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                </div>
            </div>
            </section>

                    </div>
                    <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4">
                        <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Cancel</button>
                <asp:Button ID="btnCreateStaff" runat="server"
                    Text="Add staff"
                    CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400"
                    ValidationGroup="StaffForm"
                    OnClick="btnCreateStaff_Click" />
                    </div>
                </div>
            </div>
        </div>

        <section class="overflow-hidden rounded-lg border border-slate-200 bg-white" aria-labelledby="staffListHeading">
            <div class="border-b border-slate-200 px-4 py-3">
                <h2 id="staffListHeading" class="text-sm font-semibold text-slate-950">Current staff</h2>
            </div>

            <asp:Label ID="lblLoadError" runat="server"
                Visible="false" CssClass="m-3 block rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800" />

            <div class="w-full overflow-x-auto">
                <asp:GridView ID="gridStaff" runat="server"
                    AutoGenerateColumns="false" GridLines="None"
                    CssClass="w-full min-w-[600px] border-collapse text-left text-sm [&_th]:border-b [&_th]:border-slate-200 [&_th]:bg-white [&_th]:px-4 [&_th]:py-2.5 [&_th]:text-xs [&_th]:font-medium [&_th]:text-slate-500 [&_td]:px-4 [&_td]:py-2.5 [&_td]:text-slate-700 [&_tbody_tr]:border-b [&_tbody_tr]:border-slate-100 [&_tbody_tr:hover]:bg-slate-50 [&_tbody_tr:last-child]:border-b-0"
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
                    <EmptyDataRowStyle CssClass="text-center text-slate-500 [&_td]:px-4 [&_td]:py-10" />
                </asp:GridView>
            </div>

        </section>
    </main>

</asp:Content>
