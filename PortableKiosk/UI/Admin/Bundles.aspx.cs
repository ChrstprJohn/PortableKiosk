using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;

namespace PortableKiosk.UI.Admin
{
    public partial class BundleManagement :
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
            }
        }

        protected void btnAddBundle_Click(
            object sender,
            EventArgs e)
        {
            lblMessage.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            decimal basePrice;

            if (!decimal.TryParse(
                txtBasePrice.Text.Trim(),
                out basePrice))
            {
                ShowError(
                    "Base price must be a valid number.");
                return;
            }

            if (basePrice < 0)
            {
                ShowError(
                    "Base price cannot be negative.");
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

            string imagePath;
            string savedPhysicalPath;
            string uploadError;

            if (!TrySaveImage(
                out imagePath,
                out savedPhysicalPath,
                out uploadError))
            {
                ShowError(uploadError);
                return;
            }

            Bundle bundle = new Bundle
            {
                BundleName =
                    txtBundleName.Text.Trim(),

                BasePrice = basePrice,

                ImagePath = imagePath,

                IsAvailable =
                    chkIsAvailable.Checked,

                DisplayOrder = displayOrder
            };

            try
            {
                BundleRepository repository =
                    new BundleRepository();

                int bundleID =
                    repository.Add(bundle);

                ShowSuccess(
                    "Bundle added successfully. ID: " +
                    bundleID);

                ClearForm();
                LoadBundles();
            }
            catch (SqlException)
            {
                DeleteSavedImage(
                    savedPhysicalPath);

                ShowError(
                    "The bundle could not be saved.");
            }
            catch (ArgumentException exception)
            {
                DeleteSavedImage(
                    savedPhysicalPath);

                ShowError(exception.Message);
            }
            catch (Exception)
            {
                DeleteSavedImage(
                    savedPhysicalPath);

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

                gridBundles.DataSource = bundles;
                gridBundles.DataBind();

                gridBundles.Visible = true;
                lblLoadError.Visible = false;
            }
            catch (Exception)
            {
                gridBundles.Visible = false;

                lblLoadError.Text =
                    "Bundles could not be loaded.";

                lblLoadError.Visible = true;
            }
        }

        private bool TrySaveImage(
            out string imagePath,
            out string savedPhysicalPath,
            out string errorMessage)
        {
            imagePath = null;
            savedPhysicalPath = null;
            errorMessage = null;

            if (!uploadImage.HasFile)
            {
                return true;
            }

            const int maximumFileSize =
                3 * 1024 * 1024;

            if (uploadImage.PostedFile.ContentLength >
                maximumFileSize)
            {
                errorMessage =
                    "The image cannot exceed 3 MB.";
                return false;
            }

            string extension =
                Path.GetExtension(
                    uploadImage.FileName)
                    .ToLowerInvariant();

            bool allowedExtension =
                extension == ".jpg" ||
                extension == ".jpeg" ||
                extension == ".png" ||
                extension == ".webp";

            if (!allowedExtension)
            {
                errorMessage =
                    "Only JPG, PNG, and WebP images are allowed.";
                return false;
            }

            string contentType =
                uploadImage.PostedFile.ContentType;

            bool allowedContentType =
                string.Equals(
                    contentType,
                    "image/jpeg",
                    StringComparison.OrdinalIgnoreCase) ||
                string.Equals(
                    contentType,
                    "image/png",
                    StringComparison.OrdinalIgnoreCase) ||
                string.Equals(
                    contentType,
                    "image/webp",
                    StringComparison.OrdinalIgnoreCase);

            if (!allowedContentType)
            {
                errorMessage =
                    "The uploaded file is not a supported image.";
                return false;
            }

            try
            {
                string virtualFolder =
                    "~/Content/images/bundles/";

                string physicalFolder =
                    Server.MapPath(virtualFolder);

                Directory.CreateDirectory(
                    physicalFolder);

                string fileName =
                    Guid.NewGuid().ToString("N") +
                    extension;

                savedPhysicalPath =
                    Path.Combine(
                        physicalFolder,
                        fileName);

                uploadImage.SaveAs(
                    savedPhysicalPath);

                imagePath =
                    virtualFolder + fileName;

                return true;
            }
            catch (Exception)
            {
                imagePath = null;
                savedPhysicalPath = null;

                errorMessage =
                    "The image could not be uploaded.";

                return false;
            }
        }

        private void DeleteSavedImage(
            string physicalPath)
        {
            if (string.IsNullOrWhiteSpace(
                physicalPath))
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
                // Do not replace the original database error.
            }
        }

        private void ClearForm()
        {
            txtBundleName.Text = string.Empty;
            txtBasePrice.Text = string.Empty;
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