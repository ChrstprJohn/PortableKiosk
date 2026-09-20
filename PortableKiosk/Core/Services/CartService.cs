using System;
using System.Linq;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class CartService
    {
        private const int MaximumQuantity = 99;

        private readonly ProductVariantRepository variantRepository =
            new ProductVariantRepository();

        public void AddItem(
            Cart cart,
            int productVariantID,
            int quantity)
        {
            ValidateCart(cart);
            ValidateQuantity(quantity);

            ProductVariant variant =
                variantRepository.GetAvailableByID(
                    productVariantID);

            if (variant == null)
            {
                throw new InvalidOperationException(
                    "That product option is no longer available.");
            }

            CartItem existingItem = cart.Items.FirstOrDefault(
                item => item.ProductVariantID == productVariantID);

            if (existingItem != null)
            {
                int updatedQuantity =
                    existingItem.Quantity + quantity;

                ValidateQuantity(updatedQuantity);

                existingItem.Quantity = updatedQuantity;
                existingItem.UnitPrice = variant.Price;
                return;
            }

            cart.Items.Add(new CartItem
            {
                ProductVariantID = variant.ProductVariantID,
                ProductID = variant.ProductID,
                ProductName = variant.ProductName,
                SizeName = variant.SizeName,
                ImagePath = variant.ImagePath,
                UnitPrice = variant.Price,
                Quantity = quantity
            });
        }

        public void UpdateQuantity(
            Cart cart,
            int productVariantID,
            int quantity)
        {
            ValidateCart(cart);
            ValidateQuantity(quantity);

            CartItem item = cart.Items.FirstOrDefault(
                current =>
                    current.ProductVariantID == productVariantID);

            if (item == null)
            {
                throw new InvalidOperationException(
                    "That cart item could not be found.");
            }

            ProductVariant variant =
                variantRepository.GetAvailableByID(
                    productVariantID);

            if (variant == null)
            {
                throw new InvalidOperationException(
                    "That product option is no longer available.");
            }

            item.Quantity = quantity;
            item.UnitPrice = variant.Price;
        }

        public void RemoveItem(
            Cart cart,
            int productVariantID)
        {
            ValidateCart(cart);

            CartItem item = cart.Items.FirstOrDefault(
                current =>
                    current.ProductVariantID == productVariantID);

            if (item != null)
            {
                cart.Items.Remove(item);
            }
        }

        private static void ValidateCart(Cart cart)
        {
            if (cart == null)
            {
                throw new ArgumentNullException("cart");
            }
        }

        private static void ValidateQuantity(int quantity)
        {
            if (quantity < 1 || quantity > MaximumQuantity)
            {
                throw new ArgumentException(
                    "Quantity must be between 1 and 99.",
                    "quantity");
            }
        }
    }
}
