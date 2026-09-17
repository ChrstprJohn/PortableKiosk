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
                Welcome to Portable Kiosk. This screen is the starting point
                for the customer ordering experience.
            </p>

            <div class="kiosk-idle-status" role="status">
                <span aria-hidden="true"></span>
                Kiosk ready
            </div>
        </section>

        <p class="kiosk-idle-footer">Customer home</p>
    </main>
</asp:Content>
