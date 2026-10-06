<%@ Page Title="Website QR code" Language="C#" MasterPageFile="~/Shared/Layouts/Admin.Master" AutoEventWireup="true" CodeBehind="WebsiteQr.aspx.cs" Inherits="PortableKiosk.UI.Admin.WebsiteQr" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="AdminContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/css/website-qr.css") %>" />
    <main id="websiteQrPage" class="mx-auto w-full max-w-4xl" aria-labelledby="qrHeading">
        <header class="mb-7">
            <h1 id="qrHeading" class="text-2xl font-semibold tracking-tight text-slate-950 sm:text-3xl">Website QR code</h1>
            <p class="mt-2 text-sm leading-6 text-slate-600">Save your website link, then print a QR code people can scan to open it.</p>
        </header>

        <asp:Panel ID="pnlMessage" runat="server" Visible="false" role="status" CssClass="mb-6 rounded-lg border border-slate-200 bg-white px-4 py-3 text-sm text-slate-800">
            <asp:Literal ID="litMessage" runat="server" />
        </asp:Panel>

        <section class="mb-6 rounded-xl border border-slate-200 bg-white p-5 sm:p-6" aria-labelledby="linkHeading">
            <h2 id="linkHeading" class="mb-3 text-base font-semibold text-slate-950"><asp:Literal ID="litFormHeading" runat="server" Text="Add website link" /></h2>
            <asp:Label runat="server" AssociatedControlID="txtWebsiteUrl" Text="Website link" CssClass="mb-2 block text-sm font-medium text-slate-800" />
            <asp:TextBox ID="txtWebsiteUrl" runat="server" ClientIDMode="Static" MaxLength="2048" aria-describedby="qrLinkHelp" CssClass="w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-950 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" />
            <p id="qrLinkHelp" class="mt-2 text-sm leading-6 text-slate-600">Use a full http:// or https:// link. Save changes to update the QR code below.</p>
            <div class="mt-4 flex justify-end">
                <asp:Button ID="btnSave" runat="server" Text="Save and generate QR code" OnClick="btnSave_Click" CssClass="min-h-10 cursor-pointer rounded-md bg-slate-900 px-5 py-2 text-sm font-medium text-white hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" />
            </div>
        </section>

        <asp:Panel ID="pnlEmpty" runat="server" CssClass="rounded-xl border border-slate-200 bg-white p-6 text-center text-sm leading-6 text-slate-600">
            No QR code saved yet. Save the website link above to generate one.
        </asp:Panel>

        <asp:Panel ID="websiteQrPrintArea" runat="server" ClientIDMode="Static" Visible="false" CssClass="rounded-xl border border-slate-200 bg-white p-6 text-center">
            <h2 class="text-xl font-semibold text-slate-950">Portable Kiosk</h2>
            <p class="mt-2 text-base text-slate-700">Scan to open our website</p>
            <div id="websiteQrImage" class="website-qr-image" role="img" aria-label="QR code linking to the saved website"></div>
            <p id="websiteQrError" role="alert" hidden class="my-6 text-sm text-red-800">The QR code could not be generated. Reload this page and try again.</p>
            <asp:HyperLink ID="lnkWebsite" runat="server" ClientIDMode="Static" Target="_blank" rel="noopener noreferrer" CssClass="website-qr-url text-sm text-slate-700 underline underline-offset-4" />
        </asp:Panel>

        <div id="qrActions" class="mt-5 text-center" hidden>
            <p id="qrLocalNotice" hidden class="mb-4 text-sm leading-6 text-slate-600">This localhost link only opens on the computer running the website. For phone scans, save a reachable network or deployed website link.</p>
            <button id="btnPrintQr" type="button" class="min-h-10 rounded-md bg-slate-900 px-5 py-2 text-sm font-medium text-white hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400">Print QR code</button>
        </div>
        <noscript><p class="mt-4 text-sm text-slate-700">Enable JavaScript to display and print the QR code.</p></noscript>
    </main>
    <script src="<%= ResolveUrl("~/Scripts/vendor/qrcodegen.js") %>"></script>
    <script src="<%= ResolveUrl("~/Scripts/app/admin/website-qr.js") %>"></script>
</asp:Content>
