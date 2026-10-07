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
                <p class="mt-1 text-sm text-slate-500">Manage staff roles and access.</p>
            </div>
            <button type="button" class="inline-flex min-h-9 items-center justify-center gap-2 rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-toggle="true" data-modal-target="#addStaffModal">
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg>
                Add staff
            </button>
        </header>

        <section class="mb-6" aria-label="Search and filter staff accounts">
            <div class="grid items-end gap-4 sm:grid-cols-2 lg:grid-cols-4">
                <div class="min-w-0 sm:col-span-2">
                    <label for="staffSearch" class="mb-1.5 block text-xs font-medium text-slate-600">Search staff</label>
                    <div class="relative">
                        <svg class="pointer-events-none absolute left-3 top-3.5 size-4 text-slate-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5" /><path d="m16 16 4.5 4.5" /></svg>
                        <input id="staffSearch" type="search" maxlength="150" autocomplete="off" placeholder="Search by name or email" class="block h-11 w-full rounded-md border border-slate-200 bg-white py-2 pl-10 pr-3 text-sm text-slate-900 placeholder:text-slate-500 focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" />
                    </div>
                </div>
                <div class="min-w-0">
                    <label for="staffRoleFilter" class="mb-1.5 block text-xs font-medium text-slate-600">Role</label>
                    <div class="relative">
                    <select id="staffRoleFilter" class="block h-11 w-full appearance-none rounded-md border border-slate-200 bg-white py-2 pl-3 pr-10 text-sm text-slate-900 focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200">
                        <option value="">All roles</option>
                        <option value="admin">Admin</option>
                        <option value="crew">Crew</option>
                    </select>
                    <svg class="pointer-events-none absolute inset-y-0 right-3 my-auto size-4 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6" /></svg>
                    </div>
                </div>
                <div class="min-w-0">
                    <label for="staffStatusFilter" class="mb-1.5 block text-xs font-medium text-slate-600">Account status</label>
                    <div class="relative">
                    <select id="staffStatusFilter" class="block h-11 w-full appearance-none rounded-md border border-slate-200 bg-white py-2 pl-3 pr-10 text-sm text-slate-900 focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200">
                        <option value="">All statuses</option>
                        <option value="true">Active</option>
                        <option value="false">Inactive</option>
                    </select>
                    <svg class="pointer-events-none absolute inset-y-0 right-3 my-auto size-4 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6" /></svg>
                    </div>
                </div>
            </div>
            <div class="mt-2 flex min-h-11 flex-wrap items-center justify-between gap-x-4">
                <p id="staffResultCount" class="m-0 text-xs text-slate-600" role="status" aria-live="polite" aria-atomic="true"></p>
                <button id="clearStaffFilters" type="button" hidden class="min-h-11 rounded-md px-3 text-sm font-medium text-slate-700 underline underline-offset-4 hover:text-slate-950 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400">Clear filters</button>
            </div>
        </section>

        <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="addStaffModal" tabindex="-1" aria-labelledby="createStaffHeading" aria-hidden="true">
            <div class="w-full max-w-md">
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
                HeaderText="Check these fields:"
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
                        CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Role *" />
                    <asp:DropDownList ID="ddlRole" runat="server"
                        CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200">
                          <asp:ListItem Text="Crew — POS and kitchen access" Value="CREW" />
                        <asp:ListItem Text="Admin — all workspaces" Value="ADMIN" />
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
                        CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Password *" />
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
                        ErrorMessage="Use at least 8 characters."
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

        <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="viewStaffModal" tabindex="-1" aria-labelledby="viewStaffHeading" aria-hidden="true">
            <div class="w-full max-w-md">
                <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                    <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                        <h2 id="viewStaffHeading" class="text-base font-semibold text-slate-950">Staff account</h2>
                        <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close">
                            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg>
                        </button>
                    </div>
                    <div class="overflow-y-auto p-5">
                        <dl class="divide-y divide-slate-100">
                            <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3 first:pt-0">
                                <dt class="text-sm text-slate-500">Name</dt>
                                <dd class="m-0 break-words text-sm font-medium text-slate-900"><asp:Label ID="lblViewStaffName" runat="server" /></dd>
                            </div>
                            <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3">
                                <dt class="text-sm text-slate-500">Email</dt>
                                <dd class="m-0 break-words text-sm font-medium text-slate-900"><asp:Label ID="lblViewStaffEmail" runat="server" /></dd>
                            </div>
                            <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3">
                                <dt class="text-sm text-slate-500">Role</dt>
                                <dd class="m-0 text-sm font-medium text-slate-900"><asp:Label ID="lblViewStaffRole" runat="server" /></dd>
                            </div>
                            <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3">
                                <dt class="text-sm text-slate-500">Status</dt>
                                <dd class="m-0 text-sm font-medium text-slate-900"><asp:Label ID="lblViewStaffStatus" runat="server" /></dd>
                            </div>
                            <div class="grid grid-cols-[7rem_minmax(0,1fr)] gap-3 py-3 last:pb-0">
                                <dt class="text-sm text-slate-500">Created</dt>
                                <dd class="m-0 text-sm font-medium text-slate-900"><asp:Label ID="lblViewStaffCreated" runat="server" /></dd>
                            </div>
                        </dl>
                    </div>
                    <div class="flex justify-end border-t border-slate-200 px-5 py-4">
                        <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="editStaffModal" tabindex="-1" aria-labelledby="editStaffHeading" aria-hidden="true">
            <div class="w-full max-w-md">
                <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                    <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                        <h2 id="editStaffHeading" class="text-base font-semibold text-slate-950">Edit staff account</h2>
                        <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close">
                            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg>
                        </button>
                    </div>
                    <div class="space-y-4 overflow-y-auto p-5">
                        <asp:ValidationSummary ID="editStaffValidationSummary" runat="server" ValidationGroup="EditStaffForm" CssClass="rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800" HeaderText="Check these fields:" DisplayMode="BulletList" />
                        <asp:HiddenField ID="hfEditStaffAccountID" runat="server" />
                        <div>
                            <asp:Label ID="lblEditStaffFirstName" runat="server" AssociatedControlID="txtEditStaffFirstName" CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="First name *" />
                            <asp:TextBox ID="txtEditStaffFirstName" runat="server" MaxLength="50" CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" />
                            <asp:RequiredFieldValidator ID="requiredEditStaffFirstName" runat="server" ControlToValidate="txtEditStaffFirstName" ValidationGroup="EditStaffForm" ErrorMessage="First name is required." CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                        </div>
                        <div>
                            <asp:Label ID="lblEditStaffMiddleName" runat="server" AssociatedControlID="txtEditStaffMiddleName" CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Middle name" />
                            <asp:TextBox ID="txtEditStaffMiddleName" runat="server" MaxLength="50" CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" />
                        </div>
                        <div>
                            <asp:Label ID="lblEditStaffLastName" runat="server" AssociatedControlID="txtEditStaffLastName" CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Last name *" />
                            <asp:TextBox ID="txtEditStaffLastName" runat="server" MaxLength="50" CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" />
                            <asp:RequiredFieldValidator ID="requiredEditStaffLastName" runat="server" ControlToValidate="txtEditStaffLastName" ValidationGroup="EditStaffForm" ErrorMessage="Last name is required." CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                        </div>
                        <div>
                            <asp:Label ID="lblEditStaffSuffix" runat="server" AssociatedControlID="txtEditStaffSuffix" CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Suffix" />
                            <asp:TextBox ID="txtEditStaffSuffix" runat="server" MaxLength="20" placeholder="Jr." CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" />
                        </div>
                        <div>
                            <asp:Label ID="lblEditStaffEmail" runat="server" AssociatedControlID="txtEditStaffEmail" CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Email address *" />
                            <asp:TextBox ID="txtEditStaffEmail" runat="server" TextMode="Email" MaxLength="256" CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" />
                            <asp:RequiredFieldValidator ID="requiredEditStaffEmail" runat="server" ControlToValidate="txtEditStaffEmail" ValidationGroup="EditStaffForm" ErrorMessage="Email address is required." CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="validEditStaffEmail" runat="server" ControlToValidate="txtEditStaffEmail" ValidationGroup="EditStaffForm" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email address." CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                        </div>
                        <div>
                            <asp:Label ID="lblEditStaffRole" runat="server" AssociatedControlID="ddlEditStaffRole" CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Role *" />
                            <asp:DropDownList ID="ddlEditStaffRole" runat="server" CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200">
                                  <asp:ListItem Text="Crew — POS and kitchen access" Value="CREW" />
                                <asp:ListItem Text="Admin — all workspaces" Value="ADMIN" />
                            </asp:DropDownList>
                        </div>
                        <div class="flex min-h-10 items-center">
                            <asp:CheckBox ID="chkEditStaffIsActive" runat="server" Text=" Active account" CssClass="inline-flex items-center gap-2 text-sm text-slate-700 [&_input]:size-4 [&_input]:accent-slate-900" />
                        </div>
                    </div>
                    <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4">
                        <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Cancel</button>
                        <asp:Button ID="btnUpdateStaff" runat="server" Text="Save changes" CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" ValidationGroup="EditStaffForm" OnClick="btnUpdateStaff_Click" />
                    </div>
                </div>
            </div>
        </div>

        <section class="overflow-hidden rounded-lg border border-slate-200 bg-white" aria-labelledby="staffListHeading">
            <div class="border-b border-slate-200 px-4 py-3">
                <h2 id="staffListHeading" class="text-sm font-semibold text-slate-950">Current staff</h2>
            </div>

            <div id="staffTableContainer" class="w-full overflow-x-auto">
                <asp:GridView ID="gridStaff" runat="server" ClientIDMode="Static"
                    AutoGenerateColumns="false" GridLines="None"
                    OnRowCommand="gridStaff_RowCommand"
                    CssClass="w-full min-w-[600px] border-collapse text-left text-sm [&_th]:border-b [&_th]:border-slate-200 [&_th]:bg-white [&_th]:px-4 [&_th]:py-2.5 [&_th]:text-xs [&_th]:font-medium [&_th]:text-slate-500 [&_td]:px-4 [&_td]:py-2.5 [&_td]:text-slate-700 [&_tbody_tr]:border-b [&_tbody_tr]:border-slate-100 [&_tbody_tr:hover]:bg-slate-50 [&_tbody_tr:last-child]:border-b-0"
                    EmptyDataText="No staff accounts yet.">
                    <Columns>
                        <asp:TemplateField HeaderText="Staff member">
                            <ItemTemplate>
                                <span data-staff-account data-staff-role='<%#: Eval("StaffRole") %>' data-staff-active='<%# Eval("IsActive") %>'><%#: Eval("DisplayName") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Email">
                            <ItemTemplate><span data-staff-email><%#: Eval("Email") %></span></ItemTemplate>
                        </asp:TemplateField>
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
                        <asp:TemplateField HeaderText="Actions" ItemStyle-Width="88px" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <div class="flex items-center justify-end gap-1">
                                    <asp:LinkButton ID="btnViewStaff" runat="server" CommandName="ViewStaff" CommandArgument='<%# Eval("StaffAccountID") %>' CausesValidation="false" CssClass="inline-flex size-8 shrink-0 items-center justify-center rounded-md border border-slate-200 bg-white text-slate-700 transition-colors hover:bg-slate-50 hover:text-slate-950 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" aria-label="View staff account" title="View staff account">
                                        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2.5 12s3.5-6 9.5-6 9.5 6 9.5 6-3.5 6-9.5 6-9.5-6-9.5-6Z" /><circle cx="12" cy="12" r="2.5" /></svg>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnEditStaff" runat="server" CommandName="EditStaff" CommandArgument='<%# Eval("StaffAccountID") %>' CausesValidation="false" CssClass="inline-flex size-8 shrink-0 items-center justify-center rounded-md border border-slate-200 bg-white text-slate-700 transition-colors hover:bg-slate-50 hover:text-slate-950 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" aria-label="Edit staff account" title="Edit staff account">
                                        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20h9" /><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z" /></svg>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataRowStyle CssClass="text-center text-slate-500 [&_td]:px-4 [&_td]:py-10" />
                </asp:GridView>
            </div>

            <div id="noStaffMatches" hidden class="p-8 text-center">
                <h3 class="text-sm font-semibold text-slate-900">No staff accounts match your search</h3>
                <p class="mt-1 text-sm text-slate-600">Try a different name or email, or clear the filters to see all staff.</p>
                <button id="resetStaffFilters" type="button" class="mt-4 inline-flex min-h-11 items-center justify-center rounded-md border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400">Clear filters</button>
            </div>
        </section>
    </main>

    <script src="<%= ResolveUrl("~/Scripts/app/admin/staff-accounts.js") %>?v=20261007.1"></script>
</asp:Content>
