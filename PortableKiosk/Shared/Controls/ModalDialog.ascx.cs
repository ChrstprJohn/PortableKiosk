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
        public string FooterCssClass { get; set; } = "bg-slate-50";

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
            string classes = "max-w-lg";

            switch (Size?.ToLowerInvariant())
            {
                case "sm":
                case "small":
                    classes = "max-w-sm";
                    break;
                case "lg":
                case "large":
                    classes = "max-w-3xl";
                    break;
                case "xl":
                case "extralarge":
                    classes = "max-w-5xl";
                    break;
                case "fullscreen":
                    classes = "max-w-none";
                    break;
            }

            return classes.Trim();
        }

        public string GetHeaderClasses()
        {
            switch (HeaderVariant?.ToLowerInvariant())
            {
                case "dark":
                    return "bg-slate-900 text-white";
                case "danger":
                    return "bg-red-700 text-white";
                case "success":
                    return "bg-emerald-700 text-white";
                case "warning":
                    return "bg-amber-300 text-slate-900";
                case "info":
                    return "bg-sky-700 text-white";
                case "light":
                    return "bg-slate-100 text-slate-900";
                case "primary":
                default:
                    return "bg-blue-700 text-white";
            }
        }

        /// <summary>
        /// Triggers client-side opening of the modal from server code
        /// </summary>
        public void Show()
        {
            string script = $"AppModal.open('{ClientModalID}');";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), $"ShowModal_{ClientModalID}_{Guid.NewGuid():N}", script, true);
        }

        /// <summary>
        /// Triggers client-side closing of the modal from server code
        /// </summary>
        public void Hide()
        {
            string script = $"AppModal.close('{ClientModalID}');";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), $"HideModal_{ClientModalID}_{Guid.NewGuid():N}", script, true);
        }
    }

    public class ModalContentContainer : Control, INamingContainer
    {
    }
}
