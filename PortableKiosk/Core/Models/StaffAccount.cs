using System;

namespace PortableKiosk.Core.Models
{
    public class StaffAccount
    {
        public int StaffAccountID { get; set; }

        public string FirstName { get; set; }

        public string MiddleName { get; set; }

        public string LastName { get; set; }

        public string Suffix { get; set; }

        public string Email { get; set; }

        public byte[] PasswordHash { get; set; }

        public byte[] PasswordSalt { get; set; }

        public int PasswordIterations { get; set; }

        public string StaffRole { get; set; }

        public bool IsActive { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }

        public string DisplayName
        {
            get
            {
                string name = FirstName;

                if (!string.IsNullOrWhiteSpace(MiddleName))
                {
                    name += " " + MiddleName;
                }

                name += " " + LastName;

                if (!string.IsNullOrWhiteSpace(Suffix))
                {
                    name += " " + Suffix;
                }

                return name;
            }
        }
    }
}
