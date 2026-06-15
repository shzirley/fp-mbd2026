-- ============================================================
--  MBD_FP — Pengujian dan Verifikasi Basis Data CineTrack
--  Departemen Informatika, ITS Surabaya
--  Kelompok: Maleka Ghaniya · Jorell Ramos Sinaga · Angela Vania Sugiyono
-- ============================================================

USE MBD_FP;

-- ============================================================
-- SECTION 3 — Query Cases (5 kasus kontekstual CineTrack)
-- ============================================================

-- ============================================================
-- Kasus 1: Menampilkan Daftar Film Beserta Genre-nya
-- Kebutuhan: Tim promosi membutuhkan daftar film yang sedang
-- tayang (Now Showing) beserta informasi genre-nya untuk
-- keperluan pembuatan materi iklan.
-- ============================================================
SELECT
    f.judul             AS judul_film,
    f.status_tayang     AS status,
    g.nama_genre        AS genre
FROM film f
JOIN film_genre fg ON f.id_film     = fg.film_id_film
JOIN genre      g  ON fg.genre_id_genre = g.id_genre
WHERE f.status_tayang = 'Now Showing'
ORDER BY f.judul, g.nama_genre;

-- ============================================================
-- Kasus 2: Menampilkan Jadwal Tayang Beserta Film dan Studio
-- Kebutuhan: Kasir perlu menampilkan seluruh jadwal tayang
-- hari ini lengkap dengan nama film, studio, dan harga dasar
-- tiket untuk ditampilkan kepada pelanggan.
-- ============================================================
SELECT
    jt.waktu_tayang     AS waktu,
    f.judul             AS film,
    st.kelas_studio     AS kelas_studio,
    jt.harga_dasar      AS harga_dasar,
    cb.nama_cabang      AS cabang
FROM jadwal_tayang     jt
JOIN jadwal_tayang_film jtf ON jt.id_jadwal       = jtf.jadwal_tayang_id_jadwal
JOIN film               f   ON jtf.film_id_film    = f.id_film
JOIN studio             st  ON jt.studio_id_studio = st.id_studio
JOIN cabang             cb  ON st.cabang_id_cabang = cb.id_cabang
ORDER BY jt.waktu_tayang;

-- ============================================================
-- Kasus 3: Menampilkan Transaksi dengan Total Tagihan
--          di Atas Rp200.000
-- Kebutuhan: Manajer ingin mengidentifikasi transaksi dengan
-- nilai tinggi (>Rp200.000) untuk analisis pola pembelian
-- pelanggan premium.
-- ============================================================
SELECT
    tx.id_transaksi         AS id_transaksi,
    pl.nama_pelanggan       AS pelanggan,
    tx.tanggal_transaksi    AS tanggal,
    tx.total_tagihan        AS total_tagihan,
    pb.metode_pembayaran    AS metode_bayar
FROM transaksi  tx
JOIN pelanggan  pl ON tx.pelanggan_id_pelanggan    = pl.id_pelanggan
JOIN pembayaran pb ON tx.pembayaran_id_pembayaran  = pb.id_pembayaran
WHERE tx.total_tagihan > 200000
ORDER BY tx.total_tagihan DESC;

-- ============================================================
-- Kasus 4: Menampilkan Rekap Penjualan Produk Kantin
--          per Kategori
-- Kebutuhan: Manajer kantin memerlukan laporan produk kantin
-- paling laris berdasarkan total qty terjual per kategori,
-- untuk perencanaan stok mingguan.
-- ============================================================
SELECT
    kt.nama_kategori                        AS kategori,
    pk.nama_produk                          AS produk,
    SUM(pkt.qty)                            AS total_terjual,
    SUM(pkt.subtotal)                       AS total_pendapatan
FROM produk_kantin_transaksi pkt
JOIN produk_kantin pk ON pkt.produk_kantin_id_produk = pk.id_produk
JOIN kategori      kt ON pk.kategori_id_kategori     = kt.id_kategori
WHERE pkt.qty > 0
GROUP BY kt.nama_kategori, pk.nama_produk
ORDER BY total_terjual DESC, total_pendapatan DESC;

-- ============================================================
-- Kasus 5: Menampilkan Pelanggan yang Belum Pernah
--          Melakukan Transaksi
-- Kebutuhan: Tim loyalitas ingin mengidentifikasi pelanggan
-- terdaftar yang belum pernah melakukan transaksi sama sekali
-- sebagai target kampanye promosi reaktivasi.
-- ============================================================
SELECT
    pl.id_pelanggan     AS id_pelanggan,
    pl.nama_pelanggan   AS nama_pelanggan,
    pl.no_telp_pelanggan AS nomor_telepon,
    pl.email_pelanggan  AS email
FROM pelanggan pl
WHERE pl.id_pelanggan NOT IN (
    SELECT DISTINCT tx.pelanggan_id_pelanggan
    FROM transaksi tx
    WHERE tx.pelanggan_id_pelanggan IS NOT NULL
)
ORDER BY pl.id_pelanggan;


-- ============================================================
-- UJI COBA SQL FUNCTIONS
-- ============================================================

-- Function 1: GetTotalTiketByPelanggan
-- Contoh pemanggilan (pelanggan dengan beberapa tiket):
SELECT GetTotalTiketByPelanggan('PL0001') AS TotalTiket;

-- Contoh pemanggilan (pelanggan lain):
SELECT GetTotalTiketByPelanggan('PL0008') AS TotalTiket;

-- Contoh gabungan: menampilkan semua pelanggan beserta total tiket masing-masing
SELECT
    pl.id_pelanggan                              AS id_pelanggan,
    pl.nama_pelanggan                            AS nama_pelanggan,
    GetTotalTiketByPelanggan(pl.id_pelanggan)    AS total_tiket_dibeli
FROM pelanggan pl
ORDER BY total_tiket_dibeli DESC, pl.nama_pelanggan;


-- Function 2: GetPendapatanByStudio
-- Contoh pemanggilan (studio Regular):
SELECT GetPendapatanByStudio('ST0001') AS TotalPendapatan;

-- Contoh pemanggilan (studio VIP):
SELECT GetPendapatanByStudio('ST0002') AS TotalPendapatan;

-- Contoh gabungan: menampilkan semua studio beserta total pendapatannya
SELECT
    st.id_studio                              AS id_studio,
    st.kelas_studio                           AS kelas,
    cb.nama_cabang                            AS cabang,
    GetPendapatanByStudio(st.id_studio)       AS total_pendapatan_tiket
FROM studio  st
JOIN cabang  cb ON st.cabang_id_cabang = cb.id_cabang
ORDER BY total_pendapatan_tiket DESC;


-- Function 3: GetDurasiTayang
-- Contoh pemanggilan (jadwal sesi pagi):
SELECT GetDurasiTayang('JD0001') AS DurasiMenit;

-- Contoh pemanggilan (jadwal studio VIP):
SELECT GetDurasiTayang('JD0005') AS DurasiMenit;

-- Contoh gabungan: menampilkan seluruh jadwal tayang beserta estimasi jam selesai sesi
SELECT
    jt.id_jadwal                                   AS id_jadwal,
    jt.waktu_tayang                                AS mulai,
    f.judul                                        AS film,
    GetDurasiTayang(jt.id_jadwal)                  AS durasi_menit,
    DATE_ADD(
        jt.waktu_tayang,
        INTERVAL GetDurasiTayang(jt.id_jadwal) MINUTE
    )                                              AS estimasi_selesai,
    st.kelas_studio                                AS kelas_studio,
    cb.nama_cabang                                 AS cabang
FROM jadwal_tayang      jt
JOIN jadwal_tayang_film jtf ON jt.id_jadwal            = jtf.jadwal_tayang_id_jadwal
JOIN film               f   ON jtf.film_id_film        = f.id_film
JOIN studio             st  ON jt.studio_id_studio     = st.id_studio
JOIN cabang             cb  ON st.cabang_id_cabang     = cb.id_cabang
ORDER BY jt.waktu_tayang;


-- ============================================================
-- UJI COBA SQL PROCEDURES
-- ============================================================

-- Procedure 2: TambahJadwalMidnight
CALL TambahJadwalMidnight('2026-06-15', 75000.00, 'ST0001', 'FM0001');
SELECT * FROM jadwal_tayang ORDER BY id_jadwal DESC LIMIT 1;
SELECT * FROM jadwal_tayang_film ORDER BY jadwal_tayang_id_jadwal DESC LIMIT 1;

-- Procedure 3: TambahStokKantin
SELECT id_produk, nama_produk, stok FROM produk_kantin WHERE id_produk = 'PK0002';
CALL TambahStokKantin('PK0002', 20);
SELECT id_produk, nama_produk, stok FROM produk_kantin WHERE id_produk = 'PK0002';


-- ============================================================
-- UJI COBA SQL TRIGGERS
-- ============================================================

-- Trigger 1: Pencegahan Double-Booking Kursi
-- Pendaftaran tiket pertama (berhasil)
INSERT INTO tiket (id_tiket, harga_beli, jadwal_tayang_id_jadwal, transaksi_id_transaksi, kursi_id_kursi) 
VALUES ('TK0021', 0, 'JD0001', 'TX0001', 'KR0002');
SELECT * FROM tiket WHERE id_tiket = 'TK0021';

-- Pendaftaran tiket kedua pada jadwal dan kursi yang sama (seharusnya gagal dan memicu SIGNAL)
-- PENTING: Jalankan baris di bawah ini secara terpisah untuk melihat error trigger pencegahan double-booking.
-- INSERT INTO tiket (id_tiket, harga_beli, jadwal_tayang_id_jadwal, transaksi_id_transaksi, kursi_id_kursi) 
-- VALUES ('TK0022', 0, 'JD0001', 'TX0001', 'KR0002');


-- Trigger 3: Pengurangan Stok Kantin Otomatis
SELECT id_produk, nama_produk, stok FROM produk_kantin WHERE id_produk = 'PK0007';

INSERT INTO produk_kantin_transaksi (produk_kantin_id_produk, transaksi_id_transaksi, qty, subtotal)
VALUES ('PK0007', 'TX0002', 5, 75000.00);

SELECT id_produk, nama_produk, stok FROM produk_kantin WHERE id_produk = 'PK0007';


-- ============================================================
-- VERIFIKASI INDEX DAN EXPLAIN LOGIC
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

-- EXPLAIN INDEX 5: jadwal_tayang(waktu_tayang)
EXPLAIN
SELECT
    jt.waktu_tayang,
    f.judul,
    st.kelas_studio,
    jt.harga_dasar,
    cb.nama_cabang
FROM jadwal_tayang      jt
JOIN jadwal_tayang_film jtf ON jt.id_jadwal        = jtf.jadwal_tayang_id_jadwal
JOIN film               f   ON jtf.film_id_film    = f.id_film
JOIN studio             st  ON jt.studio_id_studio = st.id_studio
JOIN cabang             cb  ON st.cabang_id_cabang = cb.id_cabang
ORDER BY jt.waktu_tayang;

-- Menampilkan semua index custom yang terdaftar di database
SELECT
    TABLE_NAME   AS tabel,
    INDEX_NAME   AS nama_index,
    COLUMN_NAME  AS kolom,
    SEQ_IN_INDEX AS urutan,
    INDEX_TYPE   AS jenis
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'MBD_FP'
  AND INDEX_NAME LIKE 'idx_%'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
