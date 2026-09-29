<%@ Page Title="Kiosk settings" Language="C#" MasterPageFile="~/Shared/Layouts/Admin.Master" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="PortableKiosk.UI.Admin.Settings" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="AdminContent" runat="server">
    <main class="mx-auto w-full max-w-4xl" aria-labelledby="settingsHeading">
        <header class="mb-7">
            <h1 id="settingsHeading" class="text-2xl font-semibold tracking-tight text-slate-950 sm:text-3xl">Kiosk settings</h1>
            <p class="mt-1 text-sm text-slate-500">Control ordering availability and the time allowed for counter payment.</p>
        </header>

        <asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert" CssClass="mb-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
            <asp:Literal ID="litMessage" runat="server" />
        </asp:Panel>

        <div class="divide-y divide-slate-200 rounded-xl border border-slate-200 bg-white">
            <section class="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between sm:p-6" aria-labelledby="availabilityHeading">
                <div class="max-w-xl">
                    <h2 id="availabilityHeading" class="text-base font-semibold text-slate-950">Accept kiosk orders</h2>
                    <p class="mt-1 text-sm leading-6 text-slate-600">When off, customers see an unavailable message and cannot place a new kiosk order. Existing orders can still be handled at the counter.</p>
                </div>
                <label class="inline-flex shrink-0 cursor-pointer items-center gap-3 text-sm font-medium text-slate-800">
                    <asp:CheckBox ID="chkAvailable" runat="server" CssClass="accent-slate-900" />
                    Available
                </label>
            </section>

            <section class="p-5 sm:p-6" aria-labelledby="expiryHeading">
                <h2 id="expiryHeading" class="text-base font-semibold text-slate-950">Counter payment window</h2>
                <p class="mt-1 max-w-2xl text-sm leading-6 text-slate-600">Unpaid cash orders expire after this many minutes. Changes apply to new orders; existing orders keep their original deadline.</p>
                <div class="mt-4 flex items-center gap-3">
                    <asp:TextBox ID="txtExpiryMinutes" runat="server" TextMode="Number" min="1" max="1440" step="1" aria-label="Counter payment window in minutes" CssClass="w-32 rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-950 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" />
                    <span class="text-sm text-slate-600">minutes</span>
                </div>
                <p class="mt-2 text-xs text-slate-500">Enter 1 to 1440 minutes.</p>
            </section>
        </div>

        <div class="mt-6 flex justify-end">
            <asp:Button ID="btnSave" runat="server" Text="Save settings" OnClick="btnSave_Click" CssClass="min-h-10 cursor-pointer rounded-md bg-slate-900 px-5 py-2 text-sm font-medium text-white hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" />
        </div>
    </main>
</asp:Content>
