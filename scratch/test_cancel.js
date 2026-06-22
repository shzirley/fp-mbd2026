const mysql = require('mysql2/promise');
async function run() {
  const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
  await pool.query("UPDATE transaksi SET status_transaksi = 'Canceled' WHERE id_transaksi = 'TX0001'");
  const [txs] = await pool.query("SELECT t.id_tiket, tx.status_transaksi, pb.status_pembayaran FROM tiket t JOIN transaksi tx ON t.transaksi_id_transaksi = tx.id_transaksi JOIN pembayaran pb ON tx.pembayaran_id_pembayaran = pb.id_pembayaran WHERE tx.id_transaksi = 'TX0001'");
  console.log(txs);
  process.exit();
}
run();
