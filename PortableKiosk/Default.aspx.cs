using System;
using PortableKiosk.Core.Data;

namespace PortableKiosk
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!IsPostBack)
            {
                TestDatabaseConnection();
            }
        }

        private void TestDatabaseConnection()
        {
            string message =
                DatabaseConnection.TestConnection();

            DatabaseStatusLabel.Text = message;

            if (message ==
                "Database connection successful.")
            {
                DatabaseStatusLabel.CssClass =
                    "text-success";
            }
            else
            {
                DatabaseStatusLabel.CssClass =
                    "text-danger";
            }
        }
    }
}