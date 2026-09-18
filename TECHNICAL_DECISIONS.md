# Portable Kiosk Technical Decisions

This document records the initial organization decisions for the Portable Kiosk ASP.NET Web Forms application. It is kept outside the `PortableKiosk` web project so it serves as project-level documentation rather than deployed application content.

## 1. Application type

- Platform: ASP.NET Web Forms on .NET Framework 4.7.2.
- Database: Microsoft SQL Server.
- UI files use the standard Web Forms triplet: `.aspx`, `.aspx.cs`, and `.aspx.designer.cs`.
- Master pages use the corresponding `.Master`, `.Master.cs`, and `.Master.designer.cs` triplet.

## 2. Layering and dependency direction

The application follows this dependency flow:

```text
UI page/code-behind -> Service -> Repository -> DbConnectionFactory -> SQL Server
```

- Code-behind handles page events, validation messages, binding, navigation, and display state.
- Services contain business rules and coordinate use cases.
- Repositories contain SQL commands and map database rows to models.
- `DbConnectionFactory` creates database connections but does not contain feature queries.
- SQL must not be placed directly in page code-behind files.

## 3. UI areas

- `UI/User`: public customer kiosk flow, including home, menu, cart, checkout, and order status.
- `UI/Admin`: protected administration screens for products, categories, bundles, orders, and accounts.
- `UI/Account`: authentication screens such as login, logout, and access denied.
- `UI/User` means the customer-facing kiosk experience; it is separate from the `UserAccount` model.

## 4. Core application code

- `Core/Models`: domain and data models such as `UserAccount`, `Category`, `Size`, `Product`, `ProductVariant`, `Bundle`, `BundleComponent`, `Order`, `OrderItem`, and `OrderItemBundleComponent`. Cart-specific models may be added when required.
- `Core/Services`: account, catalog, bundle, cart, and order business logic.
- `Core/Data/Repositories`: feature repositories for account, catalog, bundle, and order persistence.
- `Core/Data/DbConnectionFactory.cs`: the single shared place for creating configured SQL connections.

## 5. Shared application code

- `Shared/Layouts`: separate user and admin master pages.
- `Shared/Controls`: reusable Web Forms user controls only. A header or footer should remain inside its master page when it is not reused elsewhere.
- `Shared/Helpers`: small stateless helpers, including session-related helpers where appropriate.
- `Shared/Security`: authentication and authorization components.
- `Shared/Constants`: genuine application-wide constants; it must not become a miscellaneous settings folder.

## 6. Accounts and authorization

- Account records and roles are database concepts; authentication pages belong in `UI/Account`.
- At minimum, protected admin pages must verify the authenticated account and required role.
- Passwords must be stored as secure password hashes, never as plain text.
- Unauthorized users should be redirected to `UI/Account/AccessDenied.aspx` or the login page.

## 7. Database organization

- Database scripts live in the repository-level `Database` directory, outside the deployable web project.
- `Schema.sql` is the authoritative base schema.
- `SeedData.sql` will contain development/reference data when it is created.
- `Migrations` will contain ordered, incremental schema changes when they are needed.
- Current domains are Accounts, Catalog, Bundles, and Orders.

## 8. Static assets

- Existing package-managed assets remain in place until their bundle references are deliberately replaced.
- New application styles belong in `Content/css`.
- Images belong in `Content/images`; fonts belong in `Content/fonts`.
- New application JavaScript belongs in `Scripts/app`, partitioned by domain area and common utilities.
- Third-party scripts belong in `Scripts/vendor` only when they are not already managed by the current NuGet/package setup.

## 9. JavaScript architecture and conventions

- **Dedicated Script Files**: Avoid inline `<script>` tags inside `.aspx` files. Place client-side logic in dedicated `.js` files under `Scripts/app/`.
- **Folder Partitioning**: Client scripts mirror the UI area hierarchy:
  - `Scripts/app/common/`: Shared utilities, formatters, HTTP/Ajax helpers, notification/modal wrappers.
  - `Scripts/app/user/`: Customer-facing kiosk flow (home, menu, cart, checkout).
  - `Scripts/app/admin/`: Administration screens (products, categories, orders, bundles).
  - `Scripts/app/pos/`: POS / cashier workflow scripts.
  - `Scripts/app/account/`: Authentication and profile screens.
- **Script Inclusion**:
  - Master pages provide a `<asp:ContentPlaceHolder ID="ScriptsContent" runat="server" />` right before the closing body tag.
  - Individual `.aspx` views reference their dedicated script via `<asp:Content ContentPlaceHolderID="ScriptsContent" runat="server">` using `<script src="<%= ResolveUrl("~/Scripts/app/...") %>"></script>`.
- **Web Forms Client ID Handling**:
  - Favor HTML5 `data-*` attributes (e.g., `data-product-id`, `data-action`) or CSS classes for JS event binding and selectors to avoid coupling with Web Forms mangled control IDs.
  - Use `ClientIDMode="Static"` on server controls where direct ID access in JS is strictly necessary.
- **Scoping**: Wrap page script code in Immediately Invoked Function Expressions (IIFE) or modular namespaces to prevent global namespace pollution.
- **Partial Postbacks**: If ASP.NET AJAX `UpdatePanel` is utilized, re-bind event handlers via `Sys.WebForms.PageRequestManager.getInstance().add_endRequest(...)`.

## 10. Root and routing behavior

- `Default.aspx` remains the root entry point until routing deliberately replaces it. It can later redirect to `UI/User/Home.aspx`.
- `Site.Master` remains temporarily so the starter page continues to have a valid master page while the new layouts are being built.
- Friendly URL and bundle configuration remain enabled through `App_Start`.

## 11. Project maintenance rules

- Add or move Web Forms files through Visual Studio when possible so the `.csproj`, namespaces, `Inherits`, and `DependentUpon` entries remain correct.
- Generated `.vs`, `bin`, and `obj` directories are not source and may be regenerated.
- Do not manually edit generated `.designer.cs` files unless there is a specific recovery reason.
- Do not remove package, bundle, Web Forms, Bootstrap, or jQuery assets until all references have been checked and replaced.

## 12. Planned directory layout

```text
PORTABLE_KIOSK/
|-- Database/
|   |-- Schema.sql
|   `-- Migrations/
|-- TECHNICAL_DECISIONS.md
`-- PortableKiosk/
    |-- UI/
    |   |-- User/
    |   |-- Admin/
    |   |-- POS/
    |   `-- Account/
    |-- Core/
    |   |-- Models/
    |   |-- Services/
    |   `-- Data/
    |       `-- Repositories/
    |-- Shared/
    |   |-- Controls/
    |   |-- Layouts/
    |   |-- Helpers/
    |   |-- Security/
    |   `-- Constants/
    |-- Content/
    |   |-- css/
    |   |-- images/
    |   `-- fonts/
    |-- Scripts/
    |   |-- app/
    |   |   |-- common/
    |   |   |-- user/
    |   |   |-- admin/
    |   |   |-- pos/
    |   |   `-- account/
    |   `-- vendor/
    |-- App_Start/
    |-- Properties/
    |-- Default.aspx
    |-- Global.asax
    |-- Web.config
    `-- PortableKiosk.csproj
```
