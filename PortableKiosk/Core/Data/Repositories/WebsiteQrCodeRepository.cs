using System.Data;
using System.Data.SqlClient;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Data.Repositories
{
    public class WebsiteQrCodeRepository
    {
        public WebsiteQrCode Get()
        {
            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand("dbo.WebsiteQrCode_Get", connection)
                { CommandType = CommandType.StoredProcedure })
            {
                connection.Open();
                object url = command.ExecuteScalar();
                return url == null ? null : new WebsiteQrCode { WebsiteUrl = (string)url };
            }
        }

        public void Save(WebsiteQrCode code)
        {
            using (SqlConnection connection = DatabaseConnection.GetConnection())
            using (SqlCommand command = new SqlCommand("dbo.WebsiteQrCode_Save", connection)
                { CommandType = CommandType.StoredProcedure })
            {
                command.Parameters.Add("@WebsiteUrl", SqlDbType.NVarChar, 2048).Value = code.WebsiteUrl;
                connection.Open();
                command.ExecuteNonQuery();
            }
        }
    }
}
