using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace PortableKiosk.UI.Admin
{
    public partial class BundleSlotManagement :
        System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (Session["StaffAccountID"] == null)
            {
                Response.Redirect(
                    "~/UI/Account/AdminLogin.aspx",
                    false);

                Context.ApplicationInstance
                    .CompleteRequest();

                return;
            }

            if (!string.Equals(
                Convert.ToString(Session["StaffRole"]),
                "ADMIN",
                StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect(
                    "~/UI/POS/Index.aspx",
                    false);

                Context.ApplicationInstance
                    .CompleteRequest();

                return;
            }

            if (!IsPostBack)
            {
                LoadBundles();
                LoadProductVariants();
                LoadOptionGroups();
                ConfigureSlotTypeControls();
                LoadSlots();
            }
            else
            {
                ConfigureSlotTypeControls();
            }
        }

        protected void ddlSlotType_SelectedIndexChanged(
            object sender,
            EventArgs e)
        {
            lblMessage.Visible = false;
            ConfigureSlotTypeControls();

            if (IsChoiceSlot())
            {
                LoadDefaultChoices();
            }
        }

        protected void ddlOptionGroup_SelectedIndexChanged(
            object sender,
            EventArgs e)
        {
            lblMessage.Visible = false;
            LoadDefaultChoices();
        }

        protected void btnAddSlot_Click(
            object sender,
            EventArgs e)
        {
            lblMessage.Visible = false;
            ConfigureSlotTypeControls();

            if (!Page.IsValid)
            {
                return;
            }

            int bundleID;

            if (!int.TryParse(
                ddlBundle.SelectedValue,
                out bundleID))
            {
                ShowError(
                    "Please select a valid bundle.");
                return;
            }

            int quantity;

            if (!int.TryParse(
                txtQuantity.Text.Trim(),
                out quantity))
            {
                ShowError(
                    "Quantity must be a valid number.");
                return;
            }

            if (quantity <= 0)
            {
                ShowError(
                    "Quantity must be greater than zero.");
                return;
            }

            int displayOrder;

            if (!int.TryParse(
                txtDisplayOrder.Text.Trim(),
                out displayOrder))
            {
                ShowError(
                    "Display order must be a valid number.");
                return;
            }

            int? fixedProductVariantID = null;
            int? optionGroupID = null;
            int? defaultProductVariantID = null;

            if (IsChoiceSlot())
            {
                int parsedOptionGroupID;
                int parsedDefaultProductVariantID;

                if (!int.TryParse(
                    ddlOptionGroup.SelectedValue,
                    out parsedOptionGroupID))
                {
                    ShowError(
                        "Please select a valid option group.");
                    return;
                }

                if (!int.TryParse(
                    ddlDefaultProductVariant.SelectedValue,
                    out parsedDefaultProductVariantID))
                {
                    ShowError(
                        "Please select a valid default choice.");
                    return;
                }

                optionGroupID = parsedOptionGroupID;
                defaultProductVariantID =
                    parsedDefaultProductVariantID;
            }
            else
            {
                int parsedFixedProductVariantID;

                if (!int.TryParse(
                    ddlFixedProductVariant.SelectedValue,
                    out parsedFixedProductVariantID))
                {
                    ShowError(
                        "Please select a valid fixed product variant.");
                    return;
                }

                fixedProductVariantID =
                    parsedFixedProductVariantID;
            }

            BundleSlot slot = new BundleSlot
            {
                BundleID = bundleID,
                SlotName = txtSlotName.Text.Trim(),
                FixedProductVariantID =
                    fixedProductVariantID,
                OptionGroupID = optionGroupID,
                DefaultProductVariantID =
                    defaultProductVariantID,
                Quantity = quantity,
                IsRequired = chkIsRequired.Checked,
                DisplayOrder = displayOrder
            };

            try
            {
                BundleSlotRepository repository =
                    new BundleSlotRepository();

                int bundleSlotID =
                    repository.Add(slot);

                ShowSuccess(
                    "Bundle slot added successfully. ID: " +
                    bundleSlotID);

                ClearForm();
                LoadSlots();
            }
            catch (SqlException exception)
            {
                if (exception.Number == 2601 ||
                    exception.Number == 2627)
                {
                    ShowError(
                        "This bundle already has a slot with the same name.");
                }
                else if (exception.Number == 547)
                {
                    ShowError(
                        "The selected default choice does not belong to the selected option group.");
                }
                else
                {
                    ShowError(
                        "The bundle slot could not be saved.");
                }
            }
            catch (ArgumentException exception)
            {
                ShowError(exception.Message);
            }
            catch (Exception)
            {
                ShowError(
                    "An unexpected error occurred.");
            }
        }

        private void LoadBundles()
        {
            try
            {
                BundleRepository repository =
                    new BundleRepository();

                List<Bundle> bundles =
                    repository.GetAll();

                ddlBundle.DataSource = bundles;
                ddlBundle.DataTextField = "BundleName";
                ddlBundle.DataValueField = "BundleID";
                ddlBundle.DataBind();

                ddlBundle.Items.Insert(
                    0,
                    new ListItem(
                        "-- Select bundle --",
                        ""));
            }
            catch (Exception)
            {
                ddlBundle.Items.Clear();
                ddlBundle.Items.Add(
                    new ListItem(
                        "Bundles unavailable",
                        ""));

                ddlBundle.Enabled = false;
                btnAddSlot.Enabled = false;

                ShowError(
                    "Bundles could not be loaded.");
            }
        }

        private void LoadProductVariants()
        {
            try
            {
                ProductVariantRepository repository =
                    new ProductVariantRepository();

                List<ProductVariant> variants =
                    repository.GetAll();

                ddlFixedProductVariant.Items.Clear();
                ddlFixedProductVariant.Items.Add(
                    new ListItem(
                        "-- Select fixed product --",
                        ""));

                foreach (ProductVariant variant in variants)
                {
                    ddlFixedProductVariant.Items.Add(
                        new ListItem(
                            BuildVariantDisplayText(
                                variant.CategoryName,
                                variant.ProductName,
                                variant.SizeName,
                                variant.Price),
                            variant.ProductVariantID
                                .ToString()));
                }
            }
            catch (Exception)
            {
                ddlFixedProductVariant.Items.Clear();
                ddlFixedProductVariant.Items.Add(
                    new ListItem(
                        "Product variants unavailable",
                        ""));

                ddlFixedProductVariant.Enabled = false;
                btnAddSlot.Enabled = false;

                ShowError(
                    "Product variants could not be loaded.");
            }
        }

        private void LoadOptionGroups()
        {
            try
            {
                BundleOptionGroupRepository repository =
                    new BundleOptionGroupRepository();

                List<BundleOptionGroup> optionGroups =
                    repository.GetAll();

                ddlOptionGroup.DataSource = optionGroups;
                ddlOptionGroup.DataTextField =
                    "OptionGroupName";
                ddlOptionGroup.DataValueField =
                    "OptionGroupID";
                ddlOptionGroup.DataBind();

                ddlOptionGroup.Items.Insert(
                    0,
                    new ListItem(
                        "-- Select option group --",
                        ""));
            }
            catch (Exception)
            {
                ddlOptionGroup.Items.Clear();
                ddlOptionGroup.Items.Add(
                    new ListItem(
                        "Option groups unavailable",
                        ""));

                ddlOptionGroup.Enabled = false;

                ShowError(
                    "Option groups could not be loaded.");
            }
        }

        private void LoadDefaultChoices()
        {
            ddlDefaultProductVariant.Items.Clear();
            ddlDefaultProductVariant.Items.Add(
                new ListItem(
                    "-- Select default choice --",
                    ""));

            int optionGroupID;

            if (!int.TryParse(
                ddlOptionGroup.SelectedValue,
                out optionGroupID))
            {
                ddlDefaultProductVariant.Enabled = false;
                return;
            }

            try
            {
                BundleOptionGroupItemRepository repository =
                    new BundleOptionGroupItemRepository();

                List<BundleOptionGroupItem> items =
                    repository.GetAll();

                foreach (BundleOptionGroupItem item in items)
                {
                    if (item.OptionGroupID != optionGroupID ||
                        !item.IsAvailable ||
                        item.AdditionalPrice != 0m)
                    {
                        continue;
                    }

                    ddlDefaultProductVariant.Items.Add(
                        new ListItem(
                            BuildVariantDisplayText(
                                item.CategoryName,
                                item.ProductName,
                                item.SizeName,
                                item.ProductVariantPrice),
                            item.ProductVariantID
                                .ToString()));
                }

                ddlDefaultProductVariant.Enabled =
                    ddlDefaultProductVariant.Items.Count > 1;

                if (!ddlDefaultProductVariant.Enabled)
                {
                    ShowError(
                        "The selected option group has no available ₱0.00 default choices.");
                }
            }
            catch (Exception)
            {
                ddlDefaultProductVariant.Enabled = false;

                ShowError(
                    "Default choices could not be loaded.");
            }
        }

        private void LoadSlots()
        {
            try
            {
                BundleSlotRepository repository =
                    new BundleSlotRepository();

                List<BundleSlot> slots =
                    repository.GetAll();

                gridSlots.DataSource = slots;
                gridSlots.DataBind();

                gridSlots.Visible = true;
                lblLoadError.Visible = false;
            }
            catch (Exception)
            {
                gridSlots.Visible = false;

                lblLoadError.Text =
                    "Bundle slots could not be loaded.";

                lblLoadError.Visible = true;
            }
        }

        private void ConfigureSlotTypeControls()
        {
            bool isChoice = IsChoiceSlot();

            pnlFixedProduct.Visible = !isChoice;
            pnlOptionGroup.Visible = isChoice;
            pnlDefaultProductVariant.Visible = isChoice;

            requiredFixedProductVariant.Enabled =
                !isChoice;

            requiredOptionGroup.Enabled = isChoice;
            requiredDefaultProductVariant.Enabled =
                isChoice;

            if (!isChoice)
            {
                ddlDefaultProductVariant.Enabled = false;
            }
            else
            {
                ddlDefaultProductVariant.Enabled =
                    ddlDefaultProductVariant.Items.Count > 1;
            }
        }

        private bool IsChoiceSlot()
        {
            return string.Equals(
                ddlSlotType.SelectedValue,
                "CHOICE",
                StringComparison.OrdinalIgnoreCase);
        }

        private static string BuildVariantDisplayText(
            string categoryName,
            string productName,
            string sizeName,
            decimal price)
        {
            return categoryName +
                " - " +
                productName +
                " - " +
                sizeName +
                " (₱" +
                price.ToString("N2") +
                ")";
        }

        private void ClearForm()
        {
            ddlBundle.SelectedIndex = 0;
            txtSlotName.Text = string.Empty;
            ddlSlotType.SelectedValue = "FIXED";
            ddlFixedProductVariant.SelectedIndex = 0;
            ddlOptionGroup.SelectedIndex = 0;

            ddlDefaultProductVariant.Items.Clear();
            ddlDefaultProductVariant.Items.Add(
                new ListItem(
                    "-- Select default choice --",
                    ""));

            txtQuantity.Text = "1";
            txtDisplayOrder.Text = "0";
            chkIsRequired.Checked = true;

            ConfigureSlotTypeControls();
        }

        private void ShowSuccess(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass =
                "alert alert-success d-block";
            lblMessage.Visible = true;
        }

        private void ShowError(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass =
                "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
