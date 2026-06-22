const mysql = require('mysql2/promise');
const fs = require('fs');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
    const [rows] = await pool.query(`
      SELECT 
        tx.id_transaksi, 
        tx.tanggal_transaksi,
        tx.status_transaksi, 
        tx.total_tagihan,
        f.judul AS judul_film, 
        tk.id_tiket,
        k.nomor_kursi
      FROM transaksi tx
      LEFT JOIN tiket tk ON tx.id_transaksi = tk.transaksi_id_transaksi
      LEFT JOIN jadwal_tayang jt ON tk.jadwal_tayang_id_jadwal = jt.id_jadwal
      LEFT JOIN jadwal_tayang_film jtf ON jt.id_jadwal = jtf.jadwal_tayang_id_jadwal
      LEFT JOIN film f ON jtf.film_id_film = f.id_film
      LEFT JOIN kursi k ON tk.kursi_id_kursi = k.id_kursi
      WHERE tx.pelanggan_id_pelanggan = 'PL0024'
      ORDER BY tx.id_transaksi DESC
    `);
    let md = "| ID Transaksi | Tanggal | Status | Total Tagihan | Film | Kursi |\n";
    md += "|---|---|---|---|---|---|\n";
    for(const r of rows) {
      md += `| ${r.id_transaksi} | ${new Date(r.tanggal_transaksi).toLocaleString('id-ID')} | ${r.status_transaksi} | Rp ${parseFloat(r.total_tagihan).toLocaleString('id-ID')} | ${r.judul_film || '*(Gagal Insert Tiket)*'} | ${r.nomor_kursi || '-'} |\n`;
    }
    fs.writeFileSync('C:/Users/NITRO V15/.gemini/antigravity/brain/044a9728-a26f-4345-b371-653c153d1153/history_transaksi.md', md);
    console.log("Done");
  } catch(e) {
    console.error(e);
  }
  process.exit();
}
run();
