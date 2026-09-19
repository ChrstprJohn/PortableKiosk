using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.UI.Admin
{
    public partial class BundleManagement : Page
    {
        public class BundleCardViewModel
        {
            public int BundleID { get; set; }
            public string BundleName { get; set; }
            public decimal BasePrice { get; set; }
            public string ImagePath { get; set; }
            public bool IsAvailable { get; set; }
            public int DisplayOrder { get; set; }
            public List<BundleSlot> Slots { get; set; }

            public BundleCardViewModel()
            {
                Slots = new List<BundleSlot>();
            }
        }

        public class OptionGroupCardViewModel
        {
            public int OptionGroupID { get; set; }
            public string OptionGroupName { get; set; }
            public bool IsAvailable { get; set; }
            public int DisplayOrder { get; set; }
            public List<BundleOptionGroupItem> Items { get; set; }

            public OptionGroupCardViewModel()
            {
                Items = new List<BundleOptionGroupItem>();
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StaffAccountID"] == null)
            {
                Response.Redirect("~/UI/Account/AdminLogin.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!string.Equals(
                Convert.ToString(Session["StaffRole"]),
                "ADMIN",
                StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/UI/POS/Index.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadAllData();
            }
        }

        private void LoadAllData()
        {
            LoadBundles();
            LoadOptionGroups();
            LoadDropdowns();
        }

        #region Tab A: Bundles & Slots

        protected void btnAddBundle_Click(object sender, EventArgs e)
        {
            lblGlobalMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            decimal basePrice;
            if (!decimal.TryParse(txtBasePrice.Text.Trim(), out basePrice) || basePrice < 0)
            {
                ShowError("Base price must be a valid non-negative number.");
                return;
            }

            int displayOrder;
            if (!int.TryParse(txtBundleDisplayOrder.Text.Trim(), out displayOrder))
            {
                ShowError("Display order must be a valid integer.");
                return;
            }

            string imagePath;
            string savedPhysicalPath;
            string uploadError;

            if (!TrySaveBundleImage(out imagePath, out savedPhysicalPath, out uploadError))
            {
                ShowError(uploadError);
                return;
            }

            Bundle bundle = new Bundle
            {
                BundleName = txtBundleName.Text.Trim(),
                BasePrice = basePrice,
                ImagePath = imagePath,
                IsAvailable = chkBundleIsAvailable.Checked,
                DisplayOrder = displayOrder
            };

            try
            {
                BundleRepository repository = new BundleRepository();
                int bundleID = repository.Add(bundle);

                ShowSuccess("Bundle \"" + bundle.BundleName + "\" created successfully (ID: " + bundleID + "). You can now configure meal slots!");
                ClearBundleForm();
                LoadBundles();
            }
            catch (SqlException ex)
            {
                DeleteSavedImage(savedPhysicalPath);
                ShowError(ex.Message);
            }
            catch (ArgumentException ex)
            {
                DeleteSavedImage(savedPhysicalPath);
                ShowError(ex.Message);
            }
            catch (Exception)
            {
                DeleteSavedImage(savedPhysicalPath);
                ShowError("An unexpected error occurred while saving the bundle.");
            }
        }

        protected void btnSaveSlot_Click(object sender, EventArgs e)
        {
            lblGlobalMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            int bundleID;
            if (!int.TryParse(hfModalSlotBundleID.Value, out bundleID) || bundleID <= 0)
            {
                ShowError("Please select a valid bundle.");
                return;
            }

            int quantity;
            if (!int.TryParse(txtModalSlotQuantity.Text.Trim(), out quantity) || quantity <= 0)
            {
                ShowError("Slot quantity must be at least 1.");
                return;
            }

            int displayOrder;
            if (!int.TryParse(txtModalSlotDisplayOrder.Text.Trim(), out displayOrder))
            {
                displayOrder = 0;
            }

            bool isFixed = string.Equals(ddlModalSlotType.SelectedValue, "FIXED", StringComparison.OrdinalIgnoreCase);

            int? fixedVariantID = null;
            int? optionGroupID = null;

            if (isFixed)
            {
                int parsedVariantID;
                if (!int.TryParse(ddlModalFixedVariant.SelectedValue, out parsedVariantID) || parsedVariantID <= 0)
                {
                    ShowError("Please select a fixed product variant for this slot.");
                    return;
                }
                fixedVariantID = parsedVariantID;
            }
            else
            {
                int parsedGroupID;
                if (!int.TryParse(ddlModalOptionGroup.SelectedValue, out parsedGroupID) || parsedGroupID <= 0)
                {
                    ShowError("Please select an option choice pool for this slot.");
                    return;
                }
                optionGroupID = parsedGroupID;
            }

            BundleSlot slot = new BundleSlot
            {
                BundleID = bundleID,
                SlotName = txtModalSlotName.Text.Trim(),
                FixedProductVariantID = fixedVariantID,
                OptionGroupID = optionGroupID,
                Quantity = quantity,
                IsRequired = chkModalSlotIsRequired.Checked,
                DisplayOrder = displayOrder
            };

            try
            {
                BundleSlotRepository slotRepository = new BundleSlotRepository();
                int slotID = slotRepository.Add(slot);

                ShowSuccess("Slot \"" + slot.SlotName + "\" added successfully to Bundle #" + bundleID + ".");
                ClearSlotModal();
                LoadBundles();
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        private void LoadBundles()
        {
            try
            {
                BundleRepository bundleRepo = new BundleRepository();
                BundleSlotRepository slotRepo = new BundleSlotRepository();

                List<Bundle> bundles = bundleRepo.GetAll();
                List<BundleSlot> slots = slotRepo.GetAll();

                Dictionary<int, List<BundleSlot>> slotsByBundle = new Dictionary<int, List<BundleSlot>>();
                foreach (BundleSlot s in slots)
                {
                    if (!slotsByBundle.ContainsKey(s.BundleID))
                    {
                        slotsByBundle[s.BundleID] = new List<BundleSlot>();
                    }
                    slotsByBundle[s.BundleID].Add(s);
                }

                List<BundleCardViewModel> cards = new List<BundleCardViewModel>();
                foreach (Bundle b in bundles)
                {
                    BundleCardViewModel vm = new BundleCardViewModel
                    {
                        BundleID = b.BundleID,
                        BundleName = b.BundleName,
                        BasePrice = b.BasePrice,
                        ImagePath = b.ImagePath,
                        IsAvailable = b.IsAvailable,
                        DisplayOrder = b.DisplayOrder
                    };

                    if (slotsByBundle.ContainsKey(b.BundleID))
                    {
                        vm.Slots = slotsByBundle[b.BundleID];
                    }

                    cards.Add(vm);
                }

                rptBundleCards.DataSource = cards;
                rptBundleCards.DataBind();

                pnlNoBundles.Visible = cards.Count == 0;
                lblBundleStats.Text = bundles.Count + " Bundles &bull; " + slots.Count + " Total Slots Configured";
            }
            catch (Exception ex)
            {
                rptBundleCards.DataSource = null;
                rptBundleCards.DataBind();
                ShowError("Failed to load bundles and meal slots: " + ex.Message);
            }
        }

        private void ClearBundleForm()
        {
            txtBundleName.Text = string.Empty;
            txtBasePrice.Text = string.Empty;
            txtBundleDisplayOrder.Text = "0";
            chkBundleIsAvailable.Checked = true;
        }

        private void ClearSlotModal()
        {
            hfModalSlotBundleID.Value = string.Empty;
            txtModalSlotName.Text = string.Empty;
            ddlModalSlotType.SelectedIndex = 0;
            txtModalSlotQuantity.Text = "1";
            txtModalSlotDisplayOrder.Text = "0";
            chkModalSlotIsRequired.Checked = true;
        }

        #endregion

        #region Tab B: Option Groups & Choice Items

        protected void btnAddOptionGroup_Click(object sender, EventArgs e)
        {
            lblGlobalMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            int displayOrder;
            if (!int.TryParse(txtOptionGroupDisplayOrder.Text.Trim(), out displayOrder))
            {
                displayOrder = 0;
            }

            BundleOptionGroup group = new BundleOptionGroup
            {
                OptionGroupName = txtOptionGroupName.Text.Trim(),
                IsAvailable = chkOptionGroupIsAvailable.Checked,
                DisplayOrder = displayOrder
            };

            try
            {
                BundleOptionGroupRepository repo = new BundleOptionGroupRepository();
                int groupID = repo.Add(group);

                ShowSuccess("Option Group \"" + group.OptionGroupName + "\" created successfully (ID: " + groupID + "). You can now add drinks/sides to it!");
                ClearOptionGroupForm();
                LoadOptionGroups();
                LoadDropdowns(); // refresh dropdown for slot builder
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowError("An option group with this name already exists.");
                }
                else
                {
                    ShowError(ex.Message);
                }
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        protected void btnSaveGroupItem_Click(object sender, EventArgs e)
        {
            lblGlobalMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            int optionGroupID;
            if (!int.TryParse(hfModalOptionGroupID.Value, out optionGroupID) || optionGroupID <= 0)
            {
                ShowError("Please select a valid option group.");
                return;
            }

            int variantID;
            if (!int.TryParse(ddlModalGroupItemVariant.SelectedValue, out variantID) || variantID <= 0)
            {
                ShowError("Please select a valid product variant.");
                return;
            }

            decimal additionalPrice;
            if (!decimal.TryParse(txtModalGroupItemAddPrice.Text.Trim(), out additionalPrice) || additionalPrice < 0)
            {
                ShowError("Additional price must be a non-negative number.");
                return;
            }

            int displayOrder;
            if (!int.TryParse(txtModalGroupItemDisplayOrder.Text.Trim(), out displayOrder))
            {
                displayOrder = 0;
            }

            BundleOptionGroupItem item = new BundleOptionGroupItem
            {
                OptionGroupID = optionGroupID,
                ProductVariantID = variantID,
                AdditionalPrice = additionalPrice,
                IsAvailable = chkModalGroupItemIsAvailable.Checked,
                DisplayOrder = displayOrder
            };

            try
            {
                BundleOptionGroupItemRepository repo = new BundleOptionGroupItemRepository();
                repo.Add(item);

                ShowSuccess("Item added to Option Group #" + optionGroupID + " successfully.");
                ClearGroupItemModal();
                LoadOptionGroups();
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2601 || ex.Number == 2627)
                {
                    ShowError("This product variant is already in this option group.");
                }
                else
                {
                    ShowError(ex.Message);
                }
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        private void LoadOptionGroups()
        {
            try
            {
                BundleOptionGroupRepository groupRepo = new BundleOptionGroupRepository();
                BundleOptionGroupItemRepository itemRepo = new BundleOptionGroupItemRepository();

                List<BundleOptionGroup> groups = groupRepo.GetAll();
                List<BundleOptionGroupItem> items = itemRepo.GetAll();

                Dictionary<int, List<BundleOptionGroupItem>> itemsByGroup = new Dictionary<int, List<BundleOptionGroupItem>>();
                foreach (BundleOptionGroupItem item in items)
                {
                    if (!itemsByGroup.ContainsKey(item.OptionGroupID))
                    {
                        itemsByGroup[item.OptionGroupID] = new List<BundleOptionGroupItem>();
                    }
                    itemsByGroup[item.OptionGroupID].Add(item);
                }

                List<OptionGroupCardViewModel> cards = new List<OptionGroupCardViewModel>();
                foreach (BundleOptionGroup g in groups)
                {
                    OptionGroupCardViewModel vm = new OptionGroupCardViewModel
                    {
                        OptionGroupID = g.OptionGroupID,
                        OptionGroupName = g.OptionGroupName,
                        IsAvailable = g.IsAvailable,
                        DisplayOrder = g.DisplayOrder
                    };

                    if (itemsByGroup.ContainsKey(g.OptionGroupID))
                    {
                        vm.Items = itemsByGroup[g.OptionGroupID];
                    }

                    cards.Add(vm);
                }

                rptOptionGroupCards.DataSource = cards;
                rptOptionGroupCards.DataBind();

                pnlNoOptionGroups.Visible = cards.Count == 0;
                lblOptionGroupStats.Text = groups.Count + " Option Groups &bull; " + items.Count + " Total Choices Available";
            }
            catch (Exception ex)
            {
                rptOptionGroupCards.DataSource = null;
                rptOptionGroupCards.DataBind();
                ShowError("Failed to load option groups: " + ex.Message);
            }
        }

        private void ClearOptionGroupForm()
        {
            txtOptionGroupName.Text = string.Empty;
            txtOptionGroupDisplayOrder.Text = "0";
            chkOptionGroupIsAvailable.Checked = true;
        }

        private void ClearGroupItemModal()
        {
            hfModalOptionGroupID.Value = string.Empty;
            ddlModalGroupItemVariant.SelectedIndex = 0;
            txtModalGroupItemAddPrice.Text = "0.00";
            txtModalGroupItemDisplayOrder.Text = "0";
            chkModalGroupItemIsAvailable.Checked = true;
        }

        #endregion

        #region Dropdowns & Shared Helpers

        private void LoadDropdowns()
        {
            try
            {
                ProductVariantRepository variantRepo = new ProductVariantRepository();
                BundleOptionGroupRepository groupRepo = new BundleOptionGroupRepository();

                List<ProductVariant> variants = variantRepo.GetAll();
                List<BundleOptionGroup> groups = groupRepo.GetAll();

                // Fixed Variant Dropdown
                ddlModalFixedVariant.Items.Clear();
                ddlModalFixedVariant.Items.Add(new ListItem("-- Select Product Variant --", ""));

                // Group Item Variant Dropdown
                ddlModalGroupItemVariant.Items.Clear();
                ddlModalGroupItemVariant.Items.Add(new ListItem("-- Select Product Variant --", ""));

                foreach (ProductVariant v in variants)
                {
                    string label = v.CategoryName + " - " + v.ProductName + " (" + v.SizeName + ") - ₱" + v.Price.ToString("N2");
                    ddlModalFixedVariant.Items.Add(new ListItem(label, v.ProductVariantID.ToString()));
                    ddlModalGroupItemVariant.Items.Add(new ListItem(label, v.ProductVariantID.ToString()));
                }

                // Option Group Dropdown
                ddlModalOptionGroup.Items.Clear();
                ddlModalOptionGroup.Items.Add(new ListItem("-- Select Option Choice Pool --", ""));
                foreach (BundleOptionGroup g in groups)
                {
                    ddlModalOptionGroup.Items.Add(new ListItem(g.OptionGroupName, g.OptionGroupID.ToString()));
                }
            }
            catch (Exception)
            {
                ShowError("Failed to load product variants or option groups for selection.");
            }
        }

        private bool TrySaveBundleImage(out string imagePath, out string savedPhysicalPath, out string errorMessage)
        {
            imagePath = null;
            savedPhysicalPath = null;
            errorMessage = null;

            if (!uploadBundleImage.HasFile)
            {
                return true;
            }

            const int maximumFileSize = 3 * 1024 * 1024;
            if (uploadBundleImage.PostedFile.ContentLength > maximumFileSize)
            {
                errorMessage = "The bundle image cannot exceed 3 MB.";
                return false;
            }

            string extension = Path.GetExtension(uploadBundleImage.FileName).ToLowerInvariant();
            bool allowedExtension = extension == ".jpg" || extension == ".jpeg" || extension == ".png" || extension == ".webp";
            if (!allowedExtension)
            {
                errorMessage = "Only JPG, PNG, and WebP images are allowed.";
                return false;
            }

            string contentType = uploadBundleImage.PostedFile.ContentType;
            bool allowedContentType =
                string.Equals(contentType, "image/jpeg", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(contentType, "image/png", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(contentType, "image/webp", StringComparison.OrdinalIgnoreCase);

            if (!allowedContentType)
            {
                errorMessage = "The uploaded file is not a supported image.";
                return false;
            }

            try
            {
                string virtualFolder = "~/Content/images/bundles/";
                string physicalFolder = Server.MapPath(virtualFolder);

                Directory.CreateDirectory(physicalFolder);

                string fileName = Guid.NewGuid().ToString("N") + extension;
                savedPhysicalPath = Path.Combine(physicalFolder, fileName);

                uploadBundleImage.SaveAs(savedPhysicalPath);
                imagePath = virtualFolder + fileName;

                return true;
            }
            catch (Exception)
            {
                imagePath = null;
                savedPhysicalPath = null;
                errorMessage = "The image could not be uploaded.";
                return false;
            }
        }

        private void DeleteSavedImage(string physicalPath)
        {
            if (string.IsNullOrWhiteSpace(physicalPath))
            {
                return;
            }

            try
            {
                if (File.Exists(physicalPath))
                {
                    File.Delete(physicalPath);
                }
            }
            catch
            {
                // Silent
            }
        }

        private void ShowSuccess(string message)
        {
            lblGlobalMessage.Text = "<i class=\"bi bi-check-circle-fill me-1\"></i> " + message;
            lblGlobalMessage.CssClass = "alert alert-success d-block shadow-sm mb-4";
            lblGlobalMessage.Visible = true;
        }

        private void ShowError(string message)
        {
            lblGlobalMessage.Text = "<i class=\"bi bi-exclamation-triangle-fill me-1\"></i> " + message;
            lblGlobalMessage.CssClass = "alert alert-danger d-block shadow-sm mb-4";
            lblGlobalMessage.Visible = true;
        }

        #endregion
    }
}