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
            <asp:Panel ID="completeExpiry" runat="server" ClientIDMode="Static"
                CssClass="complete-expiry" Visible="false">
                <p class="complete-expiry-line">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></svg>
                    <span id="completeExpiryLabel"><asp:Literal ID="litExpiryLabel" runat="server" /></span>
                    <span id="completeExpiryTime" class="complete-expiry-time" role="timer" aria-live="off"><asp:Literal ID="litExpiryTime" runat="server" /></span>
                </p>
                <p id="completeExpiryHint" class="complete-expiry-hint" role="status"><asp:Literal ID="litExpiryHint" runat="server" /></p>
            </asp:Panel>
        </section>
    </main>
    <footer class="kiosk-flow-footer kiosk-cta-footer"><div class="kiosk-flow-footer-inner kiosk-cta-footer-inner">
        <asp:Button ID="btnFinish" runat="server" Text="Done — Start New Order"
            CssClass="kiosk-cta-button kiosk-cta-button-primary kiosk-flow-primary kiosk-flow-finish"
            OnClick="btnFinish_Click" />
    </div></footer>
</asp:Content>
<asp:Content ID="CompleteScripts" ContentPlaceHolderID="UserScriptsContent" runat="server">
    <script src="<%= ResolveUrl("~/Scripts/app/user/complete.js") %>?v=1"></script>
</asp:Content>
