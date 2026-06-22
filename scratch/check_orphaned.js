const mysql = require('mysql2/promise');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
    const [rows] = await pool.query(`
      SELECT tx.id_transaksi, tx.status_transaksi
      FROM transaksi tx
      LEFT JOIN tiket tk ON tx.id_transaksi = tk.transaksi_id_transaksi
      WHERE tk.id_tiket IS NULL
      ORDER BY tx.id_transaksi DESC LIMIT 10
    `);
    console.log(rows);
  } catch(e) {
    console.error(e);
  }
  process.exit();
}
run();
