const mysql = require('mysql2/promise');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
    const [result] = await pool.query("UPDATE transaksi SET status_transaksi = 'Canceled' WHERE id_transaksi = 'TX1002'");
    console.log(result);
  } catch(e) {
    console.error(e);
  }
  process.exit();
}
run();
