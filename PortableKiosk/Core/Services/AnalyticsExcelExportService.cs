using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Security;
using System.Text;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    /// <summary>Writes a small, self-contained Office Open XML workbook for an analytics report.</summary>
    public class AnalyticsExcelExportService
    {
        private const string SheetNamespace = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
        private static readonly CultureInfo Invariant = CultureInfo.InvariantCulture;

        public byte[] CreateWorkbook(AnalyticsReport report, string periodName, DateTime start, DateTime end)
        {
            if (report == null) throw new ArgumentNullException("report");

            List<Sheet> sheets = new List<Sheet>
            {
                BuildOverview(report, periodName, start, end),
                BuildTrend(report, start, end),
                BuildProducts(report),
                BuildCategories(report),
                BuildPayments(report)
            };

            using (MemoryStream buffer = new MemoryStream())
            {
                using (ZipArchive archive = new ZipArchive(buffer, ZipArchiveMode.Create, true))
                {
                    WriteEntry(archive, "[Content_Types].xml", ContentTypes(sheets.Count));
                    WriteEntry(archive, "_rels/.rels", "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/></Relationships>");
                    WriteEntry(archive, "xl/workbook.xml", Workbook(sheets));
                    WriteEntry(archive, "xl/_rels/workbook.xml.rels", WorkbookRelationships(sheets.Count));
                    WriteEntry(archive, "xl/styles.xml", Styles());
                    for (int i = 0; i < sheets.Count; i++)
                        WriteEntry(archive, "xl/worksheets/sheet" + (i + 1).ToString(Invariant) + ".xml", Worksheet(sheets[i]));
                }
                return buffer.ToArray();
            }
        }

        private static Sheet BuildOverview(AnalyticsReport report, string periodName, DateTime start, DateTime end)
        {
            Sheet sheet = new Sheet("Overview", new[] { 36, 20, 20 });
            sheet.Add(S("Analytics report", 1));
            sheet.Add(S("Period"), S(periodName));
            sheet.Add(S("From (Philippine time)"), S(start.ToString("yyyy-MM-dd", Invariant)));
            sheet.Add(S("Through (Philippine time)"), S(end.AddDays(-1).ToString("yyyy-MM-dd", Invariant)));
            sheet.Add();
            sheet.Add(S("Metric", 2), S("Value", 2));
            sheet.Add(S("Total paid sales"), N(report.TotalSales, 3));
            sheet.Add(S("Paid orders"), N(report.PaidOrders, 4));
            sheet.Add(S("Average order value"), N(report.AverageOrderValue, 3));
            sheet.Add(S("Placed orders"), N(report.PlacedOrders, 4));
            sheet.Add(S("Converted orders"), N(report.ConvertedOrders, 4));
            sheet.Add(S("Order conversion rate"), N(report.ConversionRate / 100m, 5));
            sheet.Add(S("Expired unpaid orders"), N(report.ExpiredOrders, 4));
            sheet.Add(S("Expired potential value"), N(report.ExpiredValue, 3));
            sheet.Add();
            sheet.Add(S("Sales, products and payment methods use paid date."));
            sheet.Add(S("Conversion and expiry use order creation date and current payment outcome."));
            sheet.Add(S("Expired orders exclude carts left before checkout."));
            sheet.Add();
            sheet.Add(S("Popular products", 2), S("Units sold", 2), S("Revenue (PHP)", 2));
            foreach (AnalyticsProductRow product in report.PopularProducts)
                sheet.Add(S(product.Name), N(product.Units, 4), N(product.Revenue, 3));
            sheet.Add();
            sheet.Add(S("Least-selling products (on menu)", 2), S("Units sold", 2), S("Revenue (PHP)", 2));
            foreach (AnalyticsProductRow product in report.LeastProducts)
                sheet.Add(S(product.Name), N(product.Units, 4), N(product.Revenue, 3));
            return sheet;
        }

        private static Sheet BuildTrend(AnalyticsReport report, DateTime start, DateTime end)
        {
            bool monthly = (end - start).TotalDays > 90;
            Sheet sheet = new Sheet("Sales trend", new[] { 22, 20 }) { Filter = true };
            sheet.Add(S(monthly ? "Month (PH)" : "Date (PH)", 2), S("Paid sales (PHP)", 2));
            Dictionary<DateTime, decimal> sales = report.Trend.ToDictionary(point => point.Date, point => point.Sales);
            for (DateTime date = start; date < end; date = monthly ? date.AddMonths(1) : date.AddDays(1))
            {
                decimal amount;
                sales.TryGetValue(date, out amount);
                sheet.Add(S(date.ToString(monthly ? "yyyy-MM" : "yyyy-MM-dd", Invariant)), N(amount, 3));
            }
            return sheet;
        }

        private static Sheet BuildProducts(AnalyticsReport report)
        {
            Sheet sheet = new Sheet("Products", new[] { 36, 16, 18, 20 }) { Filter = true };
            sheet.Add(S("Product", 2), S("On menu", 2), S("Units sold", 2), S("Revenue (PHP)", 2));
            foreach (AnalyticsProductRow product in report.AllProducts
                .OrderByDescending(item => item.Units).ThenBy(item => item.Name, StringComparer.OrdinalIgnoreCase))
                sheet.Add(S(product.Name), S(product.IsOnMenu ? "Yes" : "No"), N(product.Units, 4), N(product.Revenue, 3));
            return sheet;
        }

        private static Sheet BuildCategories(AnalyticsReport report)
        {
            Sheet sheet = new Sheet("Categories", new[] { 36, 18, 20 }) { Filter = true };
            sheet.Add(S("Category", 2), S("Units sold", 2), S("Revenue (PHP)", 2));
            foreach (AnalyticsCategoryRow category in report.Categories)
                sheet.Add(S(category.Name), N(category.Units, 4), N(category.Revenue, 3));
            return sheet;
        }

        private static Sheet BuildPayments(AnalyticsReport report)
        {
            Sheet sheet = new Sheet("Payment methods", new[] { 28, 20, 20, 18 }) { Filter = true };
            sheet.Add(S("Payment method", 2), S("Paid orders", 2), S("Sales (PHP)", 2), S("Sales share", 2));
            foreach (string method in new[] { "CASHLESS", "CASH_COUNTER" })
            {
                AnalyticsPaymentRow payment = report.PaymentMethods.FirstOrDefault(item => item.Method == method);
                decimal sales = payment == null ? 0 : payment.Sales;
                sheet.Add(S(method == "CASHLESS" ? "Cashless" : "Cash counter"),
                    N(payment == null ? 0 : payment.Orders, 4), N(sales, 3),
                    N(report.TotalSales == 0 ? 0 : sales / report.TotalSales, 5));
            }
            return sheet;
        }

        private static Cell S(string text, int style = 0) { return new Cell { Text = text ?? string.Empty, Style = style }; }
        private static Cell N(decimal number, int style) { return new Cell { Number = number, Style = style }; }

        private static string Worksheet(Sheet sheet)
        {
            StringBuilder xml = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?><worksheet xmlns=\"");
            xml.Append(SheetNamespace).Append("\"><dimension ref=\"A1:")
                .Append((char)('A' + sheet.Widths.Length - 1)).Append(Math.Max(1, sheet.Rows.Count))
                .Append("\"/><sheetViews><sheetView workbookViewId=\"0\">");
            if (sheet.Filter) xml.Append("<pane ySplit=\"1\" topLeftCell=\"A2\" activePane=\"bottomLeft\" state=\"frozen\"/>");
            xml.Append("</sheetView></sheetViews><sheetFormatPr defaultRowHeight=\"17\"/><cols>");
            for (int i = 0; i < sheet.Widths.Length; i++)
                xml.Append("<col min=\"").Append(i + 1).Append("\" max=\"").Append(i + 1)
                    .Append("\" width=\"").Append(sheet.Widths[i]).Append("\" customWidth=\"1\"/>");
            xml.Append("</cols><sheetData>");
            for (int row = 0; row < sheet.Rows.Count; row++)
            {
                xml.Append("<row r=\"").Append(row + 1).Append("\">");
                for (int column = 0; column < sheet.Rows[row].Length; column++)
                {
                    Cell cell = sheet.Rows[row][column];
                    string reference = (char)('A' + column) + (row + 1).ToString(Invariant);
                    xml.Append("<c r=\"").Append(reference).Append("\" s=\"").Append(cell.Style).Append('"');
                    if (cell.Number.HasValue)
                        xml.Append("><v>").Append(cell.Number.Value.ToString(Invariant)).Append("</v></c>");
                    else
                        xml.Append(" t=\"inlineStr\"><is><t>").Append(Escape(cell.Text)).Append("</t></is></c>");
                }
                xml.Append("</row>");
            }
            xml.Append("</sheetData>");
            if (sheet.Filter && sheet.Rows.Count > 1)
                xml.Append("<autoFilter ref=\"A1:").Append((char)('A' + sheet.Widths.Length - 1))
                    .Append(sheet.Rows.Count).Append("\"/>");
            xml.Append("</worksheet>");
            return xml.ToString();
        }

        private static string Escape(string value)
        {
            StringBuilder valid = new StringBuilder();
            foreach (char character in value ?? string.Empty)
                if (character == '\t' || character == '\n' || character == '\r' || character >= ' ')
                    valid.Append(character);
            return SecurityElement.Escape(valid.ToString()) ?? string.Empty;
        }

        private static string ContentTypes(int sheetCount)
        {
            StringBuilder xml = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/><Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>");
            for (int i = 1; i <= sheetCount; i++)
                xml.Append("<Override PartName=\"/xl/worksheets/sheet").Append(i).Append(".xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>");
            return xml.Append("</Types>").ToString();
        }

        private static string Workbook(List<Sheet> sheets)
        {
            StringBuilder xml = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?><workbook xmlns=\"");
            xml.Append(SheetNamespace).Append("\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"><sheets>");
            for (int i = 0; i < sheets.Count; i++)
                xml.Append("<sheet name=\"").Append(Escape(sheets[i].Name)).Append("\" sheetId=\"")
                    .Append(i + 1).Append("\" r:id=\"rId").Append(i + 1).Append("\"/>");
            return xml.Append("</sheets></workbook>").ToString();
        }

        private static string WorkbookRelationships(int sheetCount)
        {
            StringBuilder xml = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">");
            for (int i = 1; i <= sheetCount; i++)
                xml.Append("<Relationship Id=\"rId").Append(i).Append("\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet").Append(i).Append(".xml\"/>");
            return xml.Append("<Relationship Id=\"rId").Append(sheetCount + 1).Append("\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/></Relationships>").ToString();
        }

        private static string Styles()
        {
            return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><styleSheet xmlns=\"" + SheetNamespace + "\">" +
                "<numFmts count=\"2\"><numFmt numFmtId=\"164\" formatCode=\"&quot;₱&quot;#,##0.00\"/><numFmt numFmtId=\"165\" formatCode=\"0.0%\"/></numFmts>" +
                "<fonts count=\"3\"><font><sz val=\"11\"/><color rgb=\"FF0F172A\"/><name val=\"Aptos\"/></font><font><b/><sz val=\"15\"/><color rgb=\"FFFFFFFF\"/><name val=\"Aptos\"/></font><font><b/><sz val=\"11\"/><color rgb=\"FF0F172A\"/><name val=\"Aptos\"/></font></fonts>" +
                "<fills count=\"4\"><fill><patternFill patternType=\"none\"/></fill><fill><patternFill patternType=\"gray125\"/></fill><fill><patternFill patternType=\"solid\"><fgColor rgb=\"FF0F172A\"/><bgColor indexed=\"64\"/></patternFill></fill><fill><patternFill patternType=\"solid\"><fgColor rgb=\"FFE2E8F0\"/><bgColor indexed=\"64\"/></patternFill></fill></fills>" +
                "<borders count=\"1\"><border><left/><right/><top/><bottom/><diagonal/></border></borders><cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs>" +
                "<cellXfs count=\"6\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\"/>" +
                "<xf numFmtId=\"0\" fontId=\"1\" fillId=\"2\" borderId=\"0\" xfId=\"0\" applyFont=\"1\" applyFill=\"1\"/>" +
                "<xf numFmtId=\"0\" fontId=\"2\" fillId=\"3\" borderId=\"0\" xfId=\"0\" applyFont=\"1\" applyFill=\"1\"/>" +
                "<xf numFmtId=\"164\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\" applyNumberFormat=\"1\"/>" +
                "<xf numFmtId=\"3\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\" applyNumberFormat=\"1\"/>" +
                "<xf numFmtId=\"165\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\" applyNumberFormat=\"1\"/></cellXfs>" +
                "<cellStyles count=\"1\"><cellStyle name=\"Normal\" xfId=\"0\" builtinId=\"0\"/></cellStyles></styleSheet>";
        }

        private static void WriteEntry(ZipArchive archive, string name, string content)
        {
            ZipArchiveEntry entry = archive.CreateEntry(name, CompressionLevel.Optimal);
            using (StreamWriter writer = new StreamWriter(entry.Open(), new UTF8Encoding(false)))
                writer.Write(content);
        }

        private sealed class Cell
        {
            public string Text { get; set; }
            public decimal? Number { get; set; }
            public int Style { get; set; }
        }

        private sealed class Sheet
        {
            public Sheet(string name, int[] widths) { Name = name; Widths = widths; }
            public string Name { get; private set; }
            public int[] Widths { get; private set; }
            public bool Filter { get; set; }
            public List<Cell[]> Rows { get; private set; } = new List<Cell[]>();
            public void Add(params Cell[] cells) { Rows.Add(cells); }
        }
    }
}
