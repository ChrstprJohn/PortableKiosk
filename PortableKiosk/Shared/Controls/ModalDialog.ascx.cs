using System;
using System.ComponentModel;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PortableKiosk.Shared.Controls
{
    [ParseChildren(true)]
    [PersistChildren(false)]
    public partial class ModalDialog : UserControl
    {
        [Category("Appearance")]
        public string ModalID { get; set; } = "appModal";

        [Category("Appearance")]
        public string Title { get; set; } = string.Empty;

        [Category("Appearance")]
        public string IconCssClass { get; set; } = string.Empty;

        /// <summary>
        /// Options: Small, Default, Large, ExtraLarge, Fullscreen
        /// </summary>
        [Category("Appearance")]
        public string Size { get; set; } = "Default";

        /// <summary>
        /// Options: Primary, Dark, Danger, Success, Warning, Info, Light
        /// </summary>
        [Category("Appearance")]
        public string HeaderVariant { get; set; } = "Primary";

        [Category("Behavior")]
        public bool Centered { get; set; } = true;

        [Category("Behavior")]
        public bool Scrollable { get; set; } = false;

        [Category("Behavior")]
        public bool StaticBackdrop { get; set; } = true;

        [Category("Behavior")]
        public bool ShowCloseButton { get; set; } = true;

        [Category("Behavior")]
        public bool ShowFooter { get; set; } = true;

        [Category("Behavior")]
        public bool ShowDefaultCloseButton { get; set; } = true;

        [Category("Appearance")]
        public string CloseButtonText { get; set; } = "Close";

        [Category("Appearance")]
        public string CustomCssClass { get; set; } = string.Empty;

        [Category("Appearance")]
        public string BodyCssClass { get; set; } = string.Empty;

        [Category("Appearance")]
        public string FooterCssClass { get; set; } = "bg-light";

        [PersistenceMode(PersistenceMode.InnerProperty)]
        [TemplateContainer(typeof(ModalContentContainer))]
        [TemplateInstance(TemplateInstance.Single)]
        [Browsable(false)]
        public ITemplate Body { get; set; }

        [PersistenceMode(PersistenceMode.InnerProperty)]
        [TemplateContainer(typeof(ModalContentContainer))]
        [TemplateInstance(TemplateInstance.Single)]
        [Browsable(false)]
        public ITemplate Footer { get; set; }

        public string ClientModalID => string.IsNullOrEmpty(ModalID) ? ClientID : ModalID;

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            InitializeTemplates();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            litTitle.Text = Title;
        }

        private void InitializeTemplates()
        {
            if (Body != null)
            {
                ModalContentContainer container = new ModalContentContainer();
                Body.InstantiateIn(container);
                phBody.Controls.Add(container);
            }

            if (Footer != null)
            {
                phFooter.Controls.Clear();
                ModalContentContainer footerContainer = new ModalContentContainer();
                Footer.InstantiateIn(footerContainer);
                phFooter.Controls.Add(footerContainer);
            }
        }

        public string GetDialogClasses()
        {
            string classes = string.Empty;
            if (Centered) classes += " modal-dialog-centered";
            if (Scrollable) classes += " modal-dialog-scrollable";

            switch (Size?.ToLowerInvariant())
            {
                case "sm":
                case "small":
                    classes += " modal-sm";
                    break;
                case "lg":
                case "large":
                    classes += " modal-lg";
                    break;
                case "xl":
                case "extralarge":
                    classes += " modal-xl";
                    break;
                case "fullscreen":
                    classes += " modal-fullscreen";
                    break;
            }

            return classes.Trim();
        }

        public string GetHeaderClasses()
        {
            switch (HeaderVariant?.ToLowerInvariant())
            {
                case "dark":
                    return "bg-dark text-white";
                case "danger":
                    return "bg-danger text-white";
                case "success":
                    return "bg-success text-white";
                case "warning":
                    return "bg-warning text-dark";
                case "info":
                    return "bg-info text-white";
                case "light":
                    return "bg-light text-dark";
                case "primary":
                default:
                    return "bg-primary text-white";
            }
        }

        /// <summary>
        /// Triggers client-side opening of the modal from server code
        /// </summary>
        public void Show()
        {
            string script = $"var el = document.getElementById('{ClientModalID}'); if(el) {{ var m = bootstrap.Modal.getOrCreateInstance(el); if(m) m.show(); }}";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), $"ShowModal_{ClientModalID}_{Guid.NewGuid():N}", script, true);
        }

        /// <summary>
        /// Triggers client-side closing of the modal from server code
        /// </summary>
        public void Hide()
        {
            string script = $"var el = document.getElementById('{ClientModalID}'); if(el) {{ var m = bootstrap.Modal.getInstance(el); if(m) m.hide(); }}";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), $"HideModal_{ClientModalID}_{Guid.NewGuid():N}", script, true);
        }
    }

    public class ModalContentContainer : Control, INamingContainer
    {
    }
}
