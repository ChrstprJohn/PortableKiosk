<%@ Page
    Title="Catalog Configuration"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="CatalogConfig.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.CatalogConfig" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <main class="mx-auto w-full max-w-7xl">

        <header class="mb-7 flex flex-col items-start justify-between gap-3 sm:flex-row sm:items-end">
            <div>
                <h1 class="text-2xl font-semibold tracking-tight text-slate-950 sm:text-3xl">Catalog setup</h1>
                <p class="mt-1 text-sm text-slate-500">Manage product categories and serving sizes in one place.</p>
            </div>
        </header>

        <asp:Label ID="lblCategoryMessage" runat="server" Visible="false" role="status" aria-live="polite" CssClass="mb-4 block rounded-md border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700"></asp:Label>
        <asp:Label ID="lblSizeMessage" runat="server" Visible="false" role="status" aria-live="polite" CssClass="mb-4 block rounded-md border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700"></asp:Label>

        <section class="mb-7" aria-labelledby="headingCategoriesSection">
            <div class="overflow-hidden rounded-lg border border-slate-200 bg-white">
                <div class="flex flex-wrap items-center justify-between gap-3 border-b border-slate-200 px-4 py-3 sm:px-5">
                    <h2 id="headingCategoriesSection" class="text-sm font-semibold text-slate-950">Categories</h2>
                    <asp:Label ID="lblCategoryCount" runat="server" Visible="false"></asp:Label>
                    <button type="button" class="inline-flex min-h-9 items-center justify-center gap-2 rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-toggle="true" data-modal-target="#addCategoryModal">
                        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg>Add category
                    </button>
                </div>

                <asp:Label ID="lblCategoryLoadError" runat="server" Visible="false" CssClass="m-3 block rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800"></asp:Label>
                <div class="w-full overflow-x-auto">
                        <asp:GridView
                            ID="gridCategories"
                            runat="server"
                            AutoGenerateColumns="false"
                            GridLines="None"
                            CssClass="w-full border-collapse text-left text-sm [&_th]:border-b [&_th]:border-slate-200 [&_th]:bg-slate-50 [&_th]:px-4 [&_th]:py-3 [&_th]:text-xs [&_th]:font-medium [&_th]:text-slate-500 [&_td]:px-4 [&_td]:py-3 [&_td]:text-slate-700 [&_tbody_tr]:border-b [&_tbody_tr]:border-slate-100 [&_tbody_tr:hover]:bg-slate-50 [&_tbody_tr:last-child]:border-b-0"
                            EmptyDataText="No categories have been created yet.">

                            <Columns>
                                <asp:BoundField DataField="CategoryID" HeaderText="ID" ItemStyle-Width="90px" />
                                <asp:BoundField DataField="CategoryName" HeaderText="Category Name" />
                                <asp:TemplateField HeaderText="Status" ItemStyle-Width="140px">
                                    <ItemTemplate>
                                        <span class='inline-flex items-center rounded-md px-2 py-0.5 text-xs font-medium <%# (bool)Eval("IsAvailable") ? "bg-emerald-50 text-emerald-700" : "bg-slate-100 text-slate-600" %>'>
                                            <%# (bool)Eval("IsAvailable") ? "Active" : "Hidden" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="190px">
                                    <ItemTemplate>
                                        <div class="flex gap-2 flex-wrap">
                                            <button
                                                type="button"
                                                class="inline-flex min-h-8 items-center justify-center gap-1.5 rounded-md border border-slate-200 bg-white px-2.5 py-1 text-xs font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400"
                                                data-modal-toggle="true"
                                                data-modal-target="#editCategoryModal"
                                                onclick='openEditCategoryModal(<%# Eval("CategoryID") %>, "<%# HttpUtility.HtmlAttributeEncode(HttpUtility.JavaScriptStringEncode(Eval("CategoryName").ToString())) %>", <%# (bool)Eval("IsAvailable") ? "true" : "false" %>);'>
                                                Edit
                                            </button>
                                            <button
                                                type="button"
                                                class="inline-flex min-h-8 items-center justify-center gap-1.5 rounded-md border border-slate-200 bg-white px-2.5 py-1 text-xs font-medium text-slate-600 transition-colors hover:bg-red-50 hover:text-red-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400"
                                                data-modal-toggle="true"
                                                data-modal-target="#deleteCategoryModal"
                                                onclick='openDeleteCategoryModal(<%# Eval("CategoryID") %>, "<%# HttpUtility.HtmlAttributeEncode(HttpUtility.JavaScriptStringEncode(Eval("CategoryName").ToString())) %>");'>
                                                Delete
                                            </button>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>

                            <EmptyDataRowStyle CssClass="text-center text-slate-500 [&_td]:px-4 [&_td]:py-10" />
                        </asp:GridView>
                    </div>

                </div>

        </section>

        <section class="mb-7" aria-labelledby="headingSizesSection">
            <div class="overflow-hidden rounded-lg border border-slate-200 bg-white">
                <div class="flex flex-wrap items-center justify-between gap-3 border-b border-slate-200 px-4 py-3 sm:px-5">
                    <h2 id="headingSizesSection" class="text-sm font-semibold text-slate-950">Serving sizes</h2>
                    <asp:Label ID="lblSizeCount" runat="server" Visible="false"></asp:Label>
                    <button type="button" class="inline-flex min-h-9 items-center justify-center gap-2 rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-toggle="true" data-modal-target="#addSizeModal">
                        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg>Add size
                    </button>
                </div>

                <asp:Label ID="lblSizeLoadError" runat="server" Visible="false" CssClass="m-3 block rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800"></asp:Label>
                <div class="w-full overflow-x-auto">
                        <asp:GridView
                            ID="gridSizes"
                            runat="server"
                            AutoGenerateColumns="false"
                            GridLines="None"
                            CssClass="w-full border-collapse text-left text-sm [&_th]:border-b [&_th]:border-slate-200 [&_th]:bg-slate-50 [&_th]:px-4 [&_th]:py-3 [&_th]:text-xs [&_th]:font-medium [&_th]:text-slate-500 [&_td]:px-4 [&_td]:py-3 [&_td]:text-slate-700 [&_tbody_tr]:border-b [&_tbody_tr]:border-slate-100 [&_tbody_tr:hover]:bg-slate-50 [&_tbody_tr:last-child]:border-b-0"
                            EmptyDataText="No sizes have been created yet.">

                            <Columns>
                                <asp:BoundField DataField="SizeID" HeaderText="ID" ItemStyle-Width="90px" />
                                <asp:BoundField DataField="SizeName" HeaderText="Size Name" />
                                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="190px">
                                    <ItemTemplate>
                                        <div class="flex gap-2 flex-wrap">
                                            <button
                                                type="button"
                                                class="inline-flex min-h-8 items-center justify-center gap-1.5 rounded-md border border-slate-200 bg-white px-2.5 py-1 text-xs font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400"
                                                data-modal-toggle="true"
                                                data-modal-target="#editSizeModal"
                                                onclick='openEditSizeModal(<%# Eval("SizeID") %>, "<%# HttpUtility.HtmlAttributeEncode(HttpUtility.JavaScriptStringEncode(Eval("SizeName").ToString())) %>");'>
                                                Edit
                                            </button>
                                            <button
                                                type="button"
                                                class="inline-flex min-h-8 items-center justify-center gap-1.5 rounded-md border border-slate-200 bg-white px-2.5 py-1 text-xs font-medium text-slate-600 transition-colors hover:bg-red-50 hover:text-red-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400"
                                                data-modal-toggle="true"
                                                data-modal-target="#deleteSizeModal"
                                                onclick='openDeleteSizeModal(<%# Eval("SizeID") %>, "<%# HttpUtility.HtmlAttributeEncode(HttpUtility.JavaScriptStringEncode(Eval("SizeName").ToString())) %>");'>
                                                Delete
                                            </button>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>

                            <EmptyDataRowStyle CssClass="text-center text-slate-500 [&_td]:px-4 [&_td]:py-10" />
                        </asp:GridView>
                    </div>

                </div>

        </section>

    </main>

    <!-- ADD CATEGORY MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="addCategoryModal" tabindex="-1" aria-labelledby="addCategoryModalLabel" aria-hidden="true">
        <div class="w-full max-w-md">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-base font-semibold text-slate-950" id="addCategoryModalLabel">Add category</h2>
                    <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close">
                        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg>
                    </button>
                </div>

                <div class="space-y-4 overflow-y-auto p-5">
                    <asp:ValidationSummary ID="validationSummaryCategory" runat="server" ValidationGroup="CategoryForm" CssClass="rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800" HeaderText="Please correct the following:" DisplayMode="BulletList" />
                    <div>
                        <asp:Label ID="lblCategoryName" runat="server" AssociatedControlID="txtCategoryName" CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Category name"></asp:Label>
                        <asp:TextBox ID="txtCategoryName" runat="server" CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm placeholder:text-slate-400 focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" MaxLength="100" placeholder="e.g. Espresso Drinks" autofocus="autofocus"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="requiredCategoryName" runat="server" ControlToValidate="txtCategoryName" ValidationGroup="CategoryForm" ErrorMessage="Category name is required." CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                    </div>
                    <div>
                        <asp:CheckBox ID="chkCategoryIsAvailable" runat="server" Checked="true" CssClass="[&_input]:size-4 [&_input]:accent-slate-900" />
                        <label class="ml-2 text-sm text-slate-700" for="<%= chkCategoryIsAvailable.ClientID %>">Available in the catalog</label>
                    </div>
                </div>

                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4">
                    <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Cancel</button>
                    <asp:Button ID="btnAddCategory" runat="server" Text="Add category" CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" ValidationGroup="CategoryForm" OnClick="btnAddCategory_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- ADD SIZE MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="addSizeModal" tabindex="-1" aria-labelledby="addSizeModalLabel" aria-hidden="true">
        <div class="w-full max-w-md">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-base font-semibold text-slate-950" id="addSizeModalLabel">Add serving size</h2>
                    <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close">
                        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg>
                    </button>
                </div>

                <div class="space-y-4 overflow-y-auto p-5">
                    <asp:ValidationSummary ID="validationSummarySize" runat="server" ValidationGroup="SizeForm" CssClass="rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800" HeaderText="Please correct the following:" DisplayMode="BulletList" />
                    <div>
                        <asp:Label ID="lblSizeName" runat="server" AssociatedControlID="txtSizeName" CssClass="mb-1.5 block text-sm font-medium text-slate-700" Text="Size name"></asp:Label>
                        <asp:TextBox ID="txtSizeName" runat="server" CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm placeholder:text-slate-400 focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200" MaxLength="50" placeholder="e.g. Regular, Large, 16oz" autofocus="autofocus"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="requiredSizeName" runat="server" ControlToValidate="txtSizeName" ValidationGroup="SizeForm" ErrorMessage="Size name is required." CssClass="mt-1 block text-sm text-red-700" Display="Dynamic" />
                    </div>
                </div>

                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4">
                    <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Cancel</button>
                    <asp:Button ID="btnAddSize" runat="server" Text="Add size" CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" ValidationGroup="SizeForm" OnClick="btnAddSize_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- EDIT CATEGORY MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="editCategoryModal" tabindex="-1" aria-labelledby="editCategoryModalLabel" aria-hidden="true">
        <div class="w-full max-w-lg">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-base font-semibold text-slate-950" id="editCategoryModalLabel">Edit category</h2>
                    <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close"><svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
                </div>

                <div class="overflow-y-auto p-5">
                    <asp:ValidationSummary
                        ID="validationSummaryEditCategory"
                        runat="server"
                        ValidationGroup="EditCategoryForm"
                        CssClass="rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800"
                        HeaderText="Please correct the following:"
                        DisplayMode="BulletList" />

                    <asp:HiddenField ID="hfEditCategoryID" runat="server" />

                    <div class="mb-3">
                        <asp:Label
                            ID="lblEditCategoryName"
                            runat="server"
                            AssociatedControlID="txtEditCategoryName"
                            CssClass="mb-1.5 block text-sm font-medium text-slate-700"
                            Text="Category name">
                        </asp:Label>
                        <asp:TextBox
                            ID="txtEditCategoryName"
                            runat="server"
                            CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200"
                            MaxLength="100">
                        </asp:TextBox>
                        <asp:RequiredFieldValidator
                            ID="requiredEditCategoryName"
                            runat="server"
                            ControlToValidate="txtEditCategoryName"
                            ValidationGroup="EditCategoryForm"
                            ErrorMessage="Category name is required."
                            CssClass="mt-1 block text-sm text-red-700"
                            Display="Dynamic" />
                    </div>

                    <div class="flex items-center gap-2">
                        <asp:CheckBox
                            ID="chkEditCategoryIsAvailable"
                            runat="server"
                            CssClass="[&_input]:size-4 [&_input]:accent-slate-900" />
                        <label class="text-sm text-slate-700" for="<%= chkEditCategoryIsAvailable.ClientID %>">
                            Available in the catalog
                        </label>
                    </div>
                </div>

                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4">
                    <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Cancel</button>
                    <asp:Button
                        ID="btnUpdateCategory"
                        runat="server"
                        Text="Save category"
                        CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800"
                        ValidationGroup="EditCategoryForm"
                        OnClick="btnUpdateCategory_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- DELETE CATEGORY CONFIRMATION -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="deleteCategoryModal" tabindex="-1" aria-labelledby="deleteCategoryModalLabel" aria-hidden="true">
        <div class="w-full max-w-lg">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-base font-semibold text-slate-950" id="deleteCategoryModalLabel">Delete category?</h2>
                    <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close"><svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
                </div>
                <div class="overflow-y-auto p-5">
                    <asp:HiddenField ID="hfDeleteCategoryID" runat="server" />
                    <p class="mb-2">
                        You are about to delete <strong id="deleteCategoryName"></strong>.
                    </p>
                    <p class="text-slate-500 text-sm mb-0">
                        This cannot be undone. Categories that still contain products cannot be deleted.
                    </p>
                </div>
                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4">
                    <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Keep category</button>
                    <asp:Button
                        ID="btnDeleteCategory"
                        runat="server"
                        Text="Delete category"
                        CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-red-600 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-red-700"
                        CausesValidation="false"
                        OnClick="btnDeleteCategory_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- EDIT SIZE MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="editSizeModal" tabindex="-1" aria-labelledby="editSizeModalLabel" aria-hidden="true">
        <div class="w-full max-w-lg">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-base font-semibold text-slate-950" id="editSizeModalLabel">Edit size</h2>
                    <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close"><svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
                </div>

                <div class="overflow-y-auto p-5">
                    <asp:ValidationSummary
                        ID="validationSummaryEditSize"
                        runat="server"
                        ValidationGroup="EditSizeForm"
                        CssClass="rounded-md border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-800"
                        HeaderText="Please correct the following:"
                        DisplayMode="BulletList" />

                    <asp:HiddenField ID="hfEditSizeID" runat="server" />

                    <div class="mb-3">
                        <asp:Label
                            ID="lblEditSizeName"
                            runat="server"
                            AssociatedControlID="txtEditSizeName"
                            CssClass="mb-1.5 block text-sm font-medium text-slate-700"
                            Text="Size name">
                        </asp:Label>
                        <asp:TextBox
                            ID="txtEditSizeName"
                            runat="server"
                            CssClass="block w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus-visible:border-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-200"
                            MaxLength="50">
                        </asp:TextBox>
                        <asp:RequiredFieldValidator
                            ID="requiredEditSizeName"
                            runat="server"
                            ControlToValidate="txtEditSizeName"
                            ValidationGroup="EditSizeForm"
                            ErrorMessage="Size name is required."
                            CssClass="mt-1 block text-sm text-red-700"
                            Display="Dynamic" />
                    </div>

                </div>

                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4">
                    <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Cancel</button>
                    <asp:Button
                        ID="btnUpdateSize"
                        runat="server"
                        Text="Save size"
                        CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-slate-800"
                        ValidationGroup="EditSizeForm"
                        OnClick="btnUpdateSize_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- DELETE SIZE CONFIRMATION -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/50 p-4" id="deleteSizeModal" tabindex="-1" aria-labelledby="deleteSizeModalLabel" aria-hidden="true">
        <div class="w-full max-w-lg">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-base font-semibold text-slate-950" id="deleteSizeModalLabel">Delete size?</h2>
                    <button type="button" class="inline-flex size-8 shrink-0 items-center justify-center rounded-md text-slate-500 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true" aria-label="Close"><svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
                </div>
                <div class="overflow-y-auto p-5">
                    <asp:HiddenField ID="hfDeleteSizeID" runat="server" />
                    <p class="mb-2">
                        You are about to delete <strong id="deleteSizeName"></strong>.
                    </p>
                    <p class="text-slate-500 text-sm mb-0">
                        This cannot be undone. Sizes currently assigned to product variants cannot be deleted.
                    </p>
                </div>
                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4">
                    <button type="button" class="inline-flex min-h-9 items-center justify-center rounded-md border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-400" data-modal-dismiss="true">Keep size</button>
                    <asp:Button
                        ID="btnDeleteSize"
                        runat="server"
                        Text="Delete size"
                        CssClass="inline-flex min-h-9 cursor-pointer items-center justify-center rounded-md bg-red-600 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-red-700"
                        CausesValidation="false"
                        OnClick="btnDeleteSize_Click" />
                </div>
            </div>
        </div>
    </div>

    <script src="<%= ResolveUrl("~/Scripts/app/admin/catalog-config.js") %>"></script>

</asp:Content>
