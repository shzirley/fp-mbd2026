const mysql = require('mysql2/promise');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
    const [rows] = await pool.query(`
      SELECT 
        tx.id_transaksi, 
        tx.status_transaksi, 
        tx.tanggal_transaksi,
        f.judul AS judul_film, 
        tk.id_tiket,
        k.nomor_kursi,
        tx.pelanggan_id_pelanggan
      FROM transaksi tx
      LEFT JOIN tiket tk ON tx.id_transaksi = tk.transaksi_id_transaksi
      LEFT JOIN jadwal_tayang jt ON tk.jadwal_tayang_id_jadwal = jt.id_jadwal
      LEFT JOIN jadwal_tayang_film jtf ON jt.id_jadwal = jtf.jadwal_tayang_id_jadwal
      LEFT JOIN film f ON jtf.film_id_film = f.id_film
      LEFT JOIN kursi k ON tk.kursi_id_kursi = k.id_kursi
      ORDER BY tx.id_transaksi DESC LIMIT 5
    `);
    console.log(rows);
  } catch(e) {
    console.error(e);
  }
  process.exit();
}
run();
