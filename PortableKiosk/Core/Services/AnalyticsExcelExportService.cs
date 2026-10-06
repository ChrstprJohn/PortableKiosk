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
            string subtitle = periodName + " | " + start.ToString("MMM d, yyyy", Invariant) + " – " +
                end.AddDays(-1).ToString("MMM d, yyyy", Invariant) + " | Philippine time";

            List<Sheet> sheets = new List<Sheet>
            {
                BuildOverview(report, subtitle),
                BuildTrend(report, subtitle, start, end),
                BuildProducts(report, subtitle),
                BuildCategories(report, subtitle),
                BuildPayments(report, subtitle)
            };

            return Package(sheets);
        }

        public byte[] CreateDetailWorkbook(AnalyticsDetailReport detail)
        {
            if (detail == null) throw new ArgumentNullException("detail");
            var sheet = new Sheet(detail.RowTargets.Count > 0 ? "Breakdown" : "Records", detail.Title, detail.Period,
                detail.Columns.Select((label, index) => detail.Formats[index] == "money" ? 22 : label == "Items" ? 60 : 28).ToArray()) { Filter = true };
            sheet.Add(detail.Columns.Select(label => S(label, 2)).ToArray());
            foreach (object[] row in detail.Rows)
                sheet.AddData(row.Select((value, index) => detail.Formats[index] == "money" ? N(Convert.ToDecimal(value), 3) :
                    detail.Formats[index] == "count" ? N(Convert.ToDecimal(value), 4) :
                    detail.Formats[index] == "percent" ? N(Convert.ToDecimal(value), 5) : S(Convert.ToString(value, Invariant))).ToArray());
            sheet.FilterLastRow = sheet.Rows.Count;
            if (detail.Rows.Count == 0) sheet.AddMerged("No records for this period.", 6);
            sheet.Add();
            sheet.AddMerged(detail.Summary, 6);
            sheet.AddMerged(detail.Description, 6);
            return Package(new List<Sheet> { sheet });
        }

        private static byte[] Package(List<Sheet> sheets)
        {
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

        private static Sheet BuildOverview(AnalyticsReport report, string subtitle)
        {
            Sheet sheet = new Sheet("Overview", "Portable Kiosk · Analytics", subtitle, new[] { 36, 20, 22 });
            sheet.Add(S("Sales summary", 2), S("Value", 2));
            sheet.AddData(S("Total revenue"), N(report.TotalSales, 3));
            sheet.AddData(S("Paid orders"), N(report.PaidOrders, 4));
            sheet.AddData(S("Average order"), N(report.AverageOrderValue, 3));
            sheet.AddData(S("Paid share of placed orders"), N(report.ConversionRate / 100m, 5));
            sheet.Add();
            sheet.Add(S("Order outcomes", 2), S("Orders", 2), S("Order value (PHP)", 2));
            sheet.AddData(S("Paid"), N(report.ConvertedOrders, 4), N(report.ConvertedValue, 3));
            sheet.AddData(S("Expired (unpaid)"), N(report.ExpiredOrders, 4), N(report.ExpiredValue, 3));
            sheet.AddData(S("Remaining unpaid"), N(Math.Max(0, report.PlacedOrders - report.ConvertedOrders - report.ExpiredOrders), 4), S("—", 3));
            sheet.Add(S("Total orders placed", 7), N(report.PlacedOrders, 9), S("—", 8));
            sheet.Add();
            sheet.Add(S("Popular products · Top 5", 2), S("Units sold", 2), S("Revenue (PHP)", 2));
            foreach (AnalyticsProductRow product in report.PopularProducts)
                sheet.AddData(S(product.Name), N(product.Units, 4), N(product.Revenue, 3));
            if (report.PopularProducts.Count == 0) sheet.AddMerged("No products sold in this period.", 6);
            sheet.Add();
            sheet.Add(S("Least-selling · Bottom 5 on menu", 2), S("Units sold", 2), S("Revenue (PHP)", 2));
            foreach (AnalyticsProductRow product in report.LeastProducts)
                sheet.AddData(S(product.Name), N(product.Units, 4), N(product.Revenue, 3));
            if (report.LeastProducts.Count == 0) sheet.AddMerged("No available products to show.", 6);
            sheet.Add();
            sheet.AddMerged("Sales: payment date. Outcomes: order date. Unpaid amounts are not revenue. Currency: PHP.", 6);
            return sheet;
        }

        private static Sheet BuildTrend(AnalyticsReport report, string subtitle, DateTime start, DateTime end)
        {
            bool monthly = (end - start).TotalDays > 90;
            Sheet sheet = new Sheet("Sales trend", monthly ? "Monthly sales" : "Daily sales", subtitle, new[] { 26, 26 }) { Filter = true };
            sheet.Add(S(monthly ? "Month" : "Date", 2), S("Revenue (PHP)", 2));
            Dictionary<DateTime, decimal> sales = report.Trend.ToDictionary(point => point.Date, point => point.Sales);
            for (DateTime date = start; date < end; date = monthly ? date.AddMonths(1) : date.AddDays(1))
            {
                decimal amount;
                sales.TryGetValue(date, out amount);
                sheet.AddData(N((decimal)date.ToOADate(), monthly ? 17 : 15), N(amount, 3));
            }
            sheet.FilterLastRow = sheet.Rows.Count;
            sheet.Add(S("Total revenue", 7), N(report.Trend.Sum(point => point.Sales), 8));
            return sheet;
        }

        private static Sheet BuildProducts(AnalyticsReport report, string subtitle)
        {
            Sheet sheet = new Sheet("Products", "Product sales", subtitle, new[] { 40, 14, 14, 22 }) { Filter = true };
            sheet.Add(S("Product", 2), S("On menu", 2), S("Units sold", 2), S("Revenue (PHP)", 2));
            foreach (AnalyticsProductRow product in report.AllProducts
                .OrderByDescending(item => item.Units).ThenBy(item => item.Name, StringComparer.OrdinalIgnoreCase))
                sheet.AddData(S(product.Name), S(product.IsOnMenu ? "Yes" : "No"), N(product.Units, 4), N(product.Revenue, 3));
            sheet.FilterLastRow = sheet.Rows.Count;
            sheet.Add(S("Total", 7), S("", 7), N(report.AllProducts.Sum(product => product.Units), 9), N(report.AllProducts.Sum(product => product.Revenue), 8));
            if (report.AllProducts.Count == 0) sheet.AddMerged("No products to show.", 6);
            return sheet;
        }

        private static Sheet BuildCategories(AnalyticsReport report, string subtitle)
        {
            Sheet sheet = new Sheet("Categories", "Sales by category", subtitle, new[] { 36, 16, 22 }) { Filter = true };
            sheet.Add(S("Category", 2), S("Units sold", 2), S("Revenue (PHP)", 2));
            foreach (AnalyticsCategoryRow category in report.Categories)
                sheet.AddData(S(category.Name), N(category.Units, 4), N(category.Revenue, 3));
            sheet.FilterLastRow = sheet.Rows.Count;
            sheet.Add(S("Total", 7), N(report.Categories.Sum(category => category.Units), 9), N(report.Categories.Sum(category => category.Revenue), 8));
            if (report.Categories.Count == 0) sheet.AddMerged("No categories to show.", 6);
            return sheet;
        }

        private static Sheet BuildPayments(AnalyticsReport report, string subtitle)
        {
            Sheet sheet = new Sheet("Payment methods", "Payment methods", subtitle, new[] { 26, 16, 22, 16 }) { Filter = true };
            sheet.Add(S("Payment method", 2), S("Paid orders", 2), S("Sales (PHP)", 2), S("Sales share", 2));
            foreach (string method in new[] { "CASHLESS", "CASH_COUNTER" })
            {
                AnalyticsPaymentRow payment = report.PaymentMethods.FirstOrDefault(item => item.Method == method);
                decimal sales = payment == null ? 0 : payment.Sales;
                sheet.AddData(S(method == "CASHLESS" ? "Cashless" : "Cash counter"),
                    N(payment == null ? 0 : payment.Orders, 4), N(sales, 3),
                    N(report.TotalSales == 0 ? 0 : sales / report.TotalSales, 5));
            }
            sheet.FilterLastRow = sheet.Rows.Count;
            sheet.Add(S("Total", 7), N(report.PaidOrders, 9), N(report.TotalSales, 8), N(report.TotalSales == 0 ? 0 : 1, 10));
            return sheet;
        }

        private static Cell S(string text, int style = 0) { return new Cell { Text = text ?? string.Empty, Style = style }; }
        private static Cell N(decimal number, int style) { return new Cell { Number = number, Style = style }; }

        private static string Worksheet(Sheet sheet)
        {
            StringBuilder xml = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?><worksheet xmlns=\"");
            xml.Append(SheetNamespace).Append("\"><sheetPr><pageSetUpPr fitToPage=\"1\"/></sheetPr><dimension ref=\"A1:")
                .Append((char)('A' + sheet.Widths.Length - 1)).Append(Math.Max(1, sheet.Rows.Count))
                .Append("\"/><sheetViews><sheetView showGridLines=\"0\" workbookViewId=\"0\">")
                .Append("<pane ySplit=\"4\" topLeftCell=\"A5\" activePane=\"bottomLeft\" state=\"frozen\"/>")
                .Append("<selection pane=\"bottomLeft\" activeCell=\"A5\" sqref=\"A5\"/>");
            xml.Append("</sheetView></sheetViews><sheetFormatPr defaultRowHeight=\"20\"/><cols>");
            for (int i = 0; i < sheet.Widths.Length; i++)
                xml.Append("<col min=\"").Append(i + 1).Append("\" max=\"").Append(i + 1)
                    .Append("\" width=\"").Append(sheet.Widths[i]).Append("\" customWidth=\"1\"/>");
            xml.Append("</cols><sheetData>");
            for (int row = 0; row < sheet.Rows.Count; row++)
            {
                xml.Append("<row r=\"").Append(row + 1).Append("\" ht=\"")
                    .Append(sheet.RowHeight(row).ToString(Invariant)).Append("\" customHeight=\"1\">");
                for (int column = 0; column < sheet.Rows[row].Length; column++)
                {
                    Cell cell = sheet.Rows[row][column];
                    string reference = (char)('A' + column) + (row + 1).ToString(Invariant);
                    xml.Append("<c r=\"").Append(reference).Append("\" s=\"").Append(cell.Style).Append('"');
                    if (cell.Number.HasValue)
                        xml.Append("><v>").Append(cell.Number.Value.ToString(Invariant)).Append("</v></c>");
                    else
                        xml.Append(" t=\"inlineStr\"><is><t xml:space=\"preserve\">").Append(Escape(cell.Text)).Append("</t></is></c>");
                }
                xml.Append("</row>");
            }
            xml.Append("</sheetData>");
            if (sheet.Filter && sheet.FilterLastRow > 4)
                xml.Append("<autoFilter ref=\"A4:").Append((char)('A' + sheet.Widths.Length - 1))
                    .Append(sheet.FilterLastRow).Append("\"/>");
            if (sheet.MergedRows.Count > 0)
            {
                xml.Append("<mergeCells count=\"").Append(sheet.MergedRows.Count).Append("\">");
                foreach (int row in sheet.MergedRows)
                    xml.Append("<mergeCell ref=\"A").Append(row).Append(':')
                        .Append((char)('A' + sheet.Widths.Length - 1)).Append(row).Append("\"/>");
                xml.Append("</mergeCells>");
            }
            xml.Append("<printOptions horizontalCentered=\"1\"/><pageMargins left=\"0.3\" right=\"0.3\" top=\"0.4\" bottom=\"0.4\" header=\"0.2\" footer=\"0.2\"/>")
                .Append("<pageSetup paperSize=\"9\" orientation=\"").Append(sheet.Widths.Sum() > 80 ? "landscape" : "portrait")
                .Append("\" fitToWidth=\"1\" fitToHeight=\"0\"/>")
                .Append("<headerFooter><oddFooter>&amp;LPortable Kiosk · Analytics&amp;RPage &amp;P of &amp;N</oddFooter></headerFooter></worksheet>");
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
            xml.Append("</sheets><definedNames>");
            for (int i = 0; i < sheets.Count; i++)
            {
                string name = Escape("'" + sheets[i].Name.Replace("'", "''") + "'");
                xml.Append("<definedName name=\"_xlnm.Print_Area\" localSheetId=\"").Append(i).Append("\">")
                    .Append(name).Append("!$A$1:$").Append((char)('A' + sheets[i].Widths.Length - 1))
                    .Append('$').Append(sheets[i].Rows.Count).Append("</definedName>")
                    .Append("<definedName name=\"_xlnm.Print_Titles\" localSheetId=\"").Append(i).Append("\">")
                    .Append(name).Append("!$1:$4</definedName>");
            }
            return xml.Append("</definedNames></workbook>").ToString();
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
            StringBuilder xml = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?><styleSheet xmlns=\"" + SheetNamespace + "\">");
            xml.Append("<numFmts count=\"4\"><numFmt numFmtId=\"164\" formatCode=\"&quot;₱&quot;#,##0.00\"/><numFmt numFmtId=\"165\" formatCode=\"0.0%\"/><numFmt numFmtId=\"166\" formatCode=\"mmm d, yyyy\"/><numFmt numFmtId=\"167\" formatCode=\"mmm yyyy\"/></numFmts>")
                .Append("<fonts count=\"4\"><font><sz val=\"11\"/><color rgb=\"FF0F172A\"/><name val=\"Calibri\"/></font><font><b/><sz val=\"14\"/><color rgb=\"FF0F172A\"/><name val=\"Calibri\"/></font><font><b/><sz val=\"11\"/><color rgb=\"FF0F172A\"/><name val=\"Calibri\"/></font><font><sz val=\"10\"/><color rgb=\"FF475569\"/><name val=\"Calibri\"/></font></fonts>")
                .Append("<fills count=\"5\"><fill><patternFill patternType=\"none\"/></fill><fill><patternFill patternType=\"gray125\"/></fill>");
            foreach (string color in new[] { "FFF1F5F9", "FFF8FAFC", "FFEFF6FF" })
                xml.Append("<fill><patternFill patternType=\"solid\"><fgColor rgb=\"").Append(color).Append("\"/><bgColor indexed=\"64\"/></patternFill></fill>");
            xml.Append("</fills><borders count=\"3\"><border><left/><right/><top/><bottom/><diagonal/></border>");
            foreach (string color in new[] { "FFCBD5E1", "FF94A3B8" })
            {
                xml.Append("<border>");
                foreach (string side in new[] { "left", "right", "top", "bottom" })
                    xml.Append('<').Append(side).Append(" style=\"thin\"><color rgb=\"").Append(color).Append("\"/></").Append(side).Append('>');
                xml.Append("<diagonal/></border>");
            }
            xml.Append("</borders>")
                .Append("<cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs><cellXfs count=\"19\">");
            // Body, title, header, currency, count, percentage, note.
            AppendStyle(xml, 0, 0, 0, 1, "left");
            AppendStyle(xml, 0, 1, 0, 0, "left");
            AppendStyle(xml, 0, 2, 2, 1, "left");
            AppendStyle(xml, 164, 0, 0, 1, "right");
            AppendStyle(xml, 3, 0, 0, 1, "right");
            AppendStyle(xml, 165, 0, 0, 1, "right");
            AppendStyle(xml, 0, 3, 0, 0, "left");
            // Total row: text, currency, count, percentage.
            AppendStyle(xml, 0, 2, 4, 2, "left");
            AppendStyle(xml, 164, 2, 4, 2, "right");
            AppendStyle(xml, 3, 2, 4, 2, "right");
            AppendStyle(xml, 165, 2, 4, 2, "right");
            // Alternating data rows and real Excel dates.
            AppendStyle(xml, 0, 0, 3, 1, "left");
            AppendStyle(xml, 164, 0, 3, 1, "right");
            AppendStyle(xml, 3, 0, 3, 1, "right");
            AppendStyle(xml, 165, 0, 3, 1, "right");
            AppendStyle(xml, 166, 0, 0, 1, "left");
            AppendStyle(xml, 166, 0, 3, 1, "left");
            AppendStyle(xml, 167, 0, 0, 1, "left");
            AppendStyle(xml, 167, 0, 3, 1, "left");
            return xml.Append("</cellXfs><cellStyles count=\"1\"><cellStyle name=\"Normal\" xfId=\"0\" builtinId=\"0\"/></cellStyles></styleSheet>").ToString();
        }

        private static void AppendStyle(StringBuilder xml, int format, int font, int fill, int border, string alignment)
        {
            xml.Append("<xf numFmtId=\"").Append(format).Append("\" fontId=\"").Append(font).Append("\" fillId=\"").Append(fill)
                .Append("\" borderId=\"").Append(border).Append("\" xfId=\"0\" applyFont=\"1\" applyFill=\"1\" applyBorder=\"1\" applyNumberFormat=\"1\" applyAlignment=\"1\">")
                .Append("<alignment horizontal=\"").Append(alignment).Append("\" vertical=\"center\" wrapText=\"1\"/></xf>");
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
            public Sheet(string name, string title, string subtitle, int[] widths)
            {
                Name = name;
                Widths = widths;
                AddMerged(title, 1);
                AddMerged(subtitle, 6);
                Add();
            }
            public string Name { get; private set; }
            public int[] Widths { get; private set; }
            public bool Filter { get; set; }
            public int FilterLastRow { get; set; }
            public List<Cell[]> Rows { get; private set; } = new List<Cell[]>();
            public List<int> MergedRows { get; private set; } = new List<int>();
            public void Add(params Cell[] cells) { Rows.Add(cells); }
            public void AddMerged(string text, int style)
            {
                Add(S(text, style));
                MergedRows.Add(Rows.Count);
            }
            public void AddData(params Cell[] cells)
            {
                if (Rows.Count % 2 == 0)
                    foreach (Cell cell in cells)
                        cell.Style = cell.Style == 0 ? 11 : cell.Style == 3 ? 12 : cell.Style == 4 ? 13 :
                            cell.Style == 5 ? 14 : cell.Style == 15 ? 16 : cell.Style == 17 ? 18 : cell.Style;
                Add(cells);
            }
            public int RowHeight(int index)
            {
                Cell[] cells = Rows[index];
                if (cells.Length == 0) return 6;
                if (cells[0].Style == 1) return 26;
                if (MergedRows.Contains(index + 1))
                    return 6 + 14 * Math.Max(1, (int)Math.Ceiling((cells[0].Text ?? "").Length / (double)(Widths.Sum() - 4)));
                int lines = 1;
                for (int i = 0; i < cells.Length; i++)
                    lines = Math.Max(lines, (int)Math.Ceiling((cells[i].Text ?? "").Length / (double)(Widths[i] - 3)));
                return Math.Max(20, 4 + 16 * lines);
            }
        }
    }
}
