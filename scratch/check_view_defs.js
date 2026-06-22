const mysql = require('mysql2/promise');
async function run() {
  const c = await mysql.createConnection({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
  const views = ['vw_detail_jadwal', 'vw_film_genre', 'vw_transaksi_lengkap'];
  for(const v of views) {
    const [rows] = await c.query(`SHOW CREATE VIEW ${v}`);
    console.log(`--- ${v} ---`);
    console.log(rows[0]['Create View']);
  }
  process.exit();
}
run();
