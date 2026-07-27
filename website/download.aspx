<%@ Page Language="C#" EnableViewState="false" %>

<!DOCTYPE html>
<html lang="zh-Hant">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>文件中心 — Young Minds Join Together Corp</title>
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
            transition: all 0.3s;
        }
        .glass-card:hover {
            background: rgba(255,255,255,0.07);
            border-color: rgba(37,99,235,0.2);
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
        .doc-row {
            transition: all 0.2s;
        }
        .doc-row:hover {
            background: rgba(255,255,255,0.04);
            border-color: rgba(255,255,255,0.12);
        }
        .dl-btn {
            background: rgba(6,182,212,0.1);
            border: 1px solid rgba(6,182,212,0.2);
            color: #06b6d4;
            transition: all 0.2s;
        }
        .dl-btn:hover {
            background: #06b6d4;
            color: #0a1628;
            border-color: #06b6d4;
        }
        .stat-number {
            background: linear-gradient(180deg, #ffffff, rgba(255,255,255,0.6));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
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
                <a href="report.aspx" class="text-sm text-white/60 hover:text-white transition-colors">報表系統</a>
                <a href="download.aspx" class="text-sm text-teal font-semibold">文件中心</a>
            </nav>
        </div>
    </header>

    <!-- Page Header -->
    <section class="pt-28 pb-12 bg-gradient-to-b from-navy via-navy-light/50 to-navy">
        <div class="max-w-5xl mx-auto px-6" data-aos="fade-up">
            <div class="text-xs font-semibold tracking-widest text-teal uppercase mb-3">Document Center</div>
            <h1 class="text-3xl lg:text-4xl font-bold mb-3">文件中心</h1>
            <p class="text-white/40 text-base">存取公司內部資源、範本文件與專案文件。</p>
        </div>
    </section>

    <div class="glow-line"></div>

    <!-- Main Content -->
    <div class="max-w-5xl mx-auto px-6 py-12 space-y-8">

        <!-- Stats -->
        <div class="grid grid-cols-3 gap-4" data-aos="fade-up">
            <div class="glass-card rounded-2xl p-6 text-center">
                <div class="text-3xl font-black stat-number mb-1">1,247</div>
                <div class="text-xs text-white/35">文件總數</div>
            </div>
            <div class="glass-card rounded-2xl p-6 text-center">
                <div class="text-3xl font-black stat-number mb-1">89</div>
                <div class="text-xs text-white/35">進行中專案</div>
            </div>
            <div class="glass-card rounded-2xl p-6 text-center">
                <div class="text-3xl font-black stat-number mb-1">24/7</div>
                <div class="text-xs text-white/35">服務可用性</div>
            </div>
        </div>

        <!-- Search -->
        <div class="glass-card rounded-2xl p-8" data-aos="fade-up" data-aos-delay="100">
            <h2 class="text-lg font-bold mb-1 flex items-center gap-2">&#128269; 搜尋文件</h2>
            <p class="text-sm text-white/35 mb-6">輸入關鍵字快速搜尋公司內部文件。</p>
            <form id="form1" runat="server">
                <div class="flex gap-3">
                    <input type="text" id="txtSearch" runat="server" placeholder="輸入文件名稱或關鍵字..." class="flex-1 px-5 py-3.5 rounded-xl bg-white/5 border border-white/10 text-sm text-white placeholder-white/25 outline-none focus:border-teal/50 focus:ring-1 focus:ring-teal/20 transition-all">
                    <asp:Button ID="btnSearch" runat="server" Text="搜尋" OnClick="btnSearch_Click" CssClass="btn-primary px-8 py-3.5 rounded-xl text-sm font-semibold text-white cursor-pointer" />
                </div>
                <asp:Label ID="lblStatus" runat="server" CssClass="block mt-4 text-sm text-red-400" Visible="false"></asp:Label>
            </form>
        </div>

        <!-- Recent Documents -->
        <div class="glass-card rounded-2xl p-8" data-aos="fade-up" data-aos-delay="200">
            <h2 class="text-lg font-bold mb-1 flex items-center gap-2">&#128203; 近期文件</h2>
            <p class="text-sm text-white/35 mb-6">常用資源與最新上傳的文件。</p>

            <div class="space-y-3">
                <div class="doc-row flex items-center justify-between p-4 rounded-xl border border-white/6">
                    <div class="flex items-center gap-4">
                        <div class="w-11 h-11 rounded-xl flex items-center justify-center text-lg" style="background:rgba(220,38,38,0.12);color:#f87171">&#128196;</div>
                        <div>
                            <div class="text-sm font-semibold">YMJT_Company_Profile_2024.pdf</div>
                            <div class="text-xs text-white/30 mt-0.5">更新於 2024/07/15 · 2.4 MB</div>
                        </div>
                    </div>
                    <a href="documents/YMJT_Company_Profile_2024.pdf" class="dl-btn px-4 py-2 rounded-lg text-xs font-semibold no-underline">&#11015; 下載</a>
                </div>
                <div class="doc-row flex items-center justify-between p-4 rounded-xl border border-white/6">
                    <div class="flex items-center gap-4">
                        <div class="w-11 h-11 rounded-xl flex items-center justify-center text-lg" style="background:rgba(22,163,74,0.12);color:#4ade80">&#128202;</div>
                        <div>
                            <div class="text-sm font-semibold">Q3_2024_Performance_Report.xlsx</div>
                            <div class="text-xs text-white/30 mt-0.5">更新於 2024/07/10 · 856 KB</div>
                        </div>
                    </div>
                    <a href="documents/Q3_2024_Performance_Report.xlsx" class="dl-btn px-4 py-2 rounded-lg text-xs font-semibold no-underline">&#11015; 下載</a>
                </div>
                <div class="doc-row flex items-center justify-between p-4 rounded-xl border border-white/6">
                    <div class="flex items-center gap-4">
                        <div class="w-11 h-11 rounded-xl flex items-center justify-center text-lg" style="background:rgba(220,38,38,0.12);color:#f87171">&#128196;</div>
                        <div>
                            <div class="text-sm font-semibold">Employee_Handbook_v3.pdf</div>
                            <div class="text-xs text-white/30 mt-0.5">更新於 2024/06/28 · 5.1 MB</div>
                        </div>
                    </div>
                    <a href="documents/Employee_Handbook_v3.pdf" class="dl-btn px-4 py-2 rounded-lg text-xs font-semibold no-underline">&#11015; 下載</a>
                </div>
                <div class="doc-row flex items-center justify-between p-4 rounded-xl border border-white/6">
                    <div class="flex items-center gap-4">
                        <div class="w-11 h-11 rounded-xl flex items-center justify-center text-lg" style="background:rgba(220,38,38,0.12);color:#f87171">&#128196;</div>
                        <div>
                            <div class="text-sm font-semibold">IT_Infrastructure_Whitepaper.pdf</div>
                            <div class="text-xs text-white/30 mt-0.5">更新於 2024/06/20 · 3.7 MB</div>
                        </div>
                    </div>
                    <a href="documents/IT_Infrastructure_Whitepaper.pdf" class="dl-btn px-4 py-2 rounded-lg text-xs font-semibold no-underline">&#11015; 下載</a>
                </div>
            </div>
        </div>
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
protected void btnSearch_Click(object sender, EventArgs e)
{
    string keyword = txtSearch.Value.Trim();
    if (string.IsNullOrEmpty(keyword))
    {
        lblStatus.Text = "請輸入搜尋關鍵字。";
        lblStatus.Visible = true;
        return;
    }
    lblStatus.Text = "找不到與「" + Server.HtmlEncode(keyword) + "」相關的文件。請確認關鍵字後重試。";
    lblStatus.Visible = true;
}
</script>
