using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class KitchenBoardService
    {
        private readonly OrderRepository orderRepository = new OrderRepository();
        private readonly OrderItemRepository itemRepository = new OrderItemRepository();
        private readonly PaymentRepository paymentRepository = new PaymentRepository();

        public List<KitchenOrderCard> GetPaidOrders(bool includeCompleted = false)
        {
            return orderRepository.GetPaidKitchenOrders(includeCompleted)
                .Select(order => new KitchenOrderCard
                {
                    OrderID = order.OrderID,
                    OrderNumberDisplay = FormatOrderNumber(order.OrderNumber),
                    KitchenStatus = order.KitchenStatus,
                    TimeDisplay = order.CreatedAt.AddHours(8).ToString("h:mm tt", CultureInfo.InvariantCulture),
                    PaidTimeDisplay = FormatPaidTime(paymentRepository.GetByOrderID(order.OrderID)),
                    OrderTypeDisplay = order.OrderType == "TAKEOUT" ? "Takeout" : "Dine in",
                    OrderTypeClass = order.OrderType == "TAKEOUT"
                        ? "kitchen-type kitchen-type-takeout"
                        : "kitchen-type kitchen-type-dinein",
                    FulfillmentDisplay = order.FulfillmentMethod == "TABLE_SERVICE"
                        ? "Table " + order.TableNumber
                        : "Counter pickup",
                    Items = itemRepository.GetByOrderID(order.OrderID)
                }).ToList();
        }

        public List<KitchenOrderCard> GetPublicStatusOrders()
        {
            return orderRepository.GetPaidKitchenOrders()
                .Where(order => order.KitchenStatus == "PREPARING" || order.KitchenStatus == "SERVING")
                .Select(order => new KitchenOrderCard
                {
                    OrderNumberDisplay = FormatOrderNumber(order.OrderNumber).TrimStart('#'),
                    KitchenStatus = order.KitchenStatus
                }).ToList();
        }

        private static string FormatPaidTime(Payment payment)
        {
            return payment != null && payment.PaidAt.HasValue
                ? payment.PaidAt.Value.AddHours(8).ToString("h:mm tt", CultureInfo.InvariantCulture)
                : "Not recorded";
        }

        private static string FormatOrderNumber(string orderNumber)
        {
            string value = (orderNumber ?? string.Empty).Trim().TrimStart('#');
            int numeric;
            return int.TryParse(value, out numeric)
                ? "#" + numeric.ToString("D4", CultureInfo.InvariantCulture)
                : "#" + value;
        }
    }
}
