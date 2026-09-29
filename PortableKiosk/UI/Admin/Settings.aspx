<%@ Page Title="Kiosk settings" Language="C#" MasterPageFile="~/Shared/Layouts/Admin.Master" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="PortableKiosk.UI.Admin.Settings" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="AdminContent" runat="server">
    <main class="mx-auto w-full max-w-4xl" aria-labelledby="settingsHeading">
        <header class="mb-7">
            <h1 id="settingsHeading" class="text-2xl font-semibold tracking-tight text-slate-950 sm:text-3xl">Kiosk settings</h1>
        </header>

        <asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert" CssClass="mb-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
            <asp:Literal ID="litMessage" runat="server" />
        </asp:Panel>

        <div class="divide-y divide-slate-200 rounded-xl border border-slate-200 bg-white">
            <section class="grid gap-4 p-5 sm:grid-cols-[minmax(0,1fr)_auto] sm:items-center sm:gap-8 sm:p-6" aria-labelledby="availabilityHeading">
                <div class="max-w-xl">
                    <h2 id="availabilityHeading" class="text-base font-semibold text-slate-950">Kiosk ordering</h2>
                    <p class="mt-1 text-sm leading-6 text-slate-600">Turn this off when the kiosk is closed. Customers with an existing order can still pay at the counter.</p>
                </div>
                <label class="inline-flex shrink-0 cursor-pointer items-center gap-3 text-sm font-medium text-slate-800 sm:w-44 sm:justify-self-end">
                    <asp:CheckBox ID="chkAvailable" runat="server" CssClass="inline-flex items-center [&_input]:m-0 [&_input]:size-5 [&_input]:accent-slate-900" />
                    Accept orders
                </label>
            </section>

            <section class="grid gap-4 p-5 sm:grid-cols-[minmax(0,1fr)_auto] sm:items-center sm:gap-8 sm:p-6" aria-labelledby="expiryHeading">
                <div class="max-w-xl">
                    <h2 id="expiryHeading" class="text-base font-semibold text-slate-950">Time to pay at the counter</h2>
                    <p class="mt-1 text-sm leading-6 text-slate-600">How long customers have to pay for a cash order. Orders already placed keep their current deadline.</p>
                </div>
                <div class="flex items-center gap-3 sm:w-44 sm:justify-self-end">
                    <asp:TextBox ID="txtExpiryMinutes" runat="server" TextMode="Number" min="1" max="1440" step="1" aria-label="Time to pay at the counter in minutes" CssClass="w-24 rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-950 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" />
                    <span class="text-sm text-slate-600">minutes</span>
                </div>
            </section>
        </div>

        <div class="mt-6 flex justify-end">
            <asp:Button ID="btnSave" runat="server" Text="Save settings" OnClick="btnSave_Click" CssClass="min-h-10 cursor-pointer rounded-md bg-slate-900 px-5 py-2 text-sm font-medium text-white hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" />
        </div>
    </main>
</asp:Content>
