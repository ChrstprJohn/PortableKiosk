namespace PortableKiosk.UI.Admin
{
    public partial class StaffAccounts
    {
        protected global::System.Web.UI.WebControls.ValidationSummary validationSummary;
        protected global::System.Web.UI.WebControls.Label lblMessage;
        protected global::System.Web.UI.WebControls.Label lblFirstName;
        protected global::System.Web.UI.WebControls.TextBox txtFirstName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator requiredFirstName;
        protected global::System.Web.UI.WebControls.Label lblMiddleName;
        protected global::System.Web.UI.WebControls.TextBox txtMiddleName;
        protected global::System.Web.UI.WebControls.Label lblLastName;
        protected global::System.Web.UI.WebControls.TextBox txtLastName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator requiredLastName;
        protected global::System.Web.UI.WebControls.Label lblSuffix;
        protected global::System.Web.UI.WebControls.TextBox txtSuffix;
        protected global::System.Web.UI.WebControls.Label lblEmail;
        protected global::System.Web.UI.WebControls.TextBox txtEmail;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator requiredEmail;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator validEmail;
        protected global::System.Web.UI.WebControls.Label lblRole;
        protected global::System.Web.UI.WebControls.DropDownList ddlRole;
        protected global::System.Web.UI.WebControls.CheckBox chkIsActive;
        protected global::System.Web.UI.WebControls.Label lblPassword;
        protected global::System.Web.UI.WebControls.TextBox txtPassword;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator requiredPassword;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator validPasswordLength;
        protected global::System.Web.UI.WebControls.Label lblConfirmPassword;
        protected global::System.Web.UI.WebControls.TextBox txtConfirmPassword;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator requiredConfirmPassword;
        protected global::System.Web.UI.WebControls.CompareValidator passwordsMatch;
        protected global::System.Web.UI.WebControls.Button btnCreateStaff;
        protected global::System.Web.UI.WebControls.Label lblLoadError;
        protected global::System.Web.UI.WebControls.GridView gridStaff;
    }
}
