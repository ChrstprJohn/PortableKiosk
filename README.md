# Portable Kiosk

The Web Forms app uses Tailwind CSS 4. Bootstrap is no longer required. The compiled stylesheet is `PortableKiosk/Content/tailwind.css` and is included in the ASP.NET project, so deployment does not require Node.js.

After changing page classes or stylesheet sources, regenerate it from the repository root:

```powershell
npm install
npm run build:css
```

For local styling work, run `npm run watch:css` in the foreground and stop it when finished. Tailwind scans the ASPX pages, master pages, controls, C# class strings, and app scripts. The existing kiosk-specific and Web Forms rules in `Content/Site.css` and `Content/css/user-kiosk.css` are source files imported by `Content/tailwind.input.css`; pages load only the compiled stylesheet.
