using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using PortableKiosk.Core.Models;
using PortableKiosk.Shared.Constants;

namespace PortableKiosk.Core.Data.Repositories
{
    public class PaymentRepository
    {
        public int Add(Payment payment)
        {
            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            {
                connection.Open();

                using (SqlTransaction transaction =
                    connection.BeginTransaction())
                {
                    try
                    {
                        int paymentID = Add(
                            payment,
                            connection,
                            transaction);
                        transaction.Commit();
                        return paymentID;
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        public Payment GetByID(int paymentID)
        {
            ValidateID(paymentID, "paymentID");
            return GetSingle(
                "PaymentID = @ID",
                paymentID);
        }

        public Payment GetByOrderID(int orderID)
        {
            ValidateID(orderID, "orderID");
            return GetSingle(
                "OrderID = @ID",
                orderID);
        }

        public List<Payment> GetAll()
        {
            const string sql = @"
                SELECT
                    PaymentID,
                    OrderID,
                    PaymentMethod,
                    PaymentStatus,
                    Amount,
                    TransactionReference,
                    PaidAt,
                    CreatedAt
                FROM Payments
                ORDER BY CreatedAt DESC, PaymentID DESC;";

            List<Payment> payments = new List<Payment>();

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                connection.Open();

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        payments.Add(Map(reader));
                    }
                }
            }

            return payments;
        }

        public bool Update(Payment payment)
        {
            Validate(payment);
            ValidateID(payment.PaymentID, "paymentID");

            const string sql = @"
                UPDATE p
                SET
                    OrderID = @OrderID,
                    PaymentMethod = @PaymentMethod,
                    PaymentStatus = @PaymentStatus,
                    Amount = @Amount,
                    TransactionReference = @TransactionReference,
                    PaidAt = @PaidAt
                FROM Payments p
                WHERE p.PaymentID = @PaymentID
                    AND NOT (
                        @PaymentStatus = N'PAID'
                        AND p.PaymentStatus <> N'PAID'
                        AND p.PaymentMethod = N'CASH_COUNTER'
                        AND EXISTS (
                            SELECT 1
                            FROM Orders o
                            WHERE o.OrderID = p.OrderID
                                AND COALESCE(
                                    o.ExpiresAt,
                                    DATEADD(
                                        MINUTE,
                                        @ExpiryMinutes,
                                        o.CreatedAt)) <= SYSUTCDATETIME()
                        )
                    );";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            {
                connection.Open();

                using (SqlTransaction transaction =
                    connection.BeginTransaction())
                {
                    try
                    {
                        int affectedRows;

                        using (SqlCommand command =
                            new SqlCommand(sql, connection, transaction))
                        {
                            AddWriteParameters(command, payment);
                            command.Parameters.Add(
                                "@PaymentID",
                                SqlDbType.Int).Value = payment.PaymentID;
                            command.Parameters.Add(
                                "@ExpiryMinutes",
                                SqlDbType.Int).Value =
                                    OrderSettings.PendingPaymentExpiryMinutes;
                            affectedRows = command.ExecuteNonQuery();
                        }

                        if (affectedRows == 0)
                        {
                            transaction.Rollback();
                            return false;
                        }

                        if (string.Equals(
                            payment.PaymentStatus,
                            "PAID",
                            StringComparison.OrdinalIgnoreCase))
                        {
                            const string queueOrderSql = @"
                                UPDATE Orders
                                SET KitchenStatus = N'QUEUED'
                                WHERE OrderID = @OrderID
                                    AND KitchenStatus = N'AWAITING_PAYMENT';";

                            using (SqlCommand command =
                                new SqlCommand(
                                    queueOrderSql,
                                    connection,
                                    transaction))
                            {
                                command.Parameters.Add(
                                    "@OrderID",
                                    SqlDbType.Int).Value = payment.OrderID;
                                command.ExecuteNonQuery();
                            }
                        }

                        transaction.Commit();
                        return true;
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        public bool Delete(int paymentID)
        {
            ValidateID(paymentID, "paymentID");

            const string sql = @"
                DELETE FROM Payments
                WHERE PaymentID = @PaymentID;";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@PaymentID",
                    SqlDbType.Int).Value = paymentID;
                connection.Open();
                return command.ExecuteNonQuery() > 0;
            }
        }

        internal int Add(
            Payment payment,
            SqlConnection connection,
            SqlTransaction transaction)
        {
            Validate(payment);

            const string sql = @"
                INSERT INTO Payments
                    (
                        OrderID,
                        PaymentMethod,
                        PaymentStatus,
                        Amount,
                        TransactionReference,
                        PaidAt
                    )
                OUTPUT INSERTED.PaymentID
                VALUES
                    (
                        @OrderID,
                        @PaymentMethod,
                        @PaymentStatus,
                        @Amount,
                        @TransactionReference,
                        @PaidAt
                    );";

            using (SqlCommand command =
                new SqlCommand(sql, connection, transaction))
            {
                AddWriteParameters(command, payment);
                payment.PaymentID = Convert.ToInt32(
                    command.ExecuteScalar());
                return payment.PaymentID;
            }
        }

        private static Payment GetSingle(
            string predicate,
            int id)
        {
            string sql = @"
                SELECT
                    PaymentID,
                    OrderID,
                    PaymentMethod,
                    PaymentStatus,
                    Amount,
                    TransactionReference,
                    PaidAt,
                    CreatedAt
                FROM Payments
                WHERE " + predicate + ";";

            using (SqlConnection connection =
                DatabaseConnection.GetConnection())
            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@ID",
                    SqlDbType.Int).Value = id;
                connection.Open();

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    return reader.Read() ? Map(reader) : null;
                }
            }
        }

        private static void AddWriteParameters(
            SqlCommand command,
            Payment payment)
        {
            command.Parameters.Add(
                "@OrderID",
                SqlDbType.Int).Value = payment.OrderID;
            command.Parameters.Add(
                "@PaymentMethod",
                SqlDbType.NVarChar,
                20).Value = payment.PaymentMethod.Trim().ToUpperInvariant();
            command.Parameters.Add(
                "@PaymentStatus",
                SqlDbType.NVarChar,
                20).Value = payment.PaymentStatus.Trim().ToUpperInvariant();

            SqlParameter amount = command.Parameters.Add(
                "@Amount",
                SqlDbType.Decimal);
            amount.Precision = 10;
            amount.Scale = 2;
            amount.Value = payment.Amount;

            command.Parameters.Add(
                "@TransactionReference",
                SqlDbType.NVarChar,
                100).Value = string.IsNullOrWhiteSpace(
                    payment.TransactionReference)
                        ? (object)DBNull.Value
                        : payment.TransactionReference.Trim();
            command.Parameters.Add(
                "@PaidAt",
                SqlDbType.DateTime2).Value = payment.PaidAt.HasValue
                    ? (object)payment.PaidAt.Value
                    : DBNull.Value;
        }

        private static Payment Map(SqlDataReader reader)
        {
            int referenceOrdinal = reader.GetOrdinal(
                "TransactionReference");
            int paidAtOrdinal = reader.GetOrdinal("PaidAt");

            return new Payment
            {
                PaymentID = reader.GetInt32(
                    reader.GetOrdinal("PaymentID")),
                OrderID = reader.GetInt32(
                    reader.GetOrdinal("OrderID")),
                PaymentMethod = reader.GetString(
                    reader.GetOrdinal("PaymentMethod")),
                PaymentStatus = reader.GetString(
                    reader.GetOrdinal("PaymentStatus")),
                Amount = reader.GetDecimal(
                    reader.GetOrdinal("Amount")),
                TransactionReference = reader.IsDBNull(
                    referenceOrdinal)
                        ? null
                        : reader.GetString(referenceOrdinal),
                PaidAt = reader.IsDBNull(paidAtOrdinal)
                    ? (DateTime?)null
                    : reader.GetDateTime(paidAtOrdinal),
                CreatedAt = reader.GetDateTime(
                    reader.GetOrdinal("CreatedAt"))
            };
        }

        private static void Validate(Payment payment)
        {
            if (payment == null)
            {
                throw new ArgumentNullException("payment");
            }

            ValidateID(payment.OrderID, "orderID");

            string method = (payment.PaymentMethod ?? string.Empty)
                .Trim()
                .ToUpperInvariant();
            string status = (payment.PaymentStatus ?? string.Empty)
                .Trim()
                .ToUpperInvariant();

            if (method != "CASHLESS" && method != "CASH_COUNTER")
            {
                throw new ArgumentException(
                    "Choose a valid payment method.",
                    "payment");
            }

            if (status != "PENDING" &&
                status != "PAID" &&
                status != "FAILED" &&
                status != "CANCELLED" &&
                status != "EXPIRED")
            {
                throw new ArgumentException(
                    "Choose a valid payment status.",
                    "payment");
            }

            if (payment.Amount < 0)
            {
                throw new ArgumentException(
                    "Payment amount cannot be negative.",
                    "payment");
            }

            if (!string.IsNullOrWhiteSpace(
                    payment.TransactionReference) &&
                payment.TransactionReference.Trim().Length > 100)
            {
                throw new ArgumentException(
                    "Transaction reference cannot exceed 100 characters.",
                    "payment");
            }
        }

        private static void ValidateID(int id, string parameterName)
        {
            if (id <= 0)
            {
                throw new ArgumentException(
                    "A valid ID is required.",
                    parameterName);
            }
        }
    }
}
