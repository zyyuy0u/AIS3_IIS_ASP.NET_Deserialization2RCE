const { test, expect } = require('@playwright/test');

const BASE = 'http://localhost';

// ===== INDEX.HTML TESTS =====

test.describe('首頁 (index.html)', () => {
  test('載入正常，標題包含公司名稱', async ({ page }) => {
    const response = await page.goto(BASE + '/');
    expect(response.status()).toBe(200);
    await expect(page).toHaveTitle(/Young Minds Join Together/);
  });

  test('導覽列顯示公司全名與連結', async ({ page }) => {
    await page.goto(BASE + '/');
    await expect(page.locator('header')).toContainText('Young Minds Join Together');
    const navLinks = page.locator('header nav a');
    const count = await navLinks.count();
    expect(count).toBeGreaterThanOrEqual(4);
  });

  test('Hero 區域正確顯示', async ({ page }) => {
    await page.goto(BASE + '/');
    await expect(page.locator('h1')).toContainText('集結年輕思維');
    await expect(page.locator('.btn-primary').first()).toBeVisible();
    await expect(page.locator('.btn-ghost').first()).toBeVisible();
  });

  test('數據統計區顯示 4 項指標', async ({ page }) => {
    await page.goto(BASE + '/');
    await expect(page.locator('.stat-num')).toHaveCount(4);
    await expect(page.locator('.stat-num').first()).toContainText('150+');
  });

  test('服務區塊有 6 個項目', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.locator('#services').scrollIntoViewIfNeeded();
    const cells = page.locator('#services .bento-cell, #services .bento-accent');
    await expect(cells).toHaveCount(6);
  });

  test('專案區塊有 4 個項目', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.locator('#projects').scrollIntoViewIfNeeded();
    const cards = page.locator('#projects .project-card');
    await expect(cards).toHaveCount(4);
  });

  test('團隊區塊有 4 位成員', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.locator('#team').scrollIntoViewIfNeeded();
    const members = page.locator('#team .team-member');
    await expect(members).toHaveCount(4);
  });

  test('聯絡表單可輸入並送出', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.locator('#contact').scrollIntoViewIfNeeded();

    const nameInput = page.locator('#contact input[type="text"]').first();
    const emailInput = page.locator('#contact input[type="email"]');
    await nameInput.fill('測試');
    await emailInput.fill('test@test.com');

    expect(await nameInput.inputValue()).toBe('測試');
    expect(await emailInput.inputValue()).toBe('test@test.com');

    await page.click('#contact button[type="submit"]');
    await expect(page.locator('.submit-btn')).toContainText('已送出');
  });

  test('客戶入口連結指向 report.aspx', async ({ page }) => {
    await page.goto(BASE + '/');
    const portalLink = page.locator('header a[href="report.aspx"]');
    await expect(portalLink).toBeVisible();
  });

  test('頁尾包含公司全名與 GitHub 連結', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.locator('footer').scrollIntoViewIfNeeded();
    await expect(page.locator('footer')).toContainText('Young Minds Join Together Corp');
    const githubLink = page.locator('footer a[href*="github"]');
    await expect(githubLink).toBeVisible();
  });

  test('頁尾文件中心連結指向 download.aspx', async ({ page }) => {
    await page.goto(BASE + '/');
    const docLink = page.locator('footer a[href="download.aspx"]');
    await expect(docLink).toBeVisible();
  });

  test('無 DEVCORE 或 FLUX 殘留', async ({ page }) => {
    await page.goto(BASE + '/');
    const content = await page.content();
    expect(content).not.toContain('DEVCORE');
    expect(content).not.toContain('FLUX');
  });

  test('無 console 錯誤', async ({ page }) => {
    const errors = [];
    page.on('pageerror', err => errors.push(err.message));
    await page.goto(BASE + '/');
    await page.waitForTimeout(2000);
    expect(errors).toEqual([]);
  });
});

// ===== DOWNLOAD.ASPX TESTS =====

test.describe('文件中心 (download.aspx)', () => {
  test('載入正常，顯示公司全名', async ({ page }) => {
    const response = await page.goto(BASE + '/download.aspx');
    expect(response.status()).toBe(200);
    await expect(page).toHaveTitle(/Young Minds Join Together/);
    await expect(page.locator('header')).toContainText('Young Minds Join Together');
  });

  test('頁面標題為文件中心', async ({ page }) => {
    await page.goto(BASE + '/download.aspx');
    await expect(page.locator('h1')).toHaveText('文件中心');
  });

  test('搜尋欄位與按鈕可操作', async ({ page }) => {
    await page.goto(BASE + '/download.aspx');
    const input = page.locator('#txtSearch');
    await expect(input).toBeVisible();
    await input.fill('測試關鍵字');
    expect(await input.inputValue()).toBe('測試關鍵字');

    const btn = page.locator('#btnSearch');
    await expect(btn).toBeVisible();
  });

  test('統計數字顯示 3 項', async ({ page }) => {
    await page.goto(BASE + '/download.aspx');
    await expect(page.locator('.stat-num')).toHaveCount(3);
  });

  test('近期文件列表有 4 筆', async ({ page }) => {
    await page.goto(BASE + '/download.aspx');
    await expect(page.locator('.doc-row')).toHaveCount(4);
  });

  test('下載連結為直接檔案路徑（非 LFI）', async ({ page }) => {
    await page.goto(BASE + '/download.aspx');
    const content = await page.content();
    expect(content).not.toContain('?file=');
    expect(content).toContain('documents/YMJT_Company_Profile_2024.pdf');
  });

  test('無漏洞提示文字', async ({ page }) => {
    await page.goto(BASE + '/download.aspx');
    const content = await page.content();
    expect(content).not.toContain('VULNERABLE');
    expect(content).not.toContain('Path traversal');
    expect(content).not.toContain('VulnerableApp');
  });

  test('導覽連結可切換頁面', async ({ page }) => {
    await page.goto(BASE + '/download.aspx');
    const homeLink = page.locator('header nav a[href="/"]');
    await expect(homeLink).toBeVisible();
    const reportLink = page.locator('header nav a[href="report.aspx"]');
    await expect(reportLink).toBeVisible();
  });
});

// ===== REPORT.ASPX TESTS =====

test.describe('報表系統 (report.aspx)', () => {
  test('載入正常，顯示公司全名', async ({ page }) => {
    const response = await page.goto(BASE + '/report.aspx');
    expect(response.status()).toBe(200);
    await expect(page).toHaveTitle(/Young Minds Join Together/);
    await expect(page.locator('header')).toContainText('Young Minds Join Together');
  });

  test('頁面標題為報表產生器', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    await expect(page.locator('h1')).toHaveText('報表產生器');
  });

  test('快速統計顯示 3 項指標', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    await expect(page.locator('.stat-num')).toHaveCount(3);
    await expect(page.locator('.stat-num').first()).toContainText('24');
  });

  test('報表表單欄位可輸入', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    const nameField = page.locator('#txtReportName');
    const dateField = page.locator('#txtReportDate');
    await expect(nameField).toBeVisible();
    await expect(dateField).toBeVisible();

    await nameField.fill('Q3 績效報告');
    await dateField.fill('2024-07-15');
    expect(await nameField.inputValue()).toBe('Q3 績效報告');
    expect(await dateField.inputValue()).toBe('2024-07-15');
  });

  test('產生報表按鈕可正常運作', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    await page.locator('#txtReportName').fill('測試報表');
    await page.locator('#txtReportDate').fill('2024-01-01');
    await page.click('#btnGenerate');
    await page.waitForLoadState('networkidle');
    const result = page.locator('.result-box');
    await expect(result).toContainText('測試報表');
    await expect(result).toContainText('2024-01-01');
  });

  test('缺少名稱時顯示錯誤', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    await page.locator('#txtReportDate').fill('2024-01-01');
    await page.click('#btnGenerate');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('.text-red-400')).toContainText('報表名稱');
  });

  test('ViewState 隱藏欄位存在', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    const content = await page.content();
    expect(content).toContain('__VIEWSTATE');
    expect(content).toContain('__VIEWSTATEGENERATOR');
    expect(content).toContain('__VIEWSTATEENCRYPTED');
    expect(content).toContain('__EVENTVALIDATION');
  });

  test('無漏洞提示或技術細節', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    const content = await page.content();
    expect(content).not.toContain('Technical Notes');
    expect(content).not.toContain('VULNERABILITY');
    expect(content).not.toContain('machineKey');
    expect(content).not.toContain('BinaryFormatter');
  });

  test('導覽可切換頁面', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    await page.click('header nav a[href="download.aspx"]');
    await expect(page).toHaveTitle(/Young Minds Join Together/);
    await expect(page.locator('h1')).toHaveText('文件中心');
  });
});

// ===== CROSS-PAGE TESTS =====

test.describe('跨頁面一致性', () => {
  test('所有頁面使用公司全名', async ({ page }) => {
    for (const path of ['/', '/download.aspx', '/report.aspx']) {
      await page.goto(BASE + path);
      const content = await page.content();
      expect(content).toContain('Young Minds Join Together');
      expect(content).not.toContain('FLUX');
      expect(content).not.toContain('DEVCORE');
    }
  });

  test('所有頁面無 console 錯誤', async ({ page }) => {
    const errors = [];
    page.on('pageerror', err => errors.push(err.message));

    for (const path of ['/', '/download.aspx', '/report.aspx']) {
      await page.goto(BASE + path);
      await page.waitForTimeout(1500);
    }

    expect(errors).toEqual([]);
  });

  test('所有頁面無 404 資源', async ({ page }) => {
    const failed = [];
    page.on('response', response => {
      if (response.status() === 404 && !response.url().includes('favicon')) {
        failed.push(response.url());
      }
    });

    for (const path of ['/', '/download.aspx', '/report.aspx']) {
      await page.goto(BASE + path);
      await page.waitForTimeout(1500);
    }

    expect(failed).toEqual([]);
  });
});
