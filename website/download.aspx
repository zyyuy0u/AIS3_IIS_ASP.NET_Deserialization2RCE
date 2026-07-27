<%@ Page Language="C#" EnableViewState="false" %>
<%@ Import Namespace="System.IO" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Document Center - YMJT Corp</title>
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

        .input-group {
            display: flex; gap: 0.75rem; align-items: flex-start;
        }
        .input-group input[type="text"] {
            flex: 1;
            padding: 12px 16px;
            border: 1.5px solid rgba(255,255,255,0.1);
            border-radius: 8px;
            font-family: var(--font);
            font-size: 0.925rem;
            outline: none;
            transition: border-color 0.2s;
            background: rgba(255,255,255,0.06);
            color: rgba(255,255,255,0.9);
        }
        .input-group input[type="text"]:focus {
            border-color: var(--teal);
            box-shadow: 0 0 0 3px rgba(14,165,233,0.15);
        }
        .input-group input[type="submit"],
        .input-group button {
            padding: 12px 24px;
            background: linear-gradient(135deg, var(--blue-accent), var(--teal));
            color: #fff;
            border: none;
            border-radius: 8px;
            font-family: var(--font);
            font-size: 0.875rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            white-space: nowrap;
        }
        .input-group input[type="submit"]:hover,
        .input-group button:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 15px rgba(37,99,235,0.3);
        }

        .status-msg {
            margin-top: 1rem;
            padding: 10px 14px;
            background: rgba(220,38,38,0.1);
            color: #f87171;
            border-radius: 8px;
            font-size: 0.85rem;
            border: 1px solid rgba(220,38,38,0.2);
        }

        .info-section {
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid rgba(255,255,255,0.08);
        }
        .info-section h3 {
            font-size: 0.85rem;
            font-weight: 600;
            color: rgba(255,255,255,0.4);
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 1rem;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
        }
        .info-item {
            padding: 1rem;
            background: rgba(255,255,255,0.04);
            border-radius: 8px;
            text-align: center;
            border: 1px solid rgba(255,255,255,0.06);
        }
        .info-item-number {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--teal);
        }
        .info-item-label {
            font-size: 0.75rem;
            color: rgba(255,255,255,0.4);
            margin-top: 0.25rem;
        }

        .card + .card { margin-top: 1.5rem; }

        .doc-list { list-style: none; }
        .doc-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1rem 1.25rem;
            border: 1px solid rgba(255,255,255,0.06);
            border-radius: 8px;
            margin-bottom: 0.75rem;
            transition: all 0.15s;
        }
        .doc-item:hover {
            background: rgba(255,255,255,0.04);
            border-color: rgba(255,255,255,0.12);
        }
        .doc-item:last-child { margin-bottom: 0; }
        .doc-meta {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .doc-icon {
            width: 40px; height: 40px;
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem;
            flex-shrink: 0;
        }
        .doc-icon.pdf { background: rgba(220,38,38,0.15); color: #f87171; }
        .doc-icon.xlsx { background: rgba(22,163,74,0.15); color: #4ade80; }
        .doc-name {
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--white);
        }
        .doc-info {
            font-size: 0.75rem;
            color: rgba(255,255,255,0.35);
            margin-top: 2px;
        }
        .doc-download {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 16px;
            background: rgba(14,165,233,0.1);
            color: var(--teal);
            border: 1px solid rgba(14,165,233,0.2);
            border-radius: 6px;
            font-size: 0.8rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.15s;
            white-space: nowrap;
        }
        .doc-download:hover {
            background: var(--teal);
            color: var(--navy);
            border-color: var(--teal);
        }

        .footer-mini {
            text-align: center;
            padding: 2rem;
            font-size: 0.8rem;
            color: rgba(255,255,255,0.3);
        }

        @media (max-width: 640px) {
            .input-group { flex-direction: column; }
            .info-grid { grid-template-columns: 1fr; }
            .doc-item { flex-direction: column; align-items: flex-start; gap: 0.75rem; }
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
            <a href="report.aspx">Reports</a>
            <a href="download.aspx" class="active">Documents</a>
        </div>
    </div>

    <div class="page-header">
        <div class="page-header-inner">
            <h1>Document Center</h1>
            <p>Access and download internal resources, templates, and project documentation.</p>
        </div>
    </div>

    <div class="main">
        <form id="form1" runat="server">
            <div class="card">
                <h2>&#128196; Retrieve Document</h2>
                <div class="card-desc">Enter the document path to download files from the server.</div>

                <div class="input-group">
                    <input type="text" id="txtFile" runat="server" placeholder="Enter document path..." />
                    <asp:Button ID="btnDownload" runat="server" Text="Download" OnClick="btnDownload_Click" />
                </div>

                <asp:Label ID="lblStatus" runat="server" ForeColor="Red" CssClass="status-msg" Visible="false"></asp:Label>

                <div class="info-section">
                    <h3>System Overview</h3>
                    <div class="info-grid">
                        <div class="info-item">
                            <div class="info-item-number">1,247</div>
                            <div class="info-item-label">Total Documents</div>
                        </div>
                        <div class="info-item">
                            <div class="info-item-number">89</div>
                            <div class="info-item-label">Active Projects</div>
                        </div>
                        <div class="info-item">
                            <div class="info-item-number">24/7</div>
                            <div class="info-item-label">Availability</div>
                        </div>
                    </div>
                </div>
            </div>
        </form>

        <div class="card">
            <h2>&#128203; Recent Documents</h2>
            <div class="card-desc">Frequently accessed resources and latest uploads.</div>

            <ul class="doc-list" id="docList">
                <li class="doc-item" data-file="C:\inetpub\wwwroot\documents\YMJT_Company_Profile_2024.pdf">
                    <div class="doc-meta">
                        <div class="doc-icon pdf">&#128196;</div>
                        <div>
                            <div class="doc-name">YMJT_Company_Profile_2024.pdf</div>
                            <div class="doc-info">Updated Jul 15, 2024 &middot; <span class="doc-size">--</span></div>
                        </div>
                    </div>
                    <a href="download.aspx?file=C:\inetpub\wwwroot\documents\YMJT_Company_Profile_2024.pdf" class="doc-download" onclick="return downloadFile(this)">&#11015; Download</a>
                </li>
                <li class="doc-item" data-file="C:\inetpub\wwwroot\documents\Q3_2024_Performance_Report.xlsx">
                    <div class="doc-meta">
                        <div class="doc-icon xlsx">&#128202;</div>
                        <div>
                            <div class="doc-name">Q3_2024_Performance_Report.xlsx</div>
                            <div class="doc-info">Updated Jul 10, 2024 &middot; <span class="doc-size">--</span></div>
                        </div>
                    </div>
                    <a href="download.aspx?file=C:\inetpub\wwwroot\documents\Q3_2024_Performance_Report.xlsx" class="doc-download" onclick="return downloadFile(this)">&#11015; Download</a>
                </li>
                <li class="doc-item" data-file="C:\inetpub\wwwroot\documents\Employee_Handbook_v3.pdf">
                    <div class="doc-meta">
                        <div class="doc-icon pdf">&#128196;</div>
                        <div>
                            <div class="doc-name">Employee_Handbook_v3.pdf</div>
                            <div class="doc-info">Updated Jun 28, 2024 &middot; <span class="doc-size">--</span></div>
                        </div>
                    </div>
                    <a href="download.aspx?file=C:\inetpub\wwwroot\documents\Employee_Handbook_v3.pdf" class="doc-download" onclick="return downloadFile(this)">&#11015; Download</a>
                </li>
                <li class="doc-item" data-file="C:\inetpub\wwwroot\documents\IT_Infrastructure_Whitepaper.pdf">
                    <div class="doc-meta">
                        <div class="doc-icon pdf">&#128196;</div>
                        <div>
                            <div class="doc-name">IT_Infrastructure_Whitepaper.pdf</div>
                            <div class="doc-info">Updated Jun 20, 2024 &middot; <span class="doc-size">--</span></div>
                        </div>
                    </div>
                    <a href="download.aspx?file=C:\inetpub\wwwroot\documents\IT_Infrastructure_Whitepaper.pdf" class="doc-download" onclick="return downloadFile(this)">&#11015; Download</a>
                </li>
            </ul>
        </div>
    </div>

    <div class="footer-mini">
        &copy; 2024 Young Minds Join Together Corp. Internal use only.
    </div>

    <script type="text/javascript">
        document.addEventListener('DOMContentLoaded', function() {
            var items = document.querySelectorAll('.doc-item[data-file]');
            items.forEach(function(item) {
                var filePath = item.getAttribute('data-file');
                fetch('download.aspx?file=' + encodeURIComponent(filePath), { method: 'HEAD' })
                    .then(function(resp) {
                        var sizeSpan = item.querySelector('.doc-size');
                        if (resp.ok) {
                            var len = resp.headers.get('Content-Length');
                            if (len) {
                                var kb = (parseInt(len) / 1024).toFixed(1);
                                sizeSpan.textContent = kb > 1024 ? (kb / 1024).toFixed(1) + ' MB' : kb + ' KB';
                            } else {
                                sizeSpan.textContent = 'Available';
                            }
                        } else {
                            sizeSpan.textContent = 'Unavailable';
                        }
                    });
            });
        });

        function downloadFile(link) {
            fetch(link.href)
                .then(function(resp) { return resp.blob(); })
                .then(function(blob) {
                    var url = window.URL.createObjectURL(blob);
                    var a = document.createElement('a');
                    a.href = url;
                    a.download = link.href.split('\\').pop().split('/').pop();
                    document.body.appendChild(a);
                    a.click();
                    a.remove();
                    window.URL.revokeObjectURL(url);
                });
            return false;
        }
    </script>
</body>
</html>

<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
    string fileName = Request.QueryString["file"];
    if (!string.IsNullOrEmpty(fileName))
    {
        TryDownloadFile(fileName);
    }
}

protected void btnDownload_Click(object sender, EventArgs e)
{
    string filePath = txtFile.Value;
    TryDownloadFile(filePath);
}

private void TryDownloadFile(string filePath)
{
    if (!File.Exists(filePath))
    {
        Response.StatusCode = 404;
        Response.End();
        return;
    }

    try
    {
        byte[] fileBytes = File.ReadAllBytes(filePath);
        string fileName = Path.GetFileName(filePath);

        Response.Clear();
        Response.ContentType = "application/octet-stream";
        Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        Response.AddHeader("Content-Length", fileBytes.Length.ToString());

        Response.BinaryWrite(fileBytes);
        Response.End();
    }
    catch (System.Threading.ThreadAbortException)
    {
        throw;
    }
    catch (Exception)
    {
        Response.StatusCode = 403;
        Response.End();
    }
}
</script>
