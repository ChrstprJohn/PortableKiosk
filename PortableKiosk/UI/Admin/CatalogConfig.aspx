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

    <div class="w-full px-4 mt-4">

        <header class="page-heading mb-4 flex justify-between items-center flex-wrap gap-2">
            <div>
                <h1>Catalog setup & configurations</h1>
                <p class="text-slate-500 mb-0">Manage product categories and serving sizes in one unified workspace.</p>
            </div>
        </header>

        <!-- ========================================== -->
        <!-- 1. CATEGORIES SECTION (TOP, FULL WIDTH)   -->
        <!-- ========================================== -->
        <section class="mb-5" aria-labelledby="headingCategoriesSection">
            
            <!-- ADD CATEGORY CARD -->
            <div class="rounded-xl bg-white shadow-sm mb-4">
                <div class="border-b border-slate-200 px-5 py-4 bg-blue-700 text-white flex justify-between items-center">
                    <strong id="headingCategoriesSection"><i class="bi bi-tag-fill mr-1"></i> Add Category</strong>
                    <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold bg-slate-50 text-blue-700">Catalog taxonomy</span>
                </div>

                <div class="p-5">

                    <asp:ValidationSummary
                        ID="validationSummaryCategory"
                        runat="server"
                        ValidationGroup="CategoryForm"
                        CssClass="rounded-lg border px-4 py-3 border-red-200 bg-red-50 text-red-800"
                        HeaderText="Please correct the following:"
                        DisplayMode="BulletList" />

                    <asp:Label
                        ID="lblCategoryMessage"
                        runat="server"
                        Visible="false">
                    </asp:Label>

                    <div class="grid grid-cols-12 items-end gap-3">
                        <!-- CATEGORY NAME -->
                        <div class="col-span-12 md:col-span-5">
                            <asp:Label
                                ID="lblCategoryName"
                                runat="server"
                                AssociatedControlID="txtCategoryName"
                                CssClass="mb-1 block text-sm font-semibold text-slate-700 font-bold"
                                Text="Category Name">
                            </asp:Label>

                            <asp:TextBox
                                ID="txtCategoryName"
                                runat="server"
                                CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200"
                                MaxLength="100"
                                placeholder="e.g. Espresso Drinks">
                            </asp:TextBox>

                            <asp:RequiredFieldValidator
                                ID="requiredCategoryName"
                                runat="server"
                                ControlToValidate="txtCategoryName"
                                ValidationGroup="CategoryForm"
                                ErrorMessage="Category name is required."
                                CssClass="text-red-700 text-sm"
                                Display="Dynamic">
                            </asp:RequiredFieldValidator>
                        </div>

                        <!-- STATUS -->
                        <div class="col-span-12 md:col-span-2">
                            <label class="mb-1 block text-sm font-semibold text-slate-700 font-bold block">Status</label>
                            <div class="flex items-center gap-2 mt-2">
                                <asp:CheckBox
                                    ID="chkCategoryIsAvailable"
                                    runat="server"
                                    Checked="true"
                                    CssClass="h-4 w-4 accent-blue-700 [&_input]:h-4 [&_input]:w-4 [&_input]:accent-blue-700" />
                                <label class="text-sm text-slate-700" for="<%= chkCategoryIsAvailable.ClientID %>">Available</label>
                            </div>
                        </div>

                        <!-- ADD BUTTON -->
                        <div class="col-span-12 md:col-span-2">
                            <asp:Button
                                ID="btnAddCategory"
                                runat="server"
                                Text="Add Category"
                                CssClass="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-blue-700 bg-blue-700 text-white hover:bg-blue-800 w-full"
                                ValidationGroup="CategoryForm"
                                OnClick="btnAddCategory_Click" />
                        </div>
                    </div>

                </div>
            </div>

            <!-- CATEGORIES TABLE (FULL WIDTH) -->
            <div class="rounded-xl bg-white shadow-sm">
                <div class="border-b border-slate-200 px-5 py-4 bg-white flex justify-between items-center py-3">
                    <strong><i class="bi bi-list-ul mr-1"></i> Category List</strong>
                    <asp:Label ID="lblCategoryCount" runat="server" CssClass="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold bg-slate-600"></asp:Label>
                </div>

                <div class="p-0">

                    <asp:Label
                        ID="lblCategoryLoadError"
                        runat="server"
                        Visible="false"
                        CssClass="rounded-lg border px-4 py-3 border-red-200 bg-red-50 text-red-800 m-3 block">
                    </asp:Label>

                    <div class="w-full overflow-x-auto">
                        <asp:GridView
                            ID="gridCategories"
                            runat="server"
                            AutoGenerateColumns="false"
                            GridLines="None"
                            CssClass="w-full border-collapse text-left [&_th]:px-3 [&_th]:py-2 [&_td]:px-3 [&_td]:py-2 [&_tbody_tr]:border-b [&_tbody_tr]:border-slate-200 [&_tbody_tr:nth-child(odd)]:bg-slate-50 [&_tbody_tr:hover]:bg-slate-50 align-middle mb-0 w-full"
                            EmptyDataText="No categories have been created yet.">

                            <Columns>
                                <asp:BoundField DataField="CategoryID" HeaderText="ID" ItemStyle-Width="90px" />
                                <asp:BoundField DataField="CategoryName" HeaderText="Category Name" />
                                <asp:TemplateField HeaderText="Status" ItemStyle-Width="140px">
                                    <ItemTemplate>
                                        <span class='inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold text-white <%# (bool)Eval("IsAvailable") ? "bg-emerald-700" : "bg-slate-600" %>'>
                                            <%# (bool)Eval("IsAvailable") ? "Active" : "Hidden" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="190px">
                                    <ItemTemplate>
                                        <div class="flex gap-2 flex-wrap">
                                            <button
                                                type="button"
                                                class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors px-3 py-1.5 text-sm border-blue-700 bg-transparent text-blue-700 hover:bg-blue-50"
                                                data-modal-toggle="true"
                                                data-modal-target="#editCategoryModal"
                                                onclick='openEditCategoryModal(<%# Eval("CategoryID") %>, "<%# HttpUtility.HtmlAttributeEncode(HttpUtility.JavaScriptStringEncode(Eval("CategoryName").ToString())) %>", <%# (bool)Eval("IsAvailable") ? "true" : "false" %>);'>
                                                <i class="bi bi-pencil-square mr-1"></i>Edit
                                            </button>
                                            <button
                                                type="button"
                                                class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors px-3 py-1.5 text-sm border-red-700 bg-transparent text-red-700 hover:bg-red-50"
                                                data-modal-toggle="true"
                                                data-modal-target="#deleteCategoryModal"
                                                onclick='openDeleteCategoryModal(<%# Eval("CategoryID") %>, "<%# HttpUtility.HtmlAttributeEncode(HttpUtility.JavaScriptStringEncode(Eval("CategoryName").ToString())) %>");'>
                                                <i class="bi bi-trash mr-1"></i>Delete
                                            </button>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>

                            <HeaderStyle CssClass="bg-slate-100" />
                            <EmptyDataRowStyle CssClass="text-center text-slate-500 p-4" />
                        </asp:GridView>
                    </div>

                </div>
            </div>

        </section>

        <!-- ========================================== -->
        <!-- 2. SIZES SECTION (BOTTOM, FULL WIDTH)     -->
        <!-- ========================================== -->
        <section class="mb-5" aria-labelledby="headingSizesSection">

            <!-- ADD SIZE CARD -->
            <div class="rounded-xl bg-white shadow-sm mb-4">
                <div class="border-b border-slate-200 px-5 py-4 bg-slate-900 text-white flex justify-between items-center">
                    <strong id="headingSizesSection"><i class="bi bi-aspect-ratio mr-1"></i> Add Size</strong>
                    <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold bg-slate-50 text-slate-900">Portion sizing</span>
                </div>

                <div class="p-5">

                    <asp:ValidationSummary
                        ID="validationSummarySize"
                        runat="server"
                        ValidationGroup="SizeForm"
                        CssClass="rounded-lg border px-4 py-3 border-red-200 bg-red-50 text-red-800"
                        HeaderText="Please correct the following:"
                        DisplayMode="BulletList" />

                    <asp:Label
                        ID="lblSizeMessage"
                        runat="server"
                        Visible="false">
                    </asp:Label>

                    <div class="grid grid-cols-12 items-end gap-3">
                        <!-- SIZE NAME -->
                        <div class="col-span-12 md:col-span-6">
                            <asp:Label
                                ID="lblSizeName"
                                runat="server"
                                AssociatedControlID="txtSizeName"
                                CssClass="mb-1 block text-sm font-semibold text-slate-700 font-bold"
                                Text="Size Name">
                            </asp:Label>

                            <asp:TextBox
                                ID="txtSizeName"
                                runat="server"
                                CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200"
                                MaxLength="50"
                                placeholder="e.g. Regular, Large, 16oz">
                            </asp:TextBox>

                            <asp:RequiredFieldValidator
                                ID="requiredSizeName"
                                runat="server"
                                ControlToValidate="txtSizeName"
                                ValidationGroup="SizeForm"
                                ErrorMessage="Size name is required."
                                CssClass="text-red-700 text-sm"
                                Display="Dynamic">
                            </asp:RequiredFieldValidator>
                        </div>

                        <!-- ADD BUTTON -->
                        <div class="col-span-12 md:col-span-2">
                            <asp:Button
                                ID="btnAddSize"
                                runat="server"
                                Text="Add Size"
                                CssClass="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-slate-900 bg-slate-900 text-white hover:bg-slate-800 w-full"
                                ValidationGroup="SizeForm"
                                OnClick="btnAddSize_Click" />
                        </div>
                    </div>

                </div>
            </div>

            <!-- SIZES TABLE (FULL WIDTH) -->
            <div class="rounded-xl bg-white shadow-sm">
                <div class="border-b border-slate-200 px-5 py-4 bg-white flex justify-between items-center py-3">
                    <strong><i class="bi bi-list-ul mr-1"></i> Size List</strong>
                    <asp:Label ID="lblSizeCount" runat="server" CssClass="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold bg-slate-600"></asp:Label>
                </div>

                <div class="p-0">

                    <asp:Label
                        ID="lblSizeLoadError"
                        runat="server"
                        Visible="false"
                        CssClass="rounded-lg border px-4 py-3 border-red-200 bg-red-50 text-red-800 m-3 block">
                    </asp:Label>

                    <div class="w-full overflow-x-auto">
                        <asp:GridView
                            ID="gridSizes"
                            runat="server"
                            AutoGenerateColumns="false"
                            GridLines="None"
                            CssClass="w-full border-collapse text-left [&_th]:px-3 [&_th]:py-2 [&_td]:px-3 [&_td]:py-2 [&_tbody_tr]:border-b [&_tbody_tr]:border-slate-200 [&_tbody_tr:nth-child(odd)]:bg-slate-50 [&_tbody_tr:hover]:bg-slate-50 align-middle mb-0 w-full"
                            EmptyDataText="No sizes have been created yet.">

                            <Columns>
                                <asp:BoundField DataField="SizeID" HeaderText="ID" ItemStyle-Width="90px" />
                                <asp:BoundField DataField="SizeName" HeaderText="Size Name" />
                                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="190px">
                                    <ItemTemplate>
                                        <div class="flex gap-2 flex-wrap">
                                            <button
                                                type="button"
                                                class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors px-3 py-1.5 text-sm border-blue-700 bg-transparent text-blue-700 hover:bg-blue-50"
                                                data-modal-toggle="true"
                                                data-modal-target="#editSizeModal"
                                                onclick='openEditSizeModal(<%# Eval("SizeID") %>, "<%# HttpUtility.HtmlAttributeEncode(HttpUtility.JavaScriptStringEncode(Eval("SizeName").ToString())) %>");'>
                                                <i class="bi bi-pencil-square mr-1"></i>Edit
                                            </button>
                                            <button
                                                type="button"
                                                class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors px-3 py-1.5 text-sm border-red-700 bg-transparent text-red-700 hover:bg-red-50"
                                                data-modal-toggle="true"
                                                data-modal-target="#deleteSizeModal"
                                                onclick='openDeleteSizeModal(<%# Eval("SizeID") %>, "<%# HttpUtility.HtmlAttributeEncode(HttpUtility.JavaScriptStringEncode(Eval("SizeName").ToString())) %>");'>
                                                <i class="bi bi-trash mr-1"></i>Delete
                                            </button>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>

                            <HeaderStyle CssClass="bg-slate-100" />
                            <EmptyDataRowStyle CssClass="text-center text-slate-500 p-4" />
                        </asp:GridView>
                    </div>

                </div>
            </div>

        </section>

    </div>

    <!-- EDIT CATEGORY MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/60 p-4" id="editCategoryModal" tabindex="-1" aria-labelledby="editCategoryModalLabel" aria-hidden="true">
        <div class="w-full max-w-lg">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-xl bg-white shadow-xl">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4 bg-blue-700 text-white">
                    <h2 class="text-lg font-semibold text-lg font-semibold" id="editCategoryModalLabel">
                        <i class="bi bi-pencil-square mr-1"></i>Edit category
                    </h2>
                    <button type="button" class="inline-flex h-8 w-8 items-center justify-center rounded-full text-2xl leading-none hover:bg-black/10 text-white" data-modal-dismiss="true" aria-label="Close">&times;</button>
                </div>

                <div class="overflow-y-auto p-5">
                    <asp:ValidationSummary
                        ID="validationSummaryEditCategory"
                        runat="server"
                        ValidationGroup="EditCategoryForm"
                        CssClass="rounded-lg border px-4 py-3 border-red-200 bg-red-50 text-red-800"
                        HeaderText="Please correct the following:"
                        DisplayMode="BulletList" />

                    <asp:HiddenField ID="hfEditCategoryID" runat="server" />

                    <div class="mb-3">
                        <asp:Label
                            ID="lblEditCategoryName"
                            runat="server"
                            AssociatedControlID="txtEditCategoryName"
                            CssClass="mb-1 block text-sm font-semibold text-slate-700 font-bold"
                            Text="Category name">
                        </asp:Label>
                        <asp:TextBox
                            ID="txtEditCategoryName"
                            runat="server"
                            CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200"
                            MaxLength="100">
                        </asp:TextBox>
                        <asp:RequiredFieldValidator
                            ID="requiredEditCategoryName"
                            runat="server"
                            ControlToValidate="txtEditCategoryName"
                            ValidationGroup="EditCategoryForm"
                            ErrorMessage="Category name is required."
                            CssClass="text-red-700 text-sm"
                            Display="Dynamic" />
                    </div>

                    <div class="flex items-center gap-2">
                        <asp:CheckBox
                            ID="chkEditCategoryIsAvailable"
                            runat="server"
                            CssClass="h-4 w-4 accent-blue-700 [&_input]:h-4 [&_input]:w-4 [&_input]:accent-blue-700" />
                        <label class="text-sm text-slate-700" for="<%= chkEditCategoryIsAvailable.ClientID %>">
                            Available in the catalog
                        </label>
                    </div>
                </div>

                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4 bg-slate-50">
                    <button type="button" class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-slate-600 bg-slate-600 text-white hover:bg-slate-700" data-modal-dismiss="true">Cancel</button>
                    <asp:Button
                        ID="btnUpdateCategory"
                        runat="server"
                        Text="Save category"
                        CssClass="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-blue-700 bg-blue-700 text-white hover:bg-blue-800"
                        ValidationGroup="EditCategoryForm"
                        OnClick="btnUpdateCategory_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- DELETE CATEGORY CONFIRMATION -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/60 p-4" id="deleteCategoryModal" tabindex="-1" aria-labelledby="deleteCategoryModalLabel" aria-hidden="true">
        <div class="w-full max-w-lg">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-xl bg-white shadow-xl">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-lg font-semibold text-lg font-semibold" id="deleteCategoryModalLabel">Delete category?</h2>
                    <button type="button" class="inline-flex h-8 w-8 items-center justify-center rounded-full text-2xl leading-none hover:bg-black/10" data-modal-dismiss="true" aria-label="Close">&times;</button>
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
                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4 bg-slate-50">
                    <button type="button" class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-slate-600 bg-slate-600 text-white hover:bg-slate-700" data-modal-dismiss="true">Keep category</button>
                    <asp:Button
                        ID="btnDeleteCategory"
                        runat="server"
                        Text="Delete category"
                        CssClass="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-red-700 bg-red-700 text-white hover:bg-red-800"
                        CausesValidation="false"
                        OnClick="btnDeleteCategory_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- EDIT SIZE MODAL -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/60 p-4" id="editSizeModal" tabindex="-1" aria-labelledby="editSizeModalLabel" aria-hidden="true">
        <div class="w-full max-w-lg">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-xl bg-white shadow-xl">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4 bg-slate-900 text-white">
                    <h2 class="text-lg font-semibold text-lg font-semibold" id="editSizeModalLabel">
                        <i class="bi bi-pencil-square mr-1"></i>Edit size
                    </h2>
                    <button type="button" class="inline-flex h-8 w-8 items-center justify-center rounded-full text-2xl leading-none hover:bg-black/10 text-white" data-modal-dismiss="true" aria-label="Close">&times;</button>
                </div>

                <div class="overflow-y-auto p-5">
                    <asp:ValidationSummary
                        ID="validationSummaryEditSize"
                        runat="server"
                        ValidationGroup="EditSizeForm"
                        CssClass="rounded-lg border px-4 py-3 border-red-200 bg-red-50 text-red-800"
                        HeaderText="Please correct the following:"
                        DisplayMode="BulletList" />

                    <asp:HiddenField ID="hfEditSizeID" runat="server" />

                    <div class="mb-3">
                        <asp:Label
                            ID="lblEditSizeName"
                            runat="server"
                            AssociatedControlID="txtEditSizeName"
                            CssClass="mb-1 block text-sm font-semibold text-slate-700 font-bold"
                            Text="Size name">
                        </asp:Label>
                        <asp:TextBox
                            ID="txtEditSizeName"
                            runat="server"
                            CssClass="block w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-200"
                            MaxLength="50">
                        </asp:TextBox>
                        <asp:RequiredFieldValidator
                            ID="requiredEditSizeName"
                            runat="server"
                            ControlToValidate="txtEditSizeName"
                            ValidationGroup="EditSizeForm"
                            ErrorMessage="Size name is required."
                            CssClass="text-red-700 text-sm"
                            Display="Dynamic" />
                    </div>

                </div>

                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4 bg-slate-50">
                    <button type="button" class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-slate-600 bg-slate-600 text-white hover:bg-slate-700" data-modal-dismiss="true">Cancel</button>
                    <asp:Button
                        ID="btnUpdateSize"
                        runat="server"
                        Text="Save size"
                        CssClass="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-slate-900 bg-slate-900 text-white hover:bg-slate-800"
                        ValidationGroup="EditSizeForm"
                        OnClick="btnUpdateSize_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- DELETE SIZE CONFIRMATION -->
    <div class="fixed inset-0 z-50 hidden items-center justify-center bg-slate-950/60 p-4" id="deleteSizeModal" tabindex="-1" aria-labelledby="deleteSizeModalLabel" aria-hidden="true">
        <div class="w-full max-w-lg">
            <div class="flex max-h-[90vh] flex-col overflow-hidden rounded-xl bg-white shadow-xl">
                <div class="flex items-center justify-between gap-3 border-b border-slate-200 px-5 py-4">
                    <h2 class="text-lg font-semibold text-lg font-semibold" id="deleteSizeModalLabel">Delete size?</h2>
                    <button type="button" class="inline-flex h-8 w-8 items-center justify-center rounded-full text-2xl leading-none hover:bg-black/10" data-modal-dismiss="true" aria-label="Close">&times;</button>
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
                <div class="flex flex-wrap justify-end gap-2 border-t border-slate-200 px-5 py-4 bg-slate-50">
                    <button type="button" class="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-slate-600 bg-slate-600 text-white hover:bg-slate-700" data-modal-dismiss="true">Keep size</button>
                    <asp:Button
                        ID="btnDeleteSize"
                        runat="server"
                        Text="Delete size"
                        CssClass="inline-flex items-center justify-center rounded-lg border px-4 py-2 font-semibold transition-colors border-red-700 bg-red-700 text-white hover:bg-red-800"
                        CausesValidation="false"
                        OnClick="btnDeleteSize_Click" />
                </div>
            </div>
        </div>
    </div>

    <script src="<%= ResolveUrl("~/Scripts/app/admin/catalog-config.js") %>"></script>

</asp:Content>
