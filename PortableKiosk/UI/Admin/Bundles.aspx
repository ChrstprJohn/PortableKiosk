<%@ Page
    Title="Bundles & Option Groups"
    Language="C#"
    MasterPageFile="~/Shared/Layouts/Admin.Master"
    AutoEventWireup="true"
    CodeBehind="Bundles.aspx.cs"
    Inherits="PortableKiosk.UI.Admin.BundleManagement" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="AdminContent"
    runat="server">

    <div class="container-fluid mt-4">

        <header class="page-heading mb-4 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <div>
                <h1>Meal Bundles & Choice Groups</h1>
                <p class="text-muted mb-0">Build combo packages, meal slots, and reusable drink/side option pools for kiosk and POS.</p>
            </div>
        </header>

        <!-- GLOBAL FEEDBACK MESSAGE -->
        <asp:Label
            ID="lblGlobalMessage"
            runat="server"
            Visible="false"
            CssClass="alert alert-info d-block shadow-sm mb-4">
        </asp:Label>

        <!-- TAB NAVIGATION -->
        <ul class="nav nav-pills mb-4 gap-2" id="bundleNavTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button
                    class="nav-link active fw-bold px-4 py-2"
                    id="tab-bundles-btn"
                    data-bs-toggle="tab"
                    data-bs-target="#tab-bundles"
                    type="button"
                    role="tab"
                    aria-controls="tab-bundles"
                    aria-selected="true">
                    <i class="bi bi-box-seam-fill me-1"></i> 1. Bundles & Meal Slots
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button
                    class="nav-link fw-bold px-4 py-2"
                    id="tab-option-groups-btn"
                    data-bs-toggle="tab"
                    data-bs-target="#tab-option-groups"
                    type="button"
                    role="tab"
                    aria-controls="tab-option-groups"
                    aria-selected="false">
                    <i class="bi bi-collection-fill me-1"></i> 2. Reusable Option Pools & Upgrades
                </button>
            </li>
        </ul>

        <div class="tab-content" id="bundleTabContent">

            <!-- =========================================================
                 TAB A: BUNDLES & SLOTS BUILDER
                 ========================================================= -->
            <div class="tab-pane fade show active" id="tab-bundles" role="tabpanel" aria-labelledby="tab-bundles-btn">

                <!-- ADD BUNDLE TOP CARD -->
                <div class="card shadow-sm mb-4 border-0">
                    <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                        <strong><i class="bi bi-plus-circle-fill me-1"></i> Create New Bundle</strong>
                        <span class="badge bg-light text-primary">Meal Package</span>
                    </div>

                    <div class="card-body bg-light">

                        <asp:ValidationSummary
                            ID="validationSummaryBundle"
                            runat="server"
                            ValidationGroup="BundleForm"
                            CssClass="alert alert-danger"
                            HeaderText="Please correct the following:"
                            DisplayMode="BulletList" />

                        <div class="row g-3 align-items-end">

                            <!-- BUNDLE NAME -->
                            <div class="col-md-3">
                                <asp:Label
                                    ID="lblBundleName"
                                    runat="server"
                                    AssociatedControlID="txtBundleName"
                                    CssClass="form-label"
                                    Text="Bundle name">
                                </asp:Label>

                                <asp:TextBox
                                    ID="txtBundleName"
                                    runat="server"
                                    CssClass="form-control"
                                    MaxLength="100"
                                    placeholder="e.g. Burger Combo Deal">
                                </asp:TextBox>

                                <asp:RequiredFieldValidator
                                    ID="requiredBundleName"
                                    runat="server"
                                    ControlToValidate="txtBundleName"
                                    ValidationGroup="BundleForm"
                                    ErrorMessage="Bundle name is required."
                                    CssClass="text-danger small"
                                    Display="Dynamic">
                                </asp:RequiredFieldValidator>
                            </div>

                            <!-- BASE PRICE -->
                            <div class="col-md-2">
                                <asp:Label
                                    ID="lblBasePrice"
                                    runat="server"
                                    AssociatedControlID="txtBasePrice"
                                    CssClass="form-label"
                                    Text="Base price (₱)">
                                </asp:Label>

                                <div class="input-group">
                                    <span class="input-group-text">₱</span>
                                    <asp:TextBox
                                        ID="txtBasePrice"
                                        runat="server"
                                        CssClass="form-control"
                                        TextMode="Number"
                                        step="0.01"
                                        min="0"
                                        placeholder="0.00">
                                    </asp:TextBox>
                                </div>

                                <asp:RequiredFieldValidator
                                    ID="requiredBasePrice"
                                    runat="server"
                                    ControlToValidate="txtBasePrice"
                                    ValidationGroup="BundleForm"
                                    ErrorMessage="Base price is required."
                                    CssClass="text-danger small"
                                    Display="Dynamic">
                                </asp:RequiredFieldValidator>

                                <asp:RangeValidator
                                    ID="rangeBasePrice"
                                    runat="server"
                                    ControlToValidate="txtBasePrice"
                                    ValidationGroup="BundleForm"
                                    Type="Double"
                                    MinimumValue="0"
                                    MaximumValue="99999999.99"
                                    ErrorMessage="Price must be 0 or greater."
                                    CssClass="text-danger small"
                                    Display="Dynamic">
                                </asp:RangeValidator>
                            </div>

                            <!-- IMAGE UPLOAD -->
                            <div class="col-md-3">
                                <asp:Label
                                    ID="lblBundleImage"
                                    runat="server"
                                    AssociatedControlID="uploadBundleImage"
                                    CssClass="form-label"
                                    Text="Bundle image">
                                </asp:Label>

                                <asp:FileUpload
                                    ID="uploadBundleImage"
                                    runat="server"
                                    CssClass="form-control"
                                    accept=".jpg,.jpeg,.png,.webp" />
                                <small class="text-muted">Optional. Max 3 MB.</small>
                            </div>

                            <!-- DISPLAY ORDER -->
                            <div class="col-md-1">
                                <asp:Label
                                    ID="lblBundleDisplayOrder"
                                    runat="server"
                                    AssociatedControlID="txtBundleDisplayOrder"
                                    CssClass="form-label"
                                    Text="Order">
                                </asp:Label>

                                <asp:TextBox
                                    ID="txtBundleDisplayOrder"
                                    runat="server"
                                    CssClass="form-control"
                                    TextMode="Number"
                                    Text="0">
                                </asp:TextBox>
                            </div>

                            <!-- STATUS -->
                            <div class="col-md-1">
                                <label class="form-label d-block">Status</label>
                                <div class="form-check mt-2">
                                    <asp:CheckBox
                                        ID="chkBundleIsAvailable"
                                        runat="server"
                                        Checked="true"
                                        CssClass="form-check-input" />
                                    <label class="form-check-label small" for="<%= chkBundleIsAvailable.ClientID %>">Active</label>
                                </div>
                            </div>

                            <!-- SUBMIT BUTTON -->
                            <div class="col-md-2">
                                <asp:Button
                                    ID="btnAddBundle"
                                    runat="server"
                                    Text="+ Add Bundle"
                                    CssClass="btn btn-primary w-100"
                                    ValidationGroup="BundleForm"
                                    OnClick="btnAddBundle_Click" />
                            </div>

                        </div>

                    </div>
                </div>

                <!-- BUNDLE CARDS SECTION -->
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">Configured Bundles & Meal Slots</h4>
                    <asp:Label ID="lblBundleStats" runat="server" CssClass="text-muted small"></asp:Label>
                </div>

                <div class="row g-4">
                    <asp:Repeater ID="rptBundleCards" runat="server">
                        <ItemTemplate>
                            <div class="col-12 col-xl-6">
                                <div class="card shadow-sm h-100 border-1">

                                    <!-- CARD HEADER -->
                                    <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                                        <div class="d-flex align-items-center gap-3">
                                            <%# !string.IsNullOrWhiteSpace(Convert.ToString(Eval("ImagePath"))) 
                                                ? "<img src='" + ResolveUrl(Convert.ToString(Eval("ImagePath"))) + "' class='rounded' style='width: 48px; height: 48px; object-fit: cover;' alt='Bundle' />" 
                                                : "<div class='bg-light text-muted d-flex align-items-center justify-content-center rounded' style='width: 48px; height: 48px;'><i class='bi bi-gift'></i></div>" %>
                                            <div>
                                                <h5 class="mb-0 text-dark fw-bold"><%# Eval("BundleName") %></h5>
                                                <small class="text-muted">
                                                    Base: <strong class="text-primary">₱<%# string.Format("{0:N2}", Eval("BasePrice")) %></strong> &bull; 
                                                    ID: #<%# Eval("BundleID") %> &bull; Order: <%# Eval("DisplayOrder") %>
                                                </small>
                                            </div>
                                        </div>
                                        <div class="d-flex align-items-center gap-2">
                                            <span class='badge <%# (bool)Eval("IsAvailable") ? "bg-success" : "bg-secondary" %>'>
                                                <%# (bool)Eval("IsAvailable") ? "Active" : "Hidden" %>
                                            </span>
                                            <button
                                                type="button"
                                                class="btn btn-sm btn-outline-primary"
                                                data-bs-toggle="modal"
                                                data-bs-target="#addSlotModal"
                                                onclick='openAddSlotModal(<%# Eval("BundleID") %>, "<%# HttpUtility.JavaScriptStringEncode(Eval("BundleName").ToString()) %>");'>
                                                <i class="bi bi-plus"></i> Add Slot
                                            </button>
                                        </div>
                                    </div>

                                    <!-- CARD BODY: NESTED SLOTS TABLE -->
                                    <div class="card-body p-0">
                                        <%# ((System.Collections.Generic.List<PortableKiosk.Core.Models.BundleSlot>)Eval("Slots")).Count == 0 
                                            ? "<div class='p-4 text-center text-muted bg-light-subtle small'><i class='bi bi-info-circle me-1'></i> No meal slots configured yet. Click '+ Add Slot' to assign items (e.g. Main dish, Drink option).</div>" 
                                            : "" %>

                                        <asp:Repeater ID="rptInnerSlots" runat="server" DataSource='<%# Eval("Slots") %>'>
                                            <HeaderTemplate>
                                                <div class="table-responsive">
                                                    <table class="table table-hover align-middle mb-0 small">
                                                        <thead class="table-light">
                                                            <tr>
                                                                <th>Slot Name</th>
                                                                <th>Configuration / Content</th>
                                                                <th>Qty</th>
                                                                <th>Required</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <tr>
                                                    <td class="fw-bold"><%# Eval("SlotName") %></td>
                                                    <td>
                                                        <span class='badge <%# string.Equals(Convert.ToString(Eval("SlotType")), "Fixed product", StringComparison.OrdinalIgnoreCase) ? "bg-secondary-subtle text-secondary" : "bg-info-subtle text-info-emphasis" %> me-1'>
                                                            <%# Eval("SlotType") %>
                                                        </span>
                                                        <strong><%# Eval("ConfigurationDescription") %></strong>
                                                    </td>
                                                    <td><%# Eval("Quantity") %>x</td>
                                                    <td>
                                                        <span class='badge <%# (bool)Eval("IsRequired") ? "bg-primary" : "bg-light text-muted border" %>'>
                                                            <%# (bool)Eval("IsRequired") ? "Mandatory" : "Optional" %>
                                                        </span>
                                                    </td>
                                                </tr>
                                            </ItemTemplate>
                                            <FooterTemplate>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </FooterTemplate>
                                        </asp:Repeater>
                                    </div>

                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <asp:Panel ID="pnlNoBundles" runat="server" Visible="false" CssClass="card shadow-sm p-5 text-center text-muted mt-3">
                    <h5>No meal bundles created yet.</h5>
                    <p class="mb-0">Use the form above to add your first bundle package.</p>
                </asp:Panel>

            </div>

            <!-- =========================================================
                 TAB B: REUSABLE OPTION GROUPS & ADD-ON POOLS
                 ========================================================= -->
            <div class="tab-pane fade" id="tab-option-groups" role="tabpanel" aria-labelledby="tab-option-groups-btn">

                <!-- ADD OPTION GROUP TOP CARD -->
                <div class="card shadow-sm mb-4 border-0">
                    <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
                        <strong><i class="bi bi-plus-circle-fill me-1"></i> Add Reusable Option Group</strong>
                        <span class="badge bg-light text-dark">Choice Pool</span>
                    </div>

                    <div class="card-body bg-light">

                        <asp:ValidationSummary
                            ID="validationSummaryOptionGroup"
                            runat="server"
                            ValidationGroup="OptionGroupForm"
                            CssClass="alert alert-danger"
                            HeaderText="Please correct the following:"
                            DisplayMode="BulletList" />

                        <div class="row g-3 align-items-end">

                            <!-- GROUP NAME -->
                            <div class="col-md-6">
                                <asp:Label
                                    ID="lblOptionGroupName"
                                    runat="server"
                                    AssociatedControlID="txtOptionGroupName"
                                    CssClass="form-label"
                                    Text="Option group name">
                                </asp:Label>

                                <asp:TextBox
                                    ID="txtOptionGroupName"
                                    runat="server"
                                    CssClass="form-control"
                                    MaxLength="100"
                                    placeholder="e.g. Standard Drinks, Premium Sides, Dip Sauces">
                                </asp:TextBox>

                                <asp:RequiredFieldValidator
                                    ID="requiredOptionGroupName"
                                    runat="server"
                                    ControlToValidate="txtOptionGroupName"
                                    ValidationGroup="OptionGroupForm"
                                    ErrorMessage="Option group name is required."
                                    CssClass="text-danger small"
                                    Display="Dynamic">
                                </asp:RequiredFieldValidator>
                            </div>

                            <!-- DISPLAY ORDER -->
                            <div class="col-md-2">
                                <asp:Label
                                    ID="lblOptionGroupDisplayOrder"
                                    runat="server"
                                    AssociatedControlID="txtOptionGroupDisplayOrder"
                                    CssClass="form-label"
                                    Text="Order">
                                </asp:Label>

                                <asp:TextBox
                                    ID="txtOptionGroupDisplayOrder"
                                    runat="server"
                                    CssClass="form-control"
                                    TextMode="Number"
                                    Text="0">
                                </asp:TextBox>
                            </div>

                            <!-- STATUS -->
                            <div class="col-md-2">
                                <label class="form-label d-block">Status</label>
                                <div class="form-check mt-2">
                                    <asp:CheckBox
                                        ID="chkOptionGroupIsAvailable"
                                        runat="server"
                                        Checked="true"
                                        CssClass="form-check-input" />
                                    <label class="form-check-label small" for="<%= chkOptionGroupIsAvailable.ClientID %>">Active</label>
                                </div>
                            </div>

                            <!-- BUTTON -->
                            <div class="col-md-2">
                                <asp:Button
                                    ID="btnAddOptionGroup"
                                    runat="server"
                                    Text="+ Add Group"
                                    CssClass="btn btn-dark w-100"
                                    ValidationGroup="OptionGroupForm"
                                    OnClick="btnAddOptionGroup_Click" />
                            </div>

                        </div>

                    </div>
                </div>

                <!-- OPTION GROUPS CARDS SECTION -->
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">Reusable Option Pools & Choice Items</h4>
                    <asp:Label ID="lblOptionGroupStats" runat="server" CssClass="text-muted small"></asp:Label>
                </div>

                <div class="row g-4">
                    <asp:Repeater ID="rptOptionGroupCards" runat="server">
                        <ItemTemplate>
                            <div class="col-12 col-xl-6">
                                <div class="card shadow-sm h-100 border-1">

                                    <!-- CARD HEADER -->
                                    <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                                        <div>
                                            <h5 class="mb-0 text-dark fw-bold"><%# Eval("OptionGroupName") %></h5>
                                            <small class="text-muted">ID: #<%# Eval("OptionGroupID") %> &bull; Order: <%# Eval("DisplayOrder") %></small>
                                        </div>
                                        <div class="d-flex align-items-center gap-2">
                                            <span class='badge <%# (bool)Eval("IsAvailable") ? "bg-success" : "bg-secondary" %>'>
                                                <%# (bool)Eval("IsAvailable") ? "Active" : "Hidden" %>
                                            </span>
                                            <button
                                                type="button"
                                                class="btn btn-sm btn-outline-dark"
                                                data-bs-toggle="modal"
                                                data-bs-target="#addGroupItemModal"
                                                onclick='openAddGroupItemModal(<%# Eval("OptionGroupID") %>, "<%# HttpUtility.JavaScriptStringEncode(Eval("OptionGroupName").ToString()) %>");'>
                                                <i class="bi bi-plus"></i> Add Choice Item
                                            </button>
                                        </div>
                                    </div>

                                    <!-- CARD BODY: NESTED GROUP ITEMS TABLE -->
                                    <div class="card-body p-0">
                                        <%# ((System.Collections.Generic.List<PortableKiosk.Core.Models.BundleOptionGroupItem>)Eval("Items")).Count == 0 
                                            ? "<div class='p-4 text-center text-muted bg-light-subtle small'><i class='bi bi-info-circle me-1'></i> No choice items added yet. Click '+ Add Choice Item' to add drinks, sides, or upgrades to this pool.</div>" 
                                            : "" %>

                                        <asp:Repeater ID="rptInnerGroupItems" runat="server" DataSource='<%# Eval("Items") %>'>
                                            <HeaderTemplate>
                                                <div class="table-responsive">
                                                    <table class="table table-hover align-middle mb-0 small">
                                                        <thead class="table-light">
                                                            <tr>
                                                                <th>Product Variant</th>
                                                                <th>Standalone</th>
                                                                <th>Upgrade Price</th>
                                                                <th>Status</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <tr>
                                                    <td class="fw-semibold">
                                                        <%# Eval("ProductName") %> <span class="badge bg-light text-dark border"><%# Eval("SizeName") %></span>
                                                    </td>
                                                    <td class="text-muted">₱<%# string.Format("{0:N2}", Eval("ProductVariantPrice")) %></td>
                                                    <td class="fw-bold text-success">
                                                        <%# (decimal)Eval("AdditionalPrice") == 0 
                                                            ? "<span class='badge bg-success-subtle text-success'>Included (+₱0.00)</span>" 
                                                            : "+₱" + string.Format("{0:N2}", Eval("AdditionalPrice")) %>
                                                    </td>
                                                    <td>
                                                        <span class='badge <%# (bool)Eval("IsAvailable") ? "bg-success-subtle text-success" : "bg-secondary-subtle text-secondary" %>'>
                                                            <%# (bool)Eval("IsAvailable") ? "Available" : "Unavailable" %>
                                                        </span>
                                                    </td>
                                                </tr>
                                            </ItemTemplate>
                                            <FooterTemplate>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </FooterTemplate>
                                        </asp:Repeater>
                                    </div>

                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <asp:Panel ID="pnlNoOptionGroups" runat="server" Visible="false" CssClass="card shadow-sm p-5 text-center text-muted mt-3">
                    <h5>No option groups created yet.</h5>
                    <p class="mb-0">Use the form above to add your first reusable choice group (e.g. Standard Drinks).</p>
                </asp:Panel>

            </div>

        </div>

    </div>

    <!-- =========================================================
         MODAL 1: ADD BUNDLE SLOT
         ========================================================= -->
    <div class="modal fade" id="addSlotModal" tabindex="-1" aria-labelledby="addSlotModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">

                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="addSlotModalLabel">
                        <i class="bi bi-plus-square-fill me-1"></i> Add Bundle Slot
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">

                    <asp:ValidationSummary
                        ID="validationSummarySlot"
                        runat="server"
                        ValidationGroup="SlotModalForm"
                        CssClass="alert alert-danger"
                        HeaderText="Please correct the following errors:"
                        DisplayMode="BulletList" />

                    <!-- TARGET BUNDLE INFO -->
                    <div class="mb-3">
                        <label class="form-label text-muted small">Target Bundle</label>
                        <div id="modalDisplayBundleName" class="form-control bg-light fw-bold text-primary"></div>
                        <asp:HiddenField ID="hfModalSlotBundleID" runat="server" />
                    </div>

                    <!-- SLOT NAME -->
                    <div class="mb-3">
                        <asp:Label
                            ID="lblModalSlotName"
                            runat="server"
                            AssociatedControlID="txtModalSlotName"
                            CssClass="form-label"
                            Text="Slot Name">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtModalSlotName"
                            runat="server"
                            CssClass="form-control"
                            MaxLength="100"
                            placeholder="e.g. Main Course, Drink Choice, Side Item">
                        </asp:TextBox>

                        <asp:RequiredFieldValidator
                            ID="requiredModalSlotName"
                            runat="server"
                            ControlToValidate="txtModalSlotName"
                            ValidationGroup="SlotModalForm"
                            ErrorMessage="Slot name is required."
                            CssClass="text-danger small"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- SLOT TYPE -->
                    <div class="mb-3">
                        <asp:Label
                            ID="lblModalSlotType"
                            runat="server"
                            AssociatedControlID="ddlModalSlotType"
                            CssClass="form-label"
                            Text="Slot Content Type">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlModalSlotType"
                            runat="server"
                            CssClass="form-select">
                            <asp:ListItem Value="FIXED" Text="Fixed Product Variant (e.g. Always Cheeseburger)"></asp:ListItem>
                            <asp:ListItem Value="OPTION_GROUP" Text="Option Choice Pool (e.g. Customer chooses from Standard Drinks)"></asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <!-- FIXED VARIANT SELECTOR -->
                    <div id="slotFixedVariantGroup" class="mb-3">
                        <asp:Label
                            ID="lblModalFixedVariant"
                            runat="server"
                            AssociatedControlID="ddlModalFixedVariant"
                            CssClass="form-label"
                            Text="Select Fixed Product Variant">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlModalFixedVariant"
                            runat="server"
                            CssClass="form-select">
                        </asp:DropDownList>
                    </div>

                    <!-- OPTION GROUP SELECTOR -->
                    <div id="slotOptionGroupGroup" class="mb-3" style="display: none;">
                        <asp:Label
                            ID="lblModalOptionGroup"
                            runat="server"
                            AssociatedControlID="ddlModalOptionGroup"
                            CssClass="form-label"
                            Text="Select Option Group">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlModalOptionGroup"
                            runat="server"
                            CssClass="form-select">
                        </asp:DropDownList>
                    </div>

                    <div class="row g-2 mb-3">
                        <!-- QUANTITY -->
                        <div class="col-6">
                            <asp:Label
                                ID="lblModalSlotQuantity"
                                runat="server"
                                AssociatedControlID="txtModalSlotQuantity"
                                CssClass="form-label"
                                Text="Quantity">
                            </asp:Label>

                            <asp:TextBox
                                ID="txtModalSlotQuantity"
                                runat="server"
                                CssClass="form-control"
                                TextMode="Number"
                                Text="1">
                            </asp:TextBox>
                        </div>

                        <!-- DISPLAY ORDER -->
                        <div class="col-6">
                            <asp:Label
                                ID="lblModalSlotDisplayOrder"
                                runat="server"
                                AssociatedControlID="txtModalSlotDisplayOrder"
                                CssClass="form-label"
                                Text="Display Order">
                            </asp:Label>

                            <asp:TextBox
                                ID="txtModalSlotDisplayOrder"
                                runat="server"
                                CssClass="form-control"
                                TextMode="Number"
                                Text="0">
                            </asp:TextBox>
                        </div>
                    </div>

                    <!-- REQUIRED TOGGLE -->
                    <div class="mb-3">
                        <div class="form-check">
                            <asp:CheckBox
                                ID="chkModalSlotIsRequired"
                                runat="server"
                                Checked="true"
                                CssClass="form-check-input" />
                            <label class="form-check-label" for="<%= chkModalSlotIsRequired.ClientID %>">Required slot (Customer must select item)</label>
                        </div>
                    </div>

                </div>

                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button
                        ID="btnSaveSlot"
                        runat="server"
                        Text="Save Slot"
                        CssClass="btn btn-primary"
                        ValidationGroup="SlotModalForm"
                        OnClick="btnSaveSlot_Click" />
                </div>

            </div>
        </div>
    </div>

    <!-- =========================================================
         MODAL 2: ADD OPTION GROUP CHOICE ITEM
         ========================================================= -->
    <div class="modal fade" id="addGroupItemModal" tabindex="-1" aria-labelledby="addGroupItemModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">

                <div class="modal-header bg-dark text-white">
                    <h5 class="modal-title" id="addGroupItemModalLabel">
                        <i class="bi bi-plus-square-fill me-1"></i> Add Choice Item to Group
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">

                    <asp:ValidationSummary
                        ID="validationSummaryGroupItem"
                        runat="server"
                        ValidationGroup="GroupItemModalForm"
                        CssClass="alert alert-danger"
                        HeaderText="Please correct the following errors:"
                        DisplayMode="BulletList" />

                    <!-- TARGET GROUP INFO -->
                    <div class="mb-3">
                        <label class="form-label text-muted small">Target Option Group</label>
                        <div id="modalDisplayOptionGroupName" class="form-control bg-light fw-bold text-dark"></div>
                        <asp:HiddenField ID="hfModalOptionGroupID" runat="server" />
                    </div>

                    <!-- PRODUCT VARIANT -->
                    <div class="mb-3">
                        <asp:Label
                            ID="lblModalGroupItemVariant"
                            runat="server"
                            AssociatedControlID="ddlModalGroupItemVariant"
                            CssClass="form-label"
                            Text="Select Product Variant">
                        </asp:Label>

                        <asp:DropDownList
                            ID="ddlModalGroupItemVariant"
                            runat="server"
                            CssClass="form-select">
                        </asp:DropDownList>

                        <asp:RequiredFieldValidator
                            ID="requiredModalGroupItemVariant"
                            runat="server"
                            ControlToValidate="ddlModalGroupItemVariant"
                            InitialValue=""
                            ValidationGroup="GroupItemModalForm"
                            ErrorMessage="Product variant is required."
                            CssClass="text-danger small"
                            Display="Dynamic">
                        </asp:RequiredFieldValidator>
                    </div>

                    <!-- UPGRADE / ADDITIONAL PRICE -->
                    <div class="mb-3">
                        <asp:Label
                            ID="lblModalGroupItemAddPrice"
                            runat="server"
                            AssociatedControlID="txtModalGroupItemAddPrice"
                            CssClass="form-label"
                            Text="Upgrade / Additional Price (₱)">
                        </asp:Label>

                        <div class="input-group">
                            <span class="input-group-text">+₱</span>
                            <asp:TextBox
                                ID="txtModalGroupItemAddPrice"
                                runat="server"
                                CssClass="form-control"
                                TextMode="Number"
                                step="0.01"
                                min="0"
                                Text="0.00">
                            </asp:TextBox>
                        </div>
                        <small class="text-muted">Set to 0.00 if included for free in the bundle base price.</small>
                    </div>

                    <!-- DISPLAY ORDER -->
                    <div class="mb-3">
                        <asp:Label
                            ID="lblModalGroupItemDisplayOrder"
                            runat="server"
                            AssociatedControlID="txtModalGroupItemDisplayOrder"
                            CssClass="form-label"
                            Text="Display Order">
                        </asp:Label>

                        <asp:TextBox
                            ID="txtModalGroupItemDisplayOrder"
                            runat="server"
                            CssClass="form-control"
                            TextMode="Number"
                            Text="0">
                        </asp:TextBox>
                    </div>

                    <!-- STATUS -->
                    <div class="mb-3">
                        <div class="form-check">
                            <asp:CheckBox
                                ID="chkModalGroupItemIsAvailable"
                                runat="server"
                                Checked="true"
                                CssClass="form-check-input" />
                            <label class="form-check-label" for="<%= chkModalGroupItemIsAvailable.ClientID %>">Available in this group</label>
                        </div>
                    </div>

                </div>

                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button
                        ID="btnSaveGroupItem"
                        runat="server"
                        Text="Save Choice Item"
                        CssClass="btn btn-dark"
                        ValidationGroup="GroupItemModalForm"
                        OnClick="btnSaveGroupItem_Click" />
                </div>

            </div>
        </div>
    </div>

    <!-- EXTERNAL SCRIPT -->
    <script src="<%= ResolveUrl("~/Scripts/app/admin/bundles.js") %>"></script>

</asp:Content>