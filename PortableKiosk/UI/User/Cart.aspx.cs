using System;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using PortableKiosk.Core.Models;
using PortableKiosk.Core.Services;
using PortableKiosk.Shared.Helpers;

namespace PortableKiosk.UI.User
{
    public partial class CartPage : Page
    {
        private readonly CartService cartService =
            new CartService();

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
                BindCart();
            }
        }

        protected void rptCartItems_ItemCommand(
            object source,
            RepeaterCommandEventArgs e)
        {
            int productVariantID;

            if (!int.TryParse(
                Convert.ToString(e.CommandArgument),
                out productVariantID))
            {
                ShowError("That cart item could not be updated.");
                return;
            }

            Cart cart = KioskSession.GetCart(Session);

            try
            {
                if (string.Equals(
                    e.CommandName,
                    "RemoveItem",
                    StringComparison.OrdinalIgnoreCase))
                {
                    cartService.RemoveItem(
                        cart,
                        productVariantID);
                }
                else if (string.Equals(
                    e.CommandName,
                    "IncreaseQuantity",
                    StringComparison.OrdinalIgnoreCase))
                {
                    CartItem item = cart.Items.Find(
                        current => current.ProductVariantID == productVariantID);

                    if (item != null && item.Quantity < 99)
                    {
                        cartService.UpdateQuantity(
                            cart,
                            productVariantID,
                            item.Quantity + 1);
                    }
                }
                else if (string.Equals(
                    e.CommandName,
                    "DecreaseQuantity",
                    StringComparison.OrdinalIgnoreCase))
                {
                    CartItem item = cart.Items.Find(
                        current => current.ProductVariantID == productVariantID);

                    if (item != null)
                    {
                        if (item.Quantity > 1)
                        {
                            cartService.UpdateQuantity(
                                cart,
                                productVariantID,
                                item.Quantity - 1);
                        }
                        else
                        {
                            cartService.RemoveItem(
                                cart,
                                productVariantID);
                        }
                    }
                }
                else if (string.Equals(
                    e.CommandName,
                    "UpdateQuantity",
                    StringComparison.OrdinalIgnoreCase))
                {
                    TextBox quantityField =
                        e.Item.FindControl(
                            "txtItemQuantity") as TextBox;

                    int quantity;

                    if (quantityField == null ||
                        !int.TryParse(
                            quantityField.Text,
                            out quantity))
                    {
                        throw new ArgumentException(
                            "Enter a valid quantity.");
                    }

                    cartService.UpdateQuantity(
                        cart,
                        productVariantID,
                        quantity);
                }

                lblCartMessage.Visible = false;
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }

            BindCart();
        }

        protected void btnProceedToCheckout_Click(
            object sender,
            EventArgs e)
        {
            Cart cart = KioskSession.GetCart(Session);

            if (cart.IsEmpty)
            {
                ShowError(
                    "Add at least one product before checkout.");
                BindCart();
                return;
            }

            Redirect("~/UI/User/Payment.aspx");
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

        protected string FormatMoney(object amount)
        {
            return string.Format(
                CultureInfo.GetCultureInfo("en-PH"),
                "₱{0:N2}",
                Convert.ToDecimal(amount));
        }

        private void BindCart()
        {
            Cart cart = KioskSession.GetCart(Session);

            pnlEmptyCart.Visible = cart.IsEmpty;
            pnlCart.Visible = !cart.IsEmpty;

            rptCartItems.DataSource = cart.Items;
            rptCartItems.DataBind();

            litTotalAmount.Text = FormatMoney(
                cart.TotalAmount);
        }

        private void ShowError(string message)
        {
            lblCartMessage.Text = Server.HtmlEncode(message);
            lblCartMessage.Visible = true;
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
