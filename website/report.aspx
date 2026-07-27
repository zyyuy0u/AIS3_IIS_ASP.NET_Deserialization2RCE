<%@ Page Language="C#" EnableViewState="true" ViewStateEncryptionMode="Always" %>

<!DOCTYPE html>
<html lang="zh-Hant">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>報表系統 — Young Minds Join Together Corp</title>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
    <link href="https://unpkg.com/aos@2.3.4/dist/aos.css" rel="stylesheet">
    <style type="text/tailwindcss">
        @theme {
            --color-navy: #0a1628;
            --color-navy-light: #111d32;
            --color-accent: #2563eb;
            --color-teal: #06b6d4;
            --color-gold: #d4a574;
        }
    </style>
    <style>
        html { scroll-behavior: smooth; }
        body { background: #0a1628; }
        .glass {
            background: rgba(255,255,255,0.03);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255,255,255,0.06);
        }
        .glass-card {
            background: rgba(255,255,255,0.04);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255,255,255,0.07);
        }
        .glow-line {
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(37,99,235,0.5), rgba(6,182,212,0.5), transparent);
        }
        .icon-box {
            background: linear-gradient(135deg, rgba(37,99,235,0.15), rgba(6,182,212,0.1));
            border: 1px solid rgba(37,99,235,0.2);
        }
        .btn-primary {
            background: linear-gradient(135deg, #2563eb, #0ea5e9);
            transition: all 0.3s;
        }
        .btn-primary:hover {
            box-shadow: 0 8px 30px rgba(37,99,235,0.4);
            transform: translateY(-2px);
        }
        .stat-number {
            background: linear-gradient(180deg, #ffffff, rgba(255,255,255,0.6));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .result-area {
            background: rgba(255,255,255,0.03);
            border: 1px solid rgba(255,255,255,0.06);
        }
    </style>
</head>
<body class="text-white/90 font-sans antialiased overflow-x-hidden">

    <!-- Navigation -->
    <header class="fixed top-0 w-full z-50 glass">
        <div class="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
            <a href="/" class="flex items-center gap-3">
                <div class="w-9 h-9 rounded-lg bg-gradient-to-br from-accent to-teal flex items-center justify-center text-xs font-black text-white">YM</div>
                <span class="font-bold text-base tracking-tight">Young Minds Join Together <span class="text-gold">Corp</span></span>
            </a>
            <nav class="hidden md:flex items-center gap-8">
                <a href="/" class="text-sm text-white/60 hover:text-white transition-colors">首頁</a>
                <a href="report.aspx" class="text-sm text-teal font-semibold">報表系統</a>
                <a href="download.aspx" class="text-sm text-white/60 hover:text-white transition-colors">文件中心</a>
            </nav>
        </div>
    </header>

    <!-- Page Header -->
    <section class="pt-28 pb-12 bg-gradient-to-b from-navy via-navy-light/50 to-navy">
        <div class="max-w-5xl mx-auto px-6" data-aos="fade-up">
            <div class="text-xs font-semibold tracking-widest text-gold uppercase mb-3">Report Generator</div>
            <h1 class="text-3xl lg:text-4xl font-bold mb-3">報表產生器</h1>
            <p class="text-white/40 text-base">產生並匯出專案與客戶的自訂分析報表。</p>
        </div>
    </section>

    <div class="glow-line"></div>

    <!-- Main Content -->
    <div class="max-w-5xl mx-auto px-6 py-12 space-y-8">

        <!-- Quick Stats -->
        <div class="grid grid-cols-3 gap-4" data-aos="fade-up">
            <div class="glass-card rounded-2xl p-6 text-center">
                <div class="text-3xl font-black stat-number mb-1">24</div>
                <div class="text-xs text-white/35">進行中專案</div>
                <div class="text-xs text-green-400 mt-1">+3 本月</div>
            </div>
            <div class="glass-card rounded-2xl p-6 text-center">
                <div class="text-3xl font-black stat-number mb-1">156</div>
                <div class="text-xs text-white/35">已產生報表</div>
                <div class="text-xs text-green-400 mt-1">+12 本週</div>
            </div>
            <div class="glass-card rounded-2xl p-6 text-center">
                <div class="text-3xl font-black stat-number mb-1">94%</div>
                <div class="text-xs text-white/35">完成率</div>
                <div class="text-xs text-green-400 mt-1">+2% 較上月</div>
            </div>
        </div>

        <!-- Report Form -->
        <form id="form1" runat="server">
            <div class="glass-card rounded-2xl p-8" data-aos="fade-up" data-aos-delay="100">
                <h2 class="text-lg font-bold mb-1 flex items-center gap-2">&#128221; 產生報表</h2>
                <p class="text-sm text-white/35 mb-6">填寫以下資料以產生新的分析報表。</p>

                <div class="grid md:grid-cols-2 gap-4 mb-4">
                    <div>
                        <label class="block text-xs text-white/40 font-semibold mb-2">報表名稱</label>
                        <input type="text" id="txtReportName" runat="server" placeholder="例：Q3 績效報告" class="w-full px-4 py-3 rounded-xl bg-white/5 border border-white/10 text-sm text-white placeholder-white/25 outline-none focus:border-teal/50 focus:ring-1 focus:ring-teal/20 transition-all">
                    </div>
                    <div>
                        <label class="block text-xs text-white/40 font-semibold mb-2">報表日期</label>
                        <input type="text" id="txtReportDate" runat="server" placeholder="YYYY-MM-DD" class="w-full px-4 py-3 rounded-xl bg-white/5 border border-white/10 text-sm text-white placeholder-white/25 outline-none focus:border-teal/50 focus:ring-1 focus:ring-teal/20 transition-all">
                    </div>
                </div>

                <asp:Button ID="btnGenerate" runat="server" Text="產生報表" OnClick="btnGenerate_Click" CssClass="btn-primary px-8 py-3.5 rounded-xl text-sm font-semibold text-white cursor-pointer" />

                <div class="result-area rounded-xl p-5 mt-6 min-h-16">
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
    <div class="glow-line"></div>
    <footer class="py-8 text-center text-xs text-white/20">
        &copy; 2024 Young Minds Join Together Corp. 內部使用。
    </footer>

    <script src="https://unpkg.com/aos@2.3.4/dist/aos.js"></script>
    <script>AOS.init({ duration: 800, once: true, offset: 60 });</script>
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
