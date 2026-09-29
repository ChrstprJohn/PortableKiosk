# Portable Kiosk

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

- Customers place orders at a self-service kiosk.
- Crew members use the counter POS to take new orders or collect cash for kiosk orders.
- Admins manage the catalog, orders, and staff accounts.

## Product Purpose

Portable Kiosk carries an order from menu selection through payment and kitchen fulfillment. The counter POS lets crew review a pending kiosk cash order or build a new sale, collect cash or simulate cashless payment, and show the resulting receipt.

## Operating Context

The POS opens in an idle state. Crew can select a kiosk order awaiting cash payment or start a new counter order. Product and quantity changes are staged during the sale and saved with a successful payment. The completed receipt is shown on screen before the POS returns to idle.

## Capabilities and Constraints

- The application is ASP.NET Web Forms on .NET Framework 4.7.2 with SQL Server.
- Tailwind CSS is compiled into the deployed stylesheet.
- The POS offers cash collection and a simulated cashless QR payment. Kiosk orders eligible for pickup in the POS are pending cash-at-counter orders.
- Existing order and payment records must stay consistent when a kiosk order is changed and paid.
- New counter orders support dine-in and takeout with counter pickup.

## Evidence on Hand

- The order, item, payment, product, category, and size models and repositories are in PortableKiosk/Core.
- Customer kiosk and admin workflows are in PortableKiosk/UI/User and PortableKiosk/UI/Admin.
- Product images are in PortableKiosk/Content/images/products.

## Product Principles

- Keep the amount due, cash received, and change clear to the cashier.
- Commit a kiosk order's revised items and payment together.
- Return the register to a ready state after the receipt is closed.
