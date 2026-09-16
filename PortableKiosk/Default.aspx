<%@ Page Title="Home" Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="Default.aspx.cs"
    Inherits="PortableKiosk._Default" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="container mt-4">
        <h2>Database Connection</h2>

        <asp:Label
            ID="DatabaseStatusLabel"
            runat="server">
        </asp:Label>
    </div>

</asp:Content>