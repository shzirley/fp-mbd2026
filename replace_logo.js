const fs = require('fs');
const path = require('path');

const dir = 'FrontEnd';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.html'));

const regex = /(>)\s*(Cinetrack|CINETRACK)\s*(<\/(a|span|h1|div|h2|p)>)/g;
const replacement = '$1<img src="/assets/logo.png" alt="Cinetrack Logo" class="h-8 object-contain inline-block" />$3';

for (const file of files) {
  const filePath = path.join(dir, file);
  let content = fs.readFileSync(filePath, 'utf8');
  let newContent = content.replace(regex, replacement);
  
  if (content !== newContent) {
    fs.writeFileSync(filePath, newContent);
    console.log(`Updated ${file}`);
  }
}
