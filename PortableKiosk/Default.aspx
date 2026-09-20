<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PortableKiosk._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="kiosk-idle" aria-labelledby="idleHeading">
        <div class="kiosk-idle-brand" aria-label="Portable Kiosk">
            <span class="kiosk-idle-mark" aria-hidden="true">PK</span>
            <span>Portable Kiosk</span>
        </div>

        <section class="kiosk-idle-message">
            <h1 id="idleHeading">Ready when you are.</h1>
            <p>
                Browse the menu, choose your favorites, and build your order
                at your own pace.
            </p>

            <asp:Button
                ID="btnStartOrder"
                runat="server"
                Text="Start order"
                CssClass="kiosk-start-button"
                OnClick="btnStartOrder_Click" />
        </section>

        <div class="kiosk-idle-footer">
            <span class="kiosk-idle-status" role="status">
                <span aria-hidden="true"></span>
                Kiosk ready
            </span>
            <span>Tap Start order to begin</span>
        </div>
    </main>
</asp:Content>
