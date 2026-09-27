using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace PortableKiosk
{
    public partial class SiteMaster : MasterPage
    {
        protected string TailwindStylesheetUrl
        {
            get
            {
                string stylesheetPath = Server.MapPath("~/Content/tailwind.css");
                string version = File.GetLastWriteTimeUtc(stylesheetPath)
                    .Ticks.ToString(CultureInfo.InvariantCulture);
                return ResolveUrl("~/Content/tailwind.css") + "?v=" + version;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            var stylesheet = new HtmlLink { Href = TailwindStylesheetUrl };
            stylesheet.Attributes["rel"] = "stylesheet";
            var styleSlot = (PlaceHolder)Page.Header.FindControl("TailwindStyleSlot");
            styleSlot.Controls.Add(stylesheet);
        }
    }
}
