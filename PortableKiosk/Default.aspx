<%@ Page Title="Welcome" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PortableKiosk._Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="kiosk-attract-page group flex h-screen h-dvh w-full flex-col overflow-hidden bg-white" aria-label="Welcome to Portable Kiosk">
        <div class="relative flex min-h-0 w-full flex-1 items-center justify-center overflow-hidden bg-white">
            <img src="<%= ResolveUrl("~/Content/images/kiosk-attract.jpg") %>" alt="Portable Kiosk Menu" class="h-full w-full object-cover object-[center_25%] transition-transform duration-[6000ms] ease-[cubic-bezier(0.25,1,0.5,1)] group-hover:scale-[1.03]" />
            <span class="absolute left-[clamp(0.75rem,4vw,4rem)] top-[clamp(0.75rem,3vw,3.5rem)] z-10 select-none text-[clamp(3.25rem,7vh,5rem)] font-black leading-none tracking-[-0.04em] text-[#f59e0b] drop-shadow-[0_3px_12px_rgba(245,158,11,0.35)] kiosk-portrait:text-[clamp(4.5rem,min(12vw,10vh),18rem)] kiosk-short:text-[clamp(2.75rem,7vh,3.75rem)]" aria-label="Portable Kiosk">P</span>
        </div>

        <div class="relative z-20 flex min-h-[clamp(2.5rem,12vw,12rem)] w-full flex-col items-center justify-center border-t border-slate-200/85 bg-white px-6 py-[clamp(0.25rem,1vw,1rem)] shadow-[0_-6px_24px_rgba(15,23,42,0.05)]">
            <asp:Panel ID="pnlUnavailable" runat="server" Visible="false" CssClass="w-full max-w-xl py-5 text-center">
                <h1 class="text-2xl font-semibold text-slate-950">Kiosk temporarily unavailable</h1>
                <p class="mt-2 text-base text-slate-600">Please place your order with a crew member at the counter.</p>
            </asp:Panel>
            <asp:Button
                ID="btnStartOrder"
                runat="server"
                Text="Start order"
                CssClass="inline-flex min-h-[clamp(2rem,9vw,12rem)] w-full max-w-[clamp(14rem,76vw,100rem)] cursor-pointer items-center justify-center rounded-[clamp(0.5rem,2vw,2rem)] border-0 bg-[linear-gradient(135deg,#f59e0b,#d97706)] px-[clamp(0.75rem,3vw,3rem)] py-[clamp(0.25rem,1.5vw,1rem)] text-[clamp(1.5rem,3vw,2rem)] font-extrabold leading-tight tracking-[-0.01em] text-white no-underline kiosk-landscape:text-[clamp(1.75rem,2.2vw,3rem)] kiosk-portrait:text-[clamp(2rem,6vw,7rem)] kiosk-mobile:text-[clamp(1rem,5vw,1.5rem)] shadow-[0_6px_20px_rgba(217,119,6,0.38)] transition-[filter,transform,box-shadow] duration-200 hover:-translate-y-0.5 hover:brightness-105 hover:text-white hover:shadow-[0_8px_26px_rgba(217,119,6,0.48)] focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/50"
                OnClick="btnStartOrder_Click" />
        </div>
    </main>
</asp:Content>
