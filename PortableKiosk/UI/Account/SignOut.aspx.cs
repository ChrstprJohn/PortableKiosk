using System;

namespace PortableKiosk.UI.Account
{
    public partial class SignOut : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();

            Response.Redirect(
                "~/UI/Account/AdminLogin.aspx",
                false);

            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
