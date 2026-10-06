# Combined upgrades

These generated bundles upgrade an existing database's schema/configuration and install the related stored procedures. They belong with migrations, rather than data commands.

- `UPDATE ANALYTICS AND ORDER NUMBER CACHE.sql` includes migration 008 and analytics procedures.
- `UPDATE ORDER PLACED BY.sql` includes migration 009 and order/POS procedures. Apply any earlier required migrations first.

Run an entire bundle in SSMS. Each can be rerun safely. These are focused alternatives to applying their numbered migration and installing the corresponding procedure files separately; do not treat them as additional numbered migrations.

Run `Database/BuildStoredProcedures.ps1` to regenerate these bundles and `InstallStoredProcedures.sql` from their source files.
