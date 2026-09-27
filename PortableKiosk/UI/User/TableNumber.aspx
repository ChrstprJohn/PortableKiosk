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
            <h1 id="tableNumberHeading">Enter your table locator number</h1>

            <asp:Label
                ID="lblTableNumber"
                runat="server"
                AssociatedControlID="txtTableNumber"
                Text="Table locator number"
                CssClass="sr-only" />
            <asp:TextBox
                ID="txtTableNumber"
                runat="server"
                CssClass="table-number-input"
                ClientIDMode="Static"
                MaxLength="20"
                TextMode="SingleLine"
                inputmode="none"
                autocomplete="off"
                data-table-keypad-input="true"
                aria-label="Table locator number" />

            <div class="table-number-keypad" data-table-keypad aria-label="Number keypad">
                <button type="button" data-table-key="1">1</button>
                <button type="button" data-table-key="2">2</button>
                <button type="button" data-table-key="3">3</button>
                <button type="button" data-table-key="4">4</button>
                <button type="button" data-table-key="5">5</button>
                <button type="button" data-table-key="6">6</button>
                <button type="button" data-table-key="7">7</button>
                <button type="button" data-table-key="8">8</button>
                <button type="button" data-table-key="9">9</button>
                <button type="button" data-table-key="clear" class="table-keypad-utility">Clear</button>
                <button type="button" data-table-key="0">0</button>
                <button type="button" data-table-key="backspace" class="table-keypad-utility" aria-label="Delete last digit">⌫</button>
            </div>

            <asp:Label
                ID="lblTableNumberError"
                runat="server"
                Visible="false"
                CssClass="kiosk-alert kiosk-alert-error"
                role="alert" />

        </section>
    </main>
    <footer class="kiosk-flow-footer"><div class="kiosk-flow-footer-inner">
        <a runat="server" href="~/UI/User/Fulfillment.aspx" class="kiosk-button kiosk-flow-back">Back</a>
        <asp:Button ID="btnContinue" runat="server" Text="Go"
            CssClass="kiosk-button kiosk-button-primary kiosk-flow-primary"
            OnClick="btnContinue_Click" />
    </div></footer>
</asp:Content>
