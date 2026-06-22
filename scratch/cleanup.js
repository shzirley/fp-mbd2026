const mysql = require('mysql2/promise');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
    await pool.query("DELETE FROM tiket WHERE id_tiket = 'TK9999'");
    await pool.query("DELETE FROM transaksi WHERE id_transaksi = 'TX9999'");
    await pool.query("DELETE FROM pembayaran WHERE id_pembayaran = 'PB9999'");
    await pool.query("DELETE FROM pelanggan WHERE id_pelanggan = 'PL9999'");
    console.log('Cleaned up dummy data');
  } catch(e) {
    console.error(e);
  }
  process.exit();
}
run();
