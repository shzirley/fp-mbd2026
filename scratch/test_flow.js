const mysql = require('mysql2/promise');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
    
    // Clear previous
    await pool.query("DELETE FROM tiket WHERE id_tiket = 'TK9999'");
    await pool.query("DELETE FROM transaksi WHERE id_transaksi = 'TX9999'");
    await pool.query("DELETE FROM pembayaran WHERE id_pembayaran = 'PB9999'");
    await pool.query("DELETE FROM pelanggan WHERE id_pelanggan = 'PL9999'");

    // Insert properly
    await pool.query("INSERT INTO pelanggan (id_pelanggan, nama_pelanggan, email_pelanggan, password) VALUES ('PL9999', 'Test User', 'test@test.com', 'test')");
    await pool.query("INSERT INTO pembayaran (id_pembayaran, status_pembayaran, metode_pembayaran) VALUES ('PB9999', 'Lunas', 'Qris')");
    await pool.query("INSERT INTO transaksi (id_transaksi, tanggal_transaksi, total_tagihan, pelanggan_id_pelanggan, pembayaran_id_pembayaran, pegawai_id_pegawai, status_transaksi) VALUES ('TX9999', NOW(), 50000, 'PL9999', 'PB9999', 'PG0001', 'Active')");
    await pool.query("INSERT INTO tiket (id_tiket, harga_beli, jadwal_tayang_id_jadwal, transaksi_id_transaksi, kursi_id_kursi) VALUES ('TK9999', 50000, 'JD0001', 'TX9999', 'KR0002')");

    await pool.query("UPDATE transaksi SET status_transaksi = 'Canceled' WHERE id_transaksi = 'TX9999'");

    const [tickets] = await pool.query(`
        SELECT 
          tk.id_tiket, 
          tk.harga_beli, 
          jt.waktu_tayang, 
          f.judul AS judul_film, 
          f.poster_url,
          st.nomor_studio, 
          st.kelas_studio, 
          c.nama_cabang,
          k.nomor_kursi, 
          tx.id_transaksi, 
          tx.tanggal_transaksi,
          tx.status_transaksi
        FROM tiket tk
        JOIN jadwal_tayang jt ON tk.jadwal_tayang_id_jadwal = jt.id_jadwal
        JOIN jadwal_tayang_film jtf ON jt.id_jadwal = jtf.jadwal_tayang_id_jadwal
        JOIN film f ON jtf.film_id_film = f.id_film
        JOIN studio st ON jt.studio_id_studio = st.id_studio
        JOIN cabang c ON st.cabang_id_cabang = c.id_cabang
        JOIN kursi k ON tk.kursi_id_kursi = k.id_kursi
        JOIN transaksi tx ON tk.transaksi_id_transaksi = tx.id_transaksi
        JOIN pembayaran pb ON tx.pembayaran_id_pembayaran = pb.id_pembayaran
        WHERE tx.pelanggan_id_pelanggan = 'PL9999'
        ORDER BY jt.waktu_tayang ASC
    `);
    
    console.log('Fetched tickets length:', tickets.length);
    if (tickets.length > 0) {
        console.log('Status transaksi:', tickets[0].status_transaksi);
    }
  } catch (e) {
    console.error(e);
  }
  process.exit();
}
run();
