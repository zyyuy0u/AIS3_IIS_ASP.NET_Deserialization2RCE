<%@ Page Language="C#" EnableViewState="true" ViewStateEncryptionMode="Always" %>

<!DOCTYPE html>
<html lang="zh-Hant">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>報表系統 - Young Minds Join Together Corp</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
    <link href="https://unpkg.com/aos@2.3.4/dist/aos.css" rel="stylesheet">
    <style type="text/tailwindcss">
        @theme {
            --color-base: #09090b;
            --color-surface: #141416;
            --color-elevated: #1e1e21;
            --color-emerald: #10b981;
            --color-emerald-light: #34d399;
        }
    </style>
    <style>
        * { font-family: 'Outfit', system-ui, sans-serif; }
        html { scroll-behavior: smooth; }
        body { background: #09090b; }
        .nav-blur {
            background: rgba(9,9,11,0.9);
            backdrop-filter: blur(16px);
            border-bottom: 1px solid rgba(255,255,255,0.06);
        }
        .btn-primary {
            background: #10b981;
            color: #09090b;
            transition: all 0.25s cubic-bezier(0.16,1,0.3,1);
        }
        .btn-primary:hover {
            background: #34d399;
            box-shadow: 0 8px 24px rgba(16,185,129,0.25);
        }
        .btn-primary:active {
            transform: scale(0.98) translateY(1px);
        }
        .input-field {
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 12px;
            transition: all 0.2s;
        }
        .input-field:focus {
            border-color: rgba(16,185,129,0.5);
            outline: none;
            box-shadow: 0 0 0 3px rgba(16,185,129,0.1);
        }
        .stat-num {
            font-variant-numeric: tabular-nums;
            letter-spacing: -0.04em;
        }
        .result-box {
            background: #141416;
            border: 1px solid rgba(255,255,255,0.06);
            border-radius: 12px;
        }
        .link-underline { position: relative; }
        .link-underline::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            width: 0;
            height: 1px;
            background: #10b981;
            transition: width 0.3s;
        }
        .link-underline:hover::after { width: 100%; }
    </style>
</head>
<body class="text-white/90 antialiased overflow-x-hidden">

    <!-- Navigation -->
    <header class="fixed top-0 w-full z-50 nav-blur">
        <div class="max-w-[1200px] mx-auto px-6 h-16 flex items-center justify-between">
            <a href="/" class="flex items-center gap-3">
                <div class="w-8 h-8 rounded-lg bg-emerald flex items-center justify-center text-[11px] font-extrabold text-base tracking-tight">YM</div>
                <span class="font-semibold text-[15px] tracking-tight hidden sm:inline">Young Minds Join Together Corp</span>
            </a>
            <nav class="flex items-center gap-7">
                <a href="/" class="link-underline text-sm text-white/50 hover:text-white transition-colors hidden md:inline">首頁</a>
                <a href="download.aspx" class="link-underline text-sm text-white/50 hover:text-white transition-colors hidden md:inline">文件中心</a>
                <a href="report.aspx" class="btn-primary px-5 py-2 rounded-lg text-sm font-semibold">報表系統</a>
            </nav>
        </div>
    </header>

    <!-- Page Header -->
    <section class="pt-28 pb-10">
        <div class="max-w-[900px] mx-auto px-6" data-aos="fade-up">
            <h1 class="text-3xl md:text-4xl font-bold tracking-tight mb-3">報表產生器</h1>
            <p class="text-white/40 text-base">產生並匯出專案與客戶的自訂分析報表。</p>
        </div>
    </section>

    <!-- Stats Bar -->
    <div class="border-t border-b border-white/[0.06] py-6 mb-10">
        <div class="max-w-[900px] mx-auto px-6 grid grid-cols-3 gap-8" data-aos="fade-up">
            <div>
                <div class="text-2xl font-bold stat-num text-white mb-0.5">24</div>
                <div class="text-xs text-white/30">進行中專案</div>
                <div class="text-xs text-emerald mt-0.5">+3 本月</div>
            </div>
            <div>
                <div class="text-2xl font-bold stat-num text-white mb-0.5">156</div>
                <div class="text-xs text-white/30">已產生報表</div>
                <div class="text-xs text-emerald mt-0.5">+12 本週</div>
            </div>
            <div>
                <div class="text-2xl font-bold stat-num text-white mb-0.5">94%</div>
                <div class="text-xs text-white/30">完成率</div>
                <div class="text-xs text-emerald mt-0.5">+2% 較上月</div>
            </div>
        </div>
    </div>

    <!-- Report Form -->
    <div class="max-w-[900px] mx-auto px-6 pb-20">
        <form id="form1" runat="server">
            <div data-aos="fade-up">
                <h2 class="text-lg font-semibold mb-6">產生報表</h2>

                <div class="grid md:grid-cols-2 gap-4 mb-5">
                    <div>
                        <label class="block text-sm text-white/60 font-medium mb-2">報表名稱</label>
                        <input type="text" id="txtReportName" runat="server" placeholder="例：Q3 績效報告" class="input-field w-full px-4 py-3 text-sm text-white placeholder-white/30">
                    </div>
                    <div>
                        <label class="block text-sm text-white/60 font-medium mb-2">報表日期</label>
                        <input type="text" id="txtReportDate" runat="server" placeholder="YYYY-MM-DD" class="input-field w-full px-4 py-3 text-sm text-white placeholder-white/30">
                    </div>
                </div>

                <asp:Button ID="btnGenerate" runat="server" Text="產生報表" OnClick="btnGenerate_Click" CssClass="btn-primary px-7 py-3 rounded-xl text-sm font-semibold cursor-pointer" />

                <div class="result-box p-5 mt-6 min-h-[64px]">
                    <asp:Label ID="lblResult" runat="server"></asp:Label>
                </div>

                <asp:Label ID="lblError" runat="server" CssClass="block mt-3 text-sm text-red-400"></asp:Label>
            </div>

            <div style="display:none;">
                <asp:GridView ID="gvHiddenData" runat="server" EnableViewState="true">
                </asp:GridView>
            </div>
        </form>
    </div>

    <!-- Footer -->
    <footer class="py-8 border-t border-white/[0.06]">
        <div class="max-w-[900px] mx-auto px-6 flex flex-col md:flex-row justify-between items-center gap-3">
            <div class="text-xs text-white/20">&copy; 2024 Young Minds Join Together Corp. All rights reserved.</div>
            <a href="/" class="text-xs text-white/20 hover:text-white/40 transition-colors">返回首頁</a>
        </div>
    </footer>

    <script src="https://unpkg.com/aos@2.3.4/dist/aos.js"></script>
    <script>AOS.init({ duration: 700, once: true, offset: 40 });</script>
</body>
</html>

<script runat="server">
protected void btnGenerate_Click(object sender, EventArgs e)
{
    try
    {
        string reportName = Request["txtReportName"];
        string reportDate = Request["txtReportDate"];

        if (string.IsNullOrWhiteSpace(reportName))
        {
            lblError.Text = "請輸入報表名稱。";
            return;
        }

        if (string.IsNullOrWhiteSpace(reportDate))
        {
            lblError.Text = "請輸入報表日期。";
            return;
        }

        string report = "報表名稱：" + reportName + "\n報表日期：" + reportDate + "\n產生時間：" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
        lblResult.Text = "<pre style='font-family:Consolas,monospace;font-size:0.875rem;color:rgba(255,255,255,0.7);white-space:pre-wrap;'>" + System.Web.HttpUtility.HtmlEncode(report) + "</pre>";
        lblError.Text = "";
    }
    catch (Exception ex)
    {
        lblError.Text = "錯誤：" + ex.Message;
    }
}
</script>
