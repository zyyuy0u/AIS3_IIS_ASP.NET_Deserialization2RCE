<%@ Page Language="C#" EnableViewState="false" %>

<!DOCTYPE html>
<html lang="zh-Hant">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>文件中心 - Young Minds Join Together Corp</title>
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
        .doc-row {
            background: #141416;
            border: 1px solid rgba(255,255,255,0.06);
            border-radius: 12px;
            transition: all 0.2s cubic-bezier(0.16,1,0.3,1);
        }
        .doc-row:hover {
            border-color: rgba(16,185,129,0.15);
            background: #1a1a1d;
        }
        .dl-btn {
            background: rgba(16,185,129,0.08);
            border: 1px solid rgba(16,185,129,0.15);
            color: #10b981;
            border-radius: 8px;
            transition: all 0.2s;
        }
        .dl-btn:hover {
            background: #10b981;
            color: #09090b;
            border-color: #10b981;
        }
        .dl-btn:active {
            transform: scale(0.98);
        }
        .stat-num {
            font-variant-numeric: tabular-nums;
            letter-spacing: -0.04em;
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
                <a href="download.aspx" class="text-sm text-emerald font-medium hidden md:inline">文件中心</a>
                <a href="report.aspx" class="btn-primary px-5 py-2 rounded-lg text-sm font-semibold">報表系統</a>
            </nav>
        </div>
    </header>

    <!-- Page Header -->
    <section class="pt-28 pb-10">
        <div class="max-w-[900px] mx-auto px-6" data-aos="fade-up">
            <h1 class="text-3xl md:text-4xl font-bold tracking-tight mb-3">文件中心</h1>
            <p class="text-white/40 text-base">存取公司內部資源、範本文件與專案文件。</p>
        </div>
    </section>

    <!-- Stats Bar -->
    <div class="border-t border-b border-white/[0.06] py-6 mb-10">
        <div class="max-w-[900px] mx-auto px-6 grid grid-cols-3 gap-8" data-aos="fade-up">
            <div>
                <div class="text-2xl font-bold stat-num text-white mb-0.5">1,247</div>
                <div class="text-xs text-white/30">文件總數</div>
            </div>
            <div>
                <div class="text-2xl font-bold stat-num text-white mb-0.5">89</div>
                <div class="text-xs text-white/30">進行中專案</div>
            </div>
            <div>
                <div class="text-2xl font-bold stat-num text-white mb-0.5">24/7</div>
                <div class="text-xs text-white/30">服務可用性</div>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="max-w-[900px] mx-auto px-6 pb-20 space-y-8">

        <!-- Search -->
        <div data-aos="fade-up">
            <h2 class="text-lg font-semibold mb-4">搜尋文件</h2>
            <form id="form1" runat="server">
                <div class="flex gap-3">
                    <input type="text" id="txtSearch" runat="server" placeholder="輸入文件名稱或關鍵字..." class="input-field flex-1 px-5 py-3 text-sm text-white placeholder-white/30">
                    <asp:Button ID="btnSearch" runat="server" Text="搜尋" OnClick="btnSearch_Click" CssClass="btn-primary px-7 py-3 rounded-xl text-sm font-semibold cursor-pointer" />
                </div>
                <asp:Label ID="lblStatus" runat="server" CssClass="block mt-3 text-sm text-red-400" Visible="false"></asp:Label>
            </form>
        </div>

        <!-- Documents List -->
        <div data-aos="fade-up" data-aos-delay="80">
            <h2 class="text-lg font-semibold mb-4">近期文件</h2>
            <div class="space-y-3">
                <div class="doc-row flex items-center justify-between p-4 px-5">
                    <div class="flex items-center gap-4 min-w-0">
                        <div class="w-10 h-10 rounded-lg bg-red-500/[0.08] border border-red-500/[0.12] flex items-center justify-center text-red-400 text-sm flex-shrink-0">PDF</div>
                        <div class="min-w-0">
                            <div class="text-sm font-medium truncate">YMJT_Company_Profile_2024.pdf</div>
                            <div class="text-xs text-white/25 mt-0.5">2024/07/15 - 2.4 MB</div>
                        </div>
                    </div>
                    <a href="documents/YMJT_Company_Profile_2024.pdf" class="dl-btn px-4 py-2 text-xs font-semibold no-underline flex-shrink-0 ml-4">下載</a>
                </div>
                <div class="doc-row flex items-center justify-between p-4 px-5">
                    <div class="flex items-center gap-4 min-w-0">
                        <div class="w-10 h-10 rounded-lg bg-emerald/[0.08] border border-emerald/[0.12] flex items-center justify-center text-emerald text-sm flex-shrink-0">XLS</div>
                        <div class="min-w-0">
                            <div class="text-sm font-medium truncate">Q3_2024_Performance_Report.xlsx</div>
                            <div class="text-xs text-white/25 mt-0.5">2024/07/10 - 856 KB</div>
                        </div>
                    </div>
                    <a href="documents/Q3_2024_Performance_Report.xlsx" class="dl-btn px-4 py-2 text-xs font-semibold no-underline flex-shrink-0 ml-4">下載</a>
                </div>
                <div class="doc-row flex items-center justify-between p-4 px-5">
                    <div class="flex items-center gap-4 min-w-0">
                        <div class="w-10 h-10 rounded-lg bg-red-500/[0.08] border border-red-500/[0.12] flex items-center justify-center text-red-400 text-sm flex-shrink-0">PDF</div>
                        <div class="min-w-0">
                            <div class="text-sm font-medium truncate">Employee_Handbook_v3.pdf</div>
                            <div class="text-xs text-white/25 mt-0.5">2024/06/28 - 5.1 MB</div>
                        </div>
                    </div>
                    <a href="documents/Employee_Handbook_v3.pdf" class="dl-btn px-4 py-2 text-xs font-semibold no-underline flex-shrink-0 ml-4">下載</a>
                </div>
                <div class="doc-row flex items-center justify-between p-4 px-5">
                    <div class="flex items-center gap-4 min-w-0">
                        <div class="w-10 h-10 rounded-lg bg-red-500/[0.08] border border-red-500/[0.12] flex items-center justify-center text-red-400 text-sm flex-shrink-0">PDF</div>
                        <div class="min-w-0">
                            <div class="text-sm font-medium truncate">IT_Infrastructure_Whitepaper.pdf</div>
                            <div class="text-xs text-white/25 mt-0.5">2024/06/20 - 3.7 MB</div>
                        </div>
                    </div>
                    <a href="documents/IT_Infrastructure_Whitepaper.pdf" class="dl-btn px-4 py-2 text-xs font-semibold no-underline flex-shrink-0 ml-4">下載</a>
                </div>
            </div>
        </div>
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
