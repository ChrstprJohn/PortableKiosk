# Portable Kiosk

For an existing `portable_kiosk_db`, apply any migrations not yet run in numeric order. If migration 005 was the last one applied, run `PortableKiosk/Database/Migrations/006_RENAME_READY_TO_SERVING.sql` once before deploying this version. It converts existing kitchen orders from `READY` to `SERVING` and updates the status constraint. If 005 has not been applied, run it before 006.

For a fresh database, run `PortableKiosk/Database/Schema.sql` once. It creates the current schema, including kiosk settings and the `SERVING` kitchen status; do not run the migrations afterward. `Schema.sql` creates tables and is not an upgrade script for an existing database.

The Web Forms app uses Tailwind CSS 4. Bootstrap is no longer required. The compiled stylesheet is `PortableKiosk/Content/tailwind.css` and is included in the ASP.NET project, so deployment does not require Node.js.

After changing page classes or stylesheet sources, regenerate it from the repository root:

```powershell
npm install
npm run build:css
```

For local styling work, run `npm run watch:css` in the foreground and stop it when finished. Tailwind scans the ASPX pages, master pages, controls, C# class strings, and app scripts. The existing kiosk-specific and Web Forms rules in `Content/Site.css` and `Content/css/user-kiosk.css` are source files imported by `Content/tailwind.input.css`; pages load only the compiled stylesheet.
