<%@ Page Language="C#" EnableViewState="false" %>
<%@ Import Namespace="System.IO" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>File Download</title>
</head>
<body style="font-family: Arial, sans-serif; margin: 20px;">
    <h1>File Download Utility</h1>

    <form id="form1" runat="server">
        <div>
            <label for="txtFile">Enter file path to download:</label><br />
            <input type="text" id="txtFile" runat="server" style="width: 400px;" />
            <asp:Button ID="btnDownload" runat="server" Text="Download" OnClick="btnDownload_Click" />
        </div>

        <asp:Label ID="lblStatus" runat="server" ForeColor="Red" style="margin-top: 10px;"></asp:Label>
    </form>

    <hr />
    <h2>Usage Examples:</h2>
    <p>
        Try these paths to explore:<br />
        <code>C:\inetpub\wwwroot\VulnerableApp\download.aspx</code> - Self<br />
        <code>C:\inetpub\wwwroot\VulnerableApp\web.config</code> - Configuration file (VULNERABLE!)<br />
        <code>C:\inetpub\wwwroot\..\..\windows\win.ini</code> - Path traversal example<br />
    </p>
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
    try
    {
        if (!File.Exists(filePath))
        {
            lblStatus.Text = "Error: File not found - " + filePath;
            return;
        }

        byte[] fileBytes = File.ReadAllBytes(filePath);
        string fileName = Path.GetFileName(filePath);

        Response.Clear();
        Response.ContentType = "application/octet-stream";
        Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        Response.AddHeader("Content-Length", fileBytes.Length.ToString());

        Response.BinaryWrite(fileBytes);
        Response.End();
    }
    catch (UnauthorizedAccessException)
    {
        lblStatus.Text = "Error: Access Denied - " + filePath;
    }
    catch (Exception ex)
    {
        lblStatus.Text = "Error: " + ex.Message;
    }
}
</script>
