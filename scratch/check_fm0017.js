const mysql = require('mysql2/promise');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
    const [rows] = await pool.query(`
      SELECT tk.id_tiket, jt.waktu_tayang, tk.transaksi_id_transaksi
      FROM tiket tk
      JOIN jadwal_tayang jt ON tk.jadwal_tayang_id_jadwal = jt.id_jadwal
      JOIN jadwal_tayang_film jtf ON jt.id_jadwal = jtf.jadwal_tayang_id_jadwal
      WHERE jtf.film_id_film = 'FM0017'
    `);
    console.log(rows);
  } catch(e) {
    console.error(e);
  }
  process.exit();
}
run();
