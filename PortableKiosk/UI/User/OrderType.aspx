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
        <div class="order-type-brand" aria-label="Portable Kiosk">
            <span class="order-type-brand-mark" aria-hidden="true">P</span>
            <span>Portable Kiosk</span>
        </div>

        <h1 id="orderTypeHeading">How would you like to eat?</h1>

        <div class="order-type-options">
            <asp:LinkButton
                ID="btnDineIn"
                runat="server"
                CssClass="order-type-card"
                OnClick="btnDineIn_Click">
                <span class="order-type-card-title">Dine-in</span>
                <span class="order-type-illustration" aria-hidden="true">
                    <svg viewBox="0 0 180 130" role="img">
                        <path d="M38 63c0 25 20 44 45 44s45-19 45-44H38Z" />
                        <path d="M29 116h108M46 54h74M83 54V38" />
                        <circle cx="83" cy="31" r="5" />
                        <path d="M143 27v88M154 27v24c0 8-11 8-11 0M132 27v24c0 8 11 8 11 0" />
                    </svg>
                </span>
            </asp:LinkButton>

            <asp:LinkButton
                ID="btnTakeout"
                runat="server"
                CssClass="order-type-card"
                OnClick="btnTakeout_Click">
                <span class="order-type-card-title">Take-out</span>
                <span class="order-type-illustration" aria-hidden="true">
                    <svg viewBox="0 0 180 130" role="img">
                        <path d="M48 45h84l-8 70H56l-8-70Z" />
                        <path d="M63 45c0-20 11-31 27-31s27 11 27 31M70 67h40M69 82h42" />
                    </svg>
                </span>
            </asp:LinkButton>
        </div>
    </main>
</asp:Content>
