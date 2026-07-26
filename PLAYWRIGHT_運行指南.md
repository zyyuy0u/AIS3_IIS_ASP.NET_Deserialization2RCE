# Playwright 網站自動化驗證 - 完整指南

## 📋 概述

這份指南幫助您使用 **Playwright** 自動化測試 FLUX 創意機構網站在 IIS 上的所有功能。

測試涵蓋：
- ✅ 頁面加載
- ✅ 導覽列固定效果
- ✅ Hero 動畫
- ✅ 平滑滾動
- ✅ 案例卡片 Hover 效果
- ✅ 統計區塊
- ✅ 團隊卡片 Hover 效果
- ✅ 聯絡表單提交
- ✅ 表單焦點效果
- ✅ 頁尾完整性
- ✅ 隱藏漏洞頁面可訪問性
- ✅ 響應式設計

---

## 🚀 快速開始（3 步驟）

### 步驟 1：安裝 Node.js 和依賴

#### Windows：
1. 下載 Node.js：https://nodejs.org/
2. 安裝 LTS 版本（推薦 18.x 或 20.x）
3. 驗證安裝：
   ```powershell
   node --version
   npm --version
   ```

### 步驟 2：設置測試環境

1. **建立測試資料夾**：
   ```powershell
   mkdir flux-website-test
   cd flux-website-test
   ```

2. **複製測試檔案**：
   ```
   flux-website-test/
   ├── package.json          ← 複製這個
   ├── website_test.js       ← 複製這個
   └── screenshots/          ← 自動建立
   ```

3. **安裝依賴**：
   ```powershell
   npm install
   ```

   會看到：
   ```
   added 65 packages in 8s
   ```

### 步驟 3：部署網站到 IIS

確保網站已部署（參考前面的部署指南）：

```
http://localhost:8080/  ← 應該能訪問
```

---

## ▶️ 運行測試

### 方式 1：無頭模式（推薦）- 快速自動運行

```powershell
npm test
```

輸出會像這樣：
```
✓ 開始測試：主頁加載
  ✓ 頁面標題正確
  ✓ Logo 正常顯示
  📸 截圖已保存

✓ 開始測試：導覽列固定
  ✓ 導覽列使用 position: fixed
  ✓ 發現 3 個導覽連結
  ...
```

**耗時**：約 30-45 秒

### 方式 2：有頭模式 - 看著瀏覽器運行

```powershell
npm run test:headed
```

會打開 **Chromium 瀏覽器視窗**，讓您看到每一步的動作。

**耗時**：約 60 秒（因為看得到動畫）

### 方式 3：除錯模式 - 逐步運行

```powershell
npm run test:debug
```

會打開 Playwright Inspector，讓您逐步執行、檢查狀態。

---

## 📊 查看測試報告

### 方式 1：自動打開報告

```powershell
npm run show-report
```

會在預設瀏覽器打開詳細的 HTML 報告。

### 方式 2：手動查看結果

測試完成後，檢查 `screenshots/` 資料夾：

```
screenshots/
├── 01_主頁加載.png
├── 03_Hero動畫.png
├── 05_案例卡片Hover.png
├── 07_團隊卡片Hover.png
├── 08_聯絡表單.png
└── 10_頁尾.png
```

---

## ✅ 測試詳細說明

### 測試 1：主頁加載
```
✓ 驗證 HTTP 200 響應
✓ 驗證頁面標題包含 "FLUX STUDIO"
✓ 驗證 Logo 正常顯示
```

### 測試 2：導覽列固定
```
✓ 驗證 header 使用 position: fixed
✓ 驗證所有導覽連結存在（WORK、TEAM、CONTACT）
```

### 測試 3：Hero 動畫
```
✓ 驗證標題包含 "WE MAKE"
✓ 驗證 CTA 按鈕正常顯示
✓ 檢查 CSS 動畫
```

### 測試 4：平滑滾動
```
✓ 點擊 "WORK" 連結 → 滾動到 #work 區塊
✓ 點擊 "TEAM" 連結 → 滾動到 #team 區塊
✓ 點擊 "CONTACT" 連結 → 滾動到 #contact 區塊
```

### 測試 5：案例卡片
```
✓ 驗證 4 個案例卡片存在
✓ Hover 時顯示詳情覆蓋層
✓ 驗證卡片標題、描述、標籤
```

### 測試 6-10：其他功能
```
✓ 統計區塊 - 3 個統計項
✓ 團隊卡片 - 8 名成員 + Hover 效果
✓ 聯絡表單 - 填入 + 提交 + 確認訊息
✓ 表單焦點 - 邊框和陰影效果
✓ 頁尾 - 區塊和連結正常
```

### 測試 11：隱藏漏洞頁面
```
✓ download.aspx 可訪問
✓ report.aspx 可訪問
```

### 測試 12：響應式設計
```
✓ 手機視窗（375x667）正常
✓ 平板視窗（768x1024）正常
✓ 桌面視窗（1920x1080）正常
```

---

## 🐛 常見問題與解決方案

### 問題 1：找不到 `npm`

**症狀**：
```
npm : 無法辨識 'npm' 詞彙...
```

**解決**：
1. 檢查 Node.js 是否安裝：`node --version`
2. 重啟 PowerShell 或 Terminal
3. 將 Node.js 加入 PATH

### 問題 2：連線被拒

**症狀**：
```
Error: net::ERR_CONNECTION_REFUSED
```

**解決**：
1. 確認 IIS 正在運行：訪問 `http://localhost:8080/` 在瀏覽器
2. 檢查防火牆是否阻止 localhost
3. 在 `website_test.js` 中改變 URL：
   ```javascript
   const BASE_URL = 'http://192.168.x.x:8080';  // 改成遠端 IP
   ```

### 問題 3：測試超時

**症狀**：
```
Timeout 30000ms exceeded while waiting for...
```

**解決**：
1. 增加超時時間（在 `website_test.js` 中）
2. 關閉其他應用確保系統流暢
3. 檢查網路連線

### 問題 4：`package.json` 安裝失敗

**症狀**：
```
npm ERR! ERESOLVE unable to resolve dependency tree
```

**解決**：
```powershell
npm install --legacy-peer-deps
```

---

## 📈 測試結果範例

### 成功的測試結果

```
========================================
  FLUX 創意機構網站 - Playwright 驗證
========================================

✓ 開始測試：主頁加載
  ✓ 頁面標題正確
  ✓ Logo 正常顯示
  📸 截圖已保存

✓ 開始測試：導覽列固定
  ✓ 導覽列使用 position: fixed
  ✓ 發現 3 個導覽連結
  ✓ 所有導覽連結正常顯示

✓ 開始測試：Hero 動畫
  ✓ 標題有動畫：slideIn 0.8s cubic-bezier...
  ✓ 標題文字正確
  ✓ CTA 按鈕正常顯示
  📸 截圖已保存

✓ 開始測試：平滑滾動
  ✓ 點擊 WORK 連結後成功滾動到案例區塊
  ✓ 點擊 TEAM 連結後成功滾動到團隊區塊
  ✓ 點擊 CONTACT 連結後成功滾動到聯絡區塊

✓ 開始測試：案例卡片
  ✓ 發現 4 個案例卡片
  ✓ Hover 時顯示案例詳情覆蓋層
  ✓ 案例標題：NEXUS
  ✓ 發現 2 個案例分類標籤
  📸 截圖已保存

✓ 開始測試：統計區塊
  ✓ 發現 3 個統計項目
    - 統計 1：50+
    - 統計 2：15
    - 統計 3：8
  ✓ 所有統計數據正常顯示

✓ 開始測試：團隊卡片
  ✓ 發現 8 名團隊成員
  ✓ Hover 後背景顏色：rgb(51, 51, 51)
  ✓ 成員信息正常：Alex Kim - Creative Director
  📸 截圖已保存

✓ 開始測試：聯絡表單
  ✓ 姓名欄位存在
  ✓ 郵件欄位存在
  ✓ 項目類型下拉選單存在
  ✓ 訊息欄位存在
  ✓ 已填入表單資訊
  ✓ 顯示確認訊息：MESSAGE SENT. WE WILL GET BACK TO YOU SOON.
  ✓ 表單已清空（提交成功）
  📸 截圖已保存

✓ 開始測試：表單焦點效果
  ✓ 焦點時邊框顏色：rgb(0, 255, 0)
  ✓ 焦點時有陰影效果

✓ 開始測試：頁尾
  ✓ 頁尾正常顯示
  ✓ 發現 3 個頁尾區塊
  ✓ 版權訊息正常顯示
  ✓ 發現 6 個頁尾連結
  📸 截圖已保存

✓ 開始測試：隱藏漏洞頁面可訪問性
  ✓ download.aspx 可被訪問（HTTP 200）
  ✓ download.aspx 有內容
  ✓ report.aspx 可被訪問（HTTP 200）
  ✓ report.aspx 有內容

✓ 開始測試：響應式設計
  ✓ 手機視窗（375x667）下頁面正常顯示
  ✓ 平板視窗（768x1024）下導覽正常顯示

========================================
  測試完成！所有截圖已保存到 screenshots/
========================================

12 passed (42.3s)
```

---

## 📸 截圖位置

所有驗證截圖都自動保存到：

```
flux-website-test/
└── screenshots/
    ├── 01_主頁加載.png
    ├── 03_Hero動畫.png
    ├── 05_案例卡片Hover.png
    ├── 07_團隊卡片Hover.png
    ├── 08_聯絡表單.png
    └── 10_頁尾.png
```

這些截圖可用於：
- ✅ 教學文檔
- ✅ 演示投影片
- ✅ 驗證報告
- ✅ 部署檢查清單

---

## 🔧 進階配置

### 改變測試 URL（測試遠端伺服器）

編輯 `website_test.js`：

```javascript
// 第 10 行
const BASE_URL = 'http://192.168.1.100:8080';  // 改成您的遠端 IP
```

### 增加超時時間

編輯 `playwright.config.js`（若有）或在測試中：

```javascript
test.setTimeout(60000);  // 改成 60 秒
```

### 只運行特定測試

```powershell
npx playwright test website_test.js -g "案例卡片"  # 只測試案例卡片
```

---

## 📞 支援

若測試失敗，請檢查：

1. ✅ 網站在 `http://localhost:8080/` 可訪問
2. ✅ 所有頁面元素都已加載
3. ✅ Node.js 和 npm 正確安裝
4. ✅ 防火牆允許 localhost 連線
5. ✅ IIS 應用池正在運行

---

## 📝 測試記錄

每次運行時記錄：

| 日期 | 時間 | 測試狀態 | 耗時 | 備註 |
|---|---|---|---|---|
| 2024-07-26 | 10:30 | ✅ Pass | 42s | 所有測試通過 |
| | | | | |

---

**祝您測試順利！** 🎉
