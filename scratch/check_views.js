const mysql = require('mysql2/promise');
async function run() {
  const c = await mysql.createConnection({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
  const [rows] = await c.query("SHOW FULL TABLES WHERE TABLE_TYPE LIKE 'VIEW'");
  console.log(rows);
  process.exit();
}
run();
