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
    <main class="order-type-page" aria-labelledby="orderTypeHeading">

        <span class="order-type-logo" aria-label="Portable Kiosk">P</span>

        <h1 id="orderTypeHeading">How would you<br />like to eat?</h1>

        <div class="order-type-options">

            <asp:LinkButton ID="btnDineIn" runat="server"
                CssClass="order-type-card"
                OnClick="btnDineIn_Click">
                <span class="order-type-card-title">Dine-in</span>
                <span class="order-type-illustration" aria-hidden="true">
                    <svg viewBox="0 0 220 160" fill="none" xmlns="http://www.w3.org/2000/svg">
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
                CssClass="order-type-card"
                OnClick="btnTakeout_Click">
                <span class="order-type-card-title">Take-out</span>
                <span class="order-type-illustration" aria-hidden="true">
                    <svg viewBox="0 0 220 180" fill="none" xmlns="http://www.w3.org/2000/svg">
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
