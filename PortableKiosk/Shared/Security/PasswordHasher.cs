using System.Security.Cryptography;

namespace PortableKiosk.Shared.Security
{
    public static class PasswordHasher
    {
        private const int SaltSize = 16;
        private const int HashSize = 32;

        public static void Create(
            string password,
            int iterations,
            out byte[] salt,
            out byte[] hash)
        {
            if (string.IsNullOrEmpty(password))
            {
                throw new System.ArgumentException(
                    "Password is required.",
                    "password");
            }

            if (iterations <= 0)
            {
                throw new System.ArgumentOutOfRangeException(
                    "iterations");
            }

            salt = new byte[SaltSize];

            using (RandomNumberGenerator random =
                RandomNumberGenerator.Create())
            {
                random.GetBytes(salt);
            }

            using (Rfc2898DeriveBytes passwordHasher =
                new Rfc2898DeriveBytes(
                    password,
                    salt,
                    iterations,
                    HashAlgorithmName.SHA256))
            {
                hash = passwordHasher.GetBytes(HashSize);
            }
        }

        public static bool Verify(
            string password,
            byte[] salt,
            byte[] expectedHash,
            int iterations)
        {
            if (string.IsNullOrEmpty(password) ||
                salt == null ||
                expectedHash == null ||
                iterations <= 0)
            {
                return false;
            }

            byte[] actualHash;

            using (Rfc2898DeriveBytes passwordHasher =
                new Rfc2898DeriveBytes(
                    password,
                    salt,
                    iterations,
                    HashAlgorithmName.SHA256))
            {
                actualHash =
                    passwordHasher.GetBytes(
                        expectedHash.Length);
            }

            return FixedTimeEquals(
                actualHash,
                expectedHash);
        }

        private static bool FixedTimeEquals(
            byte[] first,
            byte[] second)
        {
            if (first == null ||
                second == null ||
                first.Length != second.Length)
            {
                return false;
            }

            int difference = 0;

            for (int index = 0;
                index < first.Length;
                index++)
            {
                difference |=
                    first[index] ^ second[index];
            }

            return difference == 0;
        }
    }
}
