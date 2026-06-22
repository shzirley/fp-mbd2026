const mysql = require('mysql2/promise');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
    const [rows] = await pool.query(`
      SELECT 
        tx.id_transaksi, 
        tx.status_transaksi, 
        f.judul AS judul_film, 
        tk.id_tiket,
        k.nomor_kursi
      FROM tiket tk
      JOIN jadwal_tayang jt ON tk.jadwal_tayang_id_jadwal = jt.id_jadwal
      JOIN jadwal_tayang_film jtf ON jt.id_jadwal = jtf.jadwal_tayang_id_jadwal
      JOIN film f ON jtf.film_id_film = f.id_film
      JOIN kursi k ON tk.kursi_id_kursi = k.id_kursi
      JOIN transaksi tx ON tk.transaksi_id_transaksi = tx.id_transaksi
      ORDER BY tx.id_transaksi DESC LIMIT 5
    `);
    console.log(rows);
  } catch(e) {
    console.error(e);
  }
  process.exit();
}
run();
