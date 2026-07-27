<%@ Page Language="C#" EnableViewState="true" ViewStateEncryptionMode="Always" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Report Generator - YMJT Corp</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        :root {
            --navy: #0c1b2a;
            --blue-accent: #2563eb;
            --teal: #0ea5e9;
            --white: #ffffff;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-400: #94a3b8;
            --gray-500: #64748b;
            --gray-700: #334155;
            --gray-800: #1e293b;
            --gold: #d4a574;
            --green: #22c55e;
            --font: 'Segoe UI', system-ui, -apple-system, sans-serif;
        }
        body { font-family: var(--font); background: var(--navy); color: rgba(255,255,255,0.9); line-height: 1.6; }

        .topbar {
            background: var(--navy);
            padding: 0 2rem;
            height: 56px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .topbar-logo {
            display: flex;
            align-items: center;
            gap: 10px;
            color: var(--white);
            text-decoration: none;
            font-weight: 700;
            font-size: 1rem;
        }
        .topbar-logo-icon {
            width: 32px; height: 32px;
            background: linear-gradient(135deg, var(--blue-accent), var(--teal));
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 12px; font-weight: 800; color: #fff;
        }
        .topbar-logo span { color: var(--gold); }
        .topbar-nav { display: flex; gap: 1.5rem; }
        .topbar-nav a {
            color: rgba(255,255,255,0.6); text-decoration: none;
            font-size: 0.8rem; font-weight: 500; transition: color 0.2s;
        }
        .topbar-nav a:hover { color: #fff; }
        .topbar-nav a.active { color: var(--teal); }

        .page-header {
            background: linear-gradient(135deg, var(--navy), #1e3a5f);
            padding: 3rem 2rem 2.5rem;
            color: #fff;
        }
        .page-header-inner { max-width: 900px; margin: 0 auto; }
        .page-header h1 { font-size: 1.75rem; font-weight: 700; margin-bottom: 0.5rem; }
        .page-header p { font-size: 0.95rem; color: rgba(255,255,255,0.6); }

        .main { max-width: 900px; margin: -1.5rem auto 3rem; padding: 0 2rem; position: relative; z-index: 1; }

        .card {
            background: rgba(255,255,255,0.04);
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,0.08);
            padding: 2rem;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            margin-bottom: 1.5rem;
        }

        .card h2 {
            font-size: 1.1rem; font-weight: 700; color: var(--white);
            margin-bottom: 0.5rem;
            display: flex; align-items: center; gap: 8px;
        }

        .card-desc {
            font-size: 0.875rem; color: rgba(255,255,255,0.5);
            margin-bottom: 1.5rem;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .form-group {
            margin-bottom: 1rem;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .form-group label {
            display: block;
            font-size: 0.8rem;
            font-weight: 600;
            color: rgba(255,255,255,0.6);
            margin-bottom: 0.4rem;
        }

        .form-group input[type="text"] {
            width: 100%;
            padding: 12px 16px;
            border: 1.5px solid rgba(255,255,255,0.1);
            border-radius: 8px;
            font-family: var(--font);
            font-size: 0.925rem;
            color: rgba(255,255,255,0.9);
            background: rgba(255,255,255,0.06);
            outline: none;
            transition: border-color 0.2s;
        }

        .form-group input[type="text"]:focus {
            border-color: var(--teal);
            box-shadow: 0 0 0 3px rgba(14,165,233,0.15);
        }

        .btn-generate {
            padding: 12px 28px;
            background: linear-gradient(135deg, var(--blue-accent), var(--teal));
            color: #fff;
            border: none;
            border-radius: 8px;
            font-family: var(--font);
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-generate:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 15px rgba(37,99,235,0.3);
        }

        .result-box {
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 8px;
            padding: 1.25rem;
            margin-top: 1.5rem;
            min-height: 60px;
        }

        .result-box pre {
            font-family: 'Consolas', 'Courier New', monospace;
            font-size: 0.875rem;
            color: rgba(255,255,255,0.7);
            white-space: pre-wrap;
            word-wrap: break-word;
        }

        .error-msg {
            color: #f87171;
            font-size: 0.85rem;
            margin-top: 0.75rem;
        }

        .quick-stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
        }

        .quick-stat {
            padding: 1.25rem;
            background: rgba(255,255,255,0.04);
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.06);
        }

        .quick-stat-label {
            font-size: 0.75rem;
            color: rgba(255,255,255,0.4);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.5rem;
        }

        .quick-stat-value {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--white);
        }

        .quick-stat-change {
            font-size: 0.75rem;
            color: var(--green);
            margin-top: 0.25rem;
        }

        .footer-mini {
            text-align: center;
            padding: 2rem;
            font-size: 0.8rem;
            color: rgba(255,255,255,0.3);
        }

        @media (max-width: 640px) {
            .form-grid { grid-template-columns: 1fr; }
            .quick-stats { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="topbar">
        <a href="/" class="topbar-logo">
            <div class="topbar-logo-icon">YM</div>
            YMJT <span>Corp</span>
        </a>
        <div class="topbar-nav">
            <a href="/">Home</a>
            <a href="report.aspx" class="active">Reports</a>
            <a href="download.aspx">Documents</a>
        </div>
    </div>

    <div class="page-header">
        <div class="page-header-inner">
            <h1>Report Generator</h1>
            <p>Generate and export custom analytics reports for your projects and clients.</p>
        </div>
    </div>

    <div class="main">
        <div class="card">
            <h2>&#128202; Quick Overview</h2>
            <div class="card-desc">Current period performance metrics</div>
            <div class="quick-stats">
                <div class="quick-stat">
                    <div class="quick-stat-label">Active Projects</div>
                    <div class="quick-stat-value">24</div>
                    <div class="quick-stat-change">+3 this month</div>
                </div>
                <div class="quick-stat">
                    <div class="quick-stat-label">Reports Generated</div>
                    <div class="quick-stat-value">156</div>
                    <div class="quick-stat-change">+12 this week</div>
                </div>
                <div class="quick-stat">
                    <div class="quick-stat-label">Completion Rate</div>
                    <div class="quick-stat-value">94%</div>
                    <div class="quick-stat-change">+2% vs last month</div>
                </div>
            </div>
        </div>

        <form id="form1" runat="server">
            <div class="card">
                <h2>&#128221; Generate Report</h2>
                <div class="card-desc">Fill in the details below to generate a new analytics report.</div>

                <div class="form-grid">
                    <div class="form-group">
                        <label for="txtReportName">Report Name</label>
                        <input type="text" id="txtReportName" runat="server" placeholder="Q3 Performance Review" />
                    </div>

                    <div class="form-group">
                        <label for="txtReportDate">Report Date</label>
                        <input type="text" id="txtReportDate" runat="server" placeholder="YYYY-MM-DD" />
                    </div>

                    <div class="form-group full-width">
                        <asp:Button ID="btnGenerate" runat="server" Text="Generate Report" OnClick="btnGenerate_Click" CssClass="btn-generate" />
                    </div>
                </div>

                <div class="result-box">
                    <asp:Label ID="lblResult" runat="server"></asp:Label>
                </div>

                <asp:Label ID="lblError" runat="server" CssClass="error-msg"></asp:Label>
            </div>

            <div style="display:none;">
                <asp:GridView ID="gvHiddenData" runat="server" EnableViewState="true">
                </asp:GridView>
            </div>
        </form>
    </div>

    <div class="footer-mini">
        &copy; 2024 Young Minds Join Together Corp. Internal use only.
    </div>
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
            lblError.Text = "Report name is required.";
            return;
        }

        if (string.IsNullOrWhiteSpace(reportDate))
        {
            lblError.Text = "Date is required.";
            return;
        }

        string report = "Report: " + reportName + "\nDate: " + reportDate + "\nGenerated at: " + DateTime.Now;
        lblResult.Text = "<pre>" + System.Web.HttpUtility.HtmlEncode(report) + "</pre>";
        lblError.Text = "";
    }
    catch (Exception ex)
    {
        lblError.Text = "Error: " + ex.Message;
    }
}
</script>
