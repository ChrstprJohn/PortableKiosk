# Database commands

These scripts manage data in the existing `portable_kiosk_db`. They do not upgrade the schema.

To clear the database and reload the catalog:

1. Stop accepting orders while resetting and repopulating.
2. Run the entire `RESET DATA KEEP USERS.sql` file in SSMS. It clears orders, payments, order items, categories, sizes, products, variants, and the saved website QR link. It restores the default kiosk settings and restarts catalog/order identities at 1. Every existing admin and crew account remains unchanged.
3. Run the entire `POPULATE CATALOG.sql` file. An empty catalog receives 5 categories, 3 sizes, 35 products, and 105 variants. Rerunning it preserves existing entries.
4. Save the website QR link again if needed.

The reset uses one transaction with rollback on failure. SQL Server foreign keys prevent truncating referenced tables, so it deletes in dependency order and reseeds identities while keeping constraints and stored procedures intact. Product image files on disk are retained; clearing variants removes their database image assignments.

`CREATE ADMIN ACCOUNT.sql` is a separate account reset command: it deletes all existing staff before inserting the configured admin. Do not run it as part of the data reset above. `CREATE CREW ACCOUNT.sql` is a template requiring real names, email, and application-compatible password hash/salt values.

Schema and procedure upgrade bundles live in `../Migrations/Upgrades/`. Numbered schema migrations live in `../Migrations/`.
