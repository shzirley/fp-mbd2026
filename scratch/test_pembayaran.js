const mysql = require('mysql2/promise');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
    const [rows] = await pool.query("SELECT id_pembayaran FROM pembayaran ORDER BY id_pembayaran DESC LIMIT 5");
    console.log(rows);
  } catch(e) {
    console.error(e);
  }
  process.exit();
}
run();
