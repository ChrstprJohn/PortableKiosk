# PortableKiosk paper-to-browser feature audit

Date: 2026-10-07 (Asia/Manila)
Source: supplied pasted-text-1.txt, “PortableKiosk: A QR-Driven Kiosk System for Instant POS Order Retrieval”.
Requested account: picardochristopherjohnoleo1@gmail.com

## Current audit status

Browser audit performed at https://localhost:44375/. Every declared requirement is accounted for. Unchecked rows have explicit verification limits; they are not assumed failures. Admin login succeeded with the requested account. The earlier port 44318 was supplied in error and is not an implementation finding. No code changes made. Browser test transactions are recorded below. 

Legend: NOT TESTED = no browser evidence yet; PASS = completed browser workflow with observed result; FAIL = reproducible failure; PARTIAL = only part verified; BLOCKED = prerequisite prevents verification. Checkboxes are checked only after verification.

## Customer ordering

| Verified | ID | Requirement | Result / evidence |
|---|---|---|---|
| [ ] | C01 | QR opens the ordering website in a browser without installing an app | PARTIAL - QR and destination exist; link opens welcome on this PC. Saved localhost URL cannot provide customer-phone access; physical scan unverified. |
| [ ] | C02 | Phone-accessible ordering and usable mobile layout | BLOCKED - phone access unverified. Requested 390x844 viewport did not apply: observed 1372x843. Mobile layout cannot be judged. |
| [x] | C03 | Browse menu categories | PASS — see browser test records below |
| [x] | C04 | Browse products with images and prices | PASS - see evidence below |
| [x] | C05 | Select available product sizes and corresponding item | PASS — see browser test records below |
| [x] | C06 | Add products to cart | PASS — see browser test records below |
| [x] | C07 | Increase and decrease quantities | PASS — see browser test records below |
| [x] | C08 | Remove cart items | PASS - see evidence below |
| [x] | C09 | Review items and accurate total before submitting | PASS — see browser test records below |
| [x] | C10 | Select dine-in or takeout | PASS — see browser test records below |
| [x] | C11 | Select counter pickup or table service | PASS — see browser test records below |
| [x] | C12 | Supply table or locator number when required; retain in fulfillment details | PASS — see browser test records below |
| [x] | C13 | Choose cash payment at counter | PASS — see browser test records below |
| [x] | C14 | Complete simulated cashless payment option | PASS - see evidence below |
| [x] | C15 | Submission generates an order number | PASS — see browser test records below |
| [x] | C16 | Show relevant payment or pickup instructions | PASS — see browser test records below |
| [x] | C17 | Automatically expire unpaid counter orders after configured period | PASS - see evidence below |

## Cashier POS and receipts

| Verified | ID | Requirement | Result / evidence |
|---|---|---|---|
| [x] | P01 | Retrieve pending cash-payment kiosk order by order number | PASS — see browser test records below |
| [x] | P02 | Retrieved items, sizes, quantities and totals match kiosk order without re-encoding | PASS — see browser test records below |
| [x] | P03 | Review retrieved order before payment | PASS — see browser test records below |
| [x] | P04 | Adjust retrieved order items and quantities before payment | PASS — see browser test records below |
| [x] | P05 | Create a new counter order | PASS - see evidence below |
| [x] | P06 | Record cash received and calculate accurate change | PASS — see browser test records below |
| [x] | P07 | Record payment and mark order paid | PASS — see browser test records below |
| [x] | P08 | Complete mock QR cashless transaction | PASS - see evidence below |
| [x] | P09 | Show completed receipt / receipt preview after payment | PASS — see browser test records below |
| [x] | P10 | Download PDF receipt containing correct transaction details | PASS - see evidence below |
| [x] | P11 | Expired unpaid orders are no longer valid for pending-order payment retrieval | PASS - see evidence below |

## Kitchen and public display

| Verified | ID | Requirement | Result / evidence |
|---|---|---|---|
| [x] | K01 | Paid orders appear on kitchen board | PASS — see browser test records below |
| [x] | K02 | Kitchen order shows items and fulfillment details | PASS — see browser test records below |
| [x] | K03 | Staff can manually advance order through preparation | PASS — see browser test records below |
| [x] | K04 | Staff can manually advance order to serving | PASS — see browser test records below |
| [x] | K05 | Staff can manually mark order completed | PASS — see browser test records below |
| [x] | K06 | Public display shows preparing order numbers | PASS — see browser test records below |
| [x] | K07 | Public display shows serving order numbers and reflects status changes | PASS — see browser test records below |

## Administration

| Verified | ID | Requirement | Result / evidence |
|---|---|---|---|
| [x] | A01 | Admin sign-in with requested account | PASS — see browser test records below |
| [ ] | A02 | Manage products | PARTIAL - existing product edit/save and availability verified. Add form opens. Creation/deletion not exercised. |
| [ ] | A03 | Manage categories | PARTIAL - Burgers category edit/save succeeded. Add/delete controls present; creation/deletion not exercised. |
| [ ] | A04 | Manage sizes | PARTIAL - Large size edit/save succeeded. Add/delete controls present; creation/deletion not exercised. |
| [ ] | A05 | Manage variants | PARTIAL - variant edit/save and price propagation verified. Add form opens; creation/deletion not exercised. |
| [x] | A06 | Manage prices; changes reflected in ordering | PASS - see evidence below |
| [ ] | A07 | Manage images; changes reflected in ordering | BLOCKED - image previews/replacement controls present. Preview button and direct file input chooser attempts timed out at 3s/10s. No upload saved; tool limitation does not establish app failure. |
| [x] | A08 | Manage availability; unavailable products cannot be ordered | PASS - see evidence below |
| [ ] | A09 | Manage staff accounts | PARTIAL - staff list and authorized admin edit/save succeeded. Add form inspected/cancelled; no new accounts created. |
| [ ] | A10 | Role-based access enforced for staff and admin | PARTIAL - admin can use admin/POS/kitchen. Role choices show Crew POS/kitchen and Admin all workspaces. Crew denial of admin cannot be tested using only authorized admin account. |
| [x] | A11 | View order records | PASS - see evidence below |
| [x] | A12 | Filter order records by payment status | PASS - see evidence below |
| [x] | A13 | Filter order records by kitchen status | PASS - see evidence below |
| [x] | A14 | Disable and enable kiosk ordering with observed customer effect | PASS — see browser test records below |
| [x] | A15 | Configure unpaid-order validity period and verify resulting expiration | PASS - see evidence below |

## Analytics and Excel reports

| Verified | ID | Requirement | Result / evidence |
|---|---|---|---|
| [x] | N01 | Today period | PASS - see evidence below |
| [x] | N02 | Last 7 Days period | PASS - see evidence below |
| [x] | N03 | This Month period | PASS - see evidence below |
| [x] | N04 | This Year period | PASS - see evidence below |
| [x] | N05 | Total paid revenue is accurate | PASS — see browser test records below |
| [x] | N06 | Paid order count is accurate | PASS — see browser test records below |
| [x] | N07 | Average order value is accurate | PASS — see browser test records below |
| [x] | N08 | Sales trends show revenue movement for selected period | PASS — see browser test records below |
| [x] | N09 | Top five products ranked by units sold | PASS — see browser test records below |
| [x] | N10 | Five least-selling available products, including zero-sales products | PASS — see browser test records below |
| [x] | N11 | Category units sold | PASS — see browser test records below |
| [x] | N12 | Category revenue | PASS — see browser test records below |
| [x] | N13 | Cash and simulated cashless order counts | PASS — see browser test records below |
| [x] | N14 | Cash and simulated cashless sales amounts | PASS — see browser test records below |
| [x] | N15 | Cash and simulated cashless payment shares | PASS — see browser test records below |
| [x] | N16 | Orders placed | PASS — see browser test records below |
| [x] | N17 | Paid orders in order outcomes | PASS — see browser test records below |
| [x] | N18 | Payment conversion rate | PASS — see browser test records below |
| [x] | N19 | Expired unpaid order count | PASS - see evidence below |
| [x] | N20 | Awaiting-payment order count | PASS — see browser test records below |
| [x] | N21 | Expired unpaid value shown separately and excluded from sales revenue | PASS - see evidence below |
| [x] | N22 | Download Excel report | PASS - see evidence below |
| [x] | N23 | Excel overview matches selected-period dashboard | PASS - see evidence below |
| [x] | N24 | Excel sales trends included | PASS - see evidence below |
| [x] | N25 | Excel products included | PASS - see evidence below |
| [x] | N26 | Excel categories included | PASS - see evidence below |
| [x] | N27 | Excel payment methods included | PASS - see evidence below |

## Paper delimitations and interpretation

Cash collection is manual; cashless payments are simulated. Automatic receipt-printer integration, live payment gateways and forecasting are expressly outside scope and are not missing features. Kitchen progress is manually updated. Expired unpaid orders must not contribute sales revenue. Reducing queues and hardware costs are project aims; browser testing alone cannot establish measured real-world improvement.

## Major gaps and recommendation

Tested core workflows match the paper and work. No missing core module was established. The major setup gap is the saved QR destination https://localhost:44375/Default.aspx: customers cannot reach the host computer from a phone using localhost. Before demonstrating QR/phone ordering, use a reachable LAN or deployed URL, update/reprint the QR, and verify an actual phone scan. This is a configuration/deployment need, not evidence that a new ordering feature must be coded. Full approval is conditional on the unchecked items; no cosmetic changes are recommended.

## Verified browser test records

- #0006: Dine-in, table service, locator 77; two Medium Calamansi Coolers at ₱49, total ₱98. Cart quantity 2 → 1 → 2 recalculated ₱98 → ₱49 → ₱98. POS loaded exact order and locator; quantity 2 → 3 → 2 recalculated ₱98 → ₱147 → ₱98. Cash ₱100 produced ₱2 change. Receipt preview included correct details; PDF downloaded as receipt-0006 (1).pdf (one-page PDF content inspected: correct order/item/size/table/total/tender/change; visual PDF rendering not performed).
- #0006 appeared on kitchen board with two Medium drinks and Table 77. Advanced Queued → Preparing → Serving → Completed. Public board showed preparing 0006 and then automatically moved it to serving.
- Last 7 days baseline: ₱1,057 revenue, 3 paid orders, ₱352.33 average, cash ₱256/1 order, cashless ₱801/2 orders, 6 placed, 2 expired worth ₱238, 1 awaiting. After #0006 payment: ₱1,155, 4 paid, ₱288.75 average, cash ₱354/2 orders, cashless unchanged; 66.7% conversion, 0 awaiting. Calamansi Cooler gained 2 units/₱98; Drinks category gained 2 units/₱98; Oct 7 trend increased from ₱59 to ₱157. Bottom five included zero-selling products.
- Kiosk ordering disabled and saved: welcome displayed Kiosk temporarily unavailable with counter instructions. Re-enabled and verified Start order returned.
- Expiration setting changed 30 → 1 minute. #0007: Takeout/counter pickup, one Regular BBQ Burger worth ₱119; confirmation timer 01:00. Original settings restored immediately to Accept orders enabled and 30 minutes. Expired at 00:00 with new-order instruction; POS refused: This kiosk order has expired. Choose another order. Admin records showed payment Expired and kitchen Cancelled.


## Additional browser evidence

- Cart Remove produced Your cart is empty and Browse menu.
- Bacon Burger availability disabled: removed from customer Burgers list. Re-enabled and verified it returned on category navigation. Regular price changed 129 to 130; customer size selector showed 130. Restored 129 and verified later cart used 129. No image upload was saved.
- Customer cashless #0008: Regular Bacon Burger, Takeout/counter pickup, PHP129. Example QR and Simulate Success led to paid order and wait-for-preparation instructions. Admin record Paid/Cashless; kitchen contained correct item/details.
- POS counter order #0009: Regular Classic Burger, Takeout, PHP89. Mock QR and Simulate payment generated receipt stating Cashless (simulated). Admin record Paid/Cashless and admin processor preserved. #0008 and #0009 both marked Completed in kitchen; existing #0005 untouched.
- Expired payment filter returned #0003/#0004/#0007. Completed kitchen filter returned #0001/#0002/#0006 at test time. Results matched records.
- Existing Burgers category and Large size edit/save succeeded without changing values. Product/variant add forms opened then cancelled. Staff admin edit/save succeeded without changing values. Add-staff form opened then cancelled; role/password/permission changes not performed. Only requested admin used for sign-in.
- Today: PHP375 revenue = #0005 59 + #0006 98 + #0008 129 + #0009 89; four paid, average 93.75. Cash 98/one order; cashless 277/three orders (73.8667%, displayed 74%). Seven placed; four paid (57.1%); three expired (42.9%) worth 357; zero awaiting. Expired #0007 increased unpaid value by 119 and did not increase revenue.
- Last 7 days, This month, This year controls each loaded PHP1373 revenue, six paid, average 228.83, nine placed, three expired. Week/month Daily trends; year Monthly trends. Current sample records fall in all three periods; this explains equal totals. Future boundary cases unverified.
- Browser-downloaded analytics-today-20261007.xlsx opened successfully for read-only inspection. All promised sheets present: Overview, Sales trend, Products, Categories, Payment methods. Overview matches Today metrics. Trend total 375; Products 36 rows including zero sellers and total five units/375; Categories total five units/375; Payment methods cashless three/277 plus cash one/98, shares sum 100%. Native Excel interaction and export visual formatting unverified.
- Browser-downloaded receipt-0006 (1).pdf opened successfully: one page with correct receipt 0006, two Medium Calamansi Coolers, locator 77, total 98, cash received 100, change 2.
- Website QR saved destination is https://localhost:44375/Default.aspx. Clicking its link opened Welcome - Portable Kiosk. Page explicitly warns localhost works only on this computer. Physical QR scanning unverified.

## Changes and verification limits

Only this Markdown file was deliberately authored in the workspace. No source edits, builds, installs, migrations, database commands or dev servers were run. UI tests created four orders (#0006-#0009): three paid totaling PHP316 and one expired unpaid worth PHP119. They remain in history/analytics; no records deleted. Paid test orders completed in kitchen. Settings restored to ordering enabled/30 minutes. Bacon Burger restored to available/Regular price 129. Category/size/staff saves retained original values. Download files remain in Downloads.

Every unchecked item explicitly records its limit. Catalog creation/deletion, image uploading, crew access restrictions, physical QR scanning and mobile behavior are not fully verified. These are verification needs, not confirmed missing features. The tested workflow is good for a desktop demonstration, but the phone-access objective is not ready with the current QR link.
