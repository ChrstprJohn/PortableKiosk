using System;
using System.Web.SessionState;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Shared.Helpers
{
    public static class KioskSession
    {
        private const string CartKey = "KioskCart";
        private const string OrderTypeKey = "KioskOrderType";
        private const string StartedAtKey = "KioskStartedAt";
        private const string PaymentMethodKey = "KioskPaymentMethod";
        private const string OnlinePaymentConfirmedKey =
            "KioskOnlinePaymentConfirmed";
        private const string FulfillmentMethodKey =
            "KioskFulfillmentMethod";
        private const string TableNumberKey = "KioskTableNumber";
        private const string CompletedOrderIDKey =
            "KioskCompletedOrderID";
        private const string CompletedOrderNumberKey =
            "KioskCompletedOrderNumber";

        public static void StartNewOrder(HttpSessionState session)
        {
            if (session == null)
            {
                throw new ArgumentNullException("session");
            }

            ClearActiveOrder(session);
            session[CartKey] = new Cart();
            session[StartedAtKey] = DateTime.UtcNow;
        }

        public static bool HasActiveOrder(HttpSessionState session)
        {
            return session != null && session[StartedAtKey] != null;
        }

        public static Cart GetCart(HttpSessionState session)
        {
            if (session == null)
            {
                throw new ArgumentNullException("session");
            }

            Cart cart = session[CartKey] as Cart;

            if (cart == null)
            {
                cart = new Cart();
                session[CartKey] = cart;
            }

            return cart;
        }

        public static string GetOrderType(HttpSessionState session)
        {
            return session == null
                ? null
                : Convert.ToString(session[OrderTypeKey]);
        }

        public static void SetOrderType(
            HttpSessionState session,
            string orderType)
        {
            if (!string.Equals(
                    orderType,
                    "DINE_IN",
                    StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(
                    orderType,
                    "TAKEOUT",
                    StringComparison.OrdinalIgnoreCase))
            {
                throw new ArgumentException(
                    "Choose dine-in or takeout.",
                    "orderType");
            }

            session[OrderTypeKey] = orderType.ToUpperInvariant();
        }

        public static string GetPaymentMethod(
            HttpSessionState session)
        {
            return session == null
                ? null
                : Convert.ToString(session[PaymentMethodKey]);
        }

        public static void SetPaymentMethod(
            HttpSessionState session,
            string paymentMethod)
        {
            if (!string.Equals(
                    paymentMethod,
                    "CASHLESS",
                    StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(
                    paymentMethod,
                    "CASH_COUNTER",
                    StringComparison.OrdinalIgnoreCase))
            {
                throw new ArgumentException(
                    "Choose a valid payment method.",
                    "paymentMethod");
            }

            session[PaymentMethodKey] =
                paymentMethod.ToUpperInvariant();
            session.Remove(OnlinePaymentConfirmedKey);
            session.Remove(FulfillmentMethodKey);
            session.Remove(TableNumberKey);
            session.Remove(CompletedOrderIDKey);
            session.Remove(CompletedOrderNumberKey);
        }

        public static void ConfirmMockOnlinePayment(
            HttpSessionState session)
        {
            if (!string.Equals(
                GetPaymentMethod(session),
                "CASHLESS",
                StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException(
                    "Choose online payment first.");
            }

            session[OnlinePaymentConfirmedKey] = true;
        }

        public static bool CanContinueFromPayment(
            HttpSessionState session)
        {
            string paymentMethod = GetPaymentMethod(session);

            if (string.Equals(
                paymentMethod,
                "CASH_COUNTER",
                StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            return string.Equals(
                    paymentMethod,
                    "CASHLESS",
                    StringComparison.OrdinalIgnoreCase) &&
                session[OnlinePaymentConfirmedKey] is bool &&
                (bool)session[OnlinePaymentConfirmedKey];
        }

        public static string GetFulfillmentMethod(
            HttpSessionState session)
        {
            return session == null
                ? null
                : Convert.ToString(
                    session[FulfillmentMethodKey]);
        }

        public static void SetFulfillmentMethod(
            HttpSessionState session,
            string fulfillmentMethod)
        {
            if (!string.Equals(
                    fulfillmentMethod,
                    "TABLE_SERVICE",
                    StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(
                    fulfillmentMethod,
                    "COUNTER_PICKUP",
                    StringComparison.OrdinalIgnoreCase))
            {
                throw new ArgumentException(
                    "Choose a valid fulfillment method.",
                    "fulfillmentMethod");
            }

            session[FulfillmentMethodKey] =
                fulfillmentMethod.ToUpperInvariant();

            if (string.Equals(
                fulfillmentMethod,
                "COUNTER_PICKUP",
                StringComparison.OrdinalIgnoreCase))
            {
                session.Remove(TableNumberKey);
            }

            session.Remove(CompletedOrderIDKey);
            session.Remove(CompletedOrderNumberKey);
        }

        public static string GetTableNumber(
            HttpSessionState session)
        {
            return session == null
                ? null
                : Convert.ToString(session[TableNumberKey]);
        }

        public static void SetTableNumber(
            HttpSessionState session,
            string tableNumber)
        {
            if (string.IsNullOrWhiteSpace(tableNumber) ||
                tableNumber.Trim().Length > 20)
            {
                throw new ArgumentException(
                    "Enter the number shown on your table locator.",
                    "tableNumber");
            }

            session[TableNumberKey] = tableNumber.Trim();
            session.Remove(CompletedOrderIDKey);
            session.Remove(CompletedOrderNumberKey);
        }

        public static void MarkOrderPlaced(
            HttpSessionState session,
            Order order)
        {
            if (session == null)
            {
                throw new ArgumentNullException("session");
            }

            if (order == null ||
                order.OrderID <= 0 ||
                string.IsNullOrWhiteSpace(order.OrderNumber))
            {
                throw new ArgumentException(
                    "A saved order is required.",
                    "order");
            }

            session[CompletedOrderIDKey] = order.OrderID;
            session[CompletedOrderNumberKey] = order.OrderNumber;
            session[CartKey] = new Cart();
        }

        public static int? GetCompletedOrderID(
            HttpSessionState session)
        {
            if (session == null ||
                session[CompletedOrderIDKey] == null)
            {
                return null;
            }

            return Convert.ToInt32(session[CompletedOrderIDKey]);
        }

        public static string GetCompletedOrderNumber(
            HttpSessionState session)
        {
            return session == null
                ? null
                : Convert.ToString(
                    session[CompletedOrderNumberKey]);
        }

        public static bool HasCompletedOrder(
            HttpSessionState session)
        {
            return GetCompletedOrderID(session).HasValue;
        }

        public static void ClearActiveOrder(HttpSessionState session)
        {
            if (session == null)
            {
                return;
            }

            session.Remove(CartKey);
            session.Remove(OrderTypeKey);
            session.Remove(StartedAtKey);
            session.Remove(PaymentMethodKey);
            session.Remove(OnlinePaymentConfirmedKey);
            session.Remove(FulfillmentMethodKey);
            session.Remove(TableNumberKey);
            session.Remove(CompletedOrderIDKey);
            session.Remove(CompletedOrderNumberKey);
        }
    }
}
