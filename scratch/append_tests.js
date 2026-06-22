const fs = require('fs');

const explains = `
-- ============================================================
-- PENGUJIAN INDEX EXPLAIN (Untuk Analisis Laporan)
-- ============================================================

-- EXPLAIN INDEX 1: film(status_tayang)
EXPLAIN
SELECT f.judul, f.status_tayang, g.nama_genre
FROM film f
JOIN film_genre fg ON f.id_film         = fg.film_id_film
JOIN genre      g  ON fg.genre_id_genre = g.id_genre
WHERE f.status_tayang = 'Now Showing'
ORDER BY f.judul, g.nama_genre;

-- EXPLAIN INDEX 2: jadwal_tayang_film(film_id_film)
EXPLAIN
SELECT
    jt.id_jadwal,
    jt.waktu_tayang,
    f.judul,
    f.durasi
FROM jadwal_tayang      jt
JOIN jadwal_tayang_film jtf ON jt.id_jadwal     = jtf.jadwal_tayang_id_jadwal
JOIN film               f   ON jtf.film_id_film = f.id_film
ORDER BY jt.waktu_tayang;

-- EXPLAIN INDEX 3: transaksi(total_tagihan)
EXPLAIN
SELECT
    tx.id_transaksi,
    pl.nama_pelanggan,
    tx.tanggal_transaksi,
    tx.total_tagihan,
    pb.metode_pembayaran
FROM transaksi  tx
JOIN pelanggan  pl ON tx.pelanggan_id_pelanggan   = pl.id_pelanggan
JOIN pembayaran pb ON tx.pembayaran_id_pembayaran = pb.id_pembayaran
WHERE tx.total_tagihan > 200000
ORDER BY tx.total_tagihan DESC;

-- EXPLAIN INDEX 4: tiket(jadwal_tayang_id_jadwal, kursi_id_kursi)
EXPLAIN
SELECT COUNT(*) AS kursi_terisi
FROM tiket
WHERE jadwal_tayang_id_jadwal = 'JD0001'
  AND kursi_id_kursi          = 'KR0001';

-- EXPLAIN INDEX 5: pelanggan(email_pelanggan)
EXPLAIN
SELECT id_pelanggan, nama_pelanggan, email_pelanggan
FROM pelanggan
WHERE email_pelanggan = 'pelanggan1@gmail.com';
`;

fs.appendFileSync('Database/MBD_D_FP_tests.sql', explains, 'utf8');
console.log("Appended EXPLAIN statements to MBD_D_FP_tests.sql");
