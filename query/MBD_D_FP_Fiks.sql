-- ============================================================
--  MBD_FP — Sistem Basis Data Bioskop CineTrack
--  Departemen Informatika, ITS Surabaya
--  Kelompok: Maleka Ghaniya · Jorell Ramos Sinaga · Angela Vania Sugiyono
-- ============================================================

DROP DATABASE IF EXISTS MBD_FP;
CREATE DATABASE MBD_FP CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE MBD_FP;

-- ============================================================
-- SECTION 1 — DDL (Schema)
-- ============================================================

-- 1. cabang
CREATE TABLE cabang (
    id_cabang       CHAR(6)       NOT NULL,
    nama_cabang     VARCHAR(100)  NOT NULL,
    alamat          VARCHAR(255)  NOT NULL,
    nomor_telepon   VARCHAR(15),
    email_cabang    VARCHAR(100),
    PRIMARY KEY (id_cabang)
);

-- 2. studio
CREATE TABLE studio (
    id_studio       CHAR(6)       NOT NULL,
    nomor_studio    INT           NOT NULL,
    kelas_studio    VARCHAR(30)   NOT NULL,
    cabang_id_cabang CHAR(6)      NOT NULL,
    PRIMARY KEY (id_studio),
    CONSTRAINT fk_studio_cabang FOREIGN KEY (cabang_id_cabang)
        REFERENCES cabang (id_cabang)
);

-- 3. kursi
CREATE TABLE kursi (
    id_kursi        CHAR(6)       NOT NULL,
    nomor_kursi     VARCHAR(5)    NOT NULL,
    baris           VARCHAR(2)    NOT NULL,
    kolom           VARCHAR(3)    NOT NULL,
    tipe_kursi      VARCHAR(20)   NOT NULL,
    tarif_tipe      DECIMAL(10,2) NOT NULL,
    studio_id_studio CHAR(6)      NOT NULL,
    PRIMARY KEY (id_kursi),
    CONSTRAINT fk_kursi_studio FOREIGN KEY (studio_id_studio)
        REFERENCES studio (id_studio)
);

-- 4. genre
CREATE TABLE genre (
    id_genre        CHAR(6)       NOT NULL,
    nama_genre      VARCHAR(50)   NOT NULL,
    PRIMARY KEY (id_genre)
);

-- 5. film
CREATE TABLE film (
    id_film         CHAR(6)       NOT NULL,
    judul           VARCHAR(150)  NOT NULL,
    sutradara       VARCHAR(100),
    rating_usia     VARCHAR(5),
    durasi          INT,
    sinopsis        TEXT,
    status_tayang   VARCHAR(20),
    PRIMARY KEY (id_film)
);

-- 6. film_genre  (junction film N:N genre)
CREATE TABLE film_genre (
    film_id_film        CHAR(6)  NOT NULL,
    genre_id_genre      CHAR(6)  NOT NULL,
    PRIMARY KEY (film_id_film, genre_id_genre),
    CONSTRAINT fk_fg_film  FOREIGN KEY (film_id_film)   REFERENCES film  (id_film),
    CONSTRAINT fk_fg_genre FOREIGN KEY (genre_id_genre) REFERENCES genre (id_genre)
);

-- 7. jadwal_tayang
CREATE TABLE jadwal_tayang (
    id_jadwal           CHAR(6)       NOT NULL,
    waktu_tayang        DATETIME      NOT NULL,
    harga_dasar         DECIMAL(10,2) NOT NULL,
    studio_id_studio    CHAR(6)       NOT NULL,
    PRIMARY KEY (id_jadwal),
    CONSTRAINT fk_jadwal_studio FOREIGN KEY (studio_id_studio)
        REFERENCES studio (id_studio)
);

-- 8. jadwal_tayang_film  (junction jadwal N:N film)
CREATE TABLE jadwal_tayang_film (
    jadwal_tayang_id_jadwal CHAR(6)  NOT NULL,
    film_id_film            CHAR(6)  NOT NULL,
    PRIMARY KEY (jadwal_tayang_id_jadwal, film_id_film),
    CONSTRAINT fk_jtf_jadwal FOREIGN KEY (jadwal_tayang_id_jadwal) REFERENCES jadwal_tayang (id_jadwal),
    CONSTRAINT fk_jtf_film   FOREIGN KEY (film_id_film)            REFERENCES film          (id_film)
);

-- 9. pelanggan
CREATE TABLE pelanggan (
    id_pelanggan        CHAR(6)       NOT NULL,
    nama_pelanggan      VARCHAR(100)  NOT NULL,
    no_telp_pelanggan   VARCHAR(15),
    email_pelanggan     VARCHAR(100),
    password            VARCHAR(255)  NOT NULL DEFAULT 'password123',
    PRIMARY KEY (id_pelanggan)
);

-- 10. pembayaran
CREATE TABLE pembayaran (
    id_pembayaran       CHAR(6)       NOT NULL,
    metode_pembayaran   VARCHAR(30)   NOT NULL,
    status_pembayaran   VARCHAR(10)   NOT NULL,
    PRIMARY KEY (id_pembayaran)
);

-- 11. pegawai
CREATE TABLE pegawai (
    id_pegawai      CHAR(6)       NOT NULL,
    nama_pegawai    VARCHAR(100)  NOT NULL,
    nomor_telepon   VARCHAR(15),
    email_pegawai   VARCHAR(100),
    password        VARCHAR(255)  NOT NULL DEFAULT 'password123',
    PRIMARY KEY (id_pegawai)
);

-- 12. shift
CREATE TABLE shift (
    id_shift        CHAR(6)       NOT NULL,
    nama_shift      VARCHAR(10)   NOT NULL,
    waktu_mulai     TIME          NOT NULL,
    waktu_selesai   TIME          NOT NULL,
    PRIMARY KEY (id_shift)
);

-- 13. pegawai_shift  (junction pegawai N:N shift)
CREATE TABLE pegawai_shift (
    pegawai_id_pegawai  CHAR(6)  NOT NULL,
    shift_id_shift      CHAR(6)  NOT NULL,
    PRIMARY KEY (pegawai_id_pegawai, shift_id_shift),
    CONSTRAINT fk_ps_pegawai FOREIGN KEY (pegawai_id_pegawai) REFERENCES pegawai (id_pegawai),
    CONSTRAINT fk_ps_shift   FOREIGN KEY (shift_id_shift)     REFERENCES shift   (id_shift)
);

-- 14. transaksi
CREATE TABLE transaksi (
    id_transaksi            CHAR(6)       NOT NULL,
    tanggal_transaksi       DATETIME      NOT NULL,
    total_tagihan           DECIMAL(9,2)  NOT NULL,
    pelanggan_id_pelanggan  CHAR(6)       NOT NULL,
    pembayaran_id_pembayaran CHAR(6)      NOT NULL,
    pegawai_id_pegawai      CHAR(6)       NOT NULL,
    PRIMARY KEY (id_transaksi),
    CONSTRAINT fk_trx_pelanggan  FOREIGN KEY (pelanggan_id_pelanggan)   REFERENCES pelanggan  (id_pelanggan),
    CONSTRAINT fk_trx_pembayaran FOREIGN KEY (pembayaran_id_pembayaran)  REFERENCES pembayaran (id_pembayaran),
    CONSTRAINT fk_trx_pegawai    FOREIGN KEY (pegawai_id_pegawai)        REFERENCES pegawai    (id_pegawai)
);

-- 15. tiket
CREATE TABLE tiket (
    id_tiket                    CHAR(6)       NOT NULL,
    harga_beli                  DECIMAL(10,2) NOT NULL,
    jadwal_tayang_id_jadwal     CHAR(6)       NOT NULL,
    transaksi_id_transaksi      CHAR(6)       NOT NULL,
    kursi_id_kursi              CHAR(6)       NOT NULL,
    PRIMARY KEY (id_tiket),
    CONSTRAINT fk_tiket_jadwal    FOREIGN KEY (jadwal_tayang_id_jadwal) REFERENCES jadwal_tayang (id_jadwal),
    CONSTRAINT fk_tiket_transaksi FOREIGN KEY (transaksi_id_transaksi)  REFERENCES transaksi     (id_transaksi),
    CONSTRAINT fk_tiket_kursi     FOREIGN KEY (kursi_id_kursi)          REFERENCES kursi         (id_kursi)
);

-- 16. kategori
CREATE TABLE kategori (
    id_kategori     CHAR(6)       NOT NULL,
    nama_kategori   VARCHAR(50)   NOT NULL,
    PRIMARY KEY (id_kategori)
);

-- 17. produk_kantin
CREATE TABLE produk_kantin (
    id_produk           CHAR(6)       NOT NULL,
    nama_produk         VARCHAR(100)  NOT NULL,
    stok                INT           NOT NULL,
    harga_satuan        DECIMAL(10,2) NOT NULL,
    kategori_id_kategori CHAR(6)      NOT NULL,
    PRIMARY KEY (id_produk),
    CONSTRAINT fk_produk_kategori FOREIGN KEY (kategori_id_kategori)
        REFERENCES kategori (id_kategori)
);

-- 18. produk_kantin_transaksi  (junction transaksi N:N produk_kantin)
CREATE TABLE produk_kantin_transaksi (
    produk_kantin_id_produk     CHAR(6)       NOT NULL,
    transaksi_id_transaksi      CHAR(6)       NOT NULL,
    qty                         INT           NOT NULL,
    subtotal                    DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (produk_kantin_id_produk, transaksi_id_transaksi),
    CONSTRAINT fk_pkt_produk     FOREIGN KEY (produk_kantin_id_produk) REFERENCES produk_kantin (id_produk),
    CONSTRAINT fk_pkt_transaksi  FOREIGN KEY (transaksi_id_transaksi)  REFERENCES transaksi     (id_transaksi)
);


-- ============================================================
-- SECTION 2 — DML (Seed Data — 20 rows per primary table)
-- ============================================================

-- ---- cabang ------------------------------------------------
INSERT INTO cabang VALUES
('CB0001','CineTrack Surabaya Pusat','Jl. Tunjungan No. 1, Surabaya','0318001001','surabaya@cinetrack.id'),
('CB0002','CineTrack Surabaya Selatan','Jl. Ahmad Yani No. 55, Surabaya','0318001002','sby.selatan@cinetrack.id'),
('CB0003','CineTrack Malang','Jl. Veteran No. 10, Malang','0341800100','malang@cinetrack.id'),
('CB0004','CineTrack Bandung','Jl. Dago No. 88, Bandung','0222800100','bandung@cinetrack.id'),
('CB0005','CineTrack Jakarta Selatan','Jl. Sudirman No. 200, Jakarta','0212800100','jaksel@cinetrack.id'),
('CB0006','CineTrack Yogyakarta','Jl. Malioboro No. 3, Yogyakarta','0274800100','yogya@cinetrack.id'),
('CB0007','CineTrack Semarang','Jl. Pemuda No. 7, Semarang','0242800100','semarang@cinetrack.id'),
('CB0008','CineTrack Makassar','Jl. Sam Ratulangi No. 22, Makassar','0411800100','makassar@cinetrack.id'),
('CB0009','CineTrack Medan','Jl. Gatot Subroto No. 9, Medan','0618800100','medan@cinetrack.id'),
('CB0010','CineTrack Denpasar','Jl. Teuku Umar No. 14, Denpasar','0361800100','bali@cinetrack.id'),
('CB0011','CineTrack Surabaya Timur','Jl. Rungkut No. 30, Surabaya','0318001011','sby.timur@cinetrack.id'),
('CB0012','CineTrack Surabaya Barat','Jl. Darmo Permai No. 5, Surabaya','0318001012','sby.barat@cinetrack.id'),
('CB0013','CineTrack Sidoarjo','Jl. Pahlawan No. 18, Sidoarjo','0318001013','sidoarjo@cinetrack.id'),
('CB0014','CineTrack Gresik','Jl. Gubernur Suryo No. 4, Gresik','0318001014','gresik@cinetrack.id'),
('CB0015','CineTrack Mojokerto','Jl. Gajah Mada No. 6, Mojokerto','0318001015','mojokerto@cinetrack.id'),
('CB0016','CineTrack Bogor','Jl. Pajajaran No. 12, Bogor','0251800100','bogor@cinetrack.id'),
('CB0017','CineTrack Depok','Jl. Margonda No. 100, Depok','0217800100','depok@cinetrack.id'),
('CB0018','CineTrack Tangerang','Jl. MH Thamrin No. 45, Tangerang','0217800110','tangerang@cinetrack.id'),
('CB0019','CineTrack Bekasi','Jl. Ahmad Yani No. 11, Bekasi','0217800120','bekasi@cinetrack.id'),
('CB0020','CineTrack Solo','Jl. Slamet Riyadi No. 33, Solo','0271800100','solo@cinetrack.id');

-- ---- studio ------------------------------------------------
INSERT INTO studio VALUES
('ST0001',1,'Regular','CB0001'),
('ST0002',2,'VIP','CB0001'),
('ST0003',3,'IMAX','CB0001'),
('ST0004',1,'Regular','CB0002'),
('ST0005',2,'VIP','CB0002'),
('ST0006',1,'Regular','CB0003'),
('ST0007',2,'VIP','CB0003'),
('ST0008',1,'Regular','CB0004'),
('ST0009',1,'IMAX','CB0005'),
('ST0010',2,'Regular','CB0005'),
('ST0011',1,'Regular','CB0006'),
('ST0012',1,'Regular','CB0007'),
('ST0013',1,'VIP','CB0008'),
('ST0014',1,'Regular','CB0009'),
('ST0015',1,'Regular','CB0010'),
('ST0016',3,'Couple','CB0001'),
('ST0017',4,'Regular','CB0001'),
('ST0018',3,'Regular','CB0002'),
('ST0019',2,'Regular','CB0003'),
('ST0020',2,'IMAX','CB0005');

-- ---- kursi ------------------------------------------------
INSERT INTO kursi VALUES
('KR0001','A1','A','1','Reguler',45000.00,'ST0001'),
('KR0002','A2','A','2','Reguler',45000.00,'ST0001'),
('KR0003','B1','B','1','VIP',85000.00,'ST0002'),
('KR0004','B2','B','2','VIP',85000.00,'ST0002'),
('KR0005','C1','C','1','Couple',120000.00,'ST0016'),
('KR0006','C2','C','2','Couple',120000.00,'ST0016'),
('KR0007','A3','A','3','Reguler',45000.00,'ST0001'),
('KR0008','A4','A','4','Reguler',45000.00,'ST0001'),
('KR0009','D1','D','1','IMAX',95000.00,'ST0003'),
('KR0010','D2','D','2','IMAX',95000.00,'ST0003'),
('KR0011','A1','A','1','Reguler',45000.00,'ST0004'),
('KR0012','A2','A','2','Reguler',45000.00,'ST0004'),
('KR0013','B1','B','1','VIP',85000.00,'ST0005'),
('KR0014','B3','B','3','VIP',85000.00,'ST0002'),
('KR0015','A5','A','5','Reguler',45000.00,'ST0001'),
('KR0016','A1','A','1','IMAX',95000.00,'ST0009'),
('KR0017','A2','A','2','IMAX',95000.00,'ST0009'),
('KR0018','B1','B','1','Reguler',45000.00,'ST0006'),
('KR0019','A1','A','1','Reguler',45000.00,'ST0011'),
('KR0020','A1','A','1','Reguler',45000.00,'ST0012');

-- ---- genre -------------------------------------------------
INSERT INTO genre VALUES
('GN0001','Action'),
('GN0002','Drama'),
('GN0003','Comedy'),
('GN0004','Horror'),
('GN0005','Romance'),
('GN0006','Sci-Fi'),
('GN0007','Thriller'),
('GN0008','Animation'),
('GN0009','Documentary'),
('GN0010','Fantasy'),
('GN0011','Adventure'),
('GN0012','Crime'),
('GN0013','Mystery'),
('GN0014','Historical'),
('GN0015','Musical'),
('GN0016','Superhero'),
('GN0017','War'),
('GN0018','Family'),
('GN0019','Biography'),
('GN0020','Sport');

-- ---- film --------------------------------------------------
INSERT INTO film VALUES
('FM0001','Garuda Merah','Riri Riza','13+',120,'Kisah perjuangan pilot muda Indonesia.','Now Showing'),
('FM0002','Pulau Hantu','Kimo Stamboel','17+',100,'Sekelompok remaja terjebak di pulau misterius.','Now Showing'),
('FM0003','Cinta di Ujung Senja','Hanung Bramantyo','13+',115,'Romansa dua insan di kota Yogyakarta.','Now Showing'),
('FM0004','Mega Force','James Cameron','13+',150,'Aksi superhero melawan ancaman alien.','Now Showing'),
('FM0005','Ketawa Terus','Raditya Dika','SU',95,'Komedi segar tentang kehidupan kantor.','Now Showing'),
('FM0006','Nusantara 2077','Joko Anwar','17+',135,'Dystopia futuristik di kepulauan Nusantara.','Coming Soon'),
('FM0007','Rumah Merah Darah','Anggy Umbara','17+',110,'Keluarga yang terperangkap rumah angker.','Leaving Soon'),
('FM0008','Laskar Petualang','Ernest Prakasa','SU',105,'Anak-anak berpetualang di hutan Kalimantan.','Now Showing'),
('FM0009','Badai Samudra','Edwin','SU',130,'Dokumenter laut Indonesia yang memukau.','Now Showing'),
('FM0010','Sang Maestro','Ifa Isfansyah','SU',125,'Perjalanan hidup seniman legendaris.','Coming Soon'),
('FM0011','Dansa Terakhir','Garin Nugroho','13+',140,'Drama musikal penuh emosi.','Now Showing'),
('FM0012','Detektif Hitam','Rako Prijanto','13+',118,'Detektif swasta menguak konspirasi besar.','Now Showing'),
('FM0013','Laut Biru','Nicholas Saputra','SU',90,'Petualangan bahari keluarga muda.','Leaving Soon'),
('FM0014','Tersesat di Mars','Yusuf Radjamuda','13+',145,'Astronot Indonesia hilang di Mars.','Coming Soon'),
('FM0015','Kopi & Kenangan','Yandy Laurens','SU',100,'Drama penutup kisah cinta 10 tahun.','Now Showing'),
('FM0016','Serigala Kota','Mouly Surya','17+',122,'Thriller kriminal di kota besar.','Now Showing'),
('FM0017','Pahlawan Kecil','Fajar Nugros','SU',98,'Animasi kepahlawanan anak bangsa.','Now Showing'),
('FM0018','Mimpi Besar','Wregas Bhanuteja','SU',112,'Inspirasi perjuangan anak pesantren.','Now Showing'),
('FM0019','Sumpah Prajurit','Timo Tjahjanto','17+',138,'Aksi militer penumpasan terorisme.','Leaving Soon'),
('FM0020','Tawa Sang Juara','Benni Setiawan','SU',92,'Drama olahraga penuh semangat.','Now Showing');

-- ---- film_genre --------------------------------------------
INSERT INTO film_genre VALUES
('FM0001','GN0001'),('FM0001','GN0011'),
('FM0002','GN0004'),('FM0002','GN0007'),
('FM0003','GN0002'),('FM0003','GN0005'),
('FM0004','GN0001'),('FM0004','GN0016'),
('FM0005','GN0003'),
('FM0006','GN0006'),('FM0006','GN0007'),
('FM0007','GN0004'),
('FM0008','GN0011'),('FM0008','GN0018'),
('FM0009','GN0009'),
('FM0010','GN0002'),('FM0010','GN0019'),
('FM0011','GN0002'),('FM0011','GN0015'),
('FM0012','GN0007'),('FM0012','GN0012'),
('FM0013','GN0011'),('FM0013','GN0018'),
('FM0014','GN0006'),('FM0014','GN0011'),
('FM0015','GN0002'),('FM0015','GN0005'),
('FM0016','GN0007'),('FM0016','GN0012'),
('FM0017','GN0008'),('FM0017','GN0018'),
('FM0018','GN0002'),
('FM0019','GN0001'),('FM0019','GN0017'),
('FM0020','GN0002'),('FM0020','GN0020');

-- ---- jadwal_tayang -----------------------------------------
INSERT INTO jadwal_tayang VALUES
('JD0001','2026-06-10 10:00:00',50000.00,'ST0001'),
('JD0002','2026-06-10 13:00:00',50000.00,'ST0001'),
('JD0003','2026-06-10 16:00:00',65000.00,'ST0001'),
('JD0004','2026-06-10 19:00:00',75000.00,'ST0001'),
('JD0005','2026-06-10 10:00:00',90000.00,'ST0002'),
('JD0006','2026-06-10 14:00:00',90000.00,'ST0002'),
('JD0007','2026-06-10 19:00:00',100000.00,'ST0002'),
('JD0008','2026-06-11 11:00:00',100000.00,'ST0003'),
('JD0009','2026-06-11 15:00:00',100000.00,'ST0003'),
('JD0010','2026-06-11 10:00:00',50000.00,'ST0004'),
('JD0011','2026-06-11 14:00:00',50000.00,'ST0004'),
('JD0012','2026-06-11 18:00:00',65000.00,'ST0004'),
('JD0013','2026-06-12 10:00:00',90000.00,'ST0005'),
('JD0014','2026-06-12 15:00:00',90000.00,'ST0005'),
('JD0015','2026-06-12 09:00:00',50000.00,'ST0006'),
('JD0016','2026-06-12 13:00:00',50000.00,'ST0006'),
('JD0017','2026-06-13 10:00:00',125000.00,'ST0016'),
('JD0018','2026-06-13 14:00:00',125000.00,'ST0016'),
('JD0019','2026-06-13 10:00:00',100000.00,'ST0009'),
('JD0020','2026-06-13 19:00:00',100000.00,'ST0009');

-- ---- jadwal_tayang_film ------------------------------------
INSERT INTO jadwal_tayang_film VALUES
('JD0001','FM0001'),
('JD0002','FM0003'),
('JD0003','FM0005'),
('JD0004','FM0007'),
('JD0005','FM0004'),
('JD0006','FM0001'),
('JD0007','FM0012'),
('JD0008','FM0006'),
('JD0009','FM0014'),
('JD0010','FM0002'),
('JD0011','FM0008'),
('JD0012','FM0015'),
('JD0013','FM0019'),
('JD0014','FM0016'),
('JD0015','FM0009'),
('JD0016','FM0017'),
('JD0017','FM0011'),
('JD0018','FM0013'),
('JD0019','FM0020'),
('JD0020','FM0018');

-- ---- pelanggan ---------------------------------------------
INSERT INTO pelanggan (id_pelanggan, nama_pelanggan, no_telp_pelanggan, email_pelanggan) VALUES
('PL0001','Ahmad Fauzi','081200000001','ahmad.fauzi@email.com'),
('PL0002','Bella Safitri','081200000002','bella.safitri@email.com'),
('PL0003','Cahyo Nugroho','081200000003','cahyo@email.com'),
('PL0004','Dina Puspita','081200000004','dina.puspita@email.com'),
('PL0005','Endra Setiawan','081200000005','endra@email.com'),
('PL0006','Fitri Amalia','081200000006','fitri.amalia@email.com'),
('PL0007','Galih Pratama','081200000007','galih@email.com'),
('PL0008','Hani Rahayu','081200000008','hani.rahayu@email.com'),
('PL0009','Ivan Kurniawan','081200000009','ivan@email.com'),
('PL0010','Julia Wulandari','081200000010','julia.wulandari@email.com'),
('PL0011','Kevin Hartanto','081200000011','kevin@email.com'),
('PL0012','Laila Nurjanah','081200000012','laila@email.com'),
('PL0013','Mario Susanto','081200000013','mario@email.com'),
('PL0014','Nanda Fitriana','081200000014','nanda@email.com'),
('PL0015','Omar Hidayat','081200000015','omar@email.com'),
('PL0016','Priska Dewanti','081200000016','priska@email.com'),
('PL0017','Qori Ramadhani','081200000017','qori@email.com'),
('PL0018','Rizky Aldiano','081200000018','rizky@email.com'),
('PL0019','Sinta Permatasari','081200000019','sinta@email.com'),
('PL0020','Taufik Hidayat',   '081200000020','taufik@email.com'),
-- Tiga pelanggan berikut sengaja tidak memiliki transaksi,
-- sehingga akan muncul pada hasil Query Kasus 5.
('PL0021','Bambang Susilo',  '081200000021','bambang@email.com'),
('PL0022','Cindy Maharani',  '081200000022','cindy@email.com'),
('PL0023','Dimas Arfian',    '081200000023','dimas@email.com');

-- ---- pembayaran --------------------------------------------
INSERT INTO pembayaran VALUES
('PB0001','Tunai','Lunas'),
('PB0002','QRIS','Lunas'),
('PB0003','Debit','Lunas'),
('PB0004','GoPay','Lunas'),
('PB0005','OVO','Lunas'),
('PB0006','Dana','Lunas'),
('PB0007','ShopeePay','Lunas'),
('PB0008','Transfer','Lunas'),
('PB0009','Tunai','Lunas'),
('PB0010','QRIS','Lunas'),
('PB0011','GoPay','Lunas'),
('PB0012','OVO','Lunas'),
('PB0013','Dana','Lunas'),
('PB0014','ShopeePay','Lunas'),
('PB0015','Debit','Lunas'),
('PB0016','Tunai','Pending'),
('PB0017','QRIS','Lunas'),
('PB0018','GoPay','Lunas'),
('PB0019','OVO','Lunas'),
('PB0020','Tunai','Lunas');

-- ---- pegawai -----------------------------------------------
INSERT INTO pegawai (id_pegawai, nama_pegawai, nomor_telepon, email_pegawai) VALUES
('PG0001','Budi Santoso','082300000001','budi@cinetrack.id'),
('PG0002','Citra Lestari','082300000002','citra@cinetrack.id'),
('PG0003','Dedy Kurniawan','082300000003','dedy@cinetrack.id'),
('PG0004','Eka Pratiwi','082300000004','eka@cinetrack.id'),
('PG0005','Feri Gunawan','082300000005','feri@cinetrack.id'),
('PG0006','Gita Nirmala','082300000006','gita@cinetrack.id'),
('PG0007','Hendra Wahyu','082300000007','hendra@cinetrack.id'),
('PG0008','Indah Permata','082300000008','indah@cinetrack.id'),
('PG0009','Joko Susilo','082300000009','joko@cinetrack.id'),
('PG0010','Kurniawati','082300000010','kurnia@cinetrack.id'),
('PG0011','Lukman Hakim','082300000011','lukman@cinetrack.id'),
('PG0012','Maya Sari','082300000012','maya@cinetrack.id'),
('PG0013','Nur Halim','082300000013','nurhalim@cinetrack.id'),
('PG0014','Oki Firmansyah','082300000014','oki@cinetrack.id'),
('PG0015','Putri Andini','082300000015','putri@cinetrack.id'),
('PG0016','Rendi Saputra','082300000016','rendi@cinetrack.id'),
('PG0017','Sari Dewi','082300000017','sari@cinetrack.id'),
('PG0018','Toni Hartono','082300000018','toni@cinetrack.id'),
('PG0019','Udin Setiawan','082300000019','udin@cinetrack.id'),
('PG0020','Vina Oktavia','082300000020','vina@cinetrack.id');

-- ---- shift -------------------------------------------------
INSERT INTO shift VALUES
('SH0001','Pagi','06:00:00','14:00:00'),
('SH0002','Siang','14:00:00','22:00:00'),
('SH0003','Malam','22:00:00','06:00:00'),
('SH0004','Pagi','07:00:00','15:00:00'),
('SH0005','Siang','13:00:00','21:00:00'),
('SH0006','Malam','21:00:00','05:00:00'),
('SH0007','Pagi','08:00:00','16:00:00'),
('SH0008','Siang','12:00:00','20:00:00'),
('SH0009','Malam','20:00:00','04:00:00'),
('SH0010','Pagi','05:00:00','13:00:00'),
('SH0011','Siang','11:00:00','19:00:00'),
('SH0012','Malam','19:00:00','03:00:00'),
('SH0013','Pagi','06:30:00','14:30:00'),
('SH0014','Siang','14:30:00','22:30:00'),
('SH0015','Malam','22:30:00','06:30:00'),
('SH0016','Pagi','07:30:00','15:30:00'),
('SH0017','Siang','15:30:00','23:30:00'),
('SH0018','Malam','23:30:00','07:30:00'),
('SH0019','Pagi','05:30:00','13:30:00'),
('SH0020','Siang','10:00:00','18:00:00');

-- ---- pegawai_shift -----------------------------------------
INSERT INTO pegawai_shift VALUES
('PG0001','SH0001'),('PG0002','SH0002'),('PG0003','SH0003'),
('PG0004','SH0001'),('PG0005','SH0002'),('PG0006','SH0003'),
('PG0007','SH0004'),('PG0008','SH0005'),('PG0009','SH0006'),
('PG0010','SH0007'),('PG0011','SH0008'),('PG0012','SH0009'),
('PG0013','SH0010'),('PG0014','SH0011'),('PG0015','SH0012'),
('PG0016','SH0013'),('PG0017','SH0014'),('PG0018','SH0015'),
('PG0019','SH0016'),('PG0020','SH0017'),
-- some pegawai cover multiple shifts
('PG0001','SH0002'),('PG0003','SH0001');

-- ---- transaksi ---------------------------------------------
INSERT INTO transaksi VALUES
('TX0001','2026-06-10 10:30:00',135000.00,'PL0001','PB0001','PG0001'),
('TX0002','2026-06-10 11:00:00',170000.00,'PL0002','PB0002','PG0002'),
('TX0003','2026-06-10 13:30:00', 95000.00,'PL0003','PB0003','PG0003'),
('TX0004','2026-06-10 14:10:00',260000.00,'PL0004','PB0004','PG0004'),
('TX0005','2026-06-10 16:30:00', 65000.00,'PL0005','PB0005','PG0005'),
('TX0006','2026-06-10 17:00:00',180000.00,'PL0006','PB0006','PG0006'),
('TX0007','2026-06-10 19:30:00',175000.00,'PL0007','PB0007','PG0007'),
('TX0008','2026-06-11 11:30:00',200000.00,'PL0008','PB0008','PG0008'),
('TX0009','2026-06-11 12:00:00',100000.00,'PL0009','PB0009','PG0009'),
('TX0010','2026-06-11 14:30:00',145000.00,'PL0010','PB0010','PG0010'),
('TX0011','2026-06-11 15:00:00', 50000.00,'PL0011','PB0011','PG0011'),
('TX0012','2026-06-11 18:30:00',220000.00,'PL0012','PB0012','PG0012'),
('TX0013','2026-06-12 10:30:00',185000.00,'PL0013','PB0013','PG0013'),
('TX0014','2026-06-12 11:00:00',270000.00,'PL0014','PB0014','PG0014'),
('TX0015','2026-06-12 15:30:00',120000.00,'PL0015','PB0015','PG0015'),
('TX0016','2026-06-12 16:00:00',240000.00,'PL0016','PB0016','PG0016'),
('TX0017','2026-06-13 10:30:00',250000.00,'PL0017','PB0017','PG0017'),
('TX0018','2026-06-13 11:00:00',155000.00,'PL0018','PB0018','PG0018'),
('TX0019','2026-06-13 14:30:00',190000.00,'PL0019','PB0019','PG0019'),
('TX0020','2026-06-13 19:30:00',310000.00,'PL0020','PB0020','PG0020');

-- ---- tiket -------------------------------------------------
-- harga_beli = harga_dasar jadwal + tarif_tipe kursi (snapshot)
INSERT INTO tiket VALUES
('TK0001', 95000.00,'JD0001','TX0001','KR0001'),
('TK0002',140000.00,'JD0002','TX0002','KR0003'),
('TK0003', 95000.00,'JD0003','TX0003','KR0007'),
('TK0004',175000.00,'JD0005','TX0004','KR0003'),
('TK0005', 65000.00,'JD0003','TX0005','KR0002'),
('TK0006',130000.00,'JD0006','TX0006','KR0004'),
('TK0007',175000.00,'JD0007','TX0007','KR0014'),
('TK0008',195000.00,'JD0008','TX0008','KR0009'),
('TK0009',100000.00,'JD0010','TX0009','KR0011'),
('TK0010',140000.00,'JD0005','TX0010','KR0003'),
('TK0011', 50000.00,'JD0010','TX0011','KR0012'),
('TK0012',175000.00,'JD0007','TX0012','KR0014'),
('TK0013',190000.00,'JD0013','TX0013','KR0013'),
('TK0014',175000.00,'JD0007','TX0014','KR0003'),
('TK0015',120000.00,'JD0012','TX0015','KR0011'),
('TK0016',215000.00,'JD0017','TX0016','KR0005'),
('TK0017',225000.00,'JD0017','TX0017','KR0006'),
('TK0018',155000.00,'JD0007','TX0018','KR0014'),
('TK0019',190000.00,'JD0013','TX0019','KR0013'),
('TK0020',195000.00,'JD0020','TX0020','KR0016');

-- ---- kategori ----------------------------------------------
INSERT INTO kategori VALUES
('KT0001','Makanan Berat'),
('KT0002','Camilan'),
('KT0003','Minuman Dingin'),
('KT0004','Minuman Panas'),
('KT0005','Dessert'),
('KT0006','Paket Combo'),
('KT0007','Popcorn'),
('KT0008','Nachos'),
('KT0009','Es Krim'),
('KT0010','Minuman Boba'),
('KT0011','Soft Drink'),
('KT0012','Jus Buah'),
('KT0013','Sandwich'),
('KT0014','Hot Dog'),
('KT0015','Pizza Slice'),
('KT0016','Roti Bakar'),
('KT0017','Kue Kering'),
('KT0018','Permen'),
('KT0019','Cokelat'),
('KT0020','Air Mineral');

-- ---- produk_kantin -----------------------------------------
INSERT INTO produk_kantin VALUES
('PK0001','Nasi Goreng Spesial',  50, 35000.00,'KT0001'),
('PK0002','Mie Goreng Ayam',      45, 30000.00,'KT0001'),
('PK0003','Popcorn Original',    120, 25000.00,'KT0007'),
('PK0004','Popcorn Karamel',     100, 28000.00,'KT0007'),
('PK0005','Nachos + Keju',        80, 32000.00,'KT0008'),
('PK0006','Coca Cola Regular',   200, 15000.00,'KT0011'),
('PK0007','Sprite Regular',      190, 15000.00,'KT0011'),
('PK0008','Orange Juice',         75, 20000.00,'KT0012'),
('PK0009','Es Krim Vanilla',     100, 22000.00,'KT0009'),
('PK0010','Boba Brown Sugar',     60, 28000.00,'KT0010'),
('PK0011','Combo Popcorn+Soda',  150, 40000.00,'KT0006'),
('PK0012','Combo Nachos+Soda',    90, 45000.00,'KT0006'),
('PK0013','Hot Dog Original',     70, 28000.00,'KT0014'),
('PK0014','Pizza Slice BBQ',      55, 30000.00,'KT0015'),
('PK0015','Cokelat Batang',      200, 12000.00,'KT0019'),
('PK0016','Air Mineral 600ml',   300, 8000.00, 'KT0020'),
('PK0017','Kopi Susu Gula Aren', 100, 25000.00,'KT0004'),
('PK0018','Roti Bakar Cokelat',   80, 18000.00,'KT0016'),
('PK0019','Es Krim Cokelat',      90, 22000.00,'KT0009'),
('PK0020','Cheesecake Slice',     40, 35000.00,'KT0005');

-- ---- produk_kantin_transaksi --------------------------------
INSERT INTO produk_kantin_transaksi VALUES
('PK0003','TX0001',1,25000.00),
('PK0006','TX0001',1,15000.00),
('PK0004','TX0002',1,28000.00),
('PK0010','TX0002',1,28000.00),  -- two items on TX0002 (VIP order)
('PK0006','TX0004',2,30000.00),
('PK0011','TX0004',2,80000.00),
('PK0003','TX0005',0, 0.00),     -- ticket only, no canteen (TX0005 = Rp65k tiket only; override below)
('PK0006','TX0006',1,15000.00),
('PK0007','TX0006',2,30000.00),
('PK0001','TX0008',1,35000.00),
('PK0003','TX0008',1,25000.00),  -- stacked with TX0008
('PK0006','TX0009',0, 0.00),     -- ticket only
('PK0011','TX0010',1,40000.00),
('PK0012','TX0012',1,45000.00),
('PK0009','TX0013',1,22000.00),
('PK0014','TX0014',2,60000.00),
('PK0003','TX0014',2,56000.00),  -- adjusted
('PK0017','TX0015',0, 0.00),     -- ticket only
('PK0020','TX0016',1,35000.00),
('PK0011','TX0017',1,40000.00);
-- note: rows with qty=0 model "ticket-only" transactions and can be filtered in queries


-- ============================================================
-- SECTION 3 — Query Cases (5 kasus kontekstual CineTrack)
-- ============================================================

-- ============================================================
-- Kasus 1: Menampilkan Daftar Film Beserta Genre-nya
-- Kebutuhan: Tim promosi membutuhkan daftar film yang sedang
-- tayang (Now Showing) beserta informasi genre-nya untuk
-- keperluan pembuatan materi iklan.
-- Aljabar Relasional:
--   π_judul,status_tayang,nama_genre (
--     σ_status_tayang='Now Showing' (film)
--     ⋈ film_genre
--     ⋈ genre
--   )
-- ============================================================
CREATE VIEW vw_daftar_film AS
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
-- Aljabar Relasional:
--   π_waktu_tayang,judul,kelas_studio,harga_dasar (
--     jadwal_tayang
--     ⋈ jadwal_tayang_film
--     ⋈ film
--     ⋈ studio
--   )
-- ============================================================
CREATE VIEW vw_jadwal_tayang AS
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
-- Aljabar Relasional:
--   π_id_transaksi,nama_pelanggan,total_tagihan,metode (
--     σ_total_tagihan > 200000 (transaksi)
--     ⋈ pelanggan
--     ⋈ pembayaran
--   )
-- ============================================================
CREATE VIEW vw_transaksi_tinggi AS
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
-- Aljabar Relasional:
--   π_nama_kategori, SUM(qty), SUM(subtotal) (
--     produk_kantin_transaksi
--     ⋈ produk_kantin
--     ⋈ kategori
--     GROUP BY nama_kategori
--   )
-- ============================================================
CREATE VIEW vw_rekap_kantin AS
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
-- Aljabar Relasional:
--   π_id_pelanggan, nama_pelanggan (pelanggan)
--   −
--   π_pelanggan_id_pelanggan (transaksi)
-- ============================================================
CREATE VIEW vw_pelanggan_tanpa_transaksi AS
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
-- SECTION 4 — SQL Functions
-- ============================================================
-- Tiga function berikut dibuat berdasarkan kebutuhan operasional
-- bioskop CineTrack. Setiap function bersifat DETERMINISTIC dan
-- hanya membaca data (READS SQL DATA) tanpa memodifikasi tabel.
-- ============================================================


-- ============================================================
-- Function 1: GetTotalTiketByPelanggan
-- Menghitung jumlah tiket yang pernah dibeli oleh seorang
-- pelanggan berdasarkan id_pelanggan yang diberikan.
--
-- Skenario:
--   Tim loyalitas CineTrack ingin mengetahui seberapa sering
--   seorang pelanggan membeli tiket agar dapat menentukan
--   threshold reward program. Dengan memanggil function ini
--   menggunakan id_pelanggan, sistem dapat langsung mengetahui
--   total tiket yang pernah dipesan pelanggan tersebut tanpa
--   harus menulis ulang query JOIN setiap saat.
--
-- Contoh pemanggilan:
--   SELECT GetTotalTiketByPelanggan('PL0001') AS TotalTiket;
--   --> Mengembalikan jumlah tiket yang dibeli oleh PL0001
--
--   SELECT GetTotalTiketByPelanggan('PL0008') AS TotalTiket;
--   --> Mengembalikan jumlah tiket yang dibeli oleh PL0008
-- ============================================================

DELIMITER $$

CREATE FUNCTION GetTotalTiketByPelanggan(p_id_pelanggan CHAR(6))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(tk.id_tiket)
    INTO   v_total
    FROM   tiket     tk
    JOIN   transaksi tx ON tk.transaksi_id_transaksi = tx.id_transaksi
    WHERE  tx.pelanggan_id_pelanggan = p_id_pelanggan;

    RETURN v_total;
END$$

DELIMITER ;

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


-- ============================================================
-- Function 2: GetPendapatanByStudio
-- Menghitung total pendapatan tiket (harga_beli) dari seluruh
-- tiket yang terjual untuk jadwal tayang di studio tertentu,
-- berdasarkan id_studio yang diberikan.
--
-- Skenario:
--   Manajer operasional CineTrack ingin mengevaluasi performa
--   setiap studio untuk keperluan laporan pendapatan harian.
--   Dengan function ini, sistem dapat langsung mengembalikan
--   total pendapatan tiket per studio tanpa perlu melakukan
--   JOIN manual ke jadwal_tayang setiap kali laporan dibutuhkan.
--
-- Contoh pemanggilan:
--   SELECT GetPendapatanByStudio('ST0001') AS TotalPendapatan;
--   --> Mengembalikan total pendapatan tiket untuk Studio ST0001
--
--   SELECT GetPendapatanByStudio('ST0002') AS TotalPendapatan;
--   --> Mengembalikan total pendapatan tiket untuk Studio ST0002
-- ============================================================

DELIMITER $$

CREATE FUNCTION GetPendapatanByStudio(p_id_studio CHAR(6))
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);

    SELECT COALESCE(SUM(tk.harga_beli), 0.00)
    INTO   v_total
    FROM   tiket          tk
    JOIN   jadwal_tayang  jt ON tk.jadwal_tayang_id_jadwal = jt.id_jadwal
    WHERE  jt.studio_id_studio = p_id_studio;

    RETURN v_total;
END$$

DELIMITER ;

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


-- ============================================================
-- Function 3: GetDurasiTayang
-- Menghitung selisih durasi (dalam menit) antara waktu tayang
-- sebuah jadwal dengan durasi film yang ditayangkan, untuk
-- mengetahui sisa jeda antar sesi di studio tersebut.
--
-- Skenario:
--   Tim penjadwalan CineTrack perlu memastikan tidak ada
--   tumpang tindih jadwal antar sesi. Dengan mengetahui
--   durasi film dari tabel film dan waktu tayang dari
--   jadwal_tayang, function ini mengembalikan durasi film
--   (menit) berdasarkan id_jadwal yang diberikan, sehingga
--   tim dapat menghitung kapan sesi berikutnya dapat dimulai.
--   Apabila satu jadwal ditayangkan lebih dari satu film
--   (via jadwal_tayang_film), function mengambil film pertama
--   berdasarkan urutan film_id_film.
--
-- Contoh pemanggilan:
--   SELECT GetDurasiTayang('JD0001') AS DurasiMenit;
--   --> Mengembalikan durasi film yang ditayangkan di JD0001
--
--   SELECT GetDurasiTayang('JD0005') AS DurasiMenit;
--   --> Mengembalikan durasi film yang ditayangkan di JD0005
-- ============================================================

DELIMITER $$

CREATE FUNCTION GetDurasiTayang(p_id_jadwal CHAR(6))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_durasi INT;

    SELECT f.durasi
    INTO   v_durasi
    FROM   jadwal_tayang_film jtf
    JOIN   film               f   ON jtf.film_id_film = f.id_film
    WHERE  jtf.jadwal_tayang_id_jadwal = p_id_jadwal
    ORDER BY jtf.film_id_film
    LIMIT 1;

    RETURN COALESCE(v_durasi, 0);
END$$

DELIMITER ;

-- Contoh pemanggilan (jadwal sesi pagi):
SELECT GetDurasiTayang('JD0001') AS DurasiMenit;

-- Contoh pemanggilan (jadwal studio VIP):
SELECT GetDurasiTayang('JD0005') AS DurasiMenit;

-- Contoh gabungan: menampilkan seluruh jadwal tayang beserta
-- nama film, durasi, dan estimasi jam selesai sesi
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
-- SECTION 5 — SQL Procedure
-- ============================================================

DELIMITER $$

-- ------------------------------------------------------------
-- Kasus 1: Penyesuaian Harga Massal (Inflasi)
-- ------------------------------------------------------------
CREATE PROCEDURE NaikkanHargaInflasi(IN p_persentase DECIMAL(5,2))
BEGIN
    UPDATE jadwal_tayang
    SET harga_dasar = harga_dasar + (harga_dasar * (p_persentase / 100));
    UPDATE produk_kantin
    SET harga_satuan = harga_satuan + (harga_satuan * (p_persentase / 100));
END$$

-- ------------------------------------------------------------
-- Kasus 2: Penambahan Jadwal Tayang Ekstra (Midnight Show)
-- ------------------------------------------------------------
CREATE PROCEDURE TambahJadwalMidnight(
    IN p_tanggal DATE, 
    IN p_harga_dasar DECIMAL(10,2), 
    IN p_id_studio CHAR(6), 
    IN p_id_film CHAR(6)
)
BEGIN
    DECLARE v_last_id CHAR(6);
    DECLARE v_next_id CHAR(6);
    DECLARE v_next_num INT;
    DECLARE v_waktu_tayang DATETIME;


    SELECT id_jadwal INTO v_last_id FROM jadwal_tayang ORDER BY id_jadwal DESC LIMIT 1;
    
    IF v_last_id IS NULL THEN
        SET v_next_id = 'JD0001';
    ELSE
        SET v_next_num = CAST(SUBSTRING(v_last_id, 3, 4) AS UNSIGNED) + 1;
        SET v_next_id = CONCAT('JD', LPAD(v_next_num, 4, '0'));
    END IF;

   
    SET v_waktu_tayang = CONCAT(p_tanggal, ' 23:30:00');


    INSERT INTO jadwal_tayang (id_jadwal, waktu_tayang, harga_dasar, studio_id_studio)
    VALUES (v_next_id, v_waktu_tayang, p_harga_dasar, p_id_studio);

    INSERT INTO jadwal_tayang_film (jadwal_tayang_id_jadwal, film_id_film)
    VALUES (v_next_id, p_id_film);
    
    SELECT v_next_id AS id_jadwal_midnight_baru;
END$$

-- Test

CALL TambahJadwalMidnight('2026-06-15', 75000.00, 'ST0001', 'FM0001');
SELECT * FROM jadwal_tayang ORDER BY id_jadwal DESC LIMIT 1;
SELECT * FROM jadwal_tayang_film ORDER BY jadwal_tayang_id_jadwal DESC LIMIT 1;

-- ------------------------------------------------------------
-- Kasus 3: Restock Barang Kantin Terjadwal
-- ------------------------------------------------------------
CREATE PROCEDURE TambahStokKantin(IN p_id_produk CHAR(6), IN p_jumlah_tambah INT)
BEGIN
	UPDATE produk_kantin
    SET stok = stok + p_jumlah_tambah
    WHERE id_produk = p_id_produk;
END$$

DELIMITER ;

-- Test
SELECT id_produk, nama_produk, stok FROM produk_kantin WHERE id_produk = 'PK0002';

CALL TambahStokKantin('PK0002', 20);

-- ============================================================
-- SECTION 6 — SQL Trigger
-- ============================================================

DELIMITER $$

-- ------------------------------------------------------------
-- Kasus 1: Pencegahan Double-Booking Kursi 
-- Waktu: BEFORE INSERT pada tabel tiket
-- ------------------------------------------------------------
CREATE TRIGGER trg_cegah_double_booking
BEFORE INSERT ON tiket
FOR EACH ROW
BEGIN
    DECLARE v_kursi_terisi INT;

    SELECT COUNT(*) INTO v_kursi_terisi
    FROM tiket
    WHERE jadwal_tayang_id_jadwal = NEW.jadwal_tayang_id_jadwal
      AND kursi_id_kursi = NEW.kursi_id_kursi;

    IF v_kursi_terisi > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gagal: Kursi sudah dipesan untuk jadwal ini!';
    END IF;
END$$

-- Test

-- INSERT INTO tiket (id_tiket, harga_beli, jadwal_tayang_id_jadwal, transaksi_id_transaksi, kursi_id_kursi) 
-- VALUES ('TK0021', 0, 'JD0001', 'TX0001', 'KR0002');

-- SELECT * FROM tiket WHERE id_tiket = 'TK0021';

-- INSERT INTO tiket (id_tiket, harga_beli, jadwal_tayang_id_jadwal, transaksi_id_transaksi, kursi_id_kursi) 
-- VALUES ('TK0022', 0, 'JD0001', 'TX0001', 'KR0002');

-- ------------------------------------------------------------
-- Kasus 2: Auto-Kalkulasi Harga Beli Tiket
-- Waktu: BEFORE INSERT pada tabel tiket (FOLLOWS Kasus 3)
-- ------------------------------------------------------------
CREATE TRIGGER trg_kalkulasi_harga_tiket
BEFORE INSERT ON tiket
FOR EACH ROW
FOLLOWS trg_cegah_double_booking
BEGIN
    DECLARE v_harga_dasar DECIMAL(10,2);
    DECLARE v_tarif_tipe DECIMAL(10,2);

    SELECT harga_dasar INTO v_harga_dasar
    FROM jadwal_tayang
    WHERE id_jadwal = NEW.jadwal_tayang_id_jadwal;

    
    SELECT tarif_tipe INTO v_tarif_tipe
    FROM kursi
    WHERE id_kursi = NEW.kursi_id_kursi;

    
    SET NEW.harga_beli = v_harga_dasar + v_tarif_tipe;
END$$



-- ------------------------------------------------------------
-- Kasus 3: Pengurangan Stok Kantin Otomatis
-- Waktu: AFTER INSERT pada tabel produk_kantin_transaksi
-- ------------------------------------------------------------
CREATE TRIGGER trg_kurangi_stok_kantin
AFTER INSERT ON produk_kantin_transaksi
FOR EACH ROW
BEGIN
    
    UPDATE produk_kantin
    SET stok = stok - NEW.qty
    WHERE id_produk = NEW.produk_kantin_id_produk;
END$$

DELIMITER ;

-- Test
SELECT id_produk, nama_produk, stok FROM produk_kantin WHERE id_produk = 'PK0007';

INSERT INTO produk_kantin_transaksi (produk_kantin_id_produk, transaksi_id_transaksi, qty, subtotal)
VALUES ('PK0007', 'TX0002', 5, 75000.00);

SELECT id_produk, nama_produk, stok FROM produk_kantin WHERE id_produk = 'PK0007';

-- ============================================================
--  MBD_FP — Implementasi Indexing Basis Data CineTrack
--  Departemen Informatika, ITS Surabaya
--  Kelompok: Maleka Ghaniya · Jorell Ramos Sinaga · Angela Vania Sugiyono
-- ============================================================
--
--  5 index dipilih berdasarkan frekuensi pemakaian kolom pada:
--    Query Cases, SQL Functions, Stored Procedures, dan Triggers.
--
--  Catatan: MySQL InnoDB otomatis membuat index pada PRIMARY KEY
--  dan kolom FOREIGN KEY (terbukti dari EXPLAIN sebelum indexing:
--  fk_trx_pelanggan dan fk_tiket_transaksi sudah dipakai otomatis).
--  Index di bawah menargetkan kolom non-PK / non-FK / non-leading
--  composite PK yang belum memiliki index otomatis.
-- ============================================================

USE MBD_FP;


-- ============================================================
-- INDEX 1: film(status_tayang)
-- ============================================================
-- Digunakan oleh:
--   • Query Kasus 1 → WHERE status_tayang = 'Now Showing'
--
-- Tanpa index : MySQL full scan seluruh tabel film.
-- Dengan index: BTREE lookup langsung ke baris yang cocok O(log n).
--
-- Jenis: BTREE — cocok untuk equality filter pada kolom
--        dengan kardinalitas rendah (3 nilai unik).
-- ============================================================

CREATE INDEX idx_film_status_tayang
    ON film (status_tayang);

-- Verifikasi EXPLAIN sebelum & sesudah:
EXPLAIN
SELECT f.judul, f.status_tayang, g.nama_genre
FROM film f
JOIN film_genre fg ON f.id_film         = fg.film_id_film
JOIN genre      g  ON fg.genre_id_genre = g.id_genre
WHERE f.status_tayang = 'Now Showing'
ORDER BY f.judul, g.nama_genre;


-- ============================================================
-- INDEX 2: jadwal_tayang_film(film_id_film)
-- ============================================================
-- Digunakan oleh:
--   • Function GetDurasiTayang
--       → JOIN film ON jtf.film_id_film = f.id_film
--         WHERE jtf.jadwal_tayang_id_jadwal = p_id_jadwal
--   • Query Kasus 2
--       → JOIN jadwal_tayang_film ON film_id_film = f.id_film
--
-- PRIMARY KEY tabel ini adalah composite (jadwal_tayang_id_jadwal,
-- film_id_film). Index BTREE pada PK composite hanya efisien untuk
-- lookup yang dimulai dari kolom PERTAMA (jadwal). Kolom KEDUA
-- (film_id_film) tidak ter-cover sebagai leading key, sehingga
-- reverse lookup "jadwal mana yang memutar film X" tetap
-- melakukan full scan tanpa index tambahan ini.
--
-- Berbeda dengan FK biasa yang di-auto-index MySQL, kolom
-- non-leading pada composite PK tidak mendapat index otomatis.
--
-- Jenis: BTREE — untuk equi-join lookup arah film → jadwal.
-- ============================================================

CREATE INDEX idx_jtf_film
    ON jadwal_tayang_film (film_id_film);

-- Verifikasi EXPLAIN (Function GetDurasiTayang — query gabungan):
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


-- ============================================================
-- INDEX 3: transaksi(total_tagihan)
-- ============================================================
-- Digunakan oleh:
--   • Query Kasus 3 → WHERE total_tagihan > 200000
--
-- Kolom DECIMAL non-PK tanpa index apapun. Index BTREE pada
-- kolom numerik sangat efisien untuk range query karena data
-- tersimpan terurut di struktur B-Tree, sehingga MySQL dapat
-- langsung melompat ke nilai threshold tanpa scan seluruh tabel.
--
-- Jenis: BTREE — optimal untuk range query (>, <, BETWEEN).
-- ============================================================

CREATE INDEX idx_transaksi_total_tagihan
    ON transaksi (total_tagihan);

-- Verifikasi EXPLAIN:
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


-- ============================================================
-- INDEX 4: tiket(jadwal_tayang_id_jadwal, kursi_id_kursi)
-- ============================================================
-- Digunakan oleh:
--   • Trigger trg_cegah_double_booking — BEFORE INSERT tiket
--       → WHERE jadwal_tayang_id_jadwal = NEW.jadwal_tayang_id_jadwal
--           AND kursi_id_kursi          = NEW.kursi_id_kursi
--
-- Ini adalah COMPOSITE INDEX. Trigger ini dieksekusi pada SETIAP
-- pembelian tiket, menjadikannya komponen paling kritis dari sisi
-- frekuensi. Composite index pada kedua kolom lebih efisien
-- daripada dua index terpisah — MySQL cukup satu traversal BTREE
-- untuk memverifikasi kombinasi jadwal + kursi sekaligus.
--
-- Urutan kolom: jadwal dahulu (selektivitas lebih tinggi),
-- kursi kedua — sesuai urutan klausa WHERE pada trigger.
--
-- Jenis: BTREE composite.
-- ============================================================

CREATE INDEX idx_tiket_jadwal_kursi
    ON tiket (jadwal_tayang_id_jadwal, kursi_id_kursi);

-- Verifikasi EXPLAIN (simulasi logika trigger):
EXPLAIN
SELECT COUNT(*) AS kursi_terisi
FROM tiket
WHERE jadwal_tayang_id_jadwal = 'JD0001'
  AND kursi_id_kursi          = 'KR0001';


-- ============================================================
-- INDEX 5: jadwal_tayang(waktu_tayang)
-- ============================================================
-- Digunakan oleh:
--   • Query Kasus 2       → ORDER BY waktu_tayang
--   • Function GetDurasiTayang (query gabungan) → ORDER BY waktu_tayang
--   • Procedure TambahJadwalMidnight
--       → ORDER BY id_jadwal DESC (akses urutan jadwal terbaru)
--
-- Kolom DATETIME non-PK. Tanpa index, setiap ORDER BY memaksa
-- MySQL melakukan filesort (pengurutan di memori/disk setelah
-- full scan). Index BTREE menyimpan DATETIME secara terurut
-- sehingga ORDER BY dapat memanfaatkan index scan langsung
-- tanpa filesort — kolom ini diakses oleh 3 komponen berbeda.
--
-- Jenis: BTREE — optimal untuk ORDER BY dan range filter DATETIME.
-- ============================================================

CREATE INDEX idx_jadwal_waktu_tayang
    ON jadwal_tayang (waktu_tayang);

-- Verifikasi EXPLAIN (Query Kasus 2):
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


-- ============================================================
-- VERIFIKASI SEMUA INDEX YANG DIBUAT
-- ============================================================

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

DROP INDEX idx_tiket_jadwal_kursi    ON tiket;
-- ============================================================
-- END OF indexing_cinetrack.sql
-- ============================================================