const mysql = require('mysql2/promise');
async function run() {
  const connection = await mysql.createConnection({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
  try {
    const [rows] = await connection.query("SELECT DISTINCT INDEX_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'MBD_FP' AND INDEX_NAME LIKE 'idx_%'");
    console.log("Indexes found:");
    for(const r of rows) console.log(r.INDEX_NAME);
  } catch (e) {
    console.error(e);
  }
  process.exit();
}
run();
