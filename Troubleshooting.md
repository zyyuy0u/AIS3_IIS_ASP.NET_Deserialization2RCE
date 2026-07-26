# ASP.NET Web Forms 靶機部署 - 痛苦指南

## 簡介
本文檔記錄了在 Windows Server 上部署漏洞 ASP.NET Web Forms 應用的**所有問題、坑點與解決方案**，供 AIS3 簡報參考。

---

## 問題 1：IIS Manager 無法找到 Application Pools

### 症狀
開啟 IIS Manager 後，在首頁右鍵無法找到「Application Pools」選項。

### 根本原因
- IIS Manager 首頁顯示的是伺服器管理面板（icon tiles），不是樹狀結構
- 需要通過樹狀菜單或右方快速連結才能存取

### 解決方案
**方案 A - 使用右方快速連結（最簡單）**：
- 在右方 Actions 面板點擊藍色連結「View Application Pools」

**方案 B - 展開左方樹狀結構**：
- 在左方「Connections」面板中，點擊伺服器名稱左邊的「>」箭頭展開
- 會看到「Application Pools」和「Sites」子項目

### 經驗教訓
- IIS Manager 的 UI 對初使用者來說容易混淆
- 優先使用右方 Actions 面板的快速連結，比樹狀菜單更直觀

---

## 問題 2：複製的檔案被加上 .txt 擴展名

### 症狀
從本機複製 5 個程式碼檔案到遠端伺服器後，所有檔案都變成了：
- `download.aspx.cs.txt`
- `download.aspx.txt`
- `report.aspx.cs.txt`
- `report.aspx.txt`
- `web.config.txt`

導致 IIS 無法識別這些檔案。

### 根本原因
- 複製時可能被另存為文本檔案
- 或 Windows 自動在副檔名末尾加上 `.txt`

### 解決方案
在 Windows 資源管理員中：
1. 啟用「View」→「File name extensions」查看完整檔案名
2. 逐一右鍵「Rename」，移除末尾的 `.txt`

或用 PowerShell：
```powershell
Get-ChildItem "C:\inetpub\wwwroot\VulnerableApp" -Filter "*.txt" | ForEach-Object {
    Rename-Item -Path $_.FullName -NewName ($_.Name -replace '\.txt$', '')
}
```

### 經驗教訓
- RDP 複製粘貼可能會意外改變檔案副檔名
- 部署後一定要驗證檔案名稱和類型
- 啟用副檔名顯示是部署前的必要步驟

---

## 問題 3：Parser Error - 無法載入 CodeBehind 類型

### 症狀
訪問頁面時出現：
```
Parser Error
Could not load type 'VulnerableApp.download'.
```

### 根本原因
- `.aspx` 檔案在 `@Page` 指令中宣告了 `CodeBehind="download.aspx.cs"` 和 `Inherits="VulnerableApp.download"`
- IIS 嘗試動態編譯 `.cs` 檔案，但編譯失敗（可能是命名空間不匹配或編譯器配置問題）
- ASP.NET 4.8 的動態編譯在某些環境下不可靠

### 解決方案
**使用內嵌代碼方式（推薦）**：
1. 移除 `.aspx.cs` 代碼後置檔案
2. 在 `.aspx` 檔案中使用 `<script runat="server">...</script>` 內嵌事件處理代碼
3. 移除 `@Page` 指令中的 `CodeBehind` 和 `Inherits` 屬性

**範例**：
```aspx
<%@ Page Language="C#" %>
<script runat="server">
protected void btnDownload_Click(object sender, EventArgs e)
{
    // 代碼直接寫在這裡
}
</script>
```

### 經驗教訓
- 代碼後置（CodeBehind）在某些 IIS 配置下不是可靠選項
- 內嵌代碼雖然不符合代碼分離最佳實踐，但在簡單場景下更穩定
- 對於教育目的的簡單應用，內嵌代碼是最保險的方式

---

## 問題 4：CryptographicException - 密碼學操作失敗

### 症狀
頁面加載時拋出：
```
System.Security.Cryptography.CryptographicException: 
Error occurred during a cryptographic operation.
```

Stack trace 指向 `ObjectStateFormatter.Serialize`（ViewState 序列化）。

### 根本原因
web.config 中的 `<machineKey>` 配置不正確：
- `validationKey` 長度不足或格式無效
- `decryptionKey` 長度不足或格式無效
- 或指定的演算法（HMACSHA256、AES）與 key 長度不匹配

**範例錯誤配置**：
```xml
<machineKey validationKey="A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E7F8A9B0C1D2E3F0A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E7F8"
             decryptionKey="F8A7B6C5D4E3F2A1B0C9D8E7F6A5B4C3D2E1F0A9B8C7D6E5F4A3B2C1D0E9F8"
             validation="HMACSHA256"
             decryption="AES" />
```
❌ `validationKey` 有 96 個字符（太長）

### 解決方案

**方案 A - 生成有效的 machineKey**：
在 PowerShell 中執行：
```powershell
$rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
$vkb = New-Object byte[] 32
$rng.GetBytes($vkb)
$dkb = New-Object byte[] 32
$rng.GetBytes($dkb)
Write-Host "validationKey: $([BitConverter]::ToString($vkb) -replace '-','')"
Write-Host "decryptionKey: $([BitConverter]::ToString($dkb) -replace '-','')"
```

**方案 B - 移除硬編 machineKey（更簡單）**：
直接從 web.config 中移除 `<machineKey>` 標籤，讓 IIS 自動生成和管理。

```xml
<!-- 不要硬編 machineKey，讓 IIS 自動生成 -->
<!-- IIS 會在 IIS_IUSRS 等位置管理 key -->
```

### 經驗教訓
- **硬編 machineKey 很容易出錯**——key 的格式、長度、編碼都要完全正確
- key 長度規則：
  - HMACSHA256：需要 64 個十六進位字符（32 bytes）
  - AES：需要 64 個十六進位字符（32 bytes）
- **推薦方案**：生產環境中不要硬編 key，讓 IIS 管理
- 對於教育目的，移除硬編 key 是最快的解決方案

---

## 問題 5：HTTP 404 - 找不到資源

### 症狀
訪問 `http://localhost:8080/download.aspx` 返回 HTTP 404：
```
The resource cannot be found.
Requested URL: /download.aspx
```

### 根本原因
多個可能性：
1. Site 設定的 Physical path 錯誤
2. 檔案確實不存在或被誤刪
3. IIS 快取舊設定

### 解決方案
**步驟 1 - 檢查 IIS 設定**：
- 在 IIS Manager 中選擇 Site
- 點右方「Basic Settings...」
- 確認「Physical path」為正確路徑：`C:\inetpub\wwwroot\VulnerableApp`

**步驟 2 - 驗證檔案存在**：
```powershell
dir "C:\inetpub\wwwroot\VulnerableApp"
```

**步驟 3 - 重啟 IIS**：
```powershell
iisreset
```

### 經驗教訓
- 404 問題通常不是代碼問題，而是配置問題
- 部署後要三層驗證：
  1. IIS 配置（Physical path）
  2. 檔案物理存在
  3. IIS 服務狀態

---

## 問題 6：Compilation Error - 非法字符 '$'

### 症狀
download.aspx 編譯時拋出：
```
CS1056: Unexpected character '$'
Line 62: lblStatus.Text = $"Error: File not found - {filePath}";
```

### 根本原因
使用了 C# 6.0+ 的字符串插值語法 `$"..."` ，但 ASP.NET 4.8 的編譯器可能不支持或配置有誤。

### 解決方案
改用傳統的字符串連接或 String.Format：

**❌ 不要用**：
```csharp
lblStatus.Text = $"Error: File not found - {filePath}";
```

**✅ 要用**：
```csharp
// 方式 1 - 字符串連接
lblStatus.Text = "Error: File not found - " + filePath;

// 方式 2 - String.Format
lblStatus.Text = String.Format("Error: File not found - {0}", filePath);
```

### 經驗教訓
- 即使目標框架是 .NET 4.8，編譯器配置也可能不支持新語法
- 保守做法：在嵌入式 ASP.NET 環境中避免現代 C# 語法
- 字符串連接是最穩定的跨版本解決方案

---

## 問題 7：應用程式池設定混亂

### 症狀
不清楚 Site 應該指向哪個 Application Pool：
- 有「DefaultAppPool」（預設）
- 建立了「VulnerableAppPool」（自定義）
- 可能還有「VulnerableApp」（誤建立）

### 根本原因
- 命名規則不統一
- 在部署過程中多次嘗試不同配置
- IIS 沒有自動清理舊的、未使用的 Pool

### 解決方案
**明確命名規則**：
- Site 名稱：`VulnerableApp`
- Application Pool 名稱：`VulnerableAppPool`（統一加 "Pool" 後綴）

**清理步驟**：
1. 在 IIS Manager 中確認 Site 指向正確的 Pool
2. 刪除未使用的舊 Pool（右鍵「Remove」）
3. 重新啟動 IIS 確保配置生效

### 經驗教訓
- **命名統一很重要**：Site 名 + "Pool" = Application Pool 名
- 部署時保持配置簡潔，不要多次試驗舊配置
- 定期清理未使用的資源

---

## 問題 8：ViewState 密碼學錯誤持續出現

### 症狀
即使在 `.aspx` 頁面中加上 `EnableViewState="false"`，仍然出現密碼學錯誤。

### 根本原因
- web.config 中 `<machineKey>` 配置本身無效
- 即使頁面禁用 ViewState，ASP.NET 框架層仍然會驗證 machineKey 配置的正確性
- 任何涉及狀態管理、身份驗證的操作都會觸發密碼學驗證

### 解決方案
**徹底的解決方案**：
1. 移除 web.config 中的 `<machineKey>` 標籤
2. 讓 IIS 使用自動管理的 key
3. 在所有 .aspx 頁面中加上 `EnableViewState="false"`

```xml
<!-- web.config - 不要包含 <machineKey> 標籤 -->
<system.web>
    <pages enableViewStateMac="true"
           viewStateEncryptionMode="Always" />
</system.web>
```

### 經驗教訓
- **最小化配置原則**：不要硬編任何密碼學配置，除非完全必要
- 教育環境可以接受讓 IIS 自動管理 key，犧牲「可預測性」以換取「可用性」
- 密碼學配置錯誤往往難以除錯，最好的方法是避免硬編

---

## 綜合建議

### 部署前檢查清單
- [ ] 啟用副檔名顯示（View → File name extensions）
- [ ] 準備內嵌代碼的 `.aspx` 檔案（不依賴 CodeBehind）
- [ ] 不要硬編 machineKey，讓 IIS 自動管理
- [ ] 所有頁面加上 `EnableViewState="false"`（簡化測試）
- [ ] 準備簡化的 web.config（移除複雜配置）

### 部署後檢查清單
- [ ] 驗證檔案副檔名正確（無多餘 `.txt`）
- [ ] 檢查 IIS Site 的 Physical path 設定
- [ ] 訪問 download.aspx 看到「File Download Utility」
- [ ] 訪問 report.aspx 看到「Report Generator」
- [ ] 無密碼學錯誤、無編譯錯誤

### 快速故障排除
| 症狀 | 可能原因 | 首先嘗試 |
|---|---|---|
| 404 Not Found | 檔案不存在或路徑錯誤 | `iisreset` + 檢查 Physical path |
| Parser Error | CodeBehind 編譯失敗 | 改用內嵌代碼 `<script runat="server">` |
| CryptographicException | machineKey 無效 | 移除硬編 machineKey |
| Compilation Error CS1056 | 字符串插值語法不支持 | 改用 `"string" + variable` |
| 密碼學錯誤 | web.config 配置有誤 | 簡化 web.config，移除不必要配置 |

---

## 結論

本部署過程的核心教訓：

1. **簡化優於複雜**：內嵌代碼 > CodeBehind；自動管理 key > 硬編 key
2. **配置驗證很關鍵**：部署後逐項驗證，不要假設配置正確
3. **密碼學配置容易出錯**：避免手動配置 machineKey，讓框架自動管理
4. **IIS 快取問題**：任何配置改變後務必 `iisreset`
5. **保守的代碼風格**：在企業環境中，用最穩定的、最保守的語法

這些教訓對於生產環境中的 ASP.NET 應用部署同樣適用。

---

*最後更新：2026-07-26*
*用途：AIS3 安全訓練簡報*
