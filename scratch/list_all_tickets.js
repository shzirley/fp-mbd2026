const mysql = require('mysql2/promise');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
    const [rows] = await pool.query(`
      SELECT 
        tx.id_transaksi, 
        tx.status_transaksi, 
        f.judul AS judul_film, 
        tx.pelanggan_id_pelanggan,
        tx.tanggal_transaksi
      FROM tiket tk
      JOIN jadwal_tayang jt ON tk.jadwal_tayang_id_jadwal = jt.id_jadwal
      JOIN jadwal_tayang_film jtf ON jt.id_jadwal = jtf.jadwal_tayang_id_jadwal
      JOIN film f ON jtf.film_id_film = f.id_film
      JOIN transaksi tx ON tk.transaksi_id_transaksi = tx.id_transaksi
      ORDER BY tx.id_transaksi DESC LIMIT 20
    `);
    console.log(rows);
  } catch(e) {
    console.error(e);
  }
  process.exit();
}
run();
