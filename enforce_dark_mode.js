const fs = require('fs');
const path = require('path');

const dir = 'FrontEnd';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.html'));

const regex = /<html[^>]*>/i;
const replacement = '<html class="dark" lang="en">';

for (const file of files) {
  const filePath = path.join(dir, file);
  let content = fs.readFileSync(filePath, 'utf8');
  let newContent = content.replace(regex, replacement);
  
  if (content !== newContent) {
    fs.writeFileSync(filePath, newContent);
    console.log(`Updated ${file}`);
  }
}
