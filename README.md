# Portable Kiosk

To clear non-user data before repopulating the catalog, run `PortableKiosk/Database/Commands/RESET DATA KEEP USERS.sql`, then `PortableKiosk/Database/Commands/POPULATE CATALOG.sql`. The reset preserves all admin/crew accounts, clears orders/payments/catalog and the saved QR link, restores default kiosk settings, and restarts catalog/order IDs at 1. See `Database/Commands/README.md` for details. Combined schema/procedure upgrades are in `PortableKiosk/Database/Migrations/Upgrades/`.

For an existing `portable_kiosk_db`, apply any migrations not yet run in numeric order. If migration 005 was the last one applied, run `PortableKiosk/Database/Migrations/006_RENAME_READY_TO_SERVING.sql` once before deploying this version. It converts existing kitchen orders from `READY` to `SERVING` and updates the status constraint. If 005 has not been applied, run it before 006.

For the admin website QR page, apply `PortableKiosk/Database/Migrations/007_ADD_WEBSITE_QR_CODE.sql` to an existing database, then run `PortableKiosk/Database/InstallStoredProcedures.sql` (or just `StoredProcedures/WebsiteQrCodeRepository.sql` if the other procedures are already installed). Migration 007 is safe to rerun and keeps any saved link.

For a fresh database, run `PortableKiosk/Database/Schema.sql` once, then `PortableKiosk/Database/InstallStoredProcedures.sql`. It creates the current schema, including kiosk settings, the `SERVING` kitchen status, and website QR links; do not run the migrations afterward. `Schema.sql` creates tables and is not an upgrade script for an existing database.

Open **Website QR code** in the admin sidebar. The first visit suggests the current website's `Default.aspx` URL, including the local port and application path. Save it to create the single QR record; later saves edit that record. The QR contains only the saved URL and is generated locally using the bundled [Project Nayuki QR library](https://www.nayuki.io/page/qr-code-generator-library) (MIT). **Print QR code** prints the QR sign and link without the admin navigation or editor. Editing the URL requires reprinting existing signs. A localhost URL is only reachable on the hosting computer; phone scans need a reachable LAN or deployed URL and appropriate server bindings.

The Web Forms app uses Tailwind CSS 4. Bootstrap is no longer required. The compiled stylesheet is `PortableKiosk/Content/tailwind.css` and is included in the ASP.NET project, so deployment does not require Node.js.

After changing page classes or stylesheet sources, regenerate it from the repository root:

```powershell
npm install
npm run build:css
```

For local styling work, run `npm run watch:css` in the foreground and stop it when finished. Tailwind scans the ASPX pages, master pages, controls, C# class strings, and app scripts. The existing kiosk-specific and Web Forms rules in `Content/Site.css` and `Content/css/user-kiosk.css` are source files imported by `Content/tailwind.input.css`; pages load only the compiled stylesheet.
