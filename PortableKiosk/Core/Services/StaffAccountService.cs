using System;
using System.Collections.Generic;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;
using PortableKiosk.Shared.Security;

namespace PortableKiosk.Core.Services
{
    public class StaffAccountService
    {
        private readonly StaffAccountRepository staffAccountRepository =
            new StaffAccountRepository();

        public int AddAdmin(
            StaffAccount account,
            string plainTextPassword)
        {
            return staffAccountRepository.AddAdmin(
                account,
                plainTextPassword);
        }

        public int AddCrew(
            StaffAccount account,
            string plainTextPassword)
        {
            return staffAccountRepository.AddCrew(
                account,
                plainTextPassword);
        }

        public List<StaffAccount> GetAll()
        {
            return staffAccountRepository.GetAll();
        }

        public StaffAccount Authenticate(
            string email,
            string plainTextPassword)
        {
            StaffAccount staff =
                staffAccountRepository.GetByEmail(email);

            if (staff == null ||
                !staff.IsActive ||
                !IsSupportedRole(staff.StaffRole) ||
                !PasswordHasher.Verify(
                    plainTextPassword,
                    staff.PasswordSalt,
                    staff.PasswordHash,
                    staff.PasswordIterations))
            {
                return null;
            }

            return staff;
        }

        private static bool IsSupportedRole(string staffRole)
        {
            return string.Equals(
                    staffRole,
                    "ADMIN",
                    StringComparison.OrdinalIgnoreCase) ||
                string.Equals(
                    staffRole,
                    "CREW",
                    StringComparison.OrdinalIgnoreCase);
        }
    }
}
