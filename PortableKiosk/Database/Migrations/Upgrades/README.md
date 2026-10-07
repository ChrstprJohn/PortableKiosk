# Combined upgrades

These generated bundles upgrade an existing database's schema/configuration and install the related stored procedures. They belong with migrations, rather than data commands.

- `UPDATE ANALYTICS AND ORDER NUMBER CACHE.sql` includes migration 008 and analytics procedures.
- `UPDATE ORDER PROCESSOR ROLE.sql` includes migrations 009 and 010 plus order/POS procedures. It saves the processor's role with their name. Existing processed orders use the linked account's current role at upgrade time; missing/deleted accounts keep an unknown role.
- `UPDATE ORDER PLACED BY.sql` includes the same migrations 009 and 010 plus order/POS procedures for compatibility with the earlier upgrade filename. Use either bundle, not both. Apply any earlier required migrations first.

Run an entire bundle in SSMS. Each can be rerun safely. These are focused alternatives to applying their numbered migration and installing the corresponding procedure files separately; do not treat them as additional numbered migrations.

Run `Database/BuildStoredProcedures.ps1` to regenerate these bundles and `InstallStoredProcedures.sql` from their source files.
