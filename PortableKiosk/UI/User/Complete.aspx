<%@ Page
    Title="Order complete"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/User.Master"
    AutoEventWireup="true"
    CodeBehind="Complete.aspx.cs"
    Inherits="PortableKiosk.UI.User.Complete" %>

<asp:Content
    ID="CompleteContent"
    ContentPlaceHolderID="UserContent"
    runat="server">
    <main class="complete-page" aria-labelledby="completeHeading">
        <section class="order-complete-panel">
            <h1 id="completeHeading" class="complete-order-title">Your order number is</h1>
            <p class="complete-order-number">#<asp:Literal ID="litOrderNumber" runat="server" /></p>
            <p class="complete-instruction"><asp:Literal ID="litInstruction" runat="server" /></p>

        </section>
    </main>
    <footer class="kiosk-flow-footer kiosk-cta-footer"><div class="kiosk-flow-footer-inner kiosk-cta-footer-inner">
        <asp:Button ID="btnFinish" runat="server" Text="Finish"
            CssClass="kiosk-cta-button kiosk-cta-button-primary kiosk-flow-primary kiosk-flow-finish"
            OnClick="btnFinish_Click" />
    </div></footer>
</asp:Content>
