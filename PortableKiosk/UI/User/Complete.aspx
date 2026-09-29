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
        <section class="complete-receipt" aria-label="Order confirmation">
            <div class="complete-receipt-printer" aria-hidden="true"></div>
            <div class="complete-receipt-paper">
                <h1 id="completeHeading" class="complete-order-title">YOUR ORDER NUMBER</h1>
                <p class="complete-order-number">#<asp:Literal ID="litOrderNumber" runat="server" /></p>
                <p class="complete-order-type"><asp:Literal ID="litOrderType" runat="server" /></p>
                <ul class="complete-order-items"><asp:Repeater ID="rptOrderItems" runat="server"><ItemTemplate>
                    <li><%#: Eval("Quantity") %> × <%#: Eval("ProductName") %></li>
                </ItemTemplate></asp:Repeater></ul>
                <p class="complete-instruction"><asp:Literal ID="litInstruction" runat="server" /></p>
            </div>
        </section>
    </main>
    <footer class="kiosk-flow-footer kiosk-cta-footer"><div class="kiosk-flow-footer-inner kiosk-cta-footer-inner">
        <asp:Button ID="btnFinish" runat="server" Text="Done — Start New Order"
            CssClass="kiosk-cta-button kiosk-cta-button-primary kiosk-flow-primary kiosk-flow-finish"
            OnClick="btnFinish_Click" />
    </div></footer>
</asp:Content>
