<%@ Page
    Title="Table locator"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/User.Master"
    AutoEventWireup="true"
    CodeBehind="TableNumber.aspx.cs"
    Inherits="PortableKiosk.UI.User.TableNumber" %>

<asp:Content
    ID="TableNumberContent"
    ContentPlaceHolderID="UserContent"
    runat="server">
    <main class="table-number-page" aria-labelledby="tableNumberHeading">
        <section class="table-number-panel">
            <p class="kiosk-eyebrow">Table service</p>
            <h1 id="tableNumberHeading">Enter your table locator number</h1>
            <p>
                Take a numbered locator, place it where the crew can see it,
                and enter that number below.
            </p>

            <asp:Label
                ID="lblTableNumber"
                runat="server"
                AssociatedControlID="txtTableNumber"
                Text="Locator number" />
            <asp:TextBox
                ID="txtTableNumber"
                runat="server"
                CssClass="table-number-input"
                MaxLength="20"
                TextMode="Number"
                inputmode="numeric"
                autocomplete="off" />

            <asp:Label
                ID="lblTableNumberError"
                runat="server"
                Visible="false"
                CssClass="kiosk-alert kiosk-alert-error"
                role="alert" />

            <div class="table-number-actions">
                <a runat="server" href="~/UI/User/Fulfillment.aspx" class="kiosk-button">Back</a>
                <asp:Button
                    ID="btnContinue"
                    runat="server"
                    Text="Continue"
                    CssClass="kiosk-button kiosk-button-primary"
                    OnClick="btnContinue_Click" />
            </div>
        </section>
    </main>
</asp:Content>
