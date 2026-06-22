const mysql = require('mysql2/promise');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
    const [txs] = await pool.query("SELECT * FROM transaksi WHERE id_transaksi = 'TX1002'");
    console.log("Transaksi:", txs);
    const [tkts] = await pool.query("SELECT * FROM tiket WHERE transaksi_id_transaksi = 'TX1002'");
    console.log("Tiket:", tkts);
  } catch(e) {
    console.error(e);
  }
  process.exit();
}
run();
