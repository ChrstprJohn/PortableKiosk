using System;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class KioskSettingsService
    {
        private readonly KioskSettingsRepository repository = new KioskSettingsRepository();

        public KioskSettings Get() { return repository.Get(); }

        public void Save(KioskSettings settings)
        {
            if (settings == null || settings.PendingPaymentExpiryMinutes < 1 ||
                settings.PendingPaymentExpiryMinutes > 1440)
            {
                throw new ArgumentException("Enter an expiration from 1 to 1440 minutes.");
            }
            repository.Save(settings);
        }
    }
}
