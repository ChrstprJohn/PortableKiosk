<%@ Page Title="Welcome" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PortableKiosk._Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="kiosk-attract-page group flex h-screen h-dvh w-full flex-col overflow-hidden bg-white" aria-label="Welcome to Portable Kiosk">
        <div class="relative flex min-h-0 w-full flex-1 items-center justify-center overflow-hidden bg-white">
            <img src="<%= ResolveUrl("~/Content/images/kiosk-attract.jpg") %>" alt="Portable Kiosk Menu" class="h-full w-full object-cover object-[center_25%] transition-transform duration-[6000ms] ease-[cubic-bezier(0.25,1,0.5,1)] group-hover:scale-[1.03]" />
            <span class="absolute left-[clamp(1.25rem,4vw,4rem)] top-[clamp(1rem,3vw,3.5rem)] z-10 select-none text-[clamp(3rem,8vw,8rem)] font-black leading-none tracking-[-0.04em] text-[#f59e0b] drop-shadow-[0_3px_12px_rgba(245,158,11,0.35)]" aria-label="Portable Kiosk">P</span>
        </div>

        <div class="relative z-20 flex min-h-[clamp(6.75rem,9vh,12rem)] w-full flex-col items-center justify-center border-t border-slate-200/85 bg-white px-[clamp(1.25rem,4vw,3rem)] pt-[clamp(1rem,2.5vh,2rem)] pb-[clamp(1.25rem,3vh,2.5rem)] shadow-[0_-6px_24px_rgba(15,23,42,0.05)]">
            <asp:Button
                ID="btnStartOrder"
                runat="server"
                Text="Start order"
                CssClass="inline-flex min-h-[clamp(3.75rem,5.5vh,6rem)] w-full !max-w-[clamp(520px,40vw,960px)] cursor-pointer items-center justify-center rounded-[22px] border-0 bg-[linear-gradient(135deg,#f59e0b,#d97706)] px-[clamp(2rem,4vw,5rem)] py-[0.85rem] text-[clamp(1.45rem,3.2vw,4rem)] font-extrabold tracking-[-0.01em] text-white no-underline shadow-[0_6px_20px_rgba(217,119,6,0.38)] transition-[filter,transform,box-shadow] duration-200 hover:-translate-y-0.5 hover:brightness-105 hover:text-white hover:shadow-[0_8px_26px_rgba(217,119,6,0.48)] focus-visible:outline focus-visible:outline-4 focus-visible:outline-amber-500/50"
                OnClick="btnStartOrder_Click" />
        </div>
    </main>
</asp:Content>
