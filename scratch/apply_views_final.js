const mysql = require('mysql2/promise');

async function run() {
  const connection = await mysql.createConnection({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
  try {
    console.log("Applying views...");

    // Kasus 1: vw_film_genre
    await connection.query(`
      CREATE OR REPLACE VIEW vw_film_genre AS
      SELECT 
          f.id_film, f.judul, f.sutradara, f.rating_usia, f.durasi, 
          f.sinopsis, f.status_tayang, f.poster_url, f.rating_score,
          GROUP_CONCAT(g.nama_genre SEPARATOR ', ') AS daftar_genre
      FROM film f
      LEFT JOIN film_genre fg ON f.id_film = fg.film_id_film
      LEFT JOIN genre g ON fg.genre_id_genre = g.id_genre
      GROUP BY f.id_film;
    `);
    console.log("vw_film_genre created.");

    // Kasus 2: vw_detail_jadwal
    await connection.query(`
      CREATE OR REPLACE VIEW vw_detail_jadwal AS
      SELECT 
          j.id_jadwal, j.waktu_tayang, j.harga_dasar, 
          s.id_studio, s.nomor_studio, s.kelas_studio, 
          c.id_cabang, c.nama_cabang, 
          f.id_film, f.judul, f.durasi,
          f.poster_url, f.rating_usia, f.status_tayang
      FROM jadwal_tayang j
      JOIN studio s ON j.studio_id_studio = s.id_studio
      JOIN cabang c ON s.cabang_id_cabang = c.id_cabang
      LEFT JOIN jadwal_tayang_film jtf ON j.id_jadwal = jtf.jadwal_tayang_id_jadwal
      LEFT JOIN film f ON jtf.film_id_film = f.id_film;
    `);
    console.log("vw_detail_jadwal created.");

    // Kasus 3: vw_transaksi_vip
    await connection.query(`
      CREATE OR REPLACE VIEW vw_transaksi_vip AS
      SELECT 
          t.id_transaksi, t.tanggal_transaksi, t.total_tagihan, 
          pl.id_pelanggan, pl.nama_pelanggan, 
          pg.id_pegawai, pg.nama_pegawai, 
          pb.metode_pembayaran, pb.status_pembayaran
      FROM transaksi t
      JOIN pelanggan pl ON t.pelanggan_id_pelanggan = pl.id_pelanggan
      JOIN pegawai pg ON t.pegawai_id_pegawai = pg.id_pegawai
      JOIN pembayaran pb ON t.pembayaran_id_pembayaran = pb.id_pembayaran
      WHERE t.total_tagihan > 200000;
    `);
    console.log("vw_transaksi_vip created.");

    // Kasus 4: vw_rekap_kantin_kategori
    await connection.query(`
      CREATE OR REPLACE VIEW vw_rekap_kantin_kategori AS
      SELECT 
          k.nama_kategori, 
          SUM(pkt.qty) AS total_item_terjual, 
          SUM(pkt.subtotal) AS total_pendapatan
      FROM kategori k
      JOIN produk_kantin pk ON k.id_kategori = pk.kategori_id_kategori
      JOIN produk_kantin_transaksi pkt ON pk.id_produk = pkt.produk_kantin_id_produk
      GROUP BY k.id_kategori, k.nama_kategori;
    `);
    console.log("vw_rekap_kantin_kategori created.");

    // Kasus 5: vw_pelanggan_idle
    await connection.query(`
      CREATE OR REPLACE VIEW vw_pelanggan_idle AS
      SELECT 
          pl.id_pelanggan, 
          pl.nama_pelanggan, 
          pl.email_pelanggan
      FROM pelanggan pl
      LEFT JOIN transaksi tx ON pl.id_pelanggan = tx.pelanggan_id_pelanggan
      WHERE tx.id_transaksi IS NULL;
    `);
    console.log("vw_pelanggan_idle created.");

    console.log("All views applied successfully!");
  } catch (e) {
    console.error(e);
  }
  process.exit();
}
run();
