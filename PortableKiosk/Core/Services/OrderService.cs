using System;
using System.Collections.Generic;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class OrderService
    {
        private readonly OrderRepository orderRepository =
            new OrderRepository();

        private readonly ProductVariantRepository variantRepository =
            new ProductVariantRepository();

        public int Add(Order order)
        {
            return orderRepository.Add(order);
        }

        public Order PlaceOrder(
            Cart cart,
            string orderType,
            string paymentMethod,
            string fulfillmentMethod,
            string tableNumber)
        {
            if (cart == null || cart.IsEmpty)
            {
                throw new InvalidOperationException(
                    "Add at least one product before checkout.");
            }

            string normalizedOrderType = NormalizeChoice(
                orderType,
                "DINE_IN",
                "TAKEOUT",
                "Choose dine-in or takeout.");
            string normalizedPaymentMethod = NormalizeChoice(
                paymentMethod,
                "CASHLESS",
                "CASH_COUNTER",
                "Choose a valid payment method.");
            string normalizedFulfillment = NormalizeChoice(
                fulfillmentMethod,
                "TABLE_SERVICE",
                "COUNTER_PICKUP",
                "Choose a valid fulfillment method.");

            if (normalizedFulfillment == "TABLE_SERVICE" &&
                string.IsNullOrWhiteSpace(tableNumber))
            {
                throw new ArgumentException(
                    "Enter the number printed on your locator.",
                    "tableNumber");
            }

            List<OrderItem> orderItems = new List<OrderItem>();
            decimal totalAmount = 0;

            foreach (CartItem cartItem in cart.Items)
            {
                if (cartItem.Quantity < 1 || cartItem.Quantity > 99)
                {
                    throw new InvalidOperationException(
                        "A cart quantity is no longer valid.");
                }

                ProductVariant variant =
                    variantRepository.GetAvailableByID(
                        cartItem.ProductVariantID);

                if (variant == null)
                {
                    throw new InvalidOperationException(
                        cartItem.ProductName +
                        " is no longer available.");
                }

                orderItems.Add(new OrderItem
                {
                    ProductVariantID = variant.ProductVariantID,
                    ProductName = variant.ProductName,
                    SizeName = variant.SizeName,
                    UnitPrice = variant.Price,
                    Quantity = cartItem.Quantity
                });

                totalAmount += variant.Price * cartItem.Quantity;
            }

            Order order = new Order
            {
                OrderType = normalizedOrderType,
                FulfillmentMethod = normalizedFulfillment,
                TableNumber = normalizedFulfillment == "TABLE_SERVICE"
                    ? tableNumber.Trim()
                    : null,
                KitchenStatus = "QUEUED"
            };

            bool isCashless = normalizedPaymentMethod == "CASHLESS";

            Payment payment = new Payment
            {
                PaymentMethod = normalizedPaymentMethod,
                PaymentStatus = isCashless ? "PAID" : "PENDING",
                Amount = totalAmount,
                TransactionReference = isCashless
                    ? "MOCK-" + Guid.NewGuid().ToString("N").Substring(0, 16)
                    : null,
                PaidAt = isCashless
                    ? (DateTime?)DateTime.UtcNow
                    : null
            };

            orderRepository.AddCompleteOrder(
                order,
                orderItems,
                payment);

            return order;
        }

        public Order GetByID(int orderID)
        {
            return orderRepository.GetByID(orderID);
        }

        public Order GetByOrderNumber(string orderNumber)
        {
            return orderRepository.GetByOrderNumber(orderNumber);
        }

        public List<Order> GetAll()
        {
            return orderRepository.GetAll();
        }

        public bool Update(Order order)
        {
            return orderRepository.Update(order);
        }

        public bool Delete(int orderID)
        {
            return orderRepository.Delete(orderID);
        }

        private static string NormalizeChoice(
            string value,
            string firstChoice,
            string secondChoice,
            string errorMessage)
        {
            string normalized = (value ?? string.Empty)
                .Trim()
                .ToUpperInvariant();

            if (normalized != firstChoice &&
                normalized != secondChoice)
            {
                throw new ArgumentException(errorMessage, "value");
            }

            return normalized;
        }
    }
}
