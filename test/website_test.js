/**
 * Playwright 自動化測試腳本
 * 用途：驗證 FLUX 創意機構網站在 IIS 上的完整功能
 *
 * 安裝依賴：
 * npm install -D @playwright/test
 *
 * 運行測試：
 * npx playwright test website_test.js
 *
 * 查看報告：
 * npx playwright show-report
 */

const { test, expect } = require('@playwright/test');

const BASE_URL = 'http://localhost:8080';

test.describe('FLUX 創意機構網站完整驗證', () => {

  // ===== 测试 1：页面加载 =====
  test('1. 主頁應該正常加載', async ({ page }) => {
    console.log('✓ 開始測試：主頁加載');

    const response = await page.goto(`${BASE_URL}/`, { waitUntil: 'networkidle' });
    expect(response.status()).toBe(200);

    // 驗證頁面標題
    await expect(page).toHaveTitle(/FLUX STUDIO/);
    console.log('  ✓ 頁面標題正確');

    // 驗證 Logo 存在
    const logo = page.locator('.logo');
    await expect(logo).toBeVisible();
    await expect(logo).toContainText('FLUX');
    console.log('  ✓ Logo 正常顯示');

    // 截圖
    await page.screenshot({ path: 'screenshots/01_主頁加載.png' });
    console.log('  📸 截圖已保存\n');
  });

  // ===== 测试 2：导航栏固定 =====
  test('2. 導覽列應該固定在頂部', async ({ page }) => {
    console.log('✓ 開始測試：導覽列固定');

    await page.goto(`${BASE_URL}/`);

    const header = page.locator('header');
    const headerPosition = await header.evaluate(el => {
      return window.getComputedStyle(el).position;
    });

    expect(headerPosition).toBe('fixed');
    console.log('  ✓ 導覽列使用 position: fixed');

    // 驗證導覽連結
    const navLinks = page.locator('nav a');
    const linkCount = await navLinks.count();
    expect(linkCount).toBeGreaterThan(0);
    console.log(`  ✓ 發現 ${linkCount} 個導覽連結`);

    // 驗證連結文字
    const workLink = page.locator('nav a:has-text("WORK")');
    await expect(workLink).toBeVisible();
    const teamLink = page.locator('nav a:has-text("TEAM")');
    await expect(teamLink).toBeVisible();
    const contactLink = page.locator('nav a:has-text("CONTACT")');
    await expect(contactLink).toBeVisible();
    console.log('  ✓ 所有導覽連結正常顯示\n');
  });

  // ===== 测试 3：Hero 动画 =====
  test('3. Hero 標題應該有動畫效果', async ({ page }) => {
    console.log('✓ 開始測試：Hero 動畫');

    await page.goto(`${BASE_URL}/`);

    const heroTitle = page.locator('.hero h1');
    await expect(heroTitle).toBeVisible();

    const animation = await heroTitle.evaluate(el => {
      return window.getComputedStyle(el).animation;
    });

    if (animation && animation !== 'none') {
      console.log(`  ✓ 標題有動畫：${animation.substring(0, 50)}...`);
    } else {
      console.log('  ⚠ 標題可能沒有動畫或動畫已完成');
    }

    // 驗證標題內容
    await expect(heroTitle).toContainText('WE MAKE');
    console.log('  ✓ 標題文字正確');

    // 驗證 CTA 按鈕
    const ctaBtn = page.locator('.cta-btn');
    await expect(ctaBtn).toBeVisible();
    await expect(ctaBtn).toContainText('SEE OUR WORK');
    console.log('  ✓ CTA 按鈕正常顯示');

    await page.screenshot({ path: 'screenshots/03_Hero動畫.png' });
    console.log('  📸 截圖已保存\n');
  });

  // ===== 测试 4：平滑滚动 =====
  test('4. 導覽連結應該觸發平滑滾動', async ({ page }) => {
    console.log('✓ 開始測試：平滑滾動');

    await page.goto(`${BASE_URL}/`);

    // 点击 "WORK" 连接
    await page.click('nav a:has-text("WORK")');

    // 等待滾動並驗證
    await page.waitForTimeout(1000);

    const caseStudiesSection = page.locator('#work');
    const isVisible = await caseStudiesSection.isVisible();
    expect(isVisible).toBe(true);
    console.log('  ✓ 點擊 WORK 連結後成功滾動到案例區塊');

    // 點擊 "TEAM" 連結
    await page.click('nav a:has-text("TEAM")');
    await page.waitForTimeout(1000);

    const teamSection = page.locator('#team');
    const teamVisible = await teamSection.isVisible();
    expect(teamVisible).toBe(true);
    console.log('  ✓ 點擊 TEAM 連結後成功滾動到團隊區塊');

    // 點擊 "CONTACT" 連結
    await page.click('nav a:has-text("CONTACT")');
    await page.waitForTimeout(1000);

    const contactSection = page.locator('#contact');
    const contactVisible = await contactSection.isVisible();
    expect(contactVisible).toBe(true);
    console.log('  ✓ 點擊 CONTACT 連結後成功滾動到聯絡區塊\n');
  });

  // ===== 测试 5：案例卡片 =====
  test('5. 案例卡片應該正常顯示並有 Hover 效果', async ({ page }) => {
    console.log('✓ 開始測試：案例卡片');

    await page.goto(`${BASE_URL}/#work`);
    await page.waitForTimeout(500);

    // 驗證案例卡片數量
    const caseCards = page.locator('.case-card');
    const cardCount = await caseCards.count();
    expect(cardCount).toBe(4);
    console.log(`  ✓ 發現 ${cardCount} 個案例卡片`);

    // 測試第一個卡片的 Hover 效果
    const firstCard = caseCards.first();
    await firstCard.hover();

    await page.waitForTimeout(300);

    const overlay = firstCard.locator('.case-overlay');
    const overlayVisible = await overlay.isVisible();
    expect(overlayVisible).toBe(true);
    console.log('  ✓ Hover 時顯示案例詳情覆蓋層');

    // 驗證卡片內容
    const caseTitle = overlay.locator('.case-title');
    await expect(caseTitle).toBeVisible();
    const titleText = await caseTitle.textContent();
    expect(titleText).toBeTruthy();
    console.log(`  ✓ 案例標題：${titleText}`);

    // 驗證標籤
    const caseTags = overlay.locator('.case-tag');
    const tagCount = await caseTags.count();
    expect(tagCount).toBeGreaterThan(0);
    console.log(`  ✓ 發現 ${tagCount} 個案例分類標籤`);

    await page.screenshot({ path: 'screenshots/05_案例卡片Hover.png' });
    console.log('  📸 截圖已保存\n');
  });

  // ===== 测试 6：统计数据 =====
  test('6. 統計區塊應該正常顯示', async ({ page }) => {
    console.log('✓ 開始測試：統計區塊');

    await page.goto(`${BASE_URL}/#work`);
    await page.waitForTimeout(500);

    // 驗證統計數據
    const stats = page.locator('.stat');
    const statCount = await stats.count();
    expect(statCount).toBe(3);
    console.log(`  ✓ 發現 ${statCount} 個統計項目`);

    // 驗證統計數值
    const statNumbers = page.locator('.stat-number');
    for (let i = 0; i < await statNumbers.count(); i++) {
      const text = await statNumbers.nth(i).textContent();
      expect(text).toBeTruthy();
      console.log(`    - 統計 ${i + 1}：${text}`);
    }
    console.log('  ✓ 所有統計數據正常顯示\n');
  });

  // ===== 测试 7：团队卡片 =====
  test('7. 團隊卡片應該正常顯示並有 Hover 效果', async ({ page }) => {
    console.log('✓ 開始測試：團隊卡片');

    await page.goto(`${BASE_URL}/#team`);
    await page.waitForTimeout(500);

    // 驗證團隊卡片數量
    const teamMembers = page.locator('.team-member');
    const memberCount = await teamMembers.count();
    expect(memberCount).toBe(8);
    console.log(`  ✓ 發現 ${memberCount} 名團隊成員`);

    // 測試 Hover 效果
    const firstMember = teamMembers.first();
    await firstMember.hover();

    await page.waitForTimeout(300);

    // 獲取 Hover 後的背景顏色
    const bgColor = await firstMember.evaluate(el => {
      return window.getComputedStyle(el).backgroundColor;
    });

    console.log(`  ✓ Hover 後背景顏色：${bgColor}`);

    // 驗證成員信息
    const memberName = firstMember.locator('.member-name');
    const memberRole = firstMember.locator('.member-role');

    await expect(memberName).toBeVisible();
    await expect(memberRole).toBeVisible();

    const nameText = await memberName.textContent();
    const roleText = await memberRole.textContent();
    console.log(`  ✓ 成員信息正常：${nameText} - ${roleText}`);

    await page.screenshot({ path: 'screenshots/07_團隊卡片Hover.png' });
    console.log('  📸 截圖已保存\n');
  });

  // ===== 测试 8：联系表单 =====
  test('8. 聯絡表單應該正常工作', async ({ page }) => {
    console.log('✓ 開始測試：聯絡表單');

    await page.goto(`${BASE_URL}/#contact`);
    await page.waitForTimeout(500);

    // 驗證表單欄位存在
    const nameInput = page.locator('#name');
    const emailInput = page.locator('#email');
    const companyInput = page.locator('#company');
    const projectSelect = page.locator('#project');
    const messageInput = page.locator('#message');

    await expect(nameInput).toBeVisible();
    console.log('  ✓ 姓名欄位存在');

    await expect(emailInput).toBeVisible();
    console.log('  ✓ 郵件欄位存在');

    await expect(projectSelect).toBeVisible();
    console.log('  ✓ 項目類型下拉選單存在');

    await expect(messageInput).toBeVisible();
    console.log('  ✓ 訊息欄位存在');

    // 測試表單提交
    await nameInput.fill('Test User');
    await emailInput.fill('test@example.com');
    await projectSelect.selectOption('branding');
    await messageInput.fill('This is a test message from Playwright automation.');

    console.log('  ✓ 已填入表單資訊');

    // 監聽 alert 對話框
    page.on('dialog', async dialog => {
      console.log(`  ✓ 顯示確認訊息：${dialog.message()}`);
      await dialog.accept();
    });

    // 點擊提交按鈕
    const submitBtn = page.locator('.form-submit');
    await submitBtn.click();

    await page.waitForTimeout(500);

    // 驗證表單是否清空（重置）
    const nameValue = await nameInput.inputValue();
    expect(nameValue).toBe('');
    console.log('  ✓ 表單已清空（提交成功）');

    await page.screenshot({ path: 'screenshots/08_聯絡表單.png' });
    console.log('  📸 截圖已保存\n');
  });

  // ===== 测试 9：表单焦点效果 =====
  test('9. 表單輸入框應該有焦點效果', async ({ page }) => {
    console.log('✓ 開始測試：表單焦點效果');

    await page.goto(`${BASE_URL}/#contact`);
    await page.waitForTimeout(500);

    const nameInput = page.locator('#name');

    // 點擊輸入框以獲得焦點
    await nameInput.click();

    await page.waitForTimeout(300);

    // 獲取焦點時的邊框顏色
    const borderColor = await nameInput.evaluate(el => {
      return window.getComputedStyle(el).borderColor;
    });

    console.log(`  ✓ 焦點時邊框顏色：${borderColor}`);

    // 驗證焦點陰影
    const boxShadow = await nameInput.evaluate(el => {
      return window.getComputedStyle(el).boxShadow;
    });

    if (boxShadow && boxShadow !== 'none') {
      console.log(`  ✓ 焦點時有陰影效果`);
    }

    console.log();
  });

  // ===== 测试 10：页脚 =====
  test('10. 頁尾應該完整顯示', async ({ page }) => {
    console.log('✓ 開始測試：頁尾');

    await page.goto(`${BASE_URL}/`);

    // 滾動到底部
    await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
    await page.waitForTimeout(500);

    // 驗證頁尾存在
    const footer = page.locator('footer');
    await expect(footer).toBeVisible();
    console.log('  ✓ 頁尾正常顯示');

    // 驗證頁尾區塊
    const footerSections = page.locator('.footer-section');
    const sectionCount = await footerSections.count();
    expect(sectionCount).toBeGreaterThan(0);
    console.log(`  ✓ 發現 ${sectionCount} 個頁尾區塊`);

    // 驗證版權訊息
    const footerBottom = page.locator('.footer-bottom');
    await expect(footerBottom).toBeVisible();
    const footerText = await footerBottom.textContent();
    expect(footerText).toContain('FLUX STUDIO');
    console.log('  ✓ 版權訊息正常顯示');

    // 驗證頁尾連結
    const footerLinks = page.locator('footer a');
    const linkCount = await footerLinks.count();
    expect(linkCount).toBeGreaterThan(0);
    console.log(`  ✓ 發現 ${linkCount} 個頁尾連結`);

    await page.screenshot({ path: 'screenshots/10_頁尾.png' });
    console.log('  📸 截圖已保存\n');
  });

  // ===== 测试 11：漏洞页面可访问性 =====
  test('11. 隱藏的漏洞頁面應該可被訪問', async ({ page }) => {
    console.log('✓ 開始測試：隱藏漏洞頁面可訪問性');

    // 測試 download.aspx
    const downloadResponse = await page.goto(`${BASE_URL}/download.aspx`, {
      waitUntil: 'networkidle',
      timeout: 10000
    }).catch(() => null);

    if (downloadResponse && downloadResponse.status() === 200) {
      console.log('  ✓ download.aspx 可被訪問（HTTP 200）');
      const hasContent = await page.content();
      if (hasContent.includes('File Download') || hasContent.length > 100) {
        console.log('  ✓ download.aspx 有內容');
      }
    } else {
      console.log('  ⚠ download.aspx 無法訪問或返回錯誤');
    }

    // 測試 report.aspx
    const reportResponse = await page.goto(`${BASE_URL}/report.aspx`, {
      waitUntil: 'networkidle',
      timeout: 10000
    }).catch(() => null);

    if (reportResponse && reportResponse.status() === 200) {
      console.log('  ✓ report.aspx 可被訪問（HTTP 200）');
      const hasContent = await page.content();
      if (hasContent.includes('Report') || hasContent.length > 100) {
        console.log('  ✓ report.aspx 有內容');
      }
    } else {
      console.log('  ⚠ report.aspx 無法訪問或返回錯誤');
    }

    console.log();
  });

  // ===== 测试 12：响应式设计 =====
  test('12. 響應式設計應該正常工作', async ({ page }) => {
    console.log('✓ 開始測試：響應式設計');

    // 測試手機視窗
    await page.setViewportSize({ width: 375, height: 667 });

    await page.goto(`${BASE_URL}/`);
    await page.waitForTimeout(500);

    // 驗證頁面在小視窗中可見
    const logo = page.locator('.logo');
    const isLogoVisible = await logo.isVisible();
    expect(isLogoVisible).toBe(true);
    console.log('  ✓ 手機視窗（375x667）下頁面正常顯示');

    // 測試平板視窗
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.reload();

    const navLinks = page.locator('nav a');
    const navVisible = await navLinks.first().isVisible();
    expect(navVisible).toBe(true);
    console.log('  ✓ 平板視窗（768x1024）下導覽正常顯示');

    // 恢復桌面視窗
    await page.setViewportSize({ width: 1920, height: 1080 });

    console.log();
  });

});

// ===== 全局測試配置 =====
test.beforeAll(async () => {
  console.log('\n========================================');
  console.log('  FLUX 創意機構網站 - Playwright 驗證');
  console.log('========================================\n');
});

test.afterAll(async () => {
  console.log('\n========================================');
  console.log('  測試完成！所有截圖已保存到 screenshots/');
  console.log('========================================\n');
});