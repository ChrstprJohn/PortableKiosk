using System;

namespace PortableKiosk.UI.POS
{
    public partial class Index : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StaffAccountID"] == null)
            {
                Redirect("~/UI/Account/AdminLogin.aspx");
                return;
            }

            string staffRole =
                Convert.ToString(Session["StaffRole"]);

            bool isCrew = string.Equals(
                staffRole,
                "CREW",
                StringComparison.OrdinalIgnoreCase);

            if (string.Equals(
                staffRole,
                "ADMIN",
                StringComparison.OrdinalIgnoreCase))
            {
                Redirect("~/UI/Admin/CreateCategory.aspx");
                return;
            }

            if (!isCrew)
            {
                Session.Clear();
                Redirect("~/UI/Account/AdminLogin.aspx");
                return;
            }

            if (!IsPostBack)
            {
                litStaffName.Text = Server.HtmlEncode(
                    Convert.ToString(
                        Session["StaffDisplayName"]));
                lblStaffRole.Text = Server.HtmlEncode(
                    staffRole);
                lblStaffRole.CssClass =
                    "role-badge role-crew";
            }
        }

        protected void btnSignOut_Click(
            object sender,
            EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Redirect("~/UI/Account/AdminLogin.aspx");
        }

        private void Redirect(string destination)
        {
            Response.Redirect(destination, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
