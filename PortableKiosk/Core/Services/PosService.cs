using System;
using System.Collections.Generic;
using System.Linq;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;
using PortableKiosk.Shared.Constants;

namespace PortableKiosk.Core.Services
{
    public class PosService
    {
        private readonly PosRepository posRepository = new PosRepository();
        private readonly OrderRepository orderRepository = new OrderRepository();
        private readonly OrderItemRepository itemRepository =
            new OrderItemRepository();
        private readonly PaymentRepository paymentRepository =
            new PaymentRepository();
        private readonly ProductVariantRepository variantRepository =
            new ProductVariantRepository();

        public List<PosCatalogItem> GetAvailableCatalog()
        {
            return posRepository.GetAvailableCatalog();
        }

        public PosCatalogGroup GetCatalogGroup()
        {
            List<PosCatalogItem> catalog = GetAvailableCatalog();
            return new PosCatalogGroup
            {
                Categories = catalog.GroupBy(item => item.CategoryID)
                    .Select(group => new PosCatalogCategory
                    {
                        CategoryID = group.Key,
                        CategoryName = group.First().CategoryName
                    }).ToList(),
                Sizes = catalog.GroupBy(item => item.SizeID.HasValue
                        ? item.SizeID.Value.ToString(System.Globalization.CultureInfo.InvariantCulture)
                        : "standard")
                    .Select(group => new PosCatalogSizeGroup
                    {
                        SizeKey = group.Key,
                        SizeName = group.First().SizeName,
                        Items = group.ToList()
                    })
                    .OrderBy(group => GetSizeOrder(group.SizeName))
                    .ThenBy(group => group.SizeName).ToList(),
                CategoryIDs = catalog.Select(item => item.CategoryID).Distinct().ToList()
            };
        }

        private static int GetSizeOrder(string sizeName)
        {
            switch ((sizeName ?? string.Empty).Trim().ToLowerInvariant())
            {
                case "regular": return 0;
                case "medium": return 1;
                case "large": return 2;
                case "standard": return -1;
                default: return 3;
            }
        }

        public PosSale StartNewSale()
        {
            return new PosSale();
        }

        public int CancelExpiredPendingOrders()
        {
            return orderRepository.CancelExpiredPendingOrders();
        }

        public PosSale TakeKioskOrder(string orderNumber)
        {
            string trimmedOrderNumber = (orderNumber ?? string.Empty).Trim();
            if (trimmedOrderNumber.StartsWith("#", StringComparison.Ordinal))
            {
                trimmedOrderNumber = trimmedOrderNumber.Substring(1).Trim();
            }

            if (trimmedOrderNumber.Length == 0)
            {
                throw new ArgumentException("Enter the kiosk order number.");
            }

            if (trimmedOrderNumber.Length > 20 ||
                trimmedOrderNumber.Any(character =>
                    character < '0' || character > '9'))
            {
                throw new ArgumentException(
                    "Enter a valid numeric order number.");
            }

            orderRepository.CancelExpiredPendingOrders();

            Order order = orderRepository.GetByOrderNumber(trimmedOrderNumber);
            if (order == null)
            {
                throw new InvalidOperationException(
                    "No kiosk order was found with that number.");
            }

            int orderID = order.OrderID;
            Payment payment = paymentRepository.GetByOrderID(orderID);
            DateTime expiresAt = order.ExpiresAt ?? order.CreatedAt.AddMinutes(
                OrderSettings.LegacyPendingPaymentExpiryMinutes);

            if (payment != null && payment.PaymentMethod == "CASH_COUNTER" &&
                (payment.PaymentStatus == "EXPIRED" ||
                    (payment.PaymentStatus == "PENDING" &&
                        expiresAt <= DateTime.UtcNow)))
            {
                throw new InvalidOperationException(
                    "This kiosk order has expired. Choose another order.");
            }

            if (payment != null && payment.PaymentStatus == "PAID")
            {
                throw new InvalidOperationException(
                    payment.PaymentMethod == "CASHLESS"
                        ? "This kiosk order has already been paid online. No payment is needed at the counter."
                        : "This kiosk order has already been paid. No payment is needed at the counter.");
            }

            if (payment == null ||
                payment.PaymentMethod != "CASH_COUNTER" ||
                payment.PaymentStatus != "PENDING" ||
                order.KitchenStatus != "AWAITING_PAYMENT")
            {
                throw new InvalidOperationException(
                    "This kiosk order is no longer waiting for cash payment.");
            }

            List<OrderItem> items = itemRepository.GetByOrderID(orderID);
            if (items.Count == 0)
            {
                throw new InvalidOperationException(
                    "This kiosk order has no items to collect payment for.");
            }

            PosSale sale = new PosSale
            {
                SourceOrderID = order.OrderID,
                SourceOrderNumber = order.OrderNumber,
                OriginalItemsSignature = PosRepository.GetItemSignature(items),
                OrderType = order.OrderType,
                FulfillmentMethod = order.FulfillmentMethod,
                TableNumber = order.TableNumber
            };

            foreach (OrderItem item in items)
            {
                sale.Cart.Items.Add(new CartItem
                {
                    ProductVariantID = item.ProductVariantID,
                    ProductName = item.ProductName,
                    SizeName = item.SizeName,
                    ImagePath = item.ImagePath,
                    UnitPrice = item.UnitPrice,
                    Quantity = item.Quantity
                });
            }

            return sale;
        }

        public void AddProduct(PosSale sale, int variantID, int quantity)
        {
            ValidateSale(sale);
            ValidateQuantity(quantity);

            ProductVariant variant = variantRepository.GetAvailableByID(variantID);
            if (variant == null)
            {
                throw new InvalidOperationException(
                    "That product is no longer available. Refresh the sale.");
            }

            CartItem existing = sale.Cart.Items.FirstOrDefault(
                item => item.ProductVariantID == variantID);

            if (existing != null)
            {
                ValidateQuantity(existing.Quantity + quantity);
                existing.Quantity += quantity;
                return;
            }

            sale.Cart.Items.Add(new CartItem
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

        public void ChangeQuantity(PosSale sale, int variantID, int delta)
        {
            ValidateSale(sale);

            CartItem item = sale.Cart.Items.FirstOrDefault(
                current => current.ProductVariantID == variantID);
            if (item == null)
            {
                throw new InvalidOperationException(
                    "That item is no longer in the sale.");
            }

            int quantity = item.Quantity + delta;
            if (quantity == 0)
            {
                sale.Cart.Items.Remove(item);
                return;
            }

            ValidateQuantity(quantity);
            item.Quantity = quantity;
        }

        public void RemoveProduct(PosSale sale, int variantID)
        {
            ValidateSale(sale);
            CartItem item = sale.Cart.Items.FirstOrDefault(
                current => current.ProductVariantID == variantID);
            if (item != null)
            {
                sale.Cart.Items.Remove(item);
            }
        }

        public PosReceipt CompleteCashSale(PosSale sale, decimal tendered)
        {
            return CompleteSale(sale, "CASH_COUNTER", tendered);
        }

        public PosReceipt CompleteMockCashlessSale(PosSale sale)
        {
            ValidateSale(sale);
            return CompleteSale(sale, "CASHLESS", sale.Cart.TotalAmount);
        }

        private PosReceipt CompleteSale(PosSale sale, string paymentMethod, decimal tendered)
        {
            ValidateSale(sale);

            if (sale.Cart.IsEmpty)
            {
                throw new InvalidOperationException(
                    "Add at least one product before payment.");
            }

            decimal total = sale.Cart.TotalAmount;
            if (total < 0 || total > 99999999.99m)
            {
                throw new InvalidOperationException(
                    "This sale exceeds the supported payment amount.");
            }

            if (tendered < total || tendered > 99999999.99m ||
                decimal.Round(tendered, 2) != tendered)
            {
                throw new ArgumentException(
                    "Enter a cash amount that covers the total.");
            }

            List<OrderItem> items = new List<OrderItem>();
            foreach (CartItem cartItem in sale.Cart.Items)
            {
                ValidateQuantity(cartItem.Quantity);

                if (cartItem.ProductVariantID <= 0 ||
                    cartItem.UnitPrice < 0 ||
                    decimal.Round(cartItem.UnitPrice, 2) != cartItem.UnitPrice)
                {
                    throw new InvalidOperationException(
                        "One sale item is invalid. Review the order.");
                }

                items.Add(new OrderItem
                {
                    ProductVariantID = cartItem.ProductVariantID,
                    UnitPrice = cartItem.UnitPrice,
                    Quantity = cartItem.Quantity
                });
            }

            Payment payment = new Payment
            {
                PaymentMethod = paymentMethod,
                PaymentStatus = "PAID",
                Amount = total,
                TransactionReference = "POS-" +
                    sale.SaleKey.ToString("N"),
                PaidAt = DateTime.UtcNow
            };

            Order order;
            if (sale.SourceOrderID.HasValue)
            {
                payment.OrderID = sale.SourceOrderID.Value;
                foreach (OrderItem item in items)
                {
                    item.OrderID = sale.SourceOrderID.Value;
                }

                order = posRepository.CompleteKioskCashOrder(
                    sale.SourceOrderID.Value, sale.OriginalItemsSignature,
                    items, payment);
            }
            else
            {
                if (sale.OrderType != "DINE_IN" && sale.OrderType != "TAKEOUT")
                {
                    throw new InvalidOperationException(
                        "Choose dine-in or takeout before payment.");
                }

                order = new Order
                {
                    OrderType = sale.OrderType,
                    FulfillmentMethod = "COUNTER_PICKUP",
                    KitchenStatus = "QUEUED"
                };

                order = posRepository.CompleteNewCashSale(
                    sale.SaleKey, order, items, payment);
            }

            return new PosReceipt
            {
                Order = order,
                Payment = payment,
                Tendered = tendered,
                Change = tendered - total,
                Items = sale.Cart.Items.Select(item => new CartItem
                {
                    ProductVariantID = item.ProductVariantID,
                    ProductName = item.ProductName,
                    SizeName = item.SizeName,
                    UnitPrice = item.UnitPrice,
                    Quantity = item.Quantity
                }).ToList()
            };
        }

        private static void ValidateSale(PosSale sale)
        {
            if (sale == null || sale.Cart == null || sale.Cart.Items == null)
            {
                throw new InvalidOperationException(
                    "Start a sale before choosing products.");
            }
        }

        private static void ValidateQuantity(int quantity)
        {
            if (quantity < 1 || quantity > 99)
            {
                throw new ArgumentException(
                    "Quantity must be between 1 and 99.");
            }
        }
    }
}
