using System;
using System.Text;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class WebsiteQrCodeService
    {
        private readonly WebsiteQrCodeRepository repository = new WebsiteQrCodeRepository();

        public WebsiteQrCode Get() { return repository.Get(); }

        public void Save(string websiteUrl)
        {
            repository.Save(new WebsiteQrCode { WebsiteUrl = ValidateUrl(websiteUrl) });
        }

        public static string ValidateUrl(string websiteUrl)
        {
            string value = (websiteUrl ?? string.Empty).Trim();
            Uri url;
            if (!Uri.TryCreate(value, UriKind.Absolute, out url) ||
                (url.Scheme != Uri.UriSchemeHttp && url.Scheme != Uri.UriSchemeHttps) ||
                string.IsNullOrEmpty(url.Host) || !string.IsNullOrEmpty(url.UserInfo))
            {
                throw new ArgumentException("Enter a full website link starting with http:// or https://, without a username or password.");
            }

            // Keep the encoded URL within both the SQL field and QR byte capacity.
            value = url.AbsoluteUri;
            if (value.Length > 2048 || Encoding.UTF8.GetByteCount(value) > 2048)
            {
                throw new ArgumentException("The website link is too long. Use a shorter link (up to 2048 bytes).");
            }
            return value;
        }
    }
}
