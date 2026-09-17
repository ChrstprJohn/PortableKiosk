<%@ Page
    Title="Staff Sign In"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="AdminLogin.aspx.cs"
    Inherits="PortableKiosk.UI.Account.AdminLogin" %>

<asp:Content
    ID="BodyContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <main class="auth-shell" aria-labelledby="loginHeading">
        <section class="auth-context" aria-label="Staff access information">
            <span class="auth-mark" aria-hidden="true">PK</span>
            <h1>One sign-in.<br />The right workspace.</h1>
            <p>
                Admins continue to kiosk management. Crew members open the
                point-of-sale workspace for their shift.
            </p>

            <div class="auth-route-list" aria-label="Role destinations">
                <div>
                    <strong>Admin</strong>
                    <span>Catalog and staff management</span>
                </div>
                <div>
                    <strong>Crew</strong>
                    <span>Point-of-sale workspace</span>
                </div>
            </div>
        </section>

        <section class="auth-form-panel">
            <div class="auth-form-header">
                <h2 id="loginHeading">Staff sign in</h2>
                <p>Use the account assigned by your administrator.</p>
            </div>

            <asp:ValidationSummary
                ID="validationSummary"
                runat="server"
                ValidationGroup="StaffLoginForm"
                CssClass="alert alert-danger"
                HeaderText="Check the following:"
                DisplayMode="BulletList" />

            <asp:Label
                ID="lblMessage"
                runat="server"
                Visible="false">
            </asp:Label>

            <div class="mb-3">
                <asp:Label
                    ID="lblEmail"
                    runat="server"
                    AssociatedControlID="txtEmail"
                    CssClass="form-label"
                    Text="Email address">
                </asp:Label>

                <asp:TextBox
                    ID="txtEmail"
                    runat="server"
                    CssClass="form-control form-control-lg"
                    TextMode="Email"
                    MaxLength="256"
                    autocomplete="username"
                    placeholder="name@company.com">
                </asp:TextBox>

                <asp:RequiredFieldValidator
                    ID="requiredEmail"
                    runat="server"
                    ControlToValidate="txtEmail"
                    ValidationGroup="StaffLoginForm"
                    ErrorMessage="Email address is required."
                    CssClass="field-error"
                    Display="Dynamic">
                </asp:RequiredFieldValidator>

                <asp:RegularExpressionValidator
                    ID="validEmail"
                    runat="server"
                    ControlToValidate="txtEmail"
                    ValidationGroup="StaffLoginForm"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Enter a valid email address."
                    CssClass="field-error"
                    Display="Dynamic">
                </asp:RegularExpressionValidator>
            </div>

            <div class="mb-4">
                <asp:Label
                    ID="lblPassword"
                    runat="server"
                    AssociatedControlID="txtPassword"
                    CssClass="form-label"
                    Text="Password">
                </asp:Label>

                <asp:TextBox
                    ID="txtPassword"
                    runat="server"
                    CssClass="form-control form-control-lg"
                    TextMode="Password"
                    MaxLength="100"
                    autocomplete="current-password"
                    placeholder="Enter your password">
                </asp:TextBox>

                <asp:RequiredFieldValidator
                    ID="requiredPassword"
                    runat="server"
                    ControlToValidate="txtPassword"
                    ValidationGroup="StaffLoginForm"
                    ErrorMessage="Password is required."
                    CssClass="field-error"
                    Display="Dynamic">
                </asp:RequiredFieldValidator>
            </div>

            <div class="d-grid">
                <asp:Button
                    ID="btnLogin"
                    runat="server"
                    Text="Continue to workspace"
                    CssClass="btn btn-primary btn-lg"
                    ValidationGroup="StaffLoginForm"
                    OnClick="btnLogin_Click" />
            </div>
        </section>
    </main>

</asp:Content>
