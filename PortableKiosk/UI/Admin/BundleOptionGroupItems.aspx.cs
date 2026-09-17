using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace PortableKiosk.UI.Admin
{
    public partial class BundleOptionGroupItemManagement :
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
                LoadOptionGroups();
                LoadProductVariants();
                LoadItems();
            }
        }

        protected void btnAddItem_Click(
            object sender,
            EventArgs e)
        {
            lblMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            int optionGroupID;

            if (!int.TryParse(
                ddlOptionGroup.SelectedValue,
                out optionGroupID))
            {
                ShowError(
                    "Please select a valid option group.");
                return;
            }

            int productVariantID;

            if (!int.TryParse(
                ddlProductVariant.SelectedValue,
                out productVariantID))
            {
                ShowError(
                    "Please select a valid product variant.");
                return;
            }

            decimal additionalPrice;

            if (!decimal.TryParse(
                txtAdditionalPrice.Text.Trim(),
                out additionalPrice))
            {
                ShowError(
                    "Upgrade price must be a valid number.");
                return;
            }

            if (additionalPrice < 0)
            {
                ShowError(
                    "Upgrade price cannot be negative.");
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

            BundleOptionGroupItem item =
                new BundleOptionGroupItem
                {
                    OptionGroupID = optionGroupID,
                    ProductVariantID = productVariantID,
                    AdditionalPrice = additionalPrice,
                    IsAvailable = chkIsAvailable.Checked,
                    DisplayOrder = displayOrder
                };

            try
            {
                BundleOptionGroupItemRepository repository =
                    new BundleOptionGroupItemRepository();

                repository.Add(item);

                ShowSuccess(
                    "Option group item added successfully.");

                ClearForm();
                LoadItems();
            }
            catch (SqlException exception)
            {
                if (exception.Number == 2601 ||
                    exception.Number == 2627)
                {
                    ShowError(
                        "This product variant is already in the selected option group.");
                }
                else
                {
                    ShowError(
                        "The option group item could not be saved.");
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
                btnAddItem.Enabled = false;

                ShowError(
                    "Option groups could not be loaded.");
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

                ddlProductVariant.Items.Clear();
                ddlProductVariant.Items.Add(
                    new ListItem(
                        "-- Select product variant --",
                        ""));

                foreach (ProductVariant variant in variants)
                {
                    string displayText =
                        variant.CategoryName +
                        " - " +
                        variant.ProductName +
                        " - " +
                        variant.SizeName +
                        " (₱" +
                        variant.Price.ToString("N2") +
                        ")";

                    ddlProductVariant.Items.Add(
                        new ListItem(
                            displayText,
                            variant.ProductVariantID
                                .ToString()));
                }
            }
            catch (Exception)
            {
                ddlProductVariant.Items.Clear();
                ddlProductVariant.Items.Add(
                    new ListItem(
                        "Product variants unavailable",
                        ""));

                ddlProductVariant.Enabled = false;
                btnAddItem.Enabled = false;

                ShowError(
                    "Product variants could not be loaded.");
            }
        }

        private void LoadItems()
        {
            try
            {
                BundleOptionGroupItemRepository repository =
                    new BundleOptionGroupItemRepository();

                List<BundleOptionGroupItem> items =
                    repository.GetAll();

                gridItems.DataSource = items;
                gridItems.DataBind();

                gridItems.Visible = true;
                lblLoadError.Visible = false;
            }
            catch (Exception)
            {
                gridItems.Visible = false;

                lblLoadError.Text =
                    "Option group items could not be loaded.";

                lblLoadError.Visible = true;
            }
        }

        private void ClearForm()
        {
            ddlOptionGroup.SelectedIndex = 0;
            ddlProductVariant.SelectedIndex = 0;
            txtAdditionalPrice.Text = "0.00";
            txtDisplayOrder.Text = "0";
            chkIsAvailable.Checked = true;
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
