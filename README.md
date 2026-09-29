# Portable Kiosk

For an existing database, run `PortableKiosk/Database/Migrations/005_ADD_KIOSK_SETTINGS.sql` against `portable_kiosk_db` before deploying this version. A fresh database created from `PortableKiosk/Database/Schema.sql` already includes the settings row. The admin **Settings** page controls kiosk availability and the payment deadline for new cash-at-counter orders.

The Web Forms app uses Tailwind CSS 4. Bootstrap is no longer required. The compiled stylesheet is `PortableKiosk/Content/tailwind.css` and is included in the ASP.NET project, so deployment does not require Node.js.

After changing page classes or stylesheet sources, regenerate it from the repository root:

```powershell
npm install
npm run build:css
```

For local styling work, run `npm run watch:css` in the foreground and stop it when finished. Tailwind scans the ASPX pages, master pages, controls, C# class strings, and app scripts. The existing kiosk-specific and Web Forms rules in `Content/Site.css` and `Content/css/user-kiosk.css` are source files imported by `Content/tailwind.input.css`; pages load only the compiled stylesheet.
