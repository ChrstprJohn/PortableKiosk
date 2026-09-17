<%@ Page
    Title="Point of Sale"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="Index.aspx.cs"
    Inherits="PortableKiosk.UI.POS.Index" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <main class="pos-shell" aria-labelledby="posHeading">
        <header class="pos-header">
            <div>
                <p class="pos-shift-label">Active workspace</p>
                <h1 id="posHeading">Point of sale</h1>
                <p>
                    Signed in as
                    <strong><asp:Literal ID="litStaffName" runat="server" /></strong>
                    <asp:Label ID="lblStaffRole" runat="server" />
                </p>
            </div>

            <div class="pos-header-actions">
                <asp:Button ID="btnSignOut" runat="server"
                    Text="Sign out" CssClass="btn btn-light"
                    CausesValidation="false"
                    OnClick="btnSignOut_Click" />
            </div>
        </header>

        <section class="pos-stage" aria-labelledby="registerHeading">
            <div class="pos-stage-copy">
                <h2 id="registerHeading">Register ready</h2>
                <p>
                    Staff authentication and role routing are working.
                    Product selection, cart controls, and payment flow can now
                    be built here without exposing admin management tools.
                </p>
            </div>

            <div class="pos-preview" aria-label="Planned POS regions">
                <div>
                    <span>Menu</span>
                    <strong>Product selection</strong>
                </div>
                <div>
                    <span>Current sale</span>
                    <strong>Order and payment</strong>
                </div>
            </div>
        </section>
    </main>

</asp:Content>
