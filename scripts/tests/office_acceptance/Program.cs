using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using PaperSwitch.Models;
using PaperSwitch.Services;

internal static class Program
{
    [STAThread]
    private static int Main(string[] args)
    {
        Console.OutputEncoding = new UTF8Encoding(false);
        try { Run(args.Single()); return 0; }
        catch (Exception ex) { Console.WriteLine(ex); return 1; }
    }

    private static void Check(bool value, string message)
    {
        if (!value) throw new InvalidOperationException(message);
        Console.WriteLine("PASS：" + message);
    }

    private static void Run(string root)
    {
        root = Path.GetFullPath(root);
        if (!File.Exists(Path.Combine(root, ".office-acceptance"))) throw new InvalidOperationException("缺少隔離驗收標記。");
        foreach (string name in new[] { "WINWORD", "EXCEL", "POWERPNT" })
            if (Process.GetProcessesByName(name).Length > 0) throw new InvalidOperationException("Office 已在執行；不操作使用者文件，停止驗收。");
        string input = Path.Combine(root, "合成 Office 來源");
        string output = Path.Combine(root, "新建輸出");
        Directory.CreateDirectory(input);
        Directory.CreateDirectory(output);
        string word = Path.Combine(input, "純合成 文件.rtf");
        string excel = Path.Combine(input, "純合成 表格.csv");
        string slides = Path.Combine(input, "純合成 簡報.pptx");
        var text = new StringBuilder(@"{\rtf1\ansi\deff0{\fonttbl{\f0 Arial;}}\f0\fs24 ");
        foreach (char character in "純合成驗收文件，非真實公文。") text.Append(@"\u").Append((short)character).Append('?');
        text.Append('}');
        File.WriteAllText(word, text.ToString(), Encoding.ASCII);
        File.WriteAllText(excel, "類別,說明\r\n合成資料,僅供功能驗證\r\n測試金額,123.45\r\n", new UTF8Encoding(true));
        CreateSlides(slides);
        var before = Directory.GetFiles(input).ToDictionary(p => p, p => SHA256.HashData(File.ReadAllBytes(p)));
        var converter = OfficeConverterService.Instance;
        var results = new[] {
            converter.ConvertWordAsync(word, Path.Combine(output, "Word.pdf")).GetAwaiter().GetResult(),
            converter.ConvertExcelAsync(excel, Path.Combine(output, "Excel"), true).GetAwaiter().GetResult(),
            converter.ConvertPowerPointAsync(slides, Path.Combine(output, "PowerPoint.pdf")).GetAwaiter().GetResult()
        };
        var pdfs = new List<string>();
        int readableOfficePdfs = 0;
        int blockedOfficePdfs = 0;
        foreach (var result in results)
        {
            Check(result.Success && result.GeneratedPdfPaths.Count > 0, Path.GetExtension(result.SourcePath) + " 正式 COM 服務已返回輸出：" + result.ErrorMessage);
            foreach (string pdf in result.GeneratedPdfPaths)
            {
                if (converter.CheckPdfHeaderAndSize(pdf).State == "igef")
                {
                    Check(!converter.WaitForPdfReadyAsync(pdf, 15).GetAwaiter().GetResult(), "IGEF 輸出被既有防護拒絕");
                    Console.WriteLine("BLOCKED：" + Path.GetExtension(result.SourcePath) + " 輸出為 IGEF，正常 Office→PDF 驗收未通過。");
                    blockedOfficePdfs++;
                    continue;
                }
                Check(converter.WaitForPdfReadyAsync(pdf, 15).GetAwaiter().GetResult()
                    && PdfService.Instance.GetPageCount(pdf) >= 1, "PDF 標頭、穩定寫入與頁數可讀");
                readableOfficePdfs++;
            }
        }
        // 獨立驗證標準 PDF；不解密、改名或轉換 IGEF 以繞過環境限制。
        for (int i = 0; i < 3; i++)
        {
            string pdf = Path.Combine(output, $"標準合成頁-{i}.pdf");
            Check(PdfService.Instance.CreateBlankA4Pdf(pdf) && PdfService.Instance.GetPageCount(pdf) == 1, "建立可讀標準 A4 合成 PDF");
            pdfs.Add(pdf);
        }
        var pages = pdfs.Select((pdf, index) => new PaperItem { SourceFilePath = pdf, SourceFileName = Path.GetFileName(pdf), SourcePageIndex = 0, Rotation = index == 1 ? 90 : 0 }).ToList();
        string merged = Path.Combine(output, "編排 合併.pdf");
        Check(PdfService.Instance.ExportArrangedPdf(pages, merged) && PdfService.Instance.GetPageCount(merged) == pages.Count, "標準合成 PDF 合併與頁數");
        Check(PdfService.Instance.GetPageDimensions(merged, 1).Rotate == 90, "向量頁面旋轉保存");
        Check(PdfService.Instance.ExportIndividualPdfs(pages, Path.Combine(output, "分頁"), "合成驗收").Count == pages.Count, "逐頁 PDF 匯出");
        Check(before.All(entry => entry.Value.SequenceEqual(SHA256.HashData(File.ReadAllBytes(entry.Key)))), "所有 Office 合成來源 SHA-256 不變");
        GC.Collect(); GC.WaitForPendingFinalizers();
        System.Threading.Thread.Sleep(2000);
        Check(new[] { "WINWORD", "EXCEL", "POWERPNT" }.All(name => Process.GetProcessesByName(name).Length == 0), "Office COM 正常關閉，沒有殘留程序");
        File.WriteAllText(Path.Combine(root, "verification.json"), System.Text.Json.JsonSerializer.Serialize(new {
            ReadableOfficePdfs = readableOfficePdfs, BlockedOfficePdfs = blockedOfficePdfs,
            StandardPdfFunctionsPassed = true, SourceHashesUnchanged = true, OfficeProcessesRemaining = 0
        }, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }), new UTF8Encoding(false));
    }

    private static void CreateSlides(string path)
    {
        dynamic? app = null, presentation = null, slide = null, shape = null, textFrame = null, range = null;
        try
        {
            app = Activator.CreateInstance(Type.GetTypeFromProgID("PowerPoint.Application") ?? throw new InvalidOperationException("未安裝 PowerPoint。"));
            presentation = app!.Presentations.Add(0);
            slide = presentation.Slides.Add(1, 12);
            shape = slide.Shapes.AddTextbox(1, 40, 40, 600, 100);
            textFrame = shape.TextFrame;
            range = textFrame.TextRange;
            range.Text = "純合成簡報，非真實案件或公文。";
            presentation.SaveAs(path, 24);
        }
        finally
        {
            try { presentation?.Close(); } catch { }
            try { app?.Quit(); } catch { }
            foreach (object? value in new object?[] { range, textFrame, shape, slide, presentation, app })
                if (value != null && Marshal.IsComObject(value)) Marshal.FinalReleaseComObject(value);
            GC.Collect(); GC.WaitForPendingFinalizers();
        }
    }
}
