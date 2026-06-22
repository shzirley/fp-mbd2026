const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  // Set localStorage before loading
  await page.evaluateOnNewDocument(() => {
    localStorage.setItem('user', JSON.stringify({id: 'PL0001', name: 'Test User'}));
  });

  await page.goto('http://localhost:5000/userMyTickets.html', { waitUntil: 'networkidle0' });
  await page.screenshot({ path: 'scratch/tickets_screenshot.png' });
  await browser.close();
})();
