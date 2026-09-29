<%@ Page Title="Staff Sign In" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="AdminLogin.aspx.cs"
    Inherits="PortableKiosk.UI.Account.AdminLogin" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="-m-3 flex min-h-dvh items-center justify-center bg-slate-50 px-6 py-12 text-slate-950 md:-mx-6 md:-my-4">
        <section id="rolePicker" runat="server" class="w-full max-w-5xl" aria-labelledby="roleHeading">
            <h1 id="roleHeading" class="text-3xl font-semibold tracking-tight md:text-4xl">Choose your workspace</h1>
            <p class="mt-2 text-slate-600">Choose a staff workspace or view order status.</p>
            <div class="mt-8 grid gap-4 sm:grid-cols-2">
                <a href="AdminLogin.aspx?mode=admin" class="group flex min-h-72 flex-col items-center justify-between rounded-2xl border border-slate-200 bg-white px-6 py-6 text-center no-underline shadow-sm transition-[border-color,background-color,box-shadow,transform] duration-200 hover:-translate-y-0.5 hover:border-blue-300 hover:bg-blue-50 hover:shadow-md focus-visible:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700">
                    <span><span class="block text-xl font-semibold text-slate-950">Admin</span><span class="mt-2 block text-sm text-slate-600">Manage products, orders, and staff.</span></span>
                    <span aria-hidden="true" class="flex size-28 items-center justify-center rounded-3xl bg-blue-50 text-blue-800 transition-colors group-hover:bg-blue-100">
                        <svg viewBox="0 0 24 24" class="size-20 fill-none stroke-current" stroke-width="1.35" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="8" r="3.25" /><path d="M2.75 20a6.25 6.25 0 0 1 12.5 0M16 5.25a3.25 3.25 0 0 1 0 6.5M17 14a6.1 6.1 0 0 1 4.25 5.75" /></svg>
                    </span>
                    <span class="flex items-center gap-2 text-sm font-semibold text-blue-700">Sign in<svg aria-hidden="true" viewBox="0 0 20 20" class="size-4 fill-none stroke-current" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3.5 10h13m-5-5 5 5-5 5" /></svg></span>
                </a>
                <a href="AdminLogin.aspx?mode=pos" class="group flex min-h-72 flex-col items-center justify-between rounded-2xl border border-slate-200 bg-white px-6 py-6 text-center no-underline shadow-sm transition-[border-color,background-color,box-shadow,transform] duration-200 hover:-translate-y-0.5 hover:border-blue-300 hover:bg-blue-50 hover:shadow-md focus-visible:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700">
                    <span><span class="block text-xl font-semibold text-slate-950">POS</span><span class="mt-2 block text-sm text-slate-600">Take orders and collect payment.</span></span>
                    <span aria-hidden="true" class="flex size-28 items-center justify-center rounded-3xl bg-blue-50 text-blue-800 transition-colors group-hover:bg-blue-100">
                        <svg viewBox="0 0 24 24" class="size-20 fill-none stroke-current" stroke-width="1.35" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4.5h16v11H4zM2.5 19.5h19M8 15.5v4m8-4v4" /><path d="M8 8h3v3H8zm6 0h2m-2 3h2" /></svg>
                    </span>
                    <span class="flex items-center gap-2 text-sm font-semibold text-blue-700">Sign in<svg aria-hidden="true" viewBox="0 0 20 20" class="size-4 fill-none stroke-current" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3.5 10h13m-5-5 5 5-5 5" /></svg></span>
                </a>
                <a href="AdminLogin.aspx?mode=kitchen" class="group flex min-h-72 flex-col items-center justify-between rounded-2xl border border-slate-200 bg-white px-6 py-6 text-center no-underline shadow-sm transition-[border-color,background-color,box-shadow,transform] duration-200 hover:-translate-y-0.5 hover:border-blue-300 hover:bg-blue-50 hover:shadow-md focus-visible:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700">
                    <span><span class="block text-xl font-semibold text-slate-950">Kitchen</span><span class="mt-2 block text-sm text-slate-600">Prepare and serve paid orders.</span></span>
                    <span aria-hidden="true" class="flex size-28 items-center justify-center rounded-3xl bg-blue-50 text-blue-800 transition-colors group-hover:bg-blue-100">
                        <svg viewBox="0 0 24 24" class="size-20 fill-none stroke-current" stroke-width="1.35" stroke-linecap="round" stroke-linejoin="round"><path d="M5 10h14l-1.25 10H6.25L5 10Zm-1.5 0a8.5 8.5 0 0 1 17 0H3.5Z" /><path d="M8 5.5V3m4 2.5V2.5m4 3V3" /></svg>
                    </span>
                    <span class="flex items-center gap-2 text-sm font-semibold text-blue-700">Sign in<svg aria-hidden="true" viewBox="0 0 20 20" class="size-4 fill-none stroke-current" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3.5 10h13m-5-5 5 5-5 5" /></svg></span>
                </a>
                <a href="../OrderStatus.aspx" class="group flex min-h-72 flex-col items-center justify-between rounded-2xl border border-slate-200 bg-white px-6 py-6 text-center no-underline shadow-sm transition-[border-color,background-color,box-shadow,transform] duration-200 hover:-translate-y-0.5 hover:border-blue-300 hover:bg-blue-50 hover:shadow-md focus-visible:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700">
                    <span><span class="block text-xl font-semibold text-slate-950">Order status</span><span class="mt-2 block text-sm text-slate-600">See which orders are preparing or serving.</span></span>
                    <span aria-hidden="true" class="flex size-28 items-center justify-center rounded-3xl bg-blue-50 text-blue-800 transition-colors group-hover:bg-blue-100">
                        <svg viewBox="0 0 24 24" class="size-20 fill-none stroke-current" stroke-width="1.35" stroke-linecap="round" stroke-linejoin="round"><path d="M7 3.5h8l4 4V20a1.5 1.5 0 0 1-1.5 1.5h-11A1.5 1.5 0 0 1 5 20V5a1.5 1.5 0 0 1 1.5-1.5Z" /><path d="M14.5 3.75V8H19m-10 4h6m-6 4h6" /><circle cx="7.5" cy="12" r=".45" fill="currentColor" stroke="none" /><circle cx="7.5" cy="16" r=".45" fill="currentColor" stroke="none" /></svg>
                    </span>
                    <span class="flex items-center gap-2 text-sm font-semibold text-blue-700">View board<svg aria-hidden="true" viewBox="0 0 20 20" class="size-4 fill-none stroke-current" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3.5 10h13m-5-5 5 5-5 5" /></svg></span>
                </a>
            </div>
        </section>
        <section id="loginForm" runat="server" class="w-full max-w-sm py-8" aria-labelledby="loginHeading">
                <a href="AdminLogin.aspx" class="mb-8 inline-block text-sm font-medium text-blue-700 hover:underline">← Choose workspace</a>
                <h1 id="loginHeading" class="text-4xl font-semibold tracking-tight text-slate-950"><asp:Literal ID="litWorkspace" runat="server" /> sign in</h1>
                <div class="mt-5 h-px w-full bg-slate-200" aria-hidden="true"></div>

                <asp:ValidationSummary ID="validationSummary" runat="server" ValidationGroup="StaffLoginForm"
                    CssClass="mt-6 rounded-lg bg-red-50 px-4 py-3 text-sm text-red-800" HeaderText="Check the following:" DisplayMode="BulletList" />
                <asp:Label ID="lblMessage" runat="server" Visible="false" />

                <div class="mt-8">
                    <asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail" Text="Email address" CssClass="mb-2 block text-sm font-medium text-slate-800" />
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="256" autocomplete="username" placeholder="name@company.com"
                        CssClass="block min-h-14 w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-base text-slate-950 shadow-sm placeholder:text-slate-400 focus-visible:border-blue-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                    <asp:RequiredFieldValidator ID="requiredEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="StaffLoginForm"
                        ErrorMessage="Email address is required." CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="validEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="StaffLoginForm"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email address."
                        CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                </div>

                <div class="mt-6">
                    <asp:Label ID="lblPassword" runat="server" AssociatedControlID="txtPassword" Text="Password" CssClass="mb-2 block text-sm font-medium text-slate-800" />
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="100" autocomplete="current-password" placeholder="Enter your password"
                        CssClass="block min-h-14 w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-base text-slate-950 shadow-sm placeholder:text-slate-400 focus-visible:border-blue-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
                    <asp:RequiredFieldValidator ID="requiredPassword" runat="server" ControlToValidate="txtPassword" ValidationGroup="StaffLoginForm"
                        ErrorMessage="Password is required." CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                </div>

                <asp:Button ID="btnLogin" runat="server" Text="Sign in" ValidationGroup="StaffLoginForm" OnClick="btnLogin_Click"
                    CssClass="mt-9 min-h-14 w-full cursor-pointer rounded-xl bg-blue-700 px-5 py-3 text-base font-semibold text-white shadow-sm transition-colors hover:bg-blue-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700" />
        </section>
    </main>
</asp:Content>
