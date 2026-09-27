<%@ Control
    Language="C#"
    AutoEventWireup="true"
    CodeBehind="ModalDialog.ascx.cs"
    Inherits="PortableKiosk.Shared.Controls.ModalDialog" %>

<div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/60 p-4 <%= CustomCssClass %>"
     id="<%= ClientModalID %>"
     tabindex="-1"
     aria-labelledby="<%= ClientModalID %>Label"
     aria-hidden="true"
     <%= StaticBackdrop ? "data-modal-backdrop=\"static\" data-modal-keyboard=\"false\"" : "" %>>

    <div class="w-full <%= GetDialogClasses() %>">
        <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-xl bg-white shadow-xl shadow">
            
            <!-- HEADER -->
            <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4 <%= GetHeaderClasses() %>">
                <h5 class="text-lg font-semibold flex items-center gap-2" id="<%= ClientModalID %>Label">
                    <% if (!string.IsNullOrEmpty(IconCssClass)) { %>
                        <i class="<%= IconCssClass %>"></i>
                    <% } %>
                    <asp:Literal ID="litTitle" runat="server" />
                </h5>
                <% if (ShowCloseButton) { %>
                    <button type="button" class="inline-flex h-8 w-8 items-center justify-center rounded-full text-2xl leading-none hover:bg-black/10 <%= HeaderVariant.Equals("Light", StringComparison.OrdinalIgnoreCase) ? "" : "text-white" %>" data-modal-dismiss="true" aria-label="Close">&times;</button>
                <% } %>
            </div>

            <!-- BODY -->
            <div class="overflow-y-auto p-5 <%= BodyCssClass %>">
                <asp:PlaceHolder ID="phBody" runat="server" />
            </div>

            <!-- FOOTER -->
            <% if (ShowFooter) { %>
                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4 <%= FooterCssClass %>">
                    <asp:PlaceHolder ID="phFooter" runat="server">
                        <% if (ShowDefaultCloseButton) { %>
                            <button type="button" class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-slate-600 bg-slate-600 text-white hover:bg-slate-700" data-modal-dismiss="true"><%= CloseButtonText %></button>
                        <% } %>
                    </asp:PlaceHolder>
                </div>
            <% } %>

        </div>
    </div>
</div>
