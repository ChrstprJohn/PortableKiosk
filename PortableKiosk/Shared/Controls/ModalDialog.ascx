<%@ Control
    Language="C#"
    AutoEventWireup="true"
    CodeBehind="ModalDialog.ascx.cs"
    Inherits="PortableKiosk.Shared.Controls.ModalDialog" %>

<div class="modal fade <%= CustomCssClass %>"
     id="<%= ClientModalID %>"
     tabindex="-1"
     aria-labelledby="<%= ClientModalID %>Label"
     aria-hidden="true"
     <%= StaticBackdrop ? "data-bs-backdrop=\"static\" data-bs-keyboard=\"false\"" : "" %>>

    <div class="modal-dialog <%= GetDialogClasses() %>">
        <div class="modal-content shadow">
            
            <!-- HEADER -->
            <div class="modal-header <%= GetHeaderClasses() %>">
                <h5 class="modal-title d-flex align-items-center gap-2" id="<%= ClientModalID %>Label">
                    <% if (!string.IsNullOrEmpty(IconCssClass)) { %>
                        <i class="<%= IconCssClass %>"></i>
                    <% } %>
                    <asp:Literal ID="litTitle" runat="server" />
                </h5>
                <% if (ShowCloseButton) { %>
                    <button type="button" class="btn-close <%= HeaderVariant.Equals("Light", StringComparison.OrdinalIgnoreCase) ? "" : "btn-close-white" %>" data-bs-dismiss="modal" aria-label="Close"></button>
                <% } %>
            </div>

            <!-- BODY -->
            <div class="modal-body <%= BodyCssClass %>">
                <asp:PlaceHolder ID="phBody" runat="server" />
            </div>

            <!-- FOOTER -->
            <% if (ShowFooter) { %>
                <div class="modal-footer <%= FooterCssClass %>">
                    <asp:PlaceHolder ID="phFooter" runat="server">
                        <% if (ShowDefaultCloseButton) { %>
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><%= CloseButtonText %></button>
                        <% } %>
                    </asp:PlaceHolder>
                </div>
            <% } %>

        </div>
    </div>
</div>
