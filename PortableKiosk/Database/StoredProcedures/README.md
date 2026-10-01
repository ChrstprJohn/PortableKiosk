Each repository has one SQL file containing its stored procedures. The application calls these procedures using `CommandType.StoredProcedure`; install them before running the updated application.

Apply `Schema.sql` for a new database, or the required migrations for an existing database. Then open `Database/InstallStoredProcedures.sql` in SSMS and execute it. It selects `portable_kiosk_db` and installs all repository procedures without changing table data. SQL Server 2016 SP1 or newer is required for `CREATE OR ALTER`. Re-running the script updates existing procedures.

After changing an individual repository SQL file, run `./BuildStoredProcedures.ps1` from the Database directory to regenerate the global installer. The installer is self-contained and does not require SQLCMD mode.

Transactions remain controlled by the repositories, including POS locking and payment/order updates. Affected-row counts remain enabled because update/delete methods use `ExecuteNonQuery()` to determine success. The expiry procedure retains its original `NOCOUNT ON` and scalar count result.
