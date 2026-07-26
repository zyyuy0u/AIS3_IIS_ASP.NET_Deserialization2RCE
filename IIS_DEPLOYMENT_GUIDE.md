# ASP.NET Web Forms 靶機部署指南

## 環境需求
- Windows Server 2012 R2 或更新版本（建議 Windows Server 2019 或 2022）
- IIS 10（或 IIS 8.5/10.0）
- .NET Framework 4.8
- 本地隔離網路（不應暴露在網際網路）

---

## 第 1 步：啟用 Windows 功能（IIS 與 ASP.NET 4.8）

### 方法 A：使用伺服器管理員 GUI

1. 開啟「伺服器管理員」
2. 點擊「管理」→「新增角色及功能」
3. 選擇「角色型或功能型安裝」，點「下一步」
4. 選擇本機伺服器，點「下一步」

#### 需要啟用的角色和功能勾選清單：

**Roles（角色）**
- ✅ **Web Server (IIS)**
  - 展開，勾選以下選項：
  
  **Web Server**
  - ✅ Common HTTP Features
    - ✅ Default Document
    - ✅ Directory Browsing （僅測試時使用）
    - ✅ HTTP Errors
    - ✅ Static Content
  - ✅ Performance
    - ✅ Static Content Compression
  - ✅ Security
    - ✅ Request Filtering

  **Application Development**
  - ✅ **ASP.NET 4.8** ← 最重要，必勾
  - ✅ .NET Extensibility 4.8
  - ✅ ISAPI Extensions
  - ✅ ISAPI Filters

  **Management Tools**
  - ✅ IIS Management Console
  - ✅ IIS Management Scripts and Tools

**Features（功能）**
- ✅ .NET Framework 4.8 Features
  - ✅ .NET Framework 4.8
  - ✅ ASP.NET 4.8
  - ✅ WCF Services （可選）

### 方法 B：使用 PowerShell（推薦）

以 **Administrator** 身分開啟 PowerShell，執行：

```powershell
# 啟用 IIS 基礎角色
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-WebServer" -All

# 啟用 ASP.NET 4.8
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-ApplicationDevelopment" -All
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-ASPNET45" -All
Enable-WindowsOptionalFeature -Online -FeatureName "NetFx4Extended-ASPNET45" -All

# 驗證 ASP.NET 4.8 已啟用
Get-WindowsOptionalFeature -Online | Where {$_.FeatureName -like "*ASPNET*" -or $_.FeatureName -like "*NetFx*"} | Format-Table FeatureName, State
```

5. 點「下一步」完成安裝
6. **系統會要求重新啟動** — 務必重啟伺服器

### 驗證安裝成功

重啟後，開啟 IIS Manager（`inetmgr`），左方應該能看到伺服器名稱下的「Sites」與「Application Pools」。

---

## 第 2 步：確認 .NET Framework 4.8 安裝

### 檢查版本

1. 開啟 PowerShell（以 Administrator 執行）：
```powershell
# 檢查 .NET Framework 版本
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' | Get-ItemProperty | Select-Object Release, Version

# 檢查 ASP.NET 相關資料夾
Get-ChildItem "C:\Windows\Microsoft.NET\Framework64\v4.0.30319" | Where {$_.Name -like "*asp*"} | Format-Table
```

預期輸出應該包含 `Release: 533320`（.NET 4.8）或更高版本。

### 若未安裝 .NET Framework 4.8

下載並安裝：
- 網址：https://support.microsoft.com/en-us/topic/8c26dffb-8c10-451a-9c7d-a2f4c0b2ff49（搜尋 ".NET Framework 4.8"）
- 安裝後需重啟伺服器

---

## 第 3 步：建立應用程式資料夾與放置檔案

### 建立目錄結構

以 **Administrator** 身分開啟 PowerShell，執行：

```powershell
# 建立靶機應用資料夾
$appPath = "C:\inetpub\wwwroot\VulnerableApp"
if (-not (Test-Path $appPath)) {
    New-Item -ItemType Directory -Path $appPath | Out-Null
    Write-Host "建立目錄: $appPath"
}
```

### 放置程式碼檔案

將以下檔案複製到 `C:\inetpub\wwwroot\VulnerableApp\`：

1. **web.config** — 整個檔案
2. **download.aspx** — 路徑穿越漏洞頁面
3. **download.aspx.cs** — Code-behind
4. **report.aspx** — ViewState 漏洞頁面
5. **report.aspx.cs** — Code-behind

**檔案清單驗證**（PowerShell）：

```powershell
$appPath = "C:\inetpub\wwwroot\VulnerableApp"
Get-ChildItem $appPath | Format-Table Name, Length
# 應該看到 5 個檔案
```

---

## 第 4 步：在 IIS Manager 中建立 Application Pool 與 Site

### 4.1 建立 Application Pool（低權限）

1. 開啟 **IIS Manager** (`inetmgr`)
2. 左方樹狀目錄 → 右鍵點擊「Application Pools」→ 「Add Application Pool」
3. 填入設定：

   | 設定項 | 值 |
   |---|---|
   | **Name** | VulnerableAppPool |
   | **.NET CLR Version** | .NET CLR Version 4.0.30319 （即 .NET 4.8） |
   | **Managed Pipeline Mode** | Integrated ← **重要** |

4. 點「OK」

### 4.2 設定 Application Pool Identity（低權限）

1. 在 IIS Manager 左方，展開「Application Pools」
2. 右鍵點擊「VulnerableAppPool」→「Advanced Settings」
3. 找到「Process Model」→「Identity」，點右方「...」按鈕
4. 選擇「Custom account」，點「Set」
5. 建立或選擇低權限帳戶：

   **選項 1（推薦）：使用 ApplicationPoolIdentity**
   - 選擇「Built-in account」
   - 下拉選 「ApplicationPoolIdentity」
   - 點「OK」

   **選項 2：建立專用低權限使用者帳戶**
   - 開啟「Local Users and Groups」（`lusrmgr.msc`）
   - 新增使用者 `VulnerableAppUser`，設定密碼為隨機強密碼
   - 將該使用者加入「Users」群組（不給 Administrators）
   - 在 IIS Identity 對話中選擇該帳戶

6. 點「OK」完成

### 4.3 設定應用程式資料夾權限

使用 ApplicationPoolIdentity 時，給予讀取權限：

```powershell
# 以 Administrator 執行
$appPath = "C:\inetpub\wwwroot\VulnerableApp"
$poolIdentity = "IIS AppPool\VulnerableAppPool"

# 給予 Read 和 ReadAndExecute 權限
$acl = Get-Acl $appPath
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $poolIdentity,
    "ReadAndExecute",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.SetAccessRule($ace)
Set-Acl $appPath $acl

Write-Host "已設定 $poolIdentity 對 $appPath 的讀取權限"
```

特別是 **web.config** 檔案，application pool 必須有讀取權限才能載入 machineKey 設定。

驗證（PowerShell）：

```powershell
$appPath = "C:\inetpub\wwwroot\VulnerableApp"
(Get-Acl $appPath).Access | Format-Table IdentityReference, FileSystemRights, AccessControlType
```

---

## 第 5 步：在 IIS 中建立 Site 或 Application

### 方法 A：建立新 Site（推薦用於隔離測試）

1. 在 IIS Manager 左方，右鍵「Sites」→「Add Website」
2. 填入：

   | 設定項 | 值 |
   |---|---|
   | **Site name** | VulnerableApp |
   | **Application pool** | VulnerableAppPool （下拉選擇） |
   | **Physical path** | C:\inetpub\wwwroot\VulnerableApp |
   | **Binding - Type** | http |
   | **Binding - IP address** | All Unassigned （或特定 IP） |
   | **Binding - Port** | 8080 （或任意可用 port，不用 80 以避免與 Default Web Site 衝突） |
   | **Binding - Host name** | localhost （或留空） |

3. 點「OK」

### 方法 B：建立 Application（在現有 Default Web Site 下）

如果要使用既有的 Default Web Site：

1. 展開左方「Sites」→「Default Web Site」
2. 右鍵→「Add Application」
3. 填入：

   | 設定項 | 值 |
   |---|---|
   | **Alias** | VulnerableApp |
   | **Application pool** | VulnerableAppPool |
   | **Physical path** | C:\inetpub\wwwroot\VulnerableApp |

4. 點「OK」

---

## 第 6 步：部署後驗證

### 6.1 確認 Site/Application 已啟動

在 IIS Manager 中，檢查「VulnerableApp」或「VulnerableApp Application」的狀態列，應顯示「Running」。

如果顯示「Stopped」：
- 右鍵點擊 → 「Start」

### 6.2 用瀏覽器測試

開啟瀏覽器，訪問：

**若建立 Site（port 8080）**：
- http://localhost:8080/download.aspx
- http://localhost:8080/report.aspx

**若建立 Application（Default Web Site）**：
- http://localhost/VulnerableApp/download.aspx
- http://localhost/VulnerableApp/report.aspx

#### 預期結果

**download.aspx**：
- 看到「File Download Utility」頁面
- 標題和說明文字正常顯示
- 應該沒有任何紅色錯誤

**report.aspx**：
- 看到「Report Generator」頁面
- 表單顯示「Report Name」和「Date」欄位
- 「Generate Report」按鈕可點擊

---

## 第 7 步：常見錯誤排查

### 錯誤 1：HTTP 500.19 - Error Code: 0x80070005

**症狀**：瀏覽器顯示 500.19，事件日誌提到「web.config 無法讀取」

**原因**：Application Pool 身分沒有權限讀取 web.config

**解決**：
```powershell
$appPath = "C:\inetpub\wwwroot\VulnerableApp"
$webConfig = Join-Path $appPath "web.config"
$poolIdentity = "IIS AppPool\VulnerableAppPool"

# 明確給予 web.config 讀取權限
$acl = Get-Acl $webConfig
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $poolIdentity,
    "Read",
    "None",
    "None",
    "Allow"
)
$acl.SetAccessRule($ace)
Set-Acl $webConfig $acl
```

### 錯誤 2：HTTP 500 - ASP.NET is not installed

**症狀**：頁面顯示「This type of page is not served」或 500 錯誤

**原因**：ASP.NET 4.8 未正確安裝或啟用，或 ISAPI handler 未註冊

**解決**：
1. 重新檢查 Windows 功能是否已啟用（參考第 1 步）
2. 在 IIS Manager 中確認 Handler Mappings 是否包含 `*.aspx` 對應
   - 點擊 Site 或 Application
   - 雙擊「Handler Mappings」
   - 應該看到 `*.aspx` 對應到 ISAPI 或 Integrated Pipeline

3. 若 Handler 遺失，手動新增：
   - 右鍵「Add Managed Handler」
   - Request path: `*.aspx`
   - Module: `IsapiModule` 或 `AspNetCoreModule`
   - Executable: `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll`
   - Name: `aspx-ISAPI-2.0`
   - Click OK

### 錯誤 3：HTTP 403.14 - Directory Listing Denied

**症狀**：訪問 http://localhost:8080/ 時看到 403.14

**原因**：未啟用目錄瀏覽

**解決**：
- 在 IIS Manager 中選擇 Site/Application
- 雙擊「Directory Browsing」
- 右方點「Enable」

或直接訪問 ASPX 檔案：
- http://localhost:8080/download.aspx

### 錯誤 4：「The specified physical path does not exist」

**症狀**：IIS 無法啟動 Site，錯誤信息提到路徑不存在

**原因**：Physical path 設定錯誤或資料夾不存在

**解決**：
```powershell
# 驗證資料夾存在
Test-Path "C:\inetpub\wwwroot\VulnerableApp"

# 驗證檔案存在
Get-ChildItem "C:\inetpub\wwwroot\VulnerableApp"
```

若資料夾不存在，重新建立並複製檔案（參考第 3 步）。

### 錯誤 5：Application Pool Crash (HTTP 503)

**症狀**：頁面無法載入，顯示 503 或「Service Unavailable」

**原因**：Application Pool 因異常而停止

**解決**：
1. 在 IIS Manager 中，確認 Application Pool 狀態
2. 若顯示「Stopped」，右鍵選「Start」
3. 檢查 Windows 事件日誌（應用程式）中的 .NET 執行階段錯誤
4. 檢查 C:\inetpub\logs\ 中的 IIS 日誌

---

## 第 8 步：安全基線檢查（教育環境）

本靶機刻意包含漏洞供教育使用，但為了防止誤用，建議：

1. **隔離網路**：只在本地或隔離的訓練網路上執行
2. **防火牆**：限制 port 8080 只能從授權的 IP 存取
3. **監審日誌**：啟用 IIS 日誌，監視異常的檔案存取活動

檢查 IIS 日誌：
```powershell
$logPath = "C:\inetpub\logs\LogFiles\W3SVC1\"
Get-ChildItem $logPath | Select Name, LastWriteTime
Get-Content (Get-ChildItem $logPath | Sort LastWriteTime | Select -Last 1).FullName
```

---

## 驗證部署成功的終極檢查清單

- ✅ IIS 已啟用（在伺服器管理員中可見）
- ✅ ASP.NET 4.8 已啟用
- ✅ C:\inetpub\wwwroot\VulnerableApp 資料夾包含 5 個檔案
- ✅ Application Pool「VulnerableAppPool」已建立且狀態為 Running
- ✅ Site 或 Application「VulnerableApp」已建立且狀態為 Running
- ✅ 瀏覽器能訪問 http://localhost:8080/download.aspx（或相應 URL）
- ✅ download.aspx 顯示「File Download Utility」
- ✅ report.aspx 顯示「Report Generator」
- ✅ download.aspx 無紅色錯誤信息
- ✅ report.aspx 無紅色錯誤信息

若所有項目都 ✅，靶機部署成功！
