<%@ Page
    Title="Choose order type"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/User.Master"
    AutoEventWireup="true"
    CodeBehind="OrderType.aspx.cs"
    Inherits="PortableKiosk.UI.User.OrderType" %>

<asp:Content
    ID="OrderTypeContent"
    ContentPlaceHolderID="UserContent"
    runat="server">
    <main class="flex min-h-screen min-h-dvh w-full flex-col items-center justify-center bg-[radial-gradient(ellipse_at_50%_30%,#fffdf6_0%,#fff_65%)] px-[clamp(1.25rem,6vw,4rem)] pt-[clamp(1.5rem,5vh,6rem)] pb-[clamp(0.5rem,1.25vh,1.5rem)] text-center max-[540px]:px-5 max-[540px]:pt-[0.9rem] max-[540px]:pb-2 kiosk-mobile:justify-center" aria-labelledby="orderTypeHeading">

        <span class="mb-[clamp(0.35rem,1vh,0.75rem)] select-none text-[clamp(3.25rem,7vh,5rem)] font-black leading-none tracking-[-0.04em] text-[#f59e0b] drop-shadow-[0_4px_16px_rgba(245,158,11,0.3)] kiosk-portrait:text-[clamp(4rem,min(8vw,7vh),10rem)] kiosk-short:mb-[0.4rem] kiosk-short:text-[clamp(2.75rem,7vh,3.75rem)]" aria-label="Portable Kiosk">P</span>

        <h1 id="orderTypeHeading" class="mb-[clamp(2rem,3.5vh,3rem)] max-w-[760px] text-[clamp(2.65rem,6vw,5rem)] font-black leading-[1.04] tracking-[-0.05em] text-slate-900 kiosk-portrait:max-w-[1600px] kiosk-portrait:mb-[clamp(2rem,4.5vh,5rem)] kiosk-portrait:text-[clamp(2.75rem,min(10vw,7vh),12rem)] kiosk-mobile:mb-8 kiosk-mobile:max-w-full kiosk-mobile:text-[clamp(2rem,10vw,3.5rem)] kiosk-short:mb-8 kiosk-short:text-[clamp(2.4rem,6vw,3.75rem)]">How would you<br />like to eat?</h1>

        <div class="grid w-full max-w-none grid-cols-2 gap-[clamp(0.65rem,2vh,1.5rem)] kiosk-landscape:gap-[clamp(1rem,2vw,2rem)] kiosk-landscape:max-w-[clamp(880px,55vw,1800px)] kiosk-portrait:gap-[clamp(1rem,2vw,2.5rem)] kiosk-portrait:max-w-none kiosk-mobile:gap-3">

            <asp:LinkButton ID="btnDineIn" runat="server"
                CssClass="flex min-h-[clamp(220px,23vh,320px)] w-full flex-col items-center overflow-hidden rounded-3xl border-2 border-slate-200 bg-[linear-gradient(145deg,#fff_35%,#fffaf0_100%)] px-[clamp(1.25rem,3vw,2rem)] pt-[clamp(1rem,2.5vh,1.5rem)] pb-[0.35rem] text-slate-900 no-underline shadow-[0_4px_14px_rgba(15,23,42,0.07)] transition-[border-color,box-shadow,transform] duration-200 hover:-translate-y-0.5 hover:border-amber-500 hover:text-slate-900 hover:shadow-[0_10px_26px_rgba(217,119,6,0.16)] focus-visible:-translate-y-0.5 focus-visible:border-amber-500 focus-visible:outline focus-visible:outline-[3px] focus-visible:outline-amber-500/30 active:scale-[0.99] kiosk-landscape:min-h-[clamp(220px,34vh,480px)] kiosk-landscape:px-[clamp(1.25rem,3vw,2rem)] kiosk-portrait:min-h-[clamp(360px,38vh,1400px)] kiosk-portrait:px-[clamp(1.5rem,3.5vw,4rem)] kiosk-portrait:pt-[clamp(1.5rem,4vh,6rem)] kiosk-mobile:min-h-[clamp(180px,25vh,230px)] kiosk-mobile:rounded-[20px] kiosk-mobile:px-2 kiosk-mobile:pt-[0.85rem] kiosk-mobile:pb-[0.2rem] kiosk-short:min-h-[clamp(170px,25vh,210px)]"
                OnClick="btnDineIn_Click">
                <span class="w-full text-center text-[clamp(1.5rem,3vw,2rem)] font-extrabold leading-[1.15] tracking-[-0.01em] text-slate-900 kiosk-landscape:text-[clamp(1.75rem,2.2vw,3rem)] kiosk-portrait:text-[clamp(2rem,6vw,7rem)] kiosk-mobile:text-[clamp(1rem,5vw,1.5rem)]">Dine-in</span>
                <span class="mt-[clamp(0.65rem,1.5vh,1rem)] flex min-h-[140px] w-full flex-1 items-end justify-center kiosk-portrait:min-h-[clamp(300px,30vh,1000px)] kiosk-mobile:mt-2.5 kiosk-mobile:min-h-[108px] kiosk-short:mt-2.5 kiosk-short:min-h-[108px]" aria-hidden="true">
                    <svg class="block h-auto max-h-[200px] w-[min(100%,240px)] max-w-[240px] kiosk-landscape:max-h-[clamp(180px,25vh,320px)] kiosk-landscape:max-w-[clamp(240px,20vw,420px)] kiosk-landscape:w-[min(100%,420px)] kiosk-portrait:max-h-[clamp(360px,38vh,960px)] kiosk-portrait:max-w-[clamp(380px,36vw,920px)] kiosk-portrait:w-[min(100%,920px)] kiosk-mobile:max-h-[135px] kiosk-mobile:max-w-[180px] kiosk-short:max-h-[140px]" viewBox="0 0 220 160" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <!-- Left chair back -->
                        <rect x="18" y="50" width="46" height="56" rx="8" fill="#e8c832"/>
                        <!-- Left chair seat -->
                        <rect x="12" y="84" width="58" height="14" rx="6" fill="#d4b420"/>
                        <!-- Left chair legs -->
                        <rect x="20" y="97" width="8" height="40" rx="4" fill="#9ca3af"/>
                        <rect x="48" y="97" width="8" height="40" rx="4" fill="#9ca3af"/>
                        <!-- Right chair back -->
                        <rect x="156" y="50" width="46" height="56" rx="8" fill="#e8c832"/>
                        <!-- Right chair seat -->
                        <rect x="150" y="84" width="58" height="14" rx="6" fill="#d4b420"/>
                        <!-- Right chair legs -->
                        <rect x="158" y="97" width="8" height="40" rx="4" fill="#9ca3af"/>
                        <rect x="186" y="97" width="8" height="40" rx="4" fill="#9ca3af"/>
                        <!-- Table top -->
                        <rect x="62" y="72" width="96" height="18" rx="8" fill="#d1d5db"/>
                        <!-- Table leg -->
                        <rect x="99" y="89" width="22" height="44" rx="5" fill="#9ca3af"/>
                        <!-- Table base -->
                        <rect x="78" y="130" width="64" height="9" rx="4" fill="#9ca3af"/>
                        <!-- Cup on table -->
                        <rect x="88" y="52" width="15" height="22" rx="4" fill="#60a5fa"/>
                        <rect x="90" y="48" width="11" height="6" rx="3" fill="#93c5fd"/>
                        <!-- Fries box -->
                        <rect x="110" y="58" width="20" height="16" rx="3" fill="#ef4444"/>
                        <!-- Fries sticks -->
                        <rect x="113" y="42" width="5" height="20" rx="3" fill="#fbbf24"/>
                        <rect x="120" y="40" width="5" height="22" rx="3" fill="#fbbf24"/>
                        <rect x="127" y="44" width="5" height="18" rx="3" fill="#fbbf24"/>
                    </svg>
                </span>
            </asp:LinkButton>

            <asp:LinkButton ID="btnTakeout" runat="server"
                CssClass="flex min-h-[clamp(220px,23vh,320px)] w-full flex-col items-center overflow-hidden rounded-3xl border-2 border-slate-200 bg-[linear-gradient(145deg,#fff_35%,#fffaf0_100%)] px-[clamp(1.25rem,3vw,2rem)] pt-[clamp(1rem,2.5vh,1.5rem)] pb-[0.35rem] text-slate-900 no-underline shadow-[0_4px_14px_rgba(15,23,42,0.07)] transition-[border-color,box-shadow,transform] duration-200 hover:-translate-y-0.5 hover:border-amber-500 hover:text-slate-900 hover:shadow-[0_10px_26px_rgba(217,119,6,0.16)] focus-visible:-translate-y-0.5 focus-visible:border-amber-500 focus-visible:outline focus-visible:outline-[3px] focus-visible:outline-amber-500/30 active:scale-[0.99] kiosk-landscape:min-h-[clamp(220px,34vh,480px)] kiosk-landscape:px-[clamp(1.25rem,3vw,2rem)] kiosk-portrait:min-h-[clamp(360px,38vh,1400px)] kiosk-portrait:px-[clamp(1.5rem,3.5vw,4rem)] kiosk-portrait:pt-[clamp(1.5rem,4vh,6rem)] kiosk-mobile:min-h-[clamp(180px,25vh,230px)] kiosk-mobile:rounded-[20px] kiosk-mobile:px-2 kiosk-mobile:pt-[0.85rem] kiosk-mobile:pb-[0.2rem] kiosk-short:min-h-[clamp(170px,25vh,210px)]"
                OnClick="btnTakeout_Click">
                <span class="w-full text-center text-[clamp(1.5rem,3vw,2rem)] font-extrabold leading-[1.15] tracking-[-0.01em] text-slate-900 kiosk-landscape:text-[clamp(1.75rem,2.2vw,3rem)] kiosk-portrait:text-[clamp(2rem,6vw,7rem)] kiosk-mobile:text-[clamp(1rem,5vw,1.5rem)]">Take-out</span>
                <span class="mt-[clamp(0.65rem,1.5vh,1rem)] flex min-h-[140px] w-full flex-1 items-end justify-center kiosk-portrait:min-h-[clamp(300px,30vh,1000px)] kiosk-mobile:mt-2.5 kiosk-mobile:min-h-[108px] kiosk-short:mt-2.5 kiosk-short:min-h-[108px]" aria-hidden="true">
                    <svg class="block h-auto max-h-[200px] w-[min(100%,240px)] max-w-[240px] kiosk-landscape:max-h-[clamp(180px,25vh,320px)] kiosk-landscape:max-w-[clamp(240px,20vw,420px)] kiosk-landscape:w-[min(100%,420px)] kiosk-portrait:max-h-[clamp(360px,38vh,960px)] kiosk-portrait:max-w-[clamp(380px,36vw,920px)] kiosk-portrait:w-[min(100%,920px)] kiosk-mobile:max-h-[135px] kiosk-mobile:max-w-[180px] kiosk-short:max-h-[140px]" viewBox="0 0 220 180" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <!-- Bag body -->
                        <path d="M50 64 L170 64 L155 162 L65 162 Z" fill="#c8a06a"/>
                        <!-- Bag top fold -->
                        <rect x="50" y="50" width="120" height="20" rx="5" fill="#a07840"/>
                        <!-- Bag handle -->
                        <path d="M80 50 C80 20 140 20 140 50" stroke="#7a5c28" stroke-width="10" stroke-linecap="round" fill="none"/>
                        <!-- Bag shade lines -->
                        <line x1="86" y1="70" x2="76" y2="156" stroke="#a07840" stroke-width="3" stroke-linecap="round"/>
                        <line x1="134" y1="70" x2="144" y2="156" stroke="#a07840" stroke-width="3" stroke-linecap="round"/>
                        <!-- Checkmark circle -->
                        <circle cx="154" cy="104" r="28" fill="#f59e0b"/>
                        <polyline points="142,104 152,116 168,90" stroke="#ffffff" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                    </svg>
                </span>
            </asp:LinkButton>

        </div>
    </main>
</asp:Content>
