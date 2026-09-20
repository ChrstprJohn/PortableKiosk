using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;
using PortableKiosk.Shared.Helpers;

namespace PortableKiosk.UI.User
{
    public partial class Menu : Page
    {
        private readonly CategoryService categoryService =
            new CategoryService();

        private readonly ProductService productService =
            new ProductService();

        private readonly ProductVariantService variantService =
            new ProductVariantService();

        private readonly CartService cartService =
            new CartService();

        public class MenuProductViewModel
        {
            public int ProductID { get; set; }
            public string CategoryName { get; set; }
            public string ProductName { get; set; }
            public string ProductDescription { get; set; }
            public decimal StartingPrice { get; set; }
            public string ImagePath { get; set; }
        }

        private int SelectedCategoryID
        {
            get
            {
                return ViewState["SelectedCategoryID"] == null
                    ? 0
                    : Convert.ToInt32(
                        ViewState["SelectedCategoryID"],
                        CultureInfo.InvariantCulture);
            }
            set { ViewState["SelectedCategoryID"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!KioskSession.HasActiveOrder(Session))
            {
                Redirect("~/Default.aspx");
                return;
            }

            if (string.IsNullOrWhiteSpace(
                KioskSession.GetOrderType(Session)))
            {
                Redirect("~/UI/User/OrderType.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindCategories();
                ShowHome();
            }
        }

        protected void btnHome_Click(
            object sender,
            EventArgs e)
        {
            ShowHome();
            BindCategories();
        }

        protected void rptCategories_ItemCommand(
            object source,
            RepeaterCommandEventArgs e)
        {
            if (!string.Equals(
                e.CommandName,
                "SelectCategory",
                StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            int categoryID;

            if (!int.TryParse(
                Convert.ToString(e.CommandArgument),
                out categoryID))
            {
                ShowMenuError("That category could not be opened.");
                return;
            }

            BindProducts(categoryID);
            BindCategories();
        }

        protected void rptProducts_ItemCommand(
            object source,
            RepeaterCommandEventArgs e)
        {
            if (!string.Equals(
                e.CommandName,
                "SelectProduct",
                StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            int productID;

            if (!int.TryParse(
                Convert.ToString(e.CommandArgument),
                out productID))
            {
                ShowMenuError("That product could not be opened.");
                return;
            }

            OpenProduct(productID, null);
        }

        protected void btnAddToCart_Click(
            object sender,
            EventArgs e)
        {
            int productID;
            int productVariantID;
            int quantity;

            int.TryParse(hfSelectedProductID.Value, out productID);

            if (!int.TryParse(
                    hfSelectedVariantID.Value,
                    out productVariantID) ||
                !int.TryParse(txtQuantity.Text, out quantity))
            {
                OpenProduct(
                    productID,
                    "Choose a size and enter a valid quantity.");
                return;
            }

            try
            {
                Cart cart = KioskSession.GetCart(Session);
                cartService.AddItem(
                    cart,
                    productVariantID,
                    quantity);

                CartItem addedItem = cart.Items.First(
                    item =>
                        item.ProductVariantID == productVariantID);

                int categoryID = SelectedCategoryID;

                if (categoryID > 0)
                {
                    BindProducts(categoryID);
                    BindCategories();
                }

                pnlAddSuccess.Visible = true;
                litAddSuccess.Text = string.Format(
                    CultureInfo.InvariantCulture,
                    " {0} ({1}) × {2} was added successfully.",
                    Server.HtmlEncode(addedItem.ProductName),
                    Server.HtmlEncode(addedItem.DisplaySize),
                    quantity);
            }
            catch (Exception ex)
            {
                OpenProduct(productID, ex.Message);
            }
        }

        protected void btnBackToMenu_Click(
            object sender,
            EventArgs e)
        {
            if (SelectedCategoryID > 0)
            {
                BindProducts(SelectedCategoryID);
                BindCategories();
                return;
            }

            ShowHome();
            BindCategories();
        }

        protected string GetCategoryCss(object categoryID)
        {
            int parsedCategoryID;
            int.TryParse(
                Convert.ToString(categoryID),
                out parsedCategoryID);

            return parsedCategoryID == SelectedCategoryID
                ? "menu-nav-item active"
                : "menu-nav-item";
        }

        protected bool HasImage(object imagePath)
        {
            return !string.IsNullOrWhiteSpace(
                Convert.ToString(imagePath));
        }

        protected string ResolveProductImage(object imagePath)
        {
            string path = Convert.ToString(imagePath);
            return string.IsNullOrWhiteSpace(path)
                ? string.Empty
                : ResolveUrl(path);
        }

        protected string GetProductDescription(object description)
        {
            string value = Convert.ToString(description);
            return string.IsNullOrWhiteSpace(value)
                ? "Choose an available size and quantity."
                : value;
        }

        protected string FormatStartingPrice(object price)
        {
            return string.Format(
                CultureInfo.GetCultureInfo("en-PH"),
                "₱{0:N2}",
                Convert.ToDecimal(price));
        }

        protected string GetVariantSizeName(object sizeName)
        {
            string value = Convert.ToString(sizeName);
            return string.IsNullOrWhiteSpace(value)
                ? "Standard"
                : value;
        }

        protected string FormatVariantPrice(object price)
        {
            return string.Format(
                CultureInfo.GetCultureInfo("en-PH"),
                "₱{0:N2}",
                Convert.ToDecimal(price));
        }

        protected string GetCategoryIconSvg(object categoryName)
        {
            string name = Convert.ToString(categoryName) ?? string.Empty;
            string lower = name.ToLowerInvariant();

            if (lower.Contains("burger"))
            {
                return "<svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M4 11h16a1 1 0 0 0 1-1A6 6 0 0 0 3 10a1 1 0 0 0 1 1z\"></path><path d=\"M4 14h16\"></path><path d=\"M5 18h14a2 2 0 0 0 2-2v-1H3v1a2 2 0 0 0 2 2z\"></path></svg>";
            }
            if (lower.Contains("chicken") || lower.Contains("poultry") || lower.Contains("wings"))
            {
                return "<svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M15 4a5 5 0 0 0-5 5v1a5 5 0 0 0 5 5h1a5 5 0 0 0 5-5V9a5 5 0 0 0-5-5z\"></path><path d=\"M10 15l-4 4\"></path><path d=\"M4 17a2 2 0 1 0 2 2\"></path></svg>";
            }
            if (lower.Contains("drink") || lower.Contains("beverage") || lower.Contains("juice") || lower.Contains("soda"))
            {
                return "<svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M7 21h10\"></path><path d=\"M12 21a7 7 0 0 1-7-7V4h14v10a7 7 0 0 1-7 7z\"></path><line x1=\"6\" y1=\"4\" x2=\"6\" y2=\"2\"></line><line x1=\"18\" y1=\"4\" x2=\"18\" y2=\"2\"></line></svg>";
            }
            if (lower.Contains("coffee") || lower.Contains("cafe") || lower.Contains("tea") || lower.Contains("latte"))
            {
                return "<svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M18 8h1a4 4 0 0 1 0 8h-1\"></path><path d=\"M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z\"></path><line x1=\"6\" y1=\"1\" x2=\"6\" y2=\"4\"></line><line x1=\"10\" y1=\"1\" x2=\"10\" y2=\"4\"></line><line x1=\"14\" y1=\"1\" x2=\"14\" y2=\"4\"></line></svg>";
            }
            if (lower.Contains("dessert") || lower.Contains("ice") || lower.Contains("sweet") || lower.Contains("sundae") || lower.Contains("pie"))
            {
                return "<svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M7 11v8a5 5 0 0 0 10 0v-8\"></path><path d=\"M12 2a4 4 0 0 0-4 4v5h8V6a4 4 0 0 0-4-4z\"></path></svg>";
            }
            if (lower.Contains("meal") || lower.Contains("happy") || lower.Contains("box") || lower.Contains("combo") || lower.Contains("share"))
            {
                return "<svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z\"></path><polyline points=\"3.27 6.96 12 12.01 20.73 6.96\"></polyline><line x1=\"12\" y1=\"22.08\" x2=\"12\" y2=\"12\"></line></svg>";
            }
            if (lower.Contains("new") || lower.Contains("offer") || lower.Contains("promo") || lower.Contains("special") || lower.Contains("featured"))
            {
                return "<svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><polygon points=\"12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2\"></polygon></svg>";
            }

            return "<svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M18 2v20\"></path><path d=\"M6 2v20\"></path><path d=\"M4 7h4\"></path><path d=\"M18 7a3 3 0 0 0-3-3v8a3 3 0 0 0 3-3z\"></path></svg>";
        }

        private void BindCategories()
        {
            rptCategories.DataSource = categoryService.GetAvailable();
            rptCategories.DataBind();

            btnHome.CssClass = SelectedCategoryID == 0
                ? "menu-nav-item active"
                : "menu-nav-item";
        }

        private void ShowHome()
        {
            SelectedCategoryID = 0;
            BindHomeContent();
            pnlHome.Visible = true;
            pnlProducts.Visible = false;
            pnlProductDetail.Visible = false;
            pnlAddSuccess.Visible = false;
            lblMenuError.Visible = false;
        }

        private void BindHomeContent()
        {
            List<Category> categories = categoryService
                .GetAvailable()
                .Take(4)
                .ToList();

            rptHomeCategories.DataSource = categories;
            rptHomeCategories.DataBind();

            List<MenuProductViewModel> featuredProducts =
                new List<MenuProductViewModel>();

            foreach (Category category in categories)
            {
                foreach (Product product in productService
                    .GetAvailableByCategoryID(category.CategoryID))
                {
                    List<ProductVariant> variants = variantService
                        .GetAvailableByProductID(product.ProductID);

                    if (variants.Count == 0)
                    {
                        continue;
                    }

                    ProductVariant imageVariant = variants.FirstOrDefault(
                        variant => !string.IsNullOrWhiteSpace(
                            variant.ImagePath));

                    featuredProducts.Add(new MenuProductViewModel
                    {
                        ProductID = product.ProductID,
                        CategoryName = product.CategoryName,
                        ProductName = product.ProductName,
                        ProductDescription = product.ProductDescription,
                        StartingPrice = variants.Min(
                            variant => variant.Price),
                        ImagePath = imageVariant == null
                            ? null
                            : imageVariant.ImagePath
                    });

                    if (featuredProducts.Count == 3)
                    {
                        break;
                    }
                }

                if (featuredProducts.Count == 3)
                {
                    break;
                }
            }

            rptBestSellers.DataSource = featuredProducts;
            rptBestSellers.DataBind();
        }

        private void BindProducts(int categoryID)
        {
            List<Product> products =
                productService.GetAvailableByCategoryID(
                    categoryID);

            List<MenuProductViewModel> menuProducts =
                new List<MenuProductViewModel>();

            foreach (Product product in products)
            {
                List<ProductVariant> variants =
                    variantService.GetAvailableByProductID(
                        product.ProductID);

                if (variants.Count == 0)
                {
                    continue;
                }

                ProductVariant imageVariant = variants.FirstOrDefault(
                    variant =>
                        !string.IsNullOrWhiteSpace(
                            variant.ImagePath));

                menuProducts.Add(new MenuProductViewModel
                {
                    ProductID = product.ProductID,
                    CategoryName = product.CategoryName,
                    ProductName = product.ProductName,
                    ProductDescription = product.ProductDescription,
                    StartingPrice = variants.Min(
                        variant => variant.Price),
                    ImagePath = imageVariant == null
                        ? null
                        : imageVariant.ImagePath
                });
            }

            SelectedCategoryID = categoryID;
            pnlHome.Visible = false;
            pnlProducts.Visible = true;
            pnlProductDetail.Visible = false;
            pnlNoProducts.Visible = menuProducts.Count == 0;
            pnlAddSuccess.Visible = false;
            lblMenuError.Visible = false;

            litCategoryName.Text = Server.HtmlEncode(
                products.Count == 0
                    ? "Menu"
                    : products[0].CategoryName);

            rptProducts.DataSource = menuProducts;
            rptProducts.DataBind();
        }

        private void OpenProduct(
            int productID,
            string errorMessage)
        {
            Product product =
                productService.GetAvailableByID(productID);

            List<ProductVariant> variants =
                product == null
                    ? new List<ProductVariant>()
                    : variantService.GetAvailableByProductID(
                        productID);

            if (product == null || variants.Count == 0)
            {
                ShowMenuError(
                    "That product is no longer available.");
                return;
            }

            hfSelectedProductID.Value =
                product.ProductID.ToString(
                    CultureInfo.InvariantCulture);

            rptVariants.DataSource = variants;
            rptVariants.DataBind();
            hfSelectedVariantID.Value = variants[0]
                .ProductVariantID
                .ToString(CultureInfo.InvariantCulture);
            txtQuantity.Text = "1";
            lblProductError.Visible =
                !string.IsNullOrWhiteSpace(errorMessage);
            lblProductError.Text =
                Server.HtmlEncode(errorMessage);

            pnlHome.Visible = false;
            pnlProducts.Visible = false;
            pnlProductDetail.Visible = true;
            pnlAddSuccess.Visible = false;
            lblMenuError.Visible = false;
        }

        private void ShowMenuError(string message)
        {
            lblMenuError.Text = Server.HtmlEncode(message);
            lblMenuError.Visible = true;
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
