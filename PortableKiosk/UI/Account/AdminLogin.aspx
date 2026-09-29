<%@ Page Title="Staff Sign In" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="AdminLogin.aspx.cs"
    Inherits="PortableKiosk.UI.Account.AdminLogin" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="-m-3 flex min-h-dvh items-center justify-center bg-slate-50 px-6 py-12 text-slate-950 md:-mx-6 md:-my-4">
        <section id="rolePicker" runat="server" class="w-full max-w-2xl">
            <h1 id="roleHeading" class="text-3xl font-semibold tracking-tight md:text-4xl">Choose your workspace</h1>
            <p class="mt-2 text-slate-600">Choose a staff workspace or view order status.</p>
            <div class="mt-6 grid gap-3">
                <a href="AdminLogin.aspx?mode=admin" class="flex min-h-24 items-center justify-between gap-4 rounded-xl bg-white px-5 py-4 shadow-sm transition hover:shadow-md focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"><span><span class="block text-xl font-semibold">Admin</span><span class="mt-1 block text-sm text-slate-600">Manage products, orders, and staff.</span></span><span class="shrink-0 text-sm font-semibold text-blue-700">Sign in</span></a>
                <a href="AdminLogin.aspx?mode=pos" class="flex min-h-24 items-center justify-between gap-4 rounded-xl bg-white px-5 py-4 shadow-sm transition hover:shadow-md focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"><span><span class="block text-xl font-semibold">POS</span><span class="mt-1 block text-sm text-slate-600">Take orders and collect payment.</span></span><span class="shrink-0 text-sm font-semibold text-blue-700">Sign in</span></a>
                <a href="AdminLogin.aspx?mode=kitchen" class="flex min-h-24 items-center justify-between gap-4 rounded-xl bg-white px-5 py-4 shadow-sm transition hover:shadow-md focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"><span><span class="block text-xl font-semibold">Kitchen</span><span class="mt-1 block text-sm text-slate-600">Prepare and serve paid orders.</span></span><span class="shrink-0 text-sm font-semibold text-blue-700">Sign in</span></a>
                <a href="../OrderStatus.aspx" class="flex min-h-24 items-center justify-between gap-4 rounded-xl bg-white px-5 py-4 shadow-sm transition hover:shadow-md focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-700"><span><span class="block text-xl font-semibold">Order status</span><span class="mt-1 block text-sm text-slate-600">See which orders are preparing or serving.</span></span><span class="shrink-0 text-sm font-semibold text-blue-700">View board</span></a>
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
