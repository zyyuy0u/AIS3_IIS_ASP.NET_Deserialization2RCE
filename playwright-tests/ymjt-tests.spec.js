const { test, expect } = require('@playwright/test');

const BASE = 'http://localhost';

// ===== INDEX.HTML TESTS =====

test.describe('Homepage (index.html)', () => {
  test('loads with HTTP 200 and correct title', async ({ page }) => {
    const response = await page.goto(BASE + '/');
    expect(response.status()).toBe(200);
    await expect(page).toHaveTitle(/YMJT/);
  });

  test('header displays YMJT Corp logo and navigation links', async ({ page }) => {
    await page.goto(BASE + '/');
    await expect(page.locator('header .logo-text')).toContainText('YMJT');
    const navLinks = page.locator('nav a');
    await expect(navLinks).toHaveCount(5);
    await expect(navLinks.nth(0)).toHaveText('Services');
    await expect(navLinks.nth(1)).toHaveText('Projects');
    await expect(navLinks.nth(2)).toHaveText('Team');
    await expect(navLinks.nth(3)).toHaveText('Contact');
    await expect(navLinks.nth(4)).toHaveText('Client Portal');
  });

  test('hero section displays correctly', async ({ page }) => {
    await page.goto(BASE + '/');
    const h1 = page.locator('.hero-content h1');
    await expect(h1).toBeVisible();
    await expect(h1).toContainText('Innovation');
    await expect(page.locator('.btn-primary')).toBeVisible();
    await expect(page.locator('.btn-outline')).toBeVisible();
  });

  test('services section has 6 cards', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.locator('#services').scrollIntoViewIfNeeded();
    const cards = page.locator('.service-card');
    await expect(cards).toHaveCount(6);
    await expect(page.locator('.services .section-heading')).toContainText('Enterprise Solutions');
  });

  test('projects section has 4 project cards', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.locator('#projects').scrollIntoViewIfNeeded();
    const cards = page.locator('.project-card');
    await expect(cards).toHaveCount(4);
  });

  test('stats section shows 4 metrics', async ({ page }) => {
    await page.goto(BASE + '/');
    const stats = page.locator('.stat-item');
    await expect(stats).toHaveCount(4);
    await expect(page.locator('.stat-number').first()).toContainText('150');
  });

  test('team section has 6 team members', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.locator('#team').scrollIntoViewIfNeeded();
    const members = page.locator('.team-card');
    await expect(members).toHaveCount(6);
  });

  test('contact form is functional - all fields work', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.locator('#contact').scrollIntoViewIfNeeded();

    await page.fill('#firstName', 'Test');
    await page.fill('#lastName', 'User');
    await page.fill('#emailField', 'test@test.com');
    await page.fill('#companyField', 'Test Corp');
    await page.selectOption('#serviceField', 'cloud');
    await page.fill('#messageField', 'Test message');

    expect(await page.inputValue('#firstName')).toBe('Test');
    expect(await page.inputValue('#lastName')).toBe('User');
    expect(await page.inputValue('#emailField')).toBe('test@test.com');
  });

  test('contact form submit shows confirmation', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.locator('#contact').scrollIntoViewIfNeeded();

    await page.fill('#firstName', 'Test');
    await page.fill('#lastName', 'User');
    await page.fill('#emailField', 'test@test.com');
    await page.selectOption('#serviceField', 'cloud');
    await page.fill('#messageField', 'Test message');

    page.on('dialog', async dialog => {
      expect(dialog.message()).toContain('Thank you');
      await dialog.accept();
    });

    await page.click('.form-submit');
  });

  test('navigation anchor links work (smooth scroll)', async ({ page }) => {
    await page.goto(BASE + '/');

    await page.click('nav a[href="#services"]');
    await page.waitForTimeout(500);
    const servicesBox = await page.locator('#services').boundingBox();
    expect(servicesBox).toBeTruthy();

    await page.click('nav a[href="#team"]');
    await page.waitForTimeout(500);
    const teamBox = await page.locator('#team').boundingBox();
    expect(teamBox).toBeTruthy();
  });

  test('Client Portal link goes to report.aspx', async ({ page }) => {
    await page.goto(BASE + '/');
    const portalLink = page.locator('a.nav-cta');
    await expect(portalLink).toHaveAttribute('href', 'report.aspx');
  });

  test('footer contains YMJT Corp branding and links', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.locator('footer').scrollIntoViewIfNeeded();
    await expect(page.locator('footer')).toContainText('Young Minds Join Together Corp');
    const footerLinks = page.locator('.footer-col a');
    const count = await footerLinks.count();
    expect(count).toBeGreaterThan(5);
  });

  test('footer Document Center links to download.aspx', async ({ page }) => {
    await page.goto(BASE + '/');
    const docLink = page.locator('footer a[href="download.aspx"]');
    await expect(docLink).toHaveText('Document Center');
  });

  test('no DEVCORE or FLUX branding remains', async ({ page }) => {
    await page.goto(BASE + '/');
    const content = await page.content();
    expect(content).not.toContain('DEVCORE');
    expect(content).not.toContain('FLUX');
    expect(content).not.toContain('flux');
  });

  test('no broken images on homepage', async ({ page }) => {
    const brokenImages = [];
    page.on('response', response => {
      if (response.request().resourceType() === 'image' && response.status() >= 400) {
        brokenImages.push(response.url());
      }
    });
    await page.goto(BASE + '/');
    await page.waitForTimeout(1000);
    expect(brokenImages).toEqual([]);
  });

  test('scroll reveal animations trigger', async ({ page }) => {
    await page.goto(BASE + '/');
    await page.waitForTimeout(300);

    await page.locator('#services').scrollIntoViewIfNeeded();
    await page.waitForTimeout(800);

    const firstCard = page.locator('.service-card.reveal').first();
    await expect(firstCard).toHaveClass(/visible/);
  });
});

// ===== DOWNLOAD.ASPX TESTS =====

test.describe('Document Center (download.aspx)', () => {
  test('loads with correct branding', async ({ page }) => {
    const response = await page.goto(BASE + '/download.aspx');
    expect(response.status()).toBe(200);
    await expect(page).toHaveTitle(/Document Center.*YMJT/);
    await expect(page.locator('.topbar-logo')).toContainText('YMJT');
  });

  test('page header shows Document Center', async ({ page }) => {
    await page.goto(BASE + '/download.aspx');
    await expect(page.locator('.page-header h1')).toHaveText('Document Center');
  });

  test('input field and download button exist and are clickable', async ({ page }) => {
    await page.goto(BASE + '/download.aspx');
    const input = page.locator('#txtFile');
    await expect(input).toBeVisible();
    await input.fill('test-path');
    expect(await input.inputValue()).toBe('test-path');

    const btn = page.locator('#btnDownload');
    await expect(btn).toBeVisible();
  });

  test('navigation links work', async ({ page }) => {
    await page.goto(BASE + '/download.aspx');
    const homeLink = page.locator('.topbar-nav a').first();
    await expect(homeLink).toHaveAttribute('href', '/');

    const reportsLink = page.locator('.topbar-nav a[href="report.aspx"]');
    await expect(reportsLink).toBeVisible();
  });

  test('system overview stats display', async ({ page }) => {
    await page.goto(BASE + '/download.aspx');
    await expect(page.locator('.info-item')).toHaveCount(3);
    await expect(page.locator('.info-item-number').first()).toContainText('1,247');
  });

  test('no vulnerability hints visible', async ({ page }) => {
    await page.goto(BASE + '/download.aspx');
    const content = await page.content();
    expect(content).not.toContain('VULNERABLE');
    expect(content).not.toContain('Path traversal');
    expect(content).not.toContain('VulnerableApp');
  });

  test('LFI still works via query string (functional test)', async ({ request }) => {
    const response = await request.get(BASE + '/download.aspx?file=C:\\inetpub\\wwwroot\\web.config');
    expect(response.status()).toBe(200);
    const body = await response.text();
    expect(body).toContain('machineKey');
  });

  test('returns 404 for nonexistent file', async ({ request }) => {
    const response = await request.get(BASE + '/download.aspx?file=C:\\nonexistent\\file.txt');
    expect(response.status()).toBe(404);
  });
});

// ===== REPORT.ASPX TESTS =====

test.describe('Report Generator (report.aspx)', () => {
  test('loads with correct branding', async ({ page }) => {
    const response = await page.goto(BASE + '/report.aspx');
    expect(response.status()).toBe(200);
    await expect(page).toHaveTitle(/Report Generator.*YMJT/);
    await expect(page.locator('.topbar-logo')).toContainText('YMJT');
  });

  test('page header shows Report Generator', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    await expect(page.locator('.page-header h1')).toHaveText('Report Generator');
  });

  test('quick stats section displays 3 metrics', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    await expect(page.locator('.quick-stat')).toHaveCount(3);
    await expect(page.locator('.quick-stat-value').first()).toContainText('24');
  });

  test('report form fields exist and accept input', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    const nameField = page.locator('#txtReportName');
    const dateField = page.locator('#txtReportDate');
    await expect(nameField).toBeVisible();
    await expect(dateField).toBeVisible();

    await nameField.fill('Q3 Report');
    await dateField.fill('2024-07-15');
    expect(await nameField.inputValue()).toBe('Q3 Report');
    expect(await dateField.inputValue()).toBe('2024-07-15');
  });

  test('generate button works and produces output', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');

    await page.locator('#txtReportName').fill('Test Report');
    await page.locator('#txtReportDate').fill('2024-01-01');
    await page.click('#btnGenerate');

    await page.waitForLoadState('networkidle');
    const result = page.locator('.result-box');
    await expect(result).toContainText('Report: Test Report');
    await expect(result).toContainText('Date: 2024-01-01');
  });

  test('error message when name is empty', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    await page.locator('#txtReportDate').fill('2024-01-01');
    await page.click('#btnGenerate');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('.error-msg')).toContainText('Report name is required');
  });

  test('ViewState hidden fields are present', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    const content = await page.content();
    expect(content).toContain('__VIEWSTATE');
    expect(content).toContain('__VIEWSTATEGENERATOR');
    expect(content).toContain('__VIEWSTATEENCRYPTED');
    expect(content).toContain('__EVENTVALIDATION');
  });

  test('no Technical Notes or vulnerability hints visible', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    const content = await page.content();
    expect(content).not.toContain('Technical Notes');
    expect(content).not.toContain('VULNERABILITY');
    expect(content).not.toContain('machineKey');
    expect(content).not.toContain('BinaryFormatter');
  });

  test('navigation between pages works', async ({ page }) => {
    await page.goto(BASE + '/report.aspx');
    await page.click('.topbar-nav a[href="download.aspx"]');
    await expect(page).toHaveTitle(/Document Center/);

    await page.click('.topbar-nav a[href="/"]');
    await expect(page).toHaveTitle(/YMJT/);
  });
});

// ===== CROSS-PAGE TESTS =====

test.describe('Cross-page consistency', () => {
  test('all pages use YMJT branding', async ({ page }) => {
    for (const path of ['/', '/download.aspx', '/report.aspx']) {
      await page.goto(BASE + path);
      const content = await page.content();
      expect(content).toContain('YMJT');
      expect(content).not.toContain('FLUX');
      expect(content).not.toContain('DEVCORE');
    }
  });

  test('no console errors on any page', async ({ page }) => {
    const errors = [];
    page.on('pageerror', err => errors.push(err.message));

    for (const path of ['/', '/download.aspx', '/report.aspx']) {
      await page.goto(BASE + path);
      await page.waitForTimeout(500);
    }

    expect(errors).toEqual([]);
  });

  test('no 404 resources on any page', async ({ page }) => {
    const failed = [];
    page.on('response', response => {
      if (response.status() === 404 && !response.url().includes('favicon')) {
        failed.push(response.url());
      }
    });

    for (const path of ['/', '/download.aspx', '/report.aspx']) {
      await page.goto(BASE + path);
      await page.waitForTimeout(500);
    }

    expect(failed).toEqual([]);
  });
});
