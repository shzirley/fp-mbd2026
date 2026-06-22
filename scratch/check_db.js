const mysql = require('mysql2/promise');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307});
    const [rows] = await pool.query("SHOW DATABASES");
    console.log(rows);
  } catch(e) {
    console.error(e);
  }
  process.exit();
}
run();
