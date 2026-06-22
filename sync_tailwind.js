const fs = require('fs');
const path = require('path');

const dir = 'FrontEnd';
const files = fs.readdirSync(dir).filter(f => f.startsWith('admin') && f.endsWith('.html') && f !== 'adminDashboard.html');

const dashboardPath = path.join(dir, 'adminDashboard.html');
const dashboardContent = fs.readFileSync(dashboardPath, 'utf8');

// Extract tailwind config
const tailwindRegex = /<script id="tailwind-config">[\s\S]*?<\/script>/;
const dashboardTailwind = dashboardContent.match(tailwindRegex)[0];

for (const file of files) {
    const filePath = path.join(dir, file);
    let content = fs.readFileSync(filePath, 'utf8');

    // Replace tailwind config
    content = content.replace(tailwindRegex, dashboardTailwind);

    fs.writeFileSync(filePath, content);
    console.log(`Synced tailwind config for ${file}`);
}
