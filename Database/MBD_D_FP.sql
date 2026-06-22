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
    poster_url      VARCHAR(512)  DEFAULT NULL,
    rating_score    DECIMAL(3,1)  DEFAULT 0.0,
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
    password        VARCHAR(255)  NOT NULL DEFAULT 'admin123',
    jabatan         VARCHAR(50)   NOT NULL DEFAULT 'Staff',
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
    status_transaksi        VARCHAR(20)   NOT NULL DEFAULT 'Active',
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
    image_url           VARCHAR(512)  DEFAULT NULL,
    deskripsi           VARCHAR(255)  DEFAULT NULL,
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
('ST0002',2,'Regular','CB0001'),
('ST0003',3,'IMAX','CB0001'),
('ST0004',1,'Regular','CB0002'),
('ST0005',2,'Regular','CB0002'),
('ST0006',1,'Regular','CB0003'),
('ST0007',2,'Regular','CB0003'),
('ST0008',1,'Regular','CB0004'),
('ST0009',1,'IMAX','CB0005'),
('ST0010',2,'Regular','CB0005'),
('ST0011',1,'Regular','CB0006'),
('ST0012',1,'Regular','CB0007'),
('ST0013',1,'Regular','CB0008'),
('ST0014',1,'Regular','CB0009'),
('ST0015',1,'Regular','CB0010'),
('ST0016',3,'Regular','CB0001'),
('ST0017',4,'Regular','CB0001'),
('ST0018',3,'Regular','CB0002'),
('ST0019',2,'Regular','CB0003'),
('ST0020',2,'IMAX','CB0005'),
('ST0021',2,'IMAX','CB0004'),
('ST0022',3,'IMAX','CB0004'),
('ST0023',4,'Regular','CB0004'),
('ST0024',5,'Regular','CB0004');

-- ---- kursi ------------------------------------------------
INSERT INTO kursi VALUES
('KR0001','A1','A','1','Reguler',45000.00,'ST0001'),
('KR0002','A2','A','2','Reguler',45000.00,'ST0001'),
('KR0003','A3','A','3','Reguler',45000.00,'ST0001'),
('KR0004','A4','A','4','Reguler',45000.00,'ST0001'),
('KR0005','A5','A','5','Reguler',45000.00,'ST0001'),
('KR0006','A6','A','6','Reguler',45000.00,'ST0001'),
('KR0007','A7','A','7','Reguler',45000.00,'ST0001'),
('KR0008','A8','A','8','Reguler',45000.00,'ST0001'),
('KR0009','A9','A','9','Reguler',45000.00,'ST0001'),
('KR0010','A10','A','10','Reguler',45000.00,'ST0001'),
('KR0011','B1','B','1','Reguler',45000.00,'ST0001'),
('KR0012','B2','B','2','Reguler',45000.00,'ST0001'),
('KR0013','B3','B','3','Reguler',45000.00,'ST0001'),
('KR0014','B4','B','4','Reguler',45000.00,'ST0001'),
('KR0015','B5','B','5','Reguler',45000.00,'ST0001'),
('KR0016','B6','B','6','Reguler',45000.00,'ST0001'),
('KR0017','B7','B','7','Reguler',45000.00,'ST0001'),
('KR0018','B8','B','8','Reguler',45000.00,'ST0001'),
('KR0019','B9','B','9','Reguler',45000.00,'ST0001'),
('KR0020','B10','B','10','Reguler',45000.00,'ST0001'),
('KR0021','C1','C','1','Premium',65000.00,'ST0001'),
('KR0022','C2','C','2','Premium',65000.00,'ST0001'),
('KR0023','C3','C','3','Premium',65000.00,'ST0001'),
('KR0024','C4','C','4','Premium',65000.00,'ST0001'),
('KR0025','C5','C','5','Premium',65000.00,'ST0001'),
('KR0026','C6','C','6','Premium',65000.00,'ST0001'),
('KR0027','C7','C','7','Premium',65000.00,'ST0001'),
('KR0028','C8','C','8','Premium',65000.00,'ST0001'),
('KR0029','C9','C','9','Premium',65000.00,'ST0001'),
('KR0030','C10','C','10','Premium',65000.00,'ST0001'),
('KR0031','D1','D','1','Premium',65000.00,'ST0001'),
('KR0032','D2','D','2','Premium',65000.00,'ST0001'),
('KR0033','D3','D','3','Premium',65000.00,'ST0001'),
('KR0034','D4','D','4','Premium',65000.00,'ST0001'),
('KR0035','D5','D','5','Premium',65000.00,'ST0001'),
('KR0036','D6','D','6','Premium',65000.00,'ST0001'),
('KR0037','D7','D','7','Premium',65000.00,'ST0001'),
('KR0038','D8','D','8','Premium',65000.00,'ST0001'),
('KR0039','D9','D','9','Premium',65000.00,'ST0001'),
('KR0040','D10','D','10','Premium',65000.00,'ST0001'),
('KR0041','E1','E','1','VIP',85000.00,'ST0001'),
('KR0042','E2','E','2','VIP',85000.00,'ST0001'),
('KR0043','E3','E','3','VIP',85000.00,'ST0001'),
('KR0044','E4','E','4','VIP',85000.00,'ST0001'),
('KR0045','E5','E','5','VIP',85000.00,'ST0001'),
('KR0046','E6','E','6','VIP',85000.00,'ST0001'),
('KR0047','E7','E','7','VIP',85000.00,'ST0001'),
('KR0048','E8','E','8','VIP',85000.00,'ST0001'),
('KR0049','E9','E','9','VIP',85000.00,'ST0001'),
('KR0050','E10','E','10','VIP',85000.00,'ST0001'),
('KR0051','A1','A','1','Reguler',45000.00,'ST0002'),
('KR0052','A2','A','2','Reguler',45000.00,'ST0002'),
('KR0053','A3','A','3','Reguler',45000.00,'ST0002'),
('KR0054','A4','A','4','Reguler',45000.00,'ST0002'),
('KR0055','A5','A','5','Reguler',45000.00,'ST0002'),
('KR0056','A6','A','6','Reguler',45000.00,'ST0002'),
('KR0057','A7','A','7','Reguler',45000.00,'ST0002'),
('KR0058','A8','A','8','Reguler',45000.00,'ST0002'),
('KR0059','A9','A','9','Reguler',45000.00,'ST0002'),
('KR0060','A10','A','10','Reguler',45000.00,'ST0002'),
('KR0061','B1','B','1','Reguler',45000.00,'ST0002'),
('KR0062','B2','B','2','Reguler',45000.00,'ST0002'),
('KR0063','B3','B','3','Reguler',45000.00,'ST0002'),
('KR0064','B4','B','4','Reguler',45000.00,'ST0002'),
('KR0065','B5','B','5','Reguler',45000.00,'ST0002'),
('KR0066','B6','B','6','Reguler',45000.00,'ST0002'),
('KR0067','B7','B','7','Reguler',45000.00,'ST0002'),
('KR0068','B8','B','8','Reguler',45000.00,'ST0002'),
('KR0069','B9','B','9','Reguler',45000.00,'ST0002'),
('KR0070','B10','B','10','Reguler',45000.00,'ST0002'),
('KR0071','C1','C','1','Premium',65000.00,'ST0002'),
('KR0072','C2','C','2','Premium',65000.00,'ST0002'),
('KR0073','C3','C','3','Premium',65000.00,'ST0002'),
('KR0074','C4','C','4','Premium',65000.00,'ST0002'),
('KR0075','C5','C','5','Premium',65000.00,'ST0002'),
('KR0076','C6','C','6','Premium',65000.00,'ST0002'),
('KR0077','C7','C','7','Premium',65000.00,'ST0002'),
('KR0078','C8','C','8','Premium',65000.00,'ST0002'),
('KR0079','C9','C','9','Premium',65000.00,'ST0002'),
('KR0080','C10','C','10','Premium',65000.00,'ST0002'),
('KR0081','D1','D','1','Premium',65000.00,'ST0002'),
('KR0082','D2','D','2','Premium',65000.00,'ST0002'),
('KR0083','D3','D','3','Premium',65000.00,'ST0002'),
('KR0084','D4','D','4','Premium',65000.00,'ST0002'),
('KR0085','D5','D','5','Premium',65000.00,'ST0002'),
('KR0086','D6','D','6','Premium',65000.00,'ST0002'),
('KR0087','D7','D','7','Premium',65000.00,'ST0002'),
('KR0088','D8','D','8','Premium',65000.00,'ST0002'),
('KR0089','D9','D','9','Premium',65000.00,'ST0002'),
('KR0090','D10','D','10','Premium',65000.00,'ST0002'),
('KR0091','E1','E','1','VIP',85000.00,'ST0002'),
('KR0092','E2','E','2','VIP',85000.00,'ST0002'),
('KR0093','E3','E','3','VIP',85000.00,'ST0002'),
('KR0094','E4','E','4','VIP',85000.00,'ST0002'),
('KR0095','E5','E','5','VIP',85000.00,'ST0002'),
('KR0096','E6','E','6','VIP',85000.00,'ST0002'),
('KR0097','E7','E','7','VIP',85000.00,'ST0002'),
('KR0098','E8','E','8','VIP',85000.00,'ST0002'),
('KR0099','E9','E','9','VIP',85000.00,'ST0002'),
('KR0100','E10','E','10','VIP',85000.00,'ST0002'),
('KR0101','A1','A','1','Reguler',45000.00,'ST0003'),
('KR0102','A2','A','2','Reguler',45000.00,'ST0003'),
('KR0103','A3','A','3','Reguler',45000.00,'ST0003'),
('KR0104','A4','A','4','Reguler',45000.00,'ST0003'),
('KR0105','A5','A','5','Reguler',45000.00,'ST0003'),
('KR0106','A6','A','6','Reguler',45000.00,'ST0003'),
('KR0107','A7','A','7','Reguler',45000.00,'ST0003'),
('KR0108','A8','A','8','Reguler',45000.00,'ST0003'),
('KR0109','A9','A','9','Reguler',45000.00,'ST0003'),
('KR0110','A10','A','10','Reguler',45000.00,'ST0003'),
('KR0111','B1','B','1','Reguler',45000.00,'ST0003'),
('KR0112','B2','B','2','Reguler',45000.00,'ST0003'),
('KR0113','B3','B','3','Reguler',45000.00,'ST0003'),
('KR0114','B4','B','4','Reguler',45000.00,'ST0003'),
('KR0115','B5','B','5','Reguler',45000.00,'ST0003'),
('KR0116','B6','B','6','Reguler',45000.00,'ST0003'),
('KR0117','B7','B','7','Reguler',45000.00,'ST0003'),
('KR0118','B8','B','8','Reguler',45000.00,'ST0003'),
('KR0119','B9','B','9','Reguler',45000.00,'ST0003'),
('KR0120','B10','B','10','Reguler',45000.00,'ST0003'),
('KR0121','C1','C','1','Premium',65000.00,'ST0003'),
('KR0122','C2','C','2','Premium',65000.00,'ST0003'),
('KR0123','C3','C','3','Premium',65000.00,'ST0003'),
('KR0124','C4','C','4','Premium',65000.00,'ST0003'),
('KR0125','C5','C','5','Premium',65000.00,'ST0003'),
('KR0126','C6','C','6','Premium',65000.00,'ST0003'),
('KR0127','C7','C','7','Premium',65000.00,'ST0003'),
('KR0128','C8','C','8','Premium',65000.00,'ST0003'),
('KR0129','C9','C','9','Premium',65000.00,'ST0003'),
('KR0130','C10','C','10','Premium',65000.00,'ST0003'),
('KR0131','D1','D','1','Premium',65000.00,'ST0003'),
('KR0132','D2','D','2','Premium',65000.00,'ST0003'),
('KR0133','D3','D','3','Premium',65000.00,'ST0003'),
('KR0134','D4','D','4','Premium',65000.00,'ST0003'),
('KR0135','D5','D','5','Premium',65000.00,'ST0003'),
('KR0136','D6','D','6','Premium',65000.00,'ST0003'),
('KR0137','D7','D','7','Premium',65000.00,'ST0003'),
('KR0138','D8','D','8','Premium',65000.00,'ST0003'),
('KR0139','D9','D','9','Premium',65000.00,'ST0003'),
('KR0140','D10','D','10','Premium',65000.00,'ST0003'),
('KR0141','E1','E','1','VIP',85000.00,'ST0003'),
('KR0142','E2','E','2','VIP',85000.00,'ST0003'),
('KR0143','E3','E','3','VIP',85000.00,'ST0003'),
('KR0144','E4','E','4','VIP',85000.00,'ST0003'),
('KR0145','E5','E','5','VIP',85000.00,'ST0003'),
('KR0146','E6','E','6','VIP',85000.00,'ST0003'),
('KR0147','E7','E','7','VIP',85000.00,'ST0003'),
('KR0148','E8','E','8','VIP',85000.00,'ST0003'),
('KR0149','E9','E','9','VIP',85000.00,'ST0003'),
('KR0150','E10','E','10','VIP',85000.00,'ST0003'),
('KR0151','A1','A','1','Reguler',45000.00,'ST0004'),
('KR0152','A2','A','2','Reguler',45000.00,'ST0004'),
('KR0153','A3','A','3','Reguler',45000.00,'ST0004'),
('KR0154','A4','A','4','Reguler',45000.00,'ST0004'),
('KR0155','A5','A','5','Reguler',45000.00,'ST0004'),
('KR0156','A6','A','6','Reguler',45000.00,'ST0004'),
('KR0157','A7','A','7','Reguler',45000.00,'ST0004'),
('KR0158','A8','A','8','Reguler',45000.00,'ST0004'),
('KR0159','A9','A','9','Reguler',45000.00,'ST0004'),
('KR0160','A10','A','10','Reguler',45000.00,'ST0004'),
('KR0161','B1','B','1','Reguler',45000.00,'ST0004'),
('KR0162','B2','B','2','Reguler',45000.00,'ST0004'),
('KR0163','B3','B','3','Reguler',45000.00,'ST0004'),
('KR0164','B4','B','4','Reguler',45000.00,'ST0004'),
('KR0165','B5','B','5','Reguler',45000.00,'ST0004'),
('KR0166','B6','B','6','Reguler',45000.00,'ST0004'),
('KR0167','B7','B','7','Reguler',45000.00,'ST0004'),
('KR0168','B8','B','8','Reguler',45000.00,'ST0004'),
('KR0169','B9','B','9','Reguler',45000.00,'ST0004'),
('KR0170','B10','B','10','Reguler',45000.00,'ST0004'),
('KR0171','C1','C','1','Premium',65000.00,'ST0004'),
('KR0172','C2','C','2','Premium',65000.00,'ST0004'),
('KR0173','C3','C','3','Premium',65000.00,'ST0004'),
('KR0174','C4','C','4','Premium',65000.00,'ST0004'),
('KR0175','C5','C','5','Premium',65000.00,'ST0004'),
('KR0176','C6','C','6','Premium',65000.00,'ST0004'),
('KR0177','C7','C','7','Premium',65000.00,'ST0004'),
('KR0178','C8','C','8','Premium',65000.00,'ST0004'),
('KR0179','C9','C','9','Premium',65000.00,'ST0004'),
('KR0180','C10','C','10','Premium',65000.00,'ST0004'),
('KR0181','D1','D','1','Premium',65000.00,'ST0004'),
('KR0182','D2','D','2','Premium',65000.00,'ST0004'),
('KR0183','D3','D','3','Premium',65000.00,'ST0004'),
('KR0184','D4','D','4','Premium',65000.00,'ST0004'),
('KR0185','D5','D','5','Premium',65000.00,'ST0004'),
('KR0186','D6','D','6','Premium',65000.00,'ST0004'),
('KR0187','D7','D','7','Premium',65000.00,'ST0004'),
('KR0188','D8','D','8','Premium',65000.00,'ST0004'),
('KR0189','D9','D','9','Premium',65000.00,'ST0004'),
('KR0190','D10','D','10','Premium',65000.00,'ST0004'),
('KR0191','E1','E','1','VIP',85000.00,'ST0004'),
('KR0192','E2','E','2','VIP',85000.00,'ST0004'),
('KR0193','E3','E','3','VIP',85000.00,'ST0004'),
('KR0194','E4','E','4','VIP',85000.00,'ST0004'),
('KR0195','E5','E','5','VIP',85000.00,'ST0004'),
('KR0196','E6','E','6','VIP',85000.00,'ST0004'),
('KR0197','E7','E','7','VIP',85000.00,'ST0004'),
('KR0198','E8','E','8','VIP',85000.00,'ST0004'),
('KR0199','E9','E','9','VIP',85000.00,'ST0004'),
('KR0200','E10','E','10','VIP',85000.00,'ST0004'),
('KR0201','A1','A','1','Reguler',45000.00,'ST0005'),
('KR0202','A2','A','2','Reguler',45000.00,'ST0005'),
('KR0203','A3','A','3','Reguler',45000.00,'ST0005'),
('KR0204','A4','A','4','Reguler',45000.00,'ST0005'),
('KR0205','A5','A','5','Reguler',45000.00,'ST0005'),
('KR0206','A6','A','6','Reguler',45000.00,'ST0005'),
('KR0207','A7','A','7','Reguler',45000.00,'ST0005'),
('KR0208','A8','A','8','Reguler',45000.00,'ST0005'),
('KR0209','A9','A','9','Reguler',45000.00,'ST0005'),
('KR0210','A10','A','10','Reguler',45000.00,'ST0005'),
('KR0211','B1','B','1','Reguler',45000.00,'ST0005'),
('KR0212','B2','B','2','Reguler',45000.00,'ST0005'),
('KR0213','B3','B','3','Reguler',45000.00,'ST0005'),
('KR0214','B4','B','4','Reguler',45000.00,'ST0005'),
('KR0215','B5','B','5','Reguler',45000.00,'ST0005'),
('KR0216','B6','B','6','Reguler',45000.00,'ST0005'),
('KR0217','B7','B','7','Reguler',45000.00,'ST0005'),
('KR0218','B8','B','8','Reguler',45000.00,'ST0005'),
('KR0219','B9','B','9','Reguler',45000.00,'ST0005'),
('KR0220','B10','B','10','Reguler',45000.00,'ST0005'),
('KR0221','C1','C','1','Premium',65000.00,'ST0005'),
('KR0222','C2','C','2','Premium',65000.00,'ST0005'),
('KR0223','C3','C','3','Premium',65000.00,'ST0005'),
('KR0224','C4','C','4','Premium',65000.00,'ST0005'),
('KR0225','C5','C','5','Premium',65000.00,'ST0005'),
('KR0226','C6','C','6','Premium',65000.00,'ST0005'),
('KR0227','C7','C','7','Premium',65000.00,'ST0005'),
('KR0228','C8','C','8','Premium',65000.00,'ST0005'),
('KR0229','C9','C','9','Premium',65000.00,'ST0005'),
('KR0230','C10','C','10','Premium',65000.00,'ST0005'),
('KR0231','D1','D','1','Premium',65000.00,'ST0005'),
('KR0232','D2','D','2','Premium',65000.00,'ST0005'),
('KR0233','D3','D','3','Premium',65000.00,'ST0005'),
('KR0234','D4','D','4','Premium',65000.00,'ST0005'),
('KR0235','D5','D','5','Premium',65000.00,'ST0005'),
('KR0236','D6','D','6','Premium',65000.00,'ST0005'),
('KR0237','D7','D','7','Premium',65000.00,'ST0005'),
('KR0238','D8','D','8','Premium',65000.00,'ST0005'),
('KR0239','D9','D','9','Premium',65000.00,'ST0005'),
('KR0240','D10','D','10','Premium',65000.00,'ST0005'),
('KR0241','E1','E','1','VIP',85000.00,'ST0005'),
('KR0242','E2','E','2','VIP',85000.00,'ST0005'),
('KR0243','E3','E','3','VIP',85000.00,'ST0005'),
('KR0244','E4','E','4','VIP',85000.00,'ST0005'),
('KR0245','E5','E','5','VIP',85000.00,'ST0005'),
('KR0246','E6','E','6','VIP',85000.00,'ST0005'),
('KR0247','E7','E','7','VIP',85000.00,'ST0005'),
('KR0248','E8','E','8','VIP',85000.00,'ST0005'),
('KR0249','E9','E','9','VIP',85000.00,'ST0005'),
('KR0250','E10','E','10','VIP',85000.00,'ST0005'),
('KR0251','A1','A','1','Reguler',45000.00,'ST0006'),
('KR0252','A2','A','2','Reguler',45000.00,'ST0006'),
('KR0253','A3','A','3','Reguler',45000.00,'ST0006'),
('KR0254','A4','A','4','Reguler',45000.00,'ST0006'),
('KR0255','A5','A','5','Reguler',45000.00,'ST0006'),
('KR0256','A6','A','6','Reguler',45000.00,'ST0006'),
('KR0257','A7','A','7','Reguler',45000.00,'ST0006'),
('KR0258','A8','A','8','Reguler',45000.00,'ST0006'),
('KR0259','A9','A','9','Reguler',45000.00,'ST0006'),
('KR0260','A10','A','10','Reguler',45000.00,'ST0006'),
('KR0261','B1','B','1','Reguler',45000.00,'ST0006'),
('KR0262','B2','B','2','Reguler',45000.00,'ST0006'),
('KR0263','B3','B','3','Reguler',45000.00,'ST0006'),
('KR0264','B4','B','4','Reguler',45000.00,'ST0006'),
('KR0265','B5','B','5','Reguler',45000.00,'ST0006'),
('KR0266','B6','B','6','Reguler',45000.00,'ST0006'),
('KR0267','B7','B','7','Reguler',45000.00,'ST0006'),
('KR0268','B8','B','8','Reguler',45000.00,'ST0006'),
('KR0269','B9','B','9','Reguler',45000.00,'ST0006'),
('KR0270','B10','B','10','Reguler',45000.00,'ST0006'),
('KR0271','C1','C','1','Premium',65000.00,'ST0006'),
('KR0272','C2','C','2','Premium',65000.00,'ST0006'),
('KR0273','C3','C','3','Premium',65000.00,'ST0006'),
('KR0274','C4','C','4','Premium',65000.00,'ST0006'),
('KR0275','C5','C','5','Premium',65000.00,'ST0006'),
('KR0276','C6','C','6','Premium',65000.00,'ST0006'),
('KR0277','C7','C','7','Premium',65000.00,'ST0006'),
('KR0278','C8','C','8','Premium',65000.00,'ST0006'),
('KR0279','C9','C','9','Premium',65000.00,'ST0006'),
('KR0280','C10','C','10','Premium',65000.00,'ST0006'),
('KR0281','D1','D','1','Premium',65000.00,'ST0006'),
('KR0282','D2','D','2','Premium',65000.00,'ST0006'),
('KR0283','D3','D','3','Premium',65000.00,'ST0006'),
('KR0284','D4','D','4','Premium',65000.00,'ST0006'),
('KR0285','D5','D','5','Premium',65000.00,'ST0006'),
('KR0286','D6','D','6','Premium',65000.00,'ST0006'),
('KR0287','D7','D','7','Premium',65000.00,'ST0006'),
('KR0288','D8','D','8','Premium',65000.00,'ST0006'),
('KR0289','D9','D','9','Premium',65000.00,'ST0006'),
('KR0290','D10','D','10','Premium',65000.00,'ST0006'),
('KR0291','E1','E','1','VIP',85000.00,'ST0006'),
('KR0292','E2','E','2','VIP',85000.00,'ST0006'),
('KR0293','E3','E','3','VIP',85000.00,'ST0006'),
('KR0294','E4','E','4','VIP',85000.00,'ST0006'),
('KR0295','E5','E','5','VIP',85000.00,'ST0006'),
('KR0296','E6','E','6','VIP',85000.00,'ST0006'),
('KR0297','E7','E','7','VIP',85000.00,'ST0006'),
('KR0298','E8','E','8','VIP',85000.00,'ST0006'),
('KR0299','E9','E','9','VIP',85000.00,'ST0006'),
('KR0300','E10','E','10','VIP',85000.00,'ST0006'),
('KR0301','A1','A','1','Reguler',45000.00,'ST0007'),
('KR0302','A2','A','2','Reguler',45000.00,'ST0007'),
('KR0303','A3','A','3','Reguler',45000.00,'ST0007'),
('KR0304','A4','A','4','Reguler',45000.00,'ST0007'),
('KR0305','A5','A','5','Reguler',45000.00,'ST0007'),
('KR0306','A6','A','6','Reguler',45000.00,'ST0007'),
('KR0307','A7','A','7','Reguler',45000.00,'ST0007'),
('KR0308','A8','A','8','Reguler',45000.00,'ST0007'),
('KR0309','A9','A','9','Reguler',45000.00,'ST0007'),
('KR0310','A10','A','10','Reguler',45000.00,'ST0007'),
('KR0311','B1','B','1','Reguler',45000.00,'ST0007'),
('KR0312','B2','B','2','Reguler',45000.00,'ST0007'),
('KR0313','B3','B','3','Reguler',45000.00,'ST0007'),
('KR0314','B4','B','4','Reguler',45000.00,'ST0007'),
('KR0315','B5','B','5','Reguler',45000.00,'ST0007'),
('KR0316','B6','B','6','Reguler',45000.00,'ST0007'),
('KR0317','B7','B','7','Reguler',45000.00,'ST0007'),
('KR0318','B8','B','8','Reguler',45000.00,'ST0007'),
('KR0319','B9','B','9','Reguler',45000.00,'ST0007'),
('KR0320','B10','B','10','Reguler',45000.00,'ST0007'),
('KR0321','C1','C','1','Premium',65000.00,'ST0007'),
('KR0322','C2','C','2','Premium',65000.00,'ST0007'),
('KR0323','C3','C','3','Premium',65000.00,'ST0007'),
('KR0324','C4','C','4','Premium',65000.00,'ST0007'),
('KR0325','C5','C','5','Premium',65000.00,'ST0007'),
('KR0326','C6','C','6','Premium',65000.00,'ST0007'),
('KR0327','C7','C','7','Premium',65000.00,'ST0007'),
('KR0328','C8','C','8','Premium',65000.00,'ST0007'),
('KR0329','C9','C','9','Premium',65000.00,'ST0007'),
('KR0330','C10','C','10','Premium',65000.00,'ST0007'),
('KR0331','D1','D','1','Premium',65000.00,'ST0007'),
('KR0332','D2','D','2','Premium',65000.00,'ST0007'),
('KR0333','D3','D','3','Premium',65000.00,'ST0007'),
('KR0334','D4','D','4','Premium',65000.00,'ST0007'),
('KR0335','D5','D','5','Premium',65000.00,'ST0007'),
('KR0336','D6','D','6','Premium',65000.00,'ST0007'),
('KR0337','D7','D','7','Premium',65000.00,'ST0007'),
('KR0338','D8','D','8','Premium',65000.00,'ST0007'),
('KR0339','D9','D','9','Premium',65000.00,'ST0007'),
('KR0340','D10','D','10','Premium',65000.00,'ST0007'),
('KR0341','E1','E','1','VIP',85000.00,'ST0007'),
('KR0342','E2','E','2','VIP',85000.00,'ST0007'),
('KR0343','E3','E','3','VIP',85000.00,'ST0007'),
('KR0344','E4','E','4','VIP',85000.00,'ST0007'),
('KR0345','E5','E','5','VIP',85000.00,'ST0007'),
('KR0346','E6','E','6','VIP',85000.00,'ST0007'),
('KR0347','E7','E','7','VIP',85000.00,'ST0007'),
('KR0348','E8','E','8','VIP',85000.00,'ST0007'),
('KR0349','E9','E','9','VIP',85000.00,'ST0007'),
('KR0350','E10','E','10','VIP',85000.00,'ST0007'),
('KR0351','A1','A','1','Reguler',45000.00,'ST0008'),
('KR0352','A2','A','2','Reguler',45000.00,'ST0008'),
('KR0353','A3','A','3','Reguler',45000.00,'ST0008'),
('KR0354','A4','A','4','Reguler',45000.00,'ST0008'),
('KR0355','A5','A','5','Reguler',45000.00,'ST0008'),
('KR0356','A6','A','6','Reguler',45000.00,'ST0008'),
('KR0357','A7','A','7','Reguler',45000.00,'ST0008'),
('KR0358','A8','A','8','Reguler',45000.00,'ST0008'),
('KR0359','A9','A','9','Reguler',45000.00,'ST0008'),
('KR0360','A10','A','10','Reguler',45000.00,'ST0008'),
('KR0361','B1','B','1','Reguler',45000.00,'ST0008'),
('KR0362','B2','B','2','Reguler',45000.00,'ST0008'),
('KR0363','B3','B','3','Reguler',45000.00,'ST0008'),
('KR0364','B4','B','4','Reguler',45000.00,'ST0008'),
('KR0365','B5','B','5','Reguler',45000.00,'ST0008'),
('KR0366','B6','B','6','Reguler',45000.00,'ST0008'),
('KR0367','B7','B','7','Reguler',45000.00,'ST0008'),
('KR0368','B8','B','8','Reguler',45000.00,'ST0008'),
('KR0369','B9','B','9','Reguler',45000.00,'ST0008'),
('KR0370','B10','B','10','Reguler',45000.00,'ST0008'),
('KR0371','C1','C','1','Premium',65000.00,'ST0008'),
('KR0372','C2','C','2','Premium',65000.00,'ST0008'),
('KR0373','C3','C','3','Premium',65000.00,'ST0008'),
('KR0374','C4','C','4','Premium',65000.00,'ST0008'),
('KR0375','C5','C','5','Premium',65000.00,'ST0008'),
('KR0376','C6','C','6','Premium',65000.00,'ST0008'),
('KR0377','C7','C','7','Premium',65000.00,'ST0008'),
('KR0378','C8','C','8','Premium',65000.00,'ST0008'),
('KR0379','C9','C','9','Premium',65000.00,'ST0008'),
('KR0380','C10','C','10','Premium',65000.00,'ST0008'),
('KR0381','D1','D','1','Premium',65000.00,'ST0008'),
('KR0382','D2','D','2','Premium',65000.00,'ST0008'),
('KR0383','D3','D','3','Premium',65000.00,'ST0008'),
('KR0384','D4','D','4','Premium',65000.00,'ST0008'),
('KR0385','D5','D','5','Premium',65000.00,'ST0008'),
('KR0386','D6','D','6','Premium',65000.00,'ST0008'),
('KR0387','D7','D','7','Premium',65000.00,'ST0008'),
('KR0388','D8','D','8','Premium',65000.00,'ST0008'),
('KR0389','D9','D','9','Premium',65000.00,'ST0008'),
('KR0390','D10','D','10','Premium',65000.00,'ST0008'),
('KR0391','E1','E','1','VIP',85000.00,'ST0008'),
('KR0392','E2','E','2','VIP',85000.00,'ST0008'),
('KR0393','E3','E','3','VIP',85000.00,'ST0008'),
('KR0394','E4','E','4','VIP',85000.00,'ST0008'),
('KR0395','E5','E','5','VIP',85000.00,'ST0008'),
('KR0396','E6','E','6','VIP',85000.00,'ST0008'),
('KR0397','E7','E','7','VIP',85000.00,'ST0008'),
('KR0398','E8','E','8','VIP',85000.00,'ST0008'),
('KR0399','E9','E','9','VIP',85000.00,'ST0008'),
('KR0400','E10','E','10','VIP',85000.00,'ST0008'),
('KR0401','A1','A','1','Reguler',45000.00,'ST0009'),
('KR0402','A2','A','2','Reguler',45000.00,'ST0009'),
('KR0403','A3','A','3','Reguler',45000.00,'ST0009'),
('KR0404','A4','A','4','Reguler',45000.00,'ST0009'),
('KR0405','A5','A','5','Reguler',45000.00,'ST0009'),
('KR0406','A6','A','6','Reguler',45000.00,'ST0009'),
('KR0407','A7','A','7','Reguler',45000.00,'ST0009'),
('KR0408','A8','A','8','Reguler',45000.00,'ST0009'),
('KR0409','A9','A','9','Reguler',45000.00,'ST0009'),
('KR0410','A10','A','10','Reguler',45000.00,'ST0009'),
('KR0411','B1','B','1','Reguler',45000.00,'ST0009'),
('KR0412','B2','B','2','Reguler',45000.00,'ST0009'),
('KR0413','B3','B','3','Reguler',45000.00,'ST0009'),
('KR0414','B4','B','4','Reguler',45000.00,'ST0009'),
('KR0415','B5','B','5','Reguler',45000.00,'ST0009'),
('KR0416','B6','B','6','Reguler',45000.00,'ST0009'),
('KR0417','B7','B','7','Reguler',45000.00,'ST0009'),
('KR0418','B8','B','8','Reguler',45000.00,'ST0009'),
('KR0419','B9','B','9','Reguler',45000.00,'ST0009'),
('KR0420','B10','B','10','Reguler',45000.00,'ST0009'),
('KR0421','C1','C','1','Premium',65000.00,'ST0009'),
('KR0422','C2','C','2','Premium',65000.00,'ST0009'),
('KR0423','C3','C','3','Premium',65000.00,'ST0009'),
('KR0424','C4','C','4','Premium',65000.00,'ST0009'),
('KR0425','C5','C','5','Premium',65000.00,'ST0009'),
('KR0426','C6','C','6','Premium',65000.00,'ST0009'),
('KR0427','C7','C','7','Premium',65000.00,'ST0009'),
('KR0428','C8','C','8','Premium',65000.00,'ST0009'),
('KR0429','C9','C','9','Premium',65000.00,'ST0009'),
('KR0430','C10','C','10','Premium',65000.00,'ST0009'),
('KR0431','D1','D','1','Premium',65000.00,'ST0009'),
('KR0432','D2','D','2','Premium',65000.00,'ST0009'),
('KR0433','D3','D','3','Premium',65000.00,'ST0009'),
('KR0434','D4','D','4','Premium',65000.00,'ST0009'),
('KR0435','D5','D','5','Premium',65000.00,'ST0009'),
('KR0436','D6','D','6','Premium',65000.00,'ST0009'),
('KR0437','D7','D','7','Premium',65000.00,'ST0009'),
('KR0438','D8','D','8','Premium',65000.00,'ST0009'),
('KR0439','D9','D','9','Premium',65000.00,'ST0009'),
('KR0440','D10','D','10','Premium',65000.00,'ST0009'),
('KR0441','E1','E','1','VIP',85000.00,'ST0009'),
('KR0442','E2','E','2','VIP',85000.00,'ST0009'),
('KR0443','E3','E','3','VIP',85000.00,'ST0009'),
('KR0444','E4','E','4','VIP',85000.00,'ST0009'),
('KR0445','E5','E','5','VIP',85000.00,'ST0009'),
('KR0446','E6','E','6','VIP',85000.00,'ST0009'),
('KR0447','E7','E','7','VIP',85000.00,'ST0009'),
('KR0448','E8','E','8','VIP',85000.00,'ST0009'),
('KR0449','E9','E','9','VIP',85000.00,'ST0009'),
('KR0450','E10','E','10','VIP',85000.00,'ST0009'),
('KR0451','A1','A','1','Reguler',45000.00,'ST0010'),
('KR0452','A2','A','2','Reguler',45000.00,'ST0010'),
('KR0453','A3','A','3','Reguler',45000.00,'ST0010'),
('KR0454','A4','A','4','Reguler',45000.00,'ST0010'),
('KR0455','A5','A','5','Reguler',45000.00,'ST0010'),
('KR0456','A6','A','6','Reguler',45000.00,'ST0010'),
('KR0457','A7','A','7','Reguler',45000.00,'ST0010'),
('KR0458','A8','A','8','Reguler',45000.00,'ST0010'),
('KR0459','A9','A','9','Reguler',45000.00,'ST0010'),
('KR0460','A10','A','10','Reguler',45000.00,'ST0010'),
('KR0461','B1','B','1','Reguler',45000.00,'ST0010'),
('KR0462','B2','B','2','Reguler',45000.00,'ST0010'),
('KR0463','B3','B','3','Reguler',45000.00,'ST0010'),
('KR0464','B4','B','4','Reguler',45000.00,'ST0010'),
('KR0465','B5','B','5','Reguler',45000.00,'ST0010'),
('KR0466','B6','B','6','Reguler',45000.00,'ST0010'),
('KR0467','B7','B','7','Reguler',45000.00,'ST0010'),
('KR0468','B8','B','8','Reguler',45000.00,'ST0010'),
('KR0469','B9','B','9','Reguler',45000.00,'ST0010'),
('KR0470','B10','B','10','Reguler',45000.00,'ST0010'),
('KR0471','C1','C','1','Premium',65000.00,'ST0010'),
('KR0472','C2','C','2','Premium',65000.00,'ST0010'),
('KR0473','C3','C','3','Premium',65000.00,'ST0010'),
('KR0474','C4','C','4','Premium',65000.00,'ST0010'),
('KR0475','C5','C','5','Premium',65000.00,'ST0010'),
('KR0476','C6','C','6','Premium',65000.00,'ST0010'),
('KR0477','C7','C','7','Premium',65000.00,'ST0010'),
('KR0478','C8','C','8','Premium',65000.00,'ST0010'),
('KR0479','C9','C','9','Premium',65000.00,'ST0010'),
('KR0480','C10','C','10','Premium',65000.00,'ST0010'),
('KR0481','D1','D','1','Premium',65000.00,'ST0010'),
('KR0482','D2','D','2','Premium',65000.00,'ST0010'),
('KR0483','D3','D','3','Premium',65000.00,'ST0010'),
('KR0484','D4','D','4','Premium',65000.00,'ST0010'),
('KR0485','D5','D','5','Premium',65000.00,'ST0010'),
('KR0486','D6','D','6','Premium',65000.00,'ST0010'),
('KR0487','D7','D','7','Premium',65000.00,'ST0010'),
('KR0488','D8','D','8','Premium',65000.00,'ST0010'),
('KR0489','D9','D','9','Premium',65000.00,'ST0010'),
('KR0490','D10','D','10','Premium',65000.00,'ST0010'),
('KR0491','E1','E','1','VIP',85000.00,'ST0010'),
('KR0492','E2','E','2','VIP',85000.00,'ST0010'),
('KR0493','E3','E','3','VIP',85000.00,'ST0010'),
('KR0494','E4','E','4','VIP',85000.00,'ST0010'),
('KR0495','E5','E','5','VIP',85000.00,'ST0010'),
('KR0496','E6','E','6','VIP',85000.00,'ST0010'),
('KR0497','E7','E','7','VIP',85000.00,'ST0010'),
('KR0498','E8','E','8','VIP',85000.00,'ST0010'),
('KR0499','E9','E','9','VIP',85000.00,'ST0010'),
('KR0500','E10','E','10','VIP',85000.00,'ST0010'),
('KR0501','A1','A','1','Reguler',45000.00,'ST0011'),
('KR0502','A2','A','2','Reguler',45000.00,'ST0011'),
('KR0503','A3','A','3','Reguler',45000.00,'ST0011'),
('KR0504','A4','A','4','Reguler',45000.00,'ST0011'),
('KR0505','A5','A','5','Reguler',45000.00,'ST0011'),
('KR0506','A6','A','6','Reguler',45000.00,'ST0011'),
('KR0507','A7','A','7','Reguler',45000.00,'ST0011'),
('KR0508','A8','A','8','Reguler',45000.00,'ST0011'),
('KR0509','A9','A','9','Reguler',45000.00,'ST0011'),
('KR0510','A10','A','10','Reguler',45000.00,'ST0011'),
('KR0511','B1','B','1','Reguler',45000.00,'ST0011'),
('KR0512','B2','B','2','Reguler',45000.00,'ST0011'),
('KR0513','B3','B','3','Reguler',45000.00,'ST0011'),
('KR0514','B4','B','4','Reguler',45000.00,'ST0011'),
('KR0515','B5','B','5','Reguler',45000.00,'ST0011'),
('KR0516','B6','B','6','Reguler',45000.00,'ST0011'),
('KR0517','B7','B','7','Reguler',45000.00,'ST0011'),
('KR0518','B8','B','8','Reguler',45000.00,'ST0011'),
('KR0519','B9','B','9','Reguler',45000.00,'ST0011'),
('KR0520','B10','B','10','Reguler',45000.00,'ST0011'),
('KR0521','C1','C','1','Premium',65000.00,'ST0011'),
('KR0522','C2','C','2','Premium',65000.00,'ST0011'),
('KR0523','C3','C','3','Premium',65000.00,'ST0011'),
('KR0524','C4','C','4','Premium',65000.00,'ST0011'),
('KR0525','C5','C','5','Premium',65000.00,'ST0011'),
('KR0526','C6','C','6','Premium',65000.00,'ST0011'),
('KR0527','C7','C','7','Premium',65000.00,'ST0011'),
('KR0528','C8','C','8','Premium',65000.00,'ST0011'),
('KR0529','C9','C','9','Premium',65000.00,'ST0011'),
('KR0530','C10','C','10','Premium',65000.00,'ST0011'),
('KR0531','D1','D','1','Premium',65000.00,'ST0011'),
('KR0532','D2','D','2','Premium',65000.00,'ST0011'),
('KR0533','D3','D','3','Premium',65000.00,'ST0011'),
('KR0534','D4','D','4','Premium',65000.00,'ST0011'),
('KR0535','D5','D','5','Premium',65000.00,'ST0011'),
('KR0536','D6','D','6','Premium',65000.00,'ST0011'),
('KR0537','D7','D','7','Premium',65000.00,'ST0011'),
('KR0538','D8','D','8','Premium',65000.00,'ST0011'),
('KR0539','D9','D','9','Premium',65000.00,'ST0011'),
('KR0540','D10','D','10','Premium',65000.00,'ST0011'),
('KR0541','E1','E','1','VIP',85000.00,'ST0011'),
('KR0542','E2','E','2','VIP',85000.00,'ST0011'),
('KR0543','E3','E','3','VIP',85000.00,'ST0011'),
('KR0544','E4','E','4','VIP',85000.00,'ST0011'),
('KR0545','E5','E','5','VIP',85000.00,'ST0011'),
('KR0546','E6','E','6','VIP',85000.00,'ST0011'),
('KR0547','E7','E','7','VIP',85000.00,'ST0011'),
('KR0548','E8','E','8','VIP',85000.00,'ST0011'),
('KR0549','E9','E','9','VIP',85000.00,'ST0011'),
('KR0550','E10','E','10','VIP',85000.00,'ST0011'),
('KR0551','A1','A','1','Reguler',45000.00,'ST0012'),
('KR0552','A2','A','2','Reguler',45000.00,'ST0012'),
('KR0553','A3','A','3','Reguler',45000.00,'ST0012'),
('KR0554','A4','A','4','Reguler',45000.00,'ST0012'),
('KR0555','A5','A','5','Reguler',45000.00,'ST0012'),
('KR0556','A6','A','6','Reguler',45000.00,'ST0012'),
('KR0557','A7','A','7','Reguler',45000.00,'ST0012'),
('KR0558','A8','A','8','Reguler',45000.00,'ST0012'),
('KR0559','A9','A','9','Reguler',45000.00,'ST0012'),
('KR0560','A10','A','10','Reguler',45000.00,'ST0012'),
('KR0561','B1','B','1','Reguler',45000.00,'ST0012'),
('KR0562','B2','B','2','Reguler',45000.00,'ST0012'),
('KR0563','B3','B','3','Reguler',45000.00,'ST0012'),
('KR0564','B4','B','4','Reguler',45000.00,'ST0012'),
('KR0565','B5','B','5','Reguler',45000.00,'ST0012'),
('KR0566','B6','B','6','Reguler',45000.00,'ST0012'),
('KR0567','B7','B','7','Reguler',45000.00,'ST0012'),
('KR0568','B8','B','8','Reguler',45000.00,'ST0012'),
('KR0569','B9','B','9','Reguler',45000.00,'ST0012'),
('KR0570','B10','B','10','Reguler',45000.00,'ST0012'),
('KR0571','C1','C','1','Premium',65000.00,'ST0012'),
('KR0572','C2','C','2','Premium',65000.00,'ST0012'),
('KR0573','C3','C','3','Premium',65000.00,'ST0012'),
('KR0574','C4','C','4','Premium',65000.00,'ST0012'),
('KR0575','C5','C','5','Premium',65000.00,'ST0012'),
('KR0576','C6','C','6','Premium',65000.00,'ST0012'),
('KR0577','C7','C','7','Premium',65000.00,'ST0012'),
('KR0578','C8','C','8','Premium',65000.00,'ST0012'),
('KR0579','C9','C','9','Premium',65000.00,'ST0012'),
('KR0580','C10','C','10','Premium',65000.00,'ST0012'),
('KR0581','D1','D','1','Premium',65000.00,'ST0012'),
('KR0582','D2','D','2','Premium',65000.00,'ST0012'),
('KR0583','D3','D','3','Premium',65000.00,'ST0012'),
('KR0584','D4','D','4','Premium',65000.00,'ST0012'),
('KR0585','D5','D','5','Premium',65000.00,'ST0012'),
('KR0586','D6','D','6','Premium',65000.00,'ST0012'),
('KR0587','D7','D','7','Premium',65000.00,'ST0012'),
('KR0588','D8','D','8','Premium',65000.00,'ST0012'),
('KR0589','D9','D','9','Premium',65000.00,'ST0012'),
('KR0590','D10','D','10','Premium',65000.00,'ST0012'),
('KR0591','E1','E','1','VIP',85000.00,'ST0012'),
('KR0592','E2','E','2','VIP',85000.00,'ST0012'),
('KR0593','E3','E','3','VIP',85000.00,'ST0012'),
('KR0594','E4','E','4','VIP',85000.00,'ST0012'),
('KR0595','E5','E','5','VIP',85000.00,'ST0012'),
('KR0596','E6','E','6','VIP',85000.00,'ST0012'),
('KR0597','E7','E','7','VIP',85000.00,'ST0012'),
('KR0598','E8','E','8','VIP',85000.00,'ST0012'),
('KR0599','E9','E','9','VIP',85000.00,'ST0012'),
('KR0600','E10','E','10','VIP',85000.00,'ST0012'),
('KR0601','A1','A','1','Reguler',45000.00,'ST0013'),
('KR0602','A2','A','2','Reguler',45000.00,'ST0013'),
('KR0603','A3','A','3','Reguler',45000.00,'ST0013'),
('KR0604','A4','A','4','Reguler',45000.00,'ST0013'),
('KR0605','A5','A','5','Reguler',45000.00,'ST0013'),
('KR0606','A6','A','6','Reguler',45000.00,'ST0013'),
('KR0607','A7','A','7','Reguler',45000.00,'ST0013'),
('KR0608','A8','A','8','Reguler',45000.00,'ST0013'),
('KR0609','A9','A','9','Reguler',45000.00,'ST0013'),
('KR0610','A10','A','10','Reguler',45000.00,'ST0013'),
('KR0611','B1','B','1','Reguler',45000.00,'ST0013'),
('KR0612','B2','B','2','Reguler',45000.00,'ST0013'),
('KR0613','B3','B','3','Reguler',45000.00,'ST0013'),
('KR0614','B4','B','4','Reguler',45000.00,'ST0013'),
('KR0615','B5','B','5','Reguler',45000.00,'ST0013'),
('KR0616','B6','B','6','Reguler',45000.00,'ST0013'),
('KR0617','B7','B','7','Reguler',45000.00,'ST0013'),
('KR0618','B8','B','8','Reguler',45000.00,'ST0013'),
('KR0619','B9','B','9','Reguler',45000.00,'ST0013'),
('KR0620','B10','B','10','Reguler',45000.00,'ST0013'),
('KR0621','C1','C','1','Premium',65000.00,'ST0013'),
('KR0622','C2','C','2','Premium',65000.00,'ST0013'),
('KR0623','C3','C','3','Premium',65000.00,'ST0013'),
('KR0624','C4','C','4','Premium',65000.00,'ST0013'),
('KR0625','C5','C','5','Premium',65000.00,'ST0013'),
('KR0626','C6','C','6','Premium',65000.00,'ST0013'),
('KR0627','C7','C','7','Premium',65000.00,'ST0013'),
('KR0628','C8','C','8','Premium',65000.00,'ST0013'),
('KR0629','C9','C','9','Premium',65000.00,'ST0013'),
('KR0630','C10','C','10','Premium',65000.00,'ST0013'),
('KR0631','D1','D','1','Premium',65000.00,'ST0013'),
('KR0632','D2','D','2','Premium',65000.00,'ST0013'),
('KR0633','D3','D','3','Premium',65000.00,'ST0013'),
('KR0634','D4','D','4','Premium',65000.00,'ST0013'),
('KR0635','D5','D','5','Premium',65000.00,'ST0013'),
('KR0636','D6','D','6','Premium',65000.00,'ST0013'),
('KR0637','D7','D','7','Premium',65000.00,'ST0013'),
('KR0638','D8','D','8','Premium',65000.00,'ST0013'),
('KR0639','D9','D','9','Premium',65000.00,'ST0013'),
('KR0640','D10','D','10','Premium',65000.00,'ST0013'),
('KR0641','E1','E','1','VIP',85000.00,'ST0013'),
('KR0642','E2','E','2','VIP',85000.00,'ST0013'),
('KR0643','E3','E','3','VIP',85000.00,'ST0013'),
('KR0644','E4','E','4','VIP',85000.00,'ST0013'),
('KR0645','E5','E','5','VIP',85000.00,'ST0013'),
('KR0646','E6','E','6','VIP',85000.00,'ST0013'),
('KR0647','E7','E','7','VIP',85000.00,'ST0013'),
('KR0648','E8','E','8','VIP',85000.00,'ST0013'),
('KR0649','E9','E','9','VIP',85000.00,'ST0013'),
('KR0650','E10','E','10','VIP',85000.00,'ST0013'),
('KR0651','A1','A','1','Reguler',45000.00,'ST0014'),
('KR0652','A2','A','2','Reguler',45000.00,'ST0014'),
('KR0653','A3','A','3','Reguler',45000.00,'ST0014'),
('KR0654','A4','A','4','Reguler',45000.00,'ST0014'),
('KR0655','A5','A','5','Reguler',45000.00,'ST0014'),
('KR0656','A6','A','6','Reguler',45000.00,'ST0014'),
('KR0657','A7','A','7','Reguler',45000.00,'ST0014'),
('KR0658','A8','A','8','Reguler',45000.00,'ST0014'),
('KR0659','A9','A','9','Reguler',45000.00,'ST0014'),
('KR0660','A10','A','10','Reguler',45000.00,'ST0014'),
('KR0661','B1','B','1','Reguler',45000.00,'ST0014'),
('KR0662','B2','B','2','Reguler',45000.00,'ST0014'),
('KR0663','B3','B','3','Reguler',45000.00,'ST0014'),
('KR0664','B4','B','4','Reguler',45000.00,'ST0014'),
('KR0665','B5','B','5','Reguler',45000.00,'ST0014'),
('KR0666','B6','B','6','Reguler',45000.00,'ST0014'),
('KR0667','B7','B','7','Reguler',45000.00,'ST0014'),
('KR0668','B8','B','8','Reguler',45000.00,'ST0014'),
('KR0669','B9','B','9','Reguler',45000.00,'ST0014'),
('KR0670','B10','B','10','Reguler',45000.00,'ST0014'),
('KR0671','C1','C','1','Premium',65000.00,'ST0014'),
('KR0672','C2','C','2','Premium',65000.00,'ST0014'),
('KR0673','C3','C','3','Premium',65000.00,'ST0014'),
('KR0674','C4','C','4','Premium',65000.00,'ST0014'),
('KR0675','C5','C','5','Premium',65000.00,'ST0014'),
('KR0676','C6','C','6','Premium',65000.00,'ST0014'),
('KR0677','C7','C','7','Premium',65000.00,'ST0014'),
('KR0678','C8','C','8','Premium',65000.00,'ST0014'),
('KR0679','C9','C','9','Premium',65000.00,'ST0014'),
('KR0680','C10','C','10','Premium',65000.00,'ST0014'),
('KR0681','D1','D','1','Premium',65000.00,'ST0014'),
('KR0682','D2','D','2','Premium',65000.00,'ST0014'),
('KR0683','D3','D','3','Premium',65000.00,'ST0014'),
('KR0684','D4','D','4','Premium',65000.00,'ST0014'),
('KR0685','D5','D','5','Premium',65000.00,'ST0014'),
('KR0686','D6','D','6','Premium',65000.00,'ST0014'),
('KR0687','D7','D','7','Premium',65000.00,'ST0014'),
('KR0688','D8','D','8','Premium',65000.00,'ST0014'),
('KR0689','D9','D','9','Premium',65000.00,'ST0014'),
('KR0690','D10','D','10','Premium',65000.00,'ST0014'),
('KR0691','E1','E','1','VIP',85000.00,'ST0014'),
('KR0692','E2','E','2','VIP',85000.00,'ST0014'),
('KR0693','E3','E','3','VIP',85000.00,'ST0014'),
('KR0694','E4','E','4','VIP',85000.00,'ST0014'),
('KR0695','E5','E','5','VIP',85000.00,'ST0014'),
('KR0696','E6','E','6','VIP',85000.00,'ST0014'),
('KR0697','E7','E','7','VIP',85000.00,'ST0014'),
('KR0698','E8','E','8','VIP',85000.00,'ST0014'),
('KR0699','E9','E','9','VIP',85000.00,'ST0014'),
('KR0700','E10','E','10','VIP',85000.00,'ST0014'),
('KR0701','A1','A','1','Reguler',45000.00,'ST0015'),
('KR0702','A2','A','2','Reguler',45000.00,'ST0015'),
('KR0703','A3','A','3','Reguler',45000.00,'ST0015'),
('KR0704','A4','A','4','Reguler',45000.00,'ST0015'),
('KR0705','A5','A','5','Reguler',45000.00,'ST0015'),
('KR0706','A6','A','6','Reguler',45000.00,'ST0015'),
('KR0707','A7','A','7','Reguler',45000.00,'ST0015'),
('KR0708','A8','A','8','Reguler',45000.00,'ST0015'),
('KR0709','A9','A','9','Reguler',45000.00,'ST0015'),
('KR0710','A10','A','10','Reguler',45000.00,'ST0015'),
('KR0711','B1','B','1','Reguler',45000.00,'ST0015'),
('KR0712','B2','B','2','Reguler',45000.00,'ST0015'),
('KR0713','B3','B','3','Reguler',45000.00,'ST0015'),
('KR0714','B4','B','4','Reguler',45000.00,'ST0015'),
('KR0715','B5','B','5','Reguler',45000.00,'ST0015'),
('KR0716','B6','B','6','Reguler',45000.00,'ST0015'),
('KR0717','B7','B','7','Reguler',45000.00,'ST0015'),
('KR0718','B8','B','8','Reguler',45000.00,'ST0015'),
('KR0719','B9','B','9','Reguler',45000.00,'ST0015'),
('KR0720','B10','B','10','Reguler',45000.00,'ST0015'),
('KR0721','C1','C','1','Premium',65000.00,'ST0015'),
('KR0722','C2','C','2','Premium',65000.00,'ST0015'),
('KR0723','C3','C','3','Premium',65000.00,'ST0015'),
('KR0724','C4','C','4','Premium',65000.00,'ST0015'),
('KR0725','C5','C','5','Premium',65000.00,'ST0015'),
('KR0726','C6','C','6','Premium',65000.00,'ST0015'),
('KR0727','C7','C','7','Premium',65000.00,'ST0015'),
('KR0728','C8','C','8','Premium',65000.00,'ST0015'),
('KR0729','C9','C','9','Premium',65000.00,'ST0015'),
('KR0730','C10','C','10','Premium',65000.00,'ST0015'),
('KR0731','D1','D','1','Premium',65000.00,'ST0015'),
('KR0732','D2','D','2','Premium',65000.00,'ST0015'),
('KR0733','D3','D','3','Premium',65000.00,'ST0015'),
('KR0734','D4','D','4','Premium',65000.00,'ST0015'),
('KR0735','D5','D','5','Premium',65000.00,'ST0015'),
('KR0736','D6','D','6','Premium',65000.00,'ST0015'),
('KR0737','D7','D','7','Premium',65000.00,'ST0015'),
('KR0738','D8','D','8','Premium',65000.00,'ST0015'),
('KR0739','D9','D','9','Premium',65000.00,'ST0015'),
('KR0740','D10','D','10','Premium',65000.00,'ST0015'),
('KR0741','E1','E','1','VIP',85000.00,'ST0015'),
('KR0742','E2','E','2','VIP',85000.00,'ST0015'),
('KR0743','E3','E','3','VIP',85000.00,'ST0015'),
('KR0744','E4','E','4','VIP',85000.00,'ST0015'),
('KR0745','E5','E','5','VIP',85000.00,'ST0015'),
('KR0746','E6','E','6','VIP',85000.00,'ST0015'),
('KR0747','E7','E','7','VIP',85000.00,'ST0015'),
('KR0748','E8','E','8','VIP',85000.00,'ST0015'),
('KR0749','E9','E','9','VIP',85000.00,'ST0015'),
('KR0750','E10','E','10','VIP',85000.00,'ST0015'),
('KR0751','A1','A','1','Reguler',45000.00,'ST0016'),
('KR0752','A2','A','2','Reguler',45000.00,'ST0016'),
('KR0753','A3','A','3','Reguler',45000.00,'ST0016'),
('KR0754','A4','A','4','Reguler',45000.00,'ST0016'),
('KR0755','A5','A','5','Reguler',45000.00,'ST0016'),
('KR0756','A6','A','6','Reguler',45000.00,'ST0016'),
('KR0757','A7','A','7','Reguler',45000.00,'ST0016'),
('KR0758','A8','A','8','Reguler',45000.00,'ST0016'),
('KR0759','A9','A','9','Reguler',45000.00,'ST0016'),
('KR0760','A10','A','10','Reguler',45000.00,'ST0016'),
('KR0761','B1','B','1','Reguler',45000.00,'ST0016'),
('KR0762','B2','B','2','Reguler',45000.00,'ST0016'),
('KR0763','B3','B','3','Reguler',45000.00,'ST0016'),
('KR0764','B4','B','4','Reguler',45000.00,'ST0016'),
('KR0765','B5','B','5','Reguler',45000.00,'ST0016'),
('KR0766','B6','B','6','Reguler',45000.00,'ST0016'),
('KR0767','B7','B','7','Reguler',45000.00,'ST0016'),
('KR0768','B8','B','8','Reguler',45000.00,'ST0016'),
('KR0769','B9','B','9','Reguler',45000.00,'ST0016'),
('KR0770','B10','B','10','Reguler',45000.00,'ST0016'),
('KR0771','C1','C','1','Premium',65000.00,'ST0016'),
('KR0772','C2','C','2','Premium',65000.00,'ST0016'),
('KR0773','C3','C','3','Premium',65000.00,'ST0016'),
('KR0774','C4','C','4','Premium',65000.00,'ST0016'),
('KR0775','C5','C','5','Premium',65000.00,'ST0016'),
('KR0776','C6','C','6','Premium',65000.00,'ST0016'),
('KR0777','C7','C','7','Premium',65000.00,'ST0016'),
('KR0778','C8','C','8','Premium',65000.00,'ST0016'),
('KR0779','C9','C','9','Premium',65000.00,'ST0016'),
('KR0780','C10','C','10','Premium',65000.00,'ST0016'),
('KR0781','D1','D','1','Premium',65000.00,'ST0016'),
('KR0782','D2','D','2','Premium',65000.00,'ST0016'),
('KR0783','D3','D','3','Premium',65000.00,'ST0016'),
('KR0784','D4','D','4','Premium',65000.00,'ST0016'),
('KR0785','D5','D','5','Premium',65000.00,'ST0016'),
('KR0786','D6','D','6','Premium',65000.00,'ST0016'),
('KR0787','D7','D','7','Premium',65000.00,'ST0016'),
('KR0788','D8','D','8','Premium',65000.00,'ST0016'),
('KR0789','D9','D','9','Premium',65000.00,'ST0016'),
('KR0790','D10','D','10','Premium',65000.00,'ST0016'),
('KR0791','E1','E','1','VIP',85000.00,'ST0016'),
('KR0792','E2','E','2','VIP',85000.00,'ST0016'),
('KR0793','E3','E','3','VIP',85000.00,'ST0016'),
('KR0794','E4','E','4','VIP',85000.00,'ST0016'),
('KR0795','E5','E','5','VIP',85000.00,'ST0016'),
('KR0796','E6','E','6','VIP',85000.00,'ST0016'),
('KR0797','E7','E','7','VIP',85000.00,'ST0016'),
('KR0798','E8','E','8','VIP',85000.00,'ST0016'),
('KR0799','E9','E','9','VIP',85000.00,'ST0016'),
('KR0800','E10','E','10','VIP',85000.00,'ST0016'),
('KR0801','A1','A','1','Reguler',45000.00,'ST0017'),
('KR0802','A2','A','2','Reguler',45000.00,'ST0017'),
('KR0803','A3','A','3','Reguler',45000.00,'ST0017'),
('KR0804','A4','A','4','Reguler',45000.00,'ST0017'),
('KR0805','A5','A','5','Reguler',45000.00,'ST0017'),
('KR0806','A6','A','6','Reguler',45000.00,'ST0017'),
('KR0807','A7','A','7','Reguler',45000.00,'ST0017'),
('KR0808','A8','A','8','Reguler',45000.00,'ST0017'),
('KR0809','A9','A','9','Reguler',45000.00,'ST0017'),
('KR0810','A10','A','10','Reguler',45000.00,'ST0017'),
('KR0811','B1','B','1','Reguler',45000.00,'ST0017'),
('KR0812','B2','B','2','Reguler',45000.00,'ST0017'),
('KR0813','B3','B','3','Reguler',45000.00,'ST0017'),
('KR0814','B4','B','4','Reguler',45000.00,'ST0017'),
('KR0815','B5','B','5','Reguler',45000.00,'ST0017'),
('KR0816','B6','B','6','Reguler',45000.00,'ST0017'),
('KR0817','B7','B','7','Reguler',45000.00,'ST0017'),
('KR0818','B8','B','8','Reguler',45000.00,'ST0017'),
('KR0819','B9','B','9','Reguler',45000.00,'ST0017'),
('KR0820','B10','B','10','Reguler',45000.00,'ST0017'),
('KR0821','C1','C','1','Premium',65000.00,'ST0017'),
('KR0822','C2','C','2','Premium',65000.00,'ST0017'),
('KR0823','C3','C','3','Premium',65000.00,'ST0017'),
('KR0824','C4','C','4','Premium',65000.00,'ST0017'),
('KR0825','C5','C','5','Premium',65000.00,'ST0017'),
('KR0826','C6','C','6','Premium',65000.00,'ST0017'),
('KR0827','C7','C','7','Premium',65000.00,'ST0017'),
('KR0828','C8','C','8','Premium',65000.00,'ST0017'),
('KR0829','C9','C','9','Premium',65000.00,'ST0017'),
('KR0830','C10','C','10','Premium',65000.00,'ST0017'),
('KR0831','D1','D','1','Premium',65000.00,'ST0017'),
('KR0832','D2','D','2','Premium',65000.00,'ST0017'),
('KR0833','D3','D','3','Premium',65000.00,'ST0017'),
('KR0834','D4','D','4','Premium',65000.00,'ST0017'),
('KR0835','D5','D','5','Premium',65000.00,'ST0017'),
('KR0836','D6','D','6','Premium',65000.00,'ST0017'),
('KR0837','D7','D','7','Premium',65000.00,'ST0017'),
('KR0838','D8','D','8','Premium',65000.00,'ST0017'),
('KR0839','D9','D','9','Premium',65000.00,'ST0017'),
('KR0840','D10','D','10','Premium',65000.00,'ST0017'),
('KR0841','E1','E','1','VIP',85000.00,'ST0017'),
('KR0842','E2','E','2','VIP',85000.00,'ST0017'),
('KR0843','E3','E','3','VIP',85000.00,'ST0017'),
('KR0844','E4','E','4','VIP',85000.00,'ST0017'),
('KR0845','E5','E','5','VIP',85000.00,'ST0017'),
('KR0846','E6','E','6','VIP',85000.00,'ST0017'),
('KR0847','E7','E','7','VIP',85000.00,'ST0017'),
('KR0848','E8','E','8','VIP',85000.00,'ST0017'),
('KR0849','E9','E','9','VIP',85000.00,'ST0017'),
('KR0850','E10','E','10','VIP',85000.00,'ST0017'),
('KR0851','A1','A','1','Reguler',45000.00,'ST0018'),
('KR0852','A2','A','2','Reguler',45000.00,'ST0018'),
('KR0853','A3','A','3','Reguler',45000.00,'ST0018'),
('KR0854','A4','A','4','Reguler',45000.00,'ST0018'),
('KR0855','A5','A','5','Reguler',45000.00,'ST0018'),
('KR0856','A6','A','6','Reguler',45000.00,'ST0018'),
('KR0857','A7','A','7','Reguler',45000.00,'ST0018'),
('KR0858','A8','A','8','Reguler',45000.00,'ST0018'),
('KR0859','A9','A','9','Reguler',45000.00,'ST0018'),
('KR0860','A10','A','10','Reguler',45000.00,'ST0018'),
('KR0861','B1','B','1','Reguler',45000.00,'ST0018'),
('KR0862','B2','B','2','Reguler',45000.00,'ST0018'),
('KR0863','B3','B','3','Reguler',45000.00,'ST0018'),
('KR0864','B4','B','4','Reguler',45000.00,'ST0018'),
('KR0865','B5','B','5','Reguler',45000.00,'ST0018'),
('KR0866','B6','B','6','Reguler',45000.00,'ST0018'),
('KR0867','B7','B','7','Reguler',45000.00,'ST0018'),
('KR0868','B8','B','8','Reguler',45000.00,'ST0018'),
('KR0869','B9','B','9','Reguler',45000.00,'ST0018'),
('KR0870','B10','B','10','Reguler',45000.00,'ST0018'),
('KR0871','C1','C','1','Premium',65000.00,'ST0018'),
('KR0872','C2','C','2','Premium',65000.00,'ST0018'),
('KR0873','C3','C','3','Premium',65000.00,'ST0018'),
('KR0874','C4','C','4','Premium',65000.00,'ST0018'),
('KR0875','C5','C','5','Premium',65000.00,'ST0018'),
('KR0876','C6','C','6','Premium',65000.00,'ST0018'),
('KR0877','C7','C','7','Premium',65000.00,'ST0018'),
('KR0878','C8','C','8','Premium',65000.00,'ST0018'),
('KR0879','C9','C','9','Premium',65000.00,'ST0018'),
('KR0880','C10','C','10','Premium',65000.00,'ST0018'),
('KR0881','D1','D','1','Premium',65000.00,'ST0018'),
('KR0882','D2','D','2','Premium',65000.00,'ST0018'),
('KR0883','D3','D','3','Premium',65000.00,'ST0018'),
('KR0884','D4','D','4','Premium',65000.00,'ST0018'),
('KR0885','D5','D','5','Premium',65000.00,'ST0018'),
('KR0886','D6','D','6','Premium',65000.00,'ST0018'),
('KR0887','D7','D','7','Premium',65000.00,'ST0018'),
('KR0888','D8','D','8','Premium',65000.00,'ST0018'),
('KR0889','D9','D','9','Premium',65000.00,'ST0018'),
('KR0890','D10','D','10','Premium',65000.00,'ST0018'),
('KR0891','E1','E','1','VIP',85000.00,'ST0018'),
('KR0892','E2','E','2','VIP',85000.00,'ST0018'),
('KR0893','E3','E','3','VIP',85000.00,'ST0018'),
('KR0894','E4','E','4','VIP',85000.00,'ST0018'),
('KR0895','E5','E','5','VIP',85000.00,'ST0018'),
('KR0896','E6','E','6','VIP',85000.00,'ST0018'),
('KR0897','E7','E','7','VIP',85000.00,'ST0018'),
('KR0898','E8','E','8','VIP',85000.00,'ST0018'),
('KR0899','E9','E','9','VIP',85000.00,'ST0018'),
('KR0900','E10','E','10','VIP',85000.00,'ST0018'),
('KR0901','A1','A','1','Reguler',45000.00,'ST0019'),
('KR0902','A2','A','2','Reguler',45000.00,'ST0019'),
('KR0903','A3','A','3','Reguler',45000.00,'ST0019'),
('KR0904','A4','A','4','Reguler',45000.00,'ST0019'),
('KR0905','A5','A','5','Reguler',45000.00,'ST0019'),
('KR0906','A6','A','6','Reguler',45000.00,'ST0019'),
('KR0907','A7','A','7','Reguler',45000.00,'ST0019'),
('KR0908','A8','A','8','Reguler',45000.00,'ST0019'),
('KR0909','A9','A','9','Reguler',45000.00,'ST0019'),
('KR0910','A10','A','10','Reguler',45000.00,'ST0019'),
('KR0911','B1','B','1','Reguler',45000.00,'ST0019'),
('KR0912','B2','B','2','Reguler',45000.00,'ST0019'),
('KR0913','B3','B','3','Reguler',45000.00,'ST0019'),
('KR0914','B4','B','4','Reguler',45000.00,'ST0019'),
('KR0915','B5','B','5','Reguler',45000.00,'ST0019'),
('KR0916','B6','B','6','Reguler',45000.00,'ST0019'),
('KR0917','B7','B','7','Reguler',45000.00,'ST0019'),
('KR0918','B8','B','8','Reguler',45000.00,'ST0019'),
('KR0919','B9','B','9','Reguler',45000.00,'ST0019'),
('KR0920','B10','B','10','Reguler',45000.00,'ST0019'),
('KR0921','C1','C','1','Premium',65000.00,'ST0019'),
('KR0922','C2','C','2','Premium',65000.00,'ST0019'),
('KR0923','C3','C','3','Premium',65000.00,'ST0019'),
('KR0924','C4','C','4','Premium',65000.00,'ST0019'),
('KR0925','C5','C','5','Premium',65000.00,'ST0019'),
('KR0926','C6','C','6','Premium',65000.00,'ST0019'),
('KR0927','C7','C','7','Premium',65000.00,'ST0019'),
('KR0928','C8','C','8','Premium',65000.00,'ST0019'),
('KR0929','C9','C','9','Premium',65000.00,'ST0019'),
('KR0930','C10','C','10','Premium',65000.00,'ST0019'),
('KR0931','D1','D','1','Premium',65000.00,'ST0019'),
('KR0932','D2','D','2','Premium',65000.00,'ST0019'),
('KR0933','D3','D','3','Premium',65000.00,'ST0019'),
('KR0934','D4','D','4','Premium',65000.00,'ST0019'),
('KR0935','D5','D','5','Premium',65000.00,'ST0019'),
('KR0936','D6','D','6','Premium',65000.00,'ST0019'),
('KR0937','D7','D','7','Premium',65000.00,'ST0019'),
('KR0938','D8','D','8','Premium',65000.00,'ST0019'),
('KR0939','D9','D','9','Premium',65000.00,'ST0019'),
('KR0940','D10','D','10','Premium',65000.00,'ST0019'),
('KR0941','E1','E','1','VIP',85000.00,'ST0019'),
('KR0942','E2','E','2','VIP',85000.00,'ST0019'),
('KR0943','E3','E','3','VIP',85000.00,'ST0019'),
('KR0944','E4','E','4','VIP',85000.00,'ST0019'),
('KR0945','E5','E','5','VIP',85000.00,'ST0019'),
('KR0946','E6','E','6','VIP',85000.00,'ST0019'),
('KR0947','E7','E','7','VIP',85000.00,'ST0019'),
('KR0948','E8','E','8','VIP',85000.00,'ST0019'),
('KR0949','E9','E','9','VIP',85000.00,'ST0019'),
('KR0950','E10','E','10','VIP',85000.00,'ST0019'),
('KR0951','A1','A','1','Reguler',45000.00,'ST0020'),
('KR0952','A2','A','2','Reguler',45000.00,'ST0020'),
('KR0953','A3','A','3','Reguler',45000.00,'ST0020'),
('KR0954','A4','A','4','Reguler',45000.00,'ST0020'),
('KR0955','A5','A','5','Reguler',45000.00,'ST0020'),
('KR0956','A6','A','6','Reguler',45000.00,'ST0020'),
('KR0957','A7','A','7','Reguler',45000.00,'ST0020'),
('KR0958','A8','A','8','Reguler',45000.00,'ST0020'),
('KR0959','A9','A','9','Reguler',45000.00,'ST0020'),
('KR0960','A10','A','10','Reguler',45000.00,'ST0020'),
('KR0961','B1','B','1','Reguler',45000.00,'ST0020'),
('KR0962','B2','B','2','Reguler',45000.00,'ST0020'),
('KR0963','B3','B','3','Reguler',45000.00,'ST0020'),
('KR0964','B4','B','4','Reguler',45000.00,'ST0020'),
('KR0965','B5','B','5','Reguler',45000.00,'ST0020'),
('KR0966','B6','B','6','Reguler',45000.00,'ST0020'),
('KR0967','B7','B','7','Reguler',45000.00,'ST0020'),
('KR0968','B8','B','8','Reguler',45000.00,'ST0020'),
('KR0969','B9','B','9','Reguler',45000.00,'ST0020'),
('KR0970','B10','B','10','Reguler',45000.00,'ST0020'),
('KR0971','C1','C','1','Premium',65000.00,'ST0020'),
('KR0972','C2','C','2','Premium',65000.00,'ST0020'),
('KR0973','C3','C','3','Premium',65000.00,'ST0020'),
('KR0974','C4','C','4','Premium',65000.00,'ST0020'),
('KR0975','C5','C','5','Premium',65000.00,'ST0020'),
('KR0976','C6','C','6','Premium',65000.00,'ST0020'),
('KR0977','C7','C','7','Premium',65000.00,'ST0020'),
('KR0978','C8','C','8','Premium',65000.00,'ST0020'),
('KR0979','C9','C','9','Premium',65000.00,'ST0020'),
('KR0980','C10','C','10','Premium',65000.00,'ST0020'),
('KR0981','D1','D','1','Premium',65000.00,'ST0020'),
('KR0982','D2','D','2','Premium',65000.00,'ST0020'),
('KR0983','D3','D','3','Premium',65000.00,'ST0020'),
('KR0984','D4','D','4','Premium',65000.00,'ST0020'),
('KR0985','D5','D','5','Premium',65000.00,'ST0020'),
('KR0986','D6','D','6','Premium',65000.00,'ST0020'),
('KR0987','D7','D','7','Premium',65000.00,'ST0020'),
('KR0988','D8','D','8','Premium',65000.00,'ST0020'),
('KR0989','D9','D','9','Premium',65000.00,'ST0020'),
('KR0990','D10','D','10','Premium',65000.00,'ST0020'),
('KR0991','E1','E','1','VIP',85000.00,'ST0020'),
('KR0992','E2','E','2','VIP',85000.00,'ST0020'),
('KR0993','E3','E','3','VIP',85000.00,'ST0020'),
('KR0994','E4','E','4','VIP',85000.00,'ST0020'),
('KR0995','E5','E','5','VIP',85000.00,'ST0020'),
('KR0996','E6','E','6','VIP',85000.00,'ST0020'),
('KR0997','E7','E','7','VIP',85000.00,'ST0020'),
('KR0998','E8','E','8','VIP',85000.00,'ST0020'),
('KR0999','E9','E','9','VIP',85000.00,'ST0020'),
('KR1000','E10','E','10','VIP',85000.00,'ST0020'),
('KR1001','A1','A','1','Reguler',45000.00,'ST0021'),
('KR1002','A2','A','2','Reguler',45000.00,'ST0021'),
('KR1003','A3','A','3','Reguler',45000.00,'ST0021'),
('KR1004','A4','A','4','Reguler',45000.00,'ST0021'),
('KR1005','A5','A','5','Reguler',45000.00,'ST0021'),
('KR1006','A6','A','6','Reguler',45000.00,'ST0021'),
('KR1007','A7','A','7','Reguler',45000.00,'ST0021'),
('KR1008','A8','A','8','Reguler',45000.00,'ST0021'),
('KR1009','A9','A','9','Reguler',45000.00,'ST0021'),
('KR1010','A10','A','10','Reguler',45000.00,'ST0021'),
('KR1011','B1','B','1','Reguler',45000.00,'ST0021'),
('KR1012','B2','B','2','Reguler',45000.00,'ST0021'),
('KR1013','B3','B','3','Reguler',45000.00,'ST0021'),
('KR1014','B4','B','4','Reguler',45000.00,'ST0021'),
('KR1015','B5','B','5','Reguler',45000.00,'ST0021'),
('KR1016','B6','B','6','Reguler',45000.00,'ST0021'),
('KR1017','B7','B','7','Reguler',45000.00,'ST0021'),
('KR1018','B8','B','8','Reguler',45000.00,'ST0021'),
('KR1019','B9','B','9','Reguler',45000.00,'ST0021'),
('KR1020','B10','B','10','Reguler',45000.00,'ST0021'),
('KR1021','C1','C','1','Premium',65000.00,'ST0021'),
('KR1022','C2','C','2','Premium',65000.00,'ST0021'),
('KR1023','C3','C','3','Premium',65000.00,'ST0021'),
('KR1024','C4','C','4','Premium',65000.00,'ST0021'),
('KR1025','C5','C','5','Premium',65000.00,'ST0021'),
('KR1026','C6','C','6','Premium',65000.00,'ST0021'),
('KR1027','C7','C','7','Premium',65000.00,'ST0021'),
('KR1028','C8','C','8','Premium',65000.00,'ST0021'),
('KR1029','C9','C','9','Premium',65000.00,'ST0021'),
('KR1030','C10','C','10','Premium',65000.00,'ST0021'),
('KR1031','D1','D','1','Premium',65000.00,'ST0021'),
('KR1032','D2','D','2','Premium',65000.00,'ST0021'),
('KR1033','D3','D','3','Premium',65000.00,'ST0021'),
('KR1034','D4','D','4','Premium',65000.00,'ST0021'),
('KR1035','D5','D','5','Premium',65000.00,'ST0021'),
('KR1036','D6','D','6','Premium',65000.00,'ST0021'),
('KR1037','D7','D','7','Premium',65000.00,'ST0021'),
('KR1038','D8','D','8','Premium',65000.00,'ST0021'),
('KR1039','D9','D','9','Premium',65000.00,'ST0021'),
('KR1040','D10','D','10','Premium',65000.00,'ST0021'),
('KR1041','E1','E','1','VIP',85000.00,'ST0021'),
('KR1042','E2','E','2','VIP',85000.00,'ST0021'),
('KR1043','E3','E','3','VIP',85000.00,'ST0021'),
('KR1044','E4','E','4','VIP',85000.00,'ST0021'),
('KR1045','E5','E','5','VIP',85000.00,'ST0021'),
('KR1046','E6','E','6','VIP',85000.00,'ST0021'),
('KR1047','E7','E','7','VIP',85000.00,'ST0021'),
('KR1048','E8','E','8','VIP',85000.00,'ST0021'),
('KR1049','E9','E','9','VIP',85000.00,'ST0021'),
('KR1050','E10','E','10','VIP',85000.00,'ST0021'),
('KR1051','A1','A','1','Reguler',45000.00,'ST0022'),
('KR1052','A2','A','2','Reguler',45000.00,'ST0022'),
('KR1053','A3','A','3','Reguler',45000.00,'ST0022'),
('KR1054','A4','A','4','Reguler',45000.00,'ST0022'),
('KR1055','A5','A','5','Reguler',45000.00,'ST0022'),
('KR1056','A6','A','6','Reguler',45000.00,'ST0022'),
('KR1057','A7','A','7','Reguler',45000.00,'ST0022'),
('KR1058','A8','A','8','Reguler',45000.00,'ST0022'),
('KR1059','A9','A','9','Reguler',45000.00,'ST0022'),
('KR1060','A10','A','10','Reguler',45000.00,'ST0022'),
('KR1061','B1','B','1','Reguler',45000.00,'ST0022'),
('KR1062','B2','B','2','Reguler',45000.00,'ST0022'),
('KR1063','B3','B','3','Reguler',45000.00,'ST0022'),
('KR1064','B4','B','4','Reguler',45000.00,'ST0022'),
('KR1065','B5','B','5','Reguler',45000.00,'ST0022'),
('KR1066','B6','B','6','Reguler',45000.00,'ST0022'),
('KR1067','B7','B','7','Reguler',45000.00,'ST0022'),
('KR1068','B8','B','8','Reguler',45000.00,'ST0022'),
('KR1069','B9','B','9','Reguler',45000.00,'ST0022'),
('KR1070','B10','B','10','Reguler',45000.00,'ST0022'),
('KR1071','C1','C','1','Premium',65000.00,'ST0022'),
('KR1072','C2','C','2','Premium',65000.00,'ST0022'),
('KR1073','C3','C','3','Premium',65000.00,'ST0022'),
('KR1074','C4','C','4','Premium',65000.00,'ST0022'),
('KR1075','C5','C','5','Premium',65000.00,'ST0022'),
('KR1076','C6','C','6','Premium',65000.00,'ST0022'),
('KR1077','C7','C','7','Premium',65000.00,'ST0022'),
('KR1078','C8','C','8','Premium',65000.00,'ST0022'),
('KR1079','C9','C','9','Premium',65000.00,'ST0022'),
('KR1080','C10','C','10','Premium',65000.00,'ST0022'),
('KR1081','D1','D','1','Premium',65000.00,'ST0022'),
('KR1082','D2','D','2','Premium',65000.00,'ST0022'),
('KR1083','D3','D','3','Premium',65000.00,'ST0022'),
('KR1084','D4','D','4','Premium',65000.00,'ST0022'),
('KR1085','D5','D','5','Premium',65000.00,'ST0022'),
('KR1086','D6','D','6','Premium',65000.00,'ST0022'),
('KR1087','D7','D','7','Premium',65000.00,'ST0022'),
('KR1088','D8','D','8','Premium',65000.00,'ST0022'),
('KR1089','D9','D','9','Premium',65000.00,'ST0022'),
('KR1090','D10','D','10','Premium',65000.00,'ST0022'),
('KR1091','E1','E','1','VIP',85000.00,'ST0022'),
('KR1092','E2','E','2','VIP',85000.00,'ST0022'),
('KR1093','E3','E','3','VIP',85000.00,'ST0022'),
('KR1094','E4','E','4','VIP',85000.00,'ST0022'),
('KR1095','E5','E','5','VIP',85000.00,'ST0022'),
('KR1096','E6','E','6','VIP',85000.00,'ST0022'),
('KR1097','E7','E','7','VIP',85000.00,'ST0022'),
('KR1098','E8','E','8','VIP',85000.00,'ST0022'),
('KR1099','E9','E','9','VIP',85000.00,'ST0022'),
('KR1100','E10','E','10','VIP',85000.00,'ST0022'),
('KR1101','A1','A','1','Reguler',45000.00,'ST0023'),
('KR1102','A2','A','2','Reguler',45000.00,'ST0023'),
('KR1103','A3','A','3','Reguler',45000.00,'ST0023'),
('KR1104','A4','A','4','Reguler',45000.00,'ST0023'),
('KR1105','A5','A','5','Reguler',45000.00,'ST0023'),
('KR1106','A6','A','6','Reguler',45000.00,'ST0023'),
('KR1107','A7','A','7','Reguler',45000.00,'ST0023'),
('KR1108','A8','A','8','Reguler',45000.00,'ST0023'),
('KR1109','A9','A','9','Reguler',45000.00,'ST0023'),
('KR1110','A10','A','10','Reguler',45000.00,'ST0023'),
('KR1111','B1','B','1','Reguler',45000.00,'ST0023'),
('KR1112','B2','B','2','Reguler',45000.00,'ST0023'),
('KR1113','B3','B','3','Reguler',45000.00,'ST0023'),
('KR1114','B4','B','4','Reguler',45000.00,'ST0023'),
('KR1115','B5','B','5','Reguler',45000.00,'ST0023'),
('KR1116','B6','B','6','Reguler',45000.00,'ST0023'),
('KR1117','B7','B','7','Reguler',45000.00,'ST0023'),
('KR1118','B8','B','8','Reguler',45000.00,'ST0023'),
('KR1119','B9','B','9','Reguler',45000.00,'ST0023'),
('KR1120','B10','B','10','Reguler',45000.00,'ST0023'),
('KR1121','C1','C','1','Premium',65000.00,'ST0023'),
('KR1122','C2','C','2','Premium',65000.00,'ST0023'),
('KR1123','C3','C','3','Premium',65000.00,'ST0023'),
('KR1124','C4','C','4','Premium',65000.00,'ST0023'),
('KR1125','C5','C','5','Premium',65000.00,'ST0023'),
('KR1126','C6','C','6','Premium',65000.00,'ST0023'),
('KR1127','C7','C','7','Premium',65000.00,'ST0023'),
('KR1128','C8','C','8','Premium',65000.00,'ST0023'),
('KR1129','C9','C','9','Premium',65000.00,'ST0023'),
('KR1130','C10','C','10','Premium',65000.00,'ST0023'),
('KR1131','D1','D','1','Premium',65000.00,'ST0023'),
('KR1132','D2','D','2','Premium',65000.00,'ST0023'),
('KR1133','D3','D','3','Premium',65000.00,'ST0023'),
('KR1134','D4','D','4','Premium',65000.00,'ST0023'),
('KR1135','D5','D','5','Premium',65000.00,'ST0023'),
('KR1136','D6','D','6','Premium',65000.00,'ST0023'),
('KR1137','D7','D','7','Premium',65000.00,'ST0023'),
('KR1138','D8','D','8','Premium',65000.00,'ST0023'),
('KR1139','D9','D','9','Premium',65000.00,'ST0023'),
('KR1140','D10','D','10','Premium',65000.00,'ST0023'),
('KR1141','E1','E','1','VIP',85000.00,'ST0023'),
('KR1142','E2','E','2','VIP',85000.00,'ST0023'),
('KR1143','E3','E','3','VIP',85000.00,'ST0023'),
('KR1144','E4','E','4','VIP',85000.00,'ST0023'),
('KR1145','E5','E','5','VIP',85000.00,'ST0023'),
('KR1146','E6','E','6','VIP',85000.00,'ST0023'),
('KR1147','E7','E','7','VIP',85000.00,'ST0023'),
('KR1148','E8','E','8','VIP',85000.00,'ST0023'),
('KR1149','E9','E','9','VIP',85000.00,'ST0023'),
('KR1150','E10','E','10','VIP',85000.00,'ST0023'),
('KR1151','A1','A','1','Reguler',45000.00,'ST0024'),
('KR1152','A2','A','2','Reguler',45000.00,'ST0024'),
('KR1153','A3','A','3','Reguler',45000.00,'ST0024'),
('KR1154','A4','A','4','Reguler',45000.00,'ST0024'),
('KR1155','A5','A','5','Reguler',45000.00,'ST0024'),
('KR1156','A6','A','6','Reguler',45000.00,'ST0024'),
('KR1157','A7','A','7','Reguler',45000.00,'ST0024'),
('KR1158','A8','A','8','Reguler',45000.00,'ST0024'),
('KR1159','A9','A','9','Reguler',45000.00,'ST0024'),
('KR1160','A10','A','10','Reguler',45000.00,'ST0024'),
('KR1161','B1','B','1','Reguler',45000.00,'ST0024'),
('KR1162','B2','B','2','Reguler',45000.00,'ST0024'),
('KR1163','B3','B','3','Reguler',45000.00,'ST0024'),
('KR1164','B4','B','4','Reguler',45000.00,'ST0024'),
('KR1165','B5','B','5','Reguler',45000.00,'ST0024'),
('KR1166','B6','B','6','Reguler',45000.00,'ST0024'),
('KR1167','B7','B','7','Reguler',45000.00,'ST0024'),
('KR1168','B8','B','8','Reguler',45000.00,'ST0024'),
('KR1169','B9','B','9','Reguler',45000.00,'ST0024'),
('KR1170','B10','B','10','Reguler',45000.00,'ST0024'),
('KR1171','C1','C','1','Premium',65000.00,'ST0024'),
('KR1172','C2','C','2','Premium',65000.00,'ST0024'),
('KR1173','C3','C','3','Premium',65000.00,'ST0024'),
('KR1174','C4','C','4','Premium',65000.00,'ST0024'),
('KR1175','C5','C','5','Premium',65000.00,'ST0024'),
('KR1176','C6','C','6','Premium',65000.00,'ST0024'),
('KR1177','C7','C','7','Premium',65000.00,'ST0024'),
('KR1178','C8','C','8','Premium',65000.00,'ST0024'),
('KR1179','C9','C','9','Premium',65000.00,'ST0024'),
('KR1180','C10','C','10','Premium',65000.00,'ST0024'),
('KR1181','D1','D','1','Premium',65000.00,'ST0024'),
('KR1182','D2','D','2','Premium',65000.00,'ST0024'),
('KR1183','D3','D','3','Premium',65000.00,'ST0024'),
('KR1184','D4','D','4','Premium',65000.00,'ST0024'),
('KR1185','D5','D','5','Premium',65000.00,'ST0024'),
('KR1186','D6','D','6','Premium',65000.00,'ST0024'),
('KR1187','D7','D','7','Premium',65000.00,'ST0024'),
('KR1188','D8','D','8','Premium',65000.00,'ST0024'),
('KR1189','D9','D','9','Premium',65000.00,'ST0024'),
('KR1190','D10','D','10','Premium',65000.00,'ST0024'),
('KR1191','E1','E','1','VIP',85000.00,'ST0024'),
('KR1192','E2','E','2','VIP',85000.00,'ST0024'),
('KR1193','E3','E','3','VIP',85000.00,'ST0024'),
('KR1194','E4','E','4','VIP',85000.00,'ST0024'),
('KR1195','E5','E','5','VIP',85000.00,'ST0024'),
('KR1196','E6','E','6','VIP',85000.00,'ST0024'),
('KR1197','E7','E','7','VIP',85000.00,'ST0024'),
('KR1198','E8','E','8','VIP',85000.00,'ST0024'),
('KR1199','E9','E','9','VIP',85000.00,'ST0024'),
('KR1200','E10','E','10','VIP',85000.00,'ST0024');

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
INSERT INTO film (id_film, judul, sutradara, rating_usia, durasi, sinopsis, status_tayang, poster_url, rating_score) VALUES
('FM0001','Laskar Pelangi','Riri Riza','SU',124,'Perjalanan mimpi anak-anak Belitong.','Now Showing','/assets/posters/Laskar_Pelangi_film.jpg',8.9),
('FM0002','Pengabdi Setan','Joko Anwar','17+',107,'Ibu kembali untuk menjemput anak-anaknya.','Now Showing','/assets/posters/Pengabdi_Setan_poster.jpg',8.2),
('FM0003','Ada Apa dengan Cinta?','Rudy Soedjarwo','13+',112,'Kisah cinta SMA antara Cinta dan Rangga.','Now Showing','/assets/posters/ada-apa-dengan-cinta.jpg',8.1),
('FM0004','Avatar','James Cameron','13+',162,'Petualangan di planet Pandora.','Now Showing','/assets/posters/Avatar-Teaser-Poster.jpg',8.5),
('FM0005','Single','Raditya Dika','13+',127,'Komedi tentang liku-liku kehidupan jomblo.','Now Showing','/assets/posters/single-poster.jpg',7.4),
('FM0006','Gundala','Joko Anwar','13+',123,'Lahirnya pahlawan super Indonesia dari negeri petir.','Coming Soon','/assets/posters/Gundala_(2019)_poster.jpg',7.6),
('FM0007','Siksa Kubur','Joko Anwar','17+',117,'Membuktikan keberadaan siksa kubur dengan taruhan nyawa.','Leaving Soon','/assets/posters/siksa-kubur.jpg',8.0),
('FM0008','Petualangan Sherina','Riri Riza','SU',115,'Petualangan Sherina dan Sadam melawan penculik.','Now Showing','/assets/posters/petualangan-sherina.jpg',8.3),
('FM0009','Bumi Manusia','Hanung Bramantyo','17+',181,'Kisah cinta Minke dan Annelies di masa kolonial.','Now Showing','/assets/posters/bumi-manusia.jpg',7.9),
('FM0010','Habibie & Ainun','Faozan Rizal','SU',120,'Kisah cinta sejati Presiden Habibie dan Ibu Ainun.','Coming Soon','/assets/posters/habibie & ainun.jpg',8.1),
('FM0011','Dilan 1990','Fajar Bustomi','13+',110,'Romansa anak motor Dilan dan Milea di Bandung.','Now Showing','/assets/posters/dilan-1990.jpg',7.8),
('FM0012','The Raid','Gareth Evans','17+',101,'Serbuan pasukan khusus ke sarang gembong narkoba.','Now Showing','/assets/posters/The_Raid_Poster.jpg',8.9),
('FM0013','5 cm','Rizal Mantovani','SU',126,'Pencarian jati diri dan persahabatan di puncak Mahameru.','Leaving Soon','/assets/posters/5-cm.jpg',7.5),
('FM0014','Interstellar','Christopher Nolan','13+',169,'Astronot mencari planet baru untuk kelangsungan umat manusia.','Coming Soon','/assets/posters/Interstellar_film_poster.jpg',8.7),
('FM0015','Filosofi Kopi','Angga Dwimas Sasongko','13+',117,'Persahabatan dan kecintaan mendalam terhadap racikan kopi.','Now Showing','/assets/posters/filosofi-kopi.jpg',7.7),
('FM0016','Mencuri Raden Saleh','Angga Dwimas Sasongko','13+',154,'Rencana besar mencuri lukisan bersejarah penangkapan Pangeran Diponegoro.','Now Showing','/assets/posters/mencuri-raden-saleh.jpg',8.4),
('FM0017','Nussa','Bony Slamet','SU',107,'Animasi penuh pesan moral persahabatan anak-anak.','Now Showing','/assets/posters/Poster_film_Nussa.jpeg',7.9),
('FM0018','Penyalin Cahaya','Wregas Bhanuteja','17+',130,'Mencari kebenaran atas foto misterius di malam pesta teater.','Now Showing','/assets/posters/penyalin-cahaya.jpg',8.0),
('FM0019','Malam Pencabut Nyawa','Sidharta Tata','17+',112,'Teror alam mimpi misterius yang mengancam nyawa.','Leaving Soon','/assets/posters/malam-pencabut-nyawa.jpg',7.2),
('FM0020','Susi Susanti: Love All','Sim F','SU',124,'Perjuangan legenda bulu tangkis meraih emas Olimpiade pertama Indonesia.','Now Showing','/assets/posters/susi-susanti.jpg',8.2);

-- ---- film_genre --------------------------------------------
INSERT INTO film_genre VALUES
('FM0001','GN0002'),('FM0001','GN0018'),
('FM0002','GN0004'),('FM0002','GN0007'),
('FM0003','GN0002'),('FM0003','GN0005'),
('FM0004','GN0001'),('FM0004','GN0006'),
('FM0005','GN0003'),
('FM0006','GN0001'),('FM0006','GN0016'),
('FM0007','GN0004'),('FM0007','GN0007'),
('FM0008','GN0011'),('FM0008','GN0018'),
('FM0009','GN0002'),('FM0009','GN0014'),
('FM0010','GN0002'),('FM0010','GN0019'),
('FM0011','GN0002'),('FM0011','GN0005'),
('FM0012','GN0001'),('FM0012','GN0007'),
('FM0013','GN0002'),('FM0013','GN0011'),
('FM0014','GN0006'),('FM0014','GN0002'),
('FM0015','GN0002'),
('FM0016','GN0001'),('FM0016','GN0012'),
('FM0017','GN0008'),('FM0017','GN0018'),
('FM0018','GN0002'),('FM0018','GN0013'),
('FM0019','GN0004'),('FM0019','GN0007'),
('FM0020','GN0019'),('FM0020','GN0020');

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
('JD0020','2026-06-13 19:00:00',100000.00,'ST0009'),
('JD0021','2026-06-25 11:00:00',50000.00,'ST0008'),
('JD0022','2026-06-25 15:00:00',90000.00,'ST0021'),
('JD0023','2026-06-25 19:00:00',100000.00,'ST0022'),
('JD0024','2026-06-25 11:00:00',50000.00,'ST0023'),
('JD0025','2026-06-25 15:00:00',125000.00,'ST0024'),
('JD0026','2026-06-25 19:00:00',50000.00,'ST0008'),
('JD0027','2026-06-25 11:00:00',90000.00,'ST0021'),
('JD0028','2026-06-25 15:00:00',100000.00,'ST0022'),
('JD0029','2026-06-25 19:00:00',50000.00,'ST0023'),
('JD0030','2026-06-25 11:00:00',125000.00,'ST0024'),
('JD0031','2026-06-25 15:00:00',50000.00,'ST0008'),
('JD0032','2026-06-25 19:00:00',90000.00,'ST0021'),
('JD0033','2026-06-25 11:00:00',100000.00,'ST0022'),
('JD0034','2026-06-25 15:00:00',50000.00,'ST0023'),
('JD0035','2026-06-25 19:00:00',125000.00,'ST0024'),
('JD0036','2026-06-25 11:00:00',50000.00,'ST0008'),
('JD0037','2026-06-25 15:00:00',90000.00,'ST0021'),
('JD0038','2026-06-25 19:00:00',100000.00,'ST0022'),
('JD0039','2026-06-25 11:00:00',50000.00,'ST0023'),
('JD0040','2026-06-25 15:00:00',125000.00,'ST0024'),
('JD0041','2026-06-25 19:00:00',50000.00,'ST0008'),
('JD0042','2026-06-25 11:00:00',90000.00,'ST0021'),
('JD0043','2026-06-25 15:00:00',100000.00,'ST0022'),
('JD0044','2026-06-25 19:00:00',50000.00,'ST0023'),
('JD0045','2026-06-25 11:00:00',125000.00,'ST0024'),
('JD0046','2026-06-25 15:00:00',50000.00,'ST0008'),
('JD0047','2026-06-25 19:00:00',90000.00,'ST0021'),
('JD0048','2026-06-25 11:00:00',100000.00,'ST0022'),
('JD0049','2026-06-25 15:00:00',50000.00,'ST0023'),
('JD0050','2026-06-25 19:00:00',125000.00,'ST0024'),
('JD0051','2026-06-25 11:00:00',50000.00,'ST0008'),
('JD0052','2026-06-25 15:00:00',90000.00,'ST0021'),
('JD0053','2026-06-25 19:00:00',100000.00,'ST0022'),
('JD0054','2026-06-25 11:00:00',50000.00,'ST0023'),
('JD0055','2026-06-25 15:00:00',125000.00,'ST0024'),
('JD0056','2026-06-25 19:00:00',50000.00,'ST0008'),
('JD0057','2026-06-25 11:00:00',90000.00,'ST0021'),
('JD0058','2026-06-25 15:00:00',100000.00,'ST0022'),
('JD0059','2026-06-25 19:00:00',50000.00,'ST0023'),
('JD0060','2026-06-25 11:00:00',125000.00,'ST0024'),
('JD0061','2026-06-25 15:00:00',50000.00,'ST0008'),
('JD0062','2026-06-25 19:00:00',90000.00,'ST0021'),
('JD0063','2026-06-25 11:00:00',100000.00,'ST0022'),
('JD0064','2026-06-25 15:00:00',50000.00,'ST0023'),
('JD0065','2026-06-25 19:00:00',125000.00,'ST0024'),
('JD0066','2026-06-25 11:00:00',50000.00,'ST0008'),
('JD0067','2026-06-25 15:00:00',90000.00,'ST0021'),
('JD0068','2026-06-25 19:00:00',100000.00,'ST0022'),
('JD0069','2026-06-25 11:00:00',50000.00,'ST0023'),
('JD0070','2026-06-25 15:00:00',125000.00,'ST0024'),
('JD0071','2026-06-25 19:00:00',50000.00,'ST0008'),
('JD0072','2026-06-25 11:00:00',90000.00,'ST0021'),
('JD0073','2026-06-25 15:00:00',100000.00,'ST0022'),
('JD0074','2026-06-25 19:00:00',50000.00,'ST0023'),
('JD0075','2026-06-25 11:00:00',125000.00,'ST0024'),
('JD0076','2026-06-25 15:00:00',50000.00,'ST0008'),
('JD0077','2026-06-25 19:00:00',90000.00,'ST0021'),
('JD0078','2026-06-25 11:00:00',100000.00,'ST0022'),
('JD0079','2026-06-25 15:00:00',50000.00,'ST0023'),
('JD0080','2026-06-25 19:00:00',125000.00,'ST0024');

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
('JD0020','FM0018'),
('JD0021','FM0001'),
('JD0022','FM0001'),
('JD0023','FM0001'),
('JD0024','FM0002'),
('JD0025','FM0002'),
('JD0026','FM0002'),
('JD0027','FM0003'),
('JD0028','FM0003'),
('JD0029','FM0003'),
('JD0030','FM0004'),
('JD0031','FM0004'),
('JD0032','FM0004'),
('JD0033','FM0005'),
('JD0034','FM0005'),
('JD0035','FM0005'),
('JD0036','FM0006'),
('JD0037','FM0006'),
('JD0038','FM0006'),
('JD0039','FM0007'),
('JD0040','FM0007'),
('JD0041','FM0007'),
('JD0042','FM0008'),
('JD0043','FM0008'),
('JD0044','FM0008'),
('JD0045','FM0009'),
('JD0046','FM0009'),
('JD0047','FM0009'),
('JD0048','FM0010'),
('JD0049','FM0010'),
('JD0050','FM0010'),
('JD0051','FM0011'),
('JD0052','FM0011'),
('JD0053','FM0011'),
('JD0054','FM0012'),
('JD0055','FM0012'),
('JD0056','FM0012'),
('JD0057','FM0013'),
('JD0058','FM0013'),
('JD0059','FM0013'),
('JD0060','FM0014'),
('JD0061','FM0014'),
('JD0062','FM0014'),
('JD0063','FM0015'),
('JD0064','FM0015'),
('JD0065','FM0015'),
('JD0066','FM0016'),
('JD0067','FM0016'),
('JD0068','FM0016'),
('JD0069','FM0017'),
('JD0070','FM0017'),
('JD0071','FM0017'),
('JD0072','FM0018'),
('JD0073','FM0018'),
('JD0074','FM0018'),
('JD0075','FM0019'),
('JD0076','FM0019'),
('JD0077','FM0019'),
('JD0078','FM0020'),
('JD0079','FM0020'),
('JD0080','FM0020');

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
('TX0001','2026-06-10 10:30:00',135000.00,'PL0001','PB0001','PG0001','Active'),
('TX0002','2026-06-10 11:00:00',170000.00,'PL0002','PB0002','PG0002','Active'),
('TX0003','2026-06-10 13:30:00', 95000.00,'PL0003','PB0003','PG0003','Active'),
('TX0004','2026-06-10 14:10:00',260000.00,'PL0004','PB0004','PG0004','Active'),
('TX0005','2026-06-10 16:30:00', 65000.00,'PL0005','PB0005','PG0005','Active'),
('TX0006','2026-06-10 17:00:00',180000.00,'PL0006','PB0006','PG0006','Active'),
('TX0007','2026-06-10 19:30:00',175000.00,'PL0007','PB0007','PG0007','Active'),
('TX0008','2026-06-11 11:30:00',200000.00,'PL0008','PB0008','PG0008','Active'),
('TX0009','2026-06-11 12:00:00',100000.00,'PL0009','PB0009','PG0009','Active'),
('TX0010','2026-06-11 14:30:00',145000.00,'PL0010','PB0010','PG0010','Active'),
('TX0011','2026-06-11 15:00:00', 50000.00,'PL0011','PB0011','PG0011','Active'),
('TX0012','2026-06-11 18:30:00',220000.00,'PL0012','PB0012','PG0012','Active'),
('TX0013','2026-06-12 10:30:00',185000.00,'PL0013','PB0013','PG0013','Active'),
('TX0014','2026-06-12 11:00:00',270000.00,'PL0014','PB0014','PG0014','Active'),
('TX0015','2026-06-12 15:30:00',120000.00,'PL0015','PB0015','PG0015','Active'),
('TX0016','2026-06-12 16:00:00',240000.00,'PL0016','PB0016','PG0016','Active'),
('TX0017','2026-06-13 10:30:00',250000.00,'PL0017','PB0017','PG0017','Active'),
('TX0018','2026-06-13 11:00:00',155000.00,'PL0018','PB0018','PG0018','Active'),
('TX0019','2026-06-13 14:30:00',190000.00,'PL0019','PB0019','PG0019','Active'),
('TX0020','2026-06-13 19:30:00',310000.00,'PL0020','PB0020','PG0020','Active');

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
INSERT INTO produk_kantin (id_produk, nama_produk, stok, harga_satuan, kategori_id_kategori, image_url, deskripsi) VALUES
('PK0001','Nasi Goreng Spesial',  50, 35000.00,'KT0001','/assets/foodImages/nasi-goreng-spesial.jpg','Indonesian style fried rice with egg and chicken.'),
('PK0002','Mie Goreng Ayam',      45, 30000.00,'KT0001','/assets/foodImages/mie-goreng-ayam.jpg','Indonesian style fried noodles with chicken and vegetables.'),
('PK0003','Popcorn Original',    120, 25000.00,'KT0007','/assets/foodImages/popcorn-original.jpg','Classic salty cinema popcorn.'),
('PK0004','Popcorn Karamel',     100, 28000.00,'KT0007','/assets/foodImages/popcorn-caramel.jpg','Large bucket of handcrafted caramel-glazed kernels.'),
('PK0005','Nachos + Keju',        80, 32000.00,'KT0008','/assets/foodImages/nachos+keju.jpg','Served with warm jalapeño cheese and fresh salsa.'),
('PK0006','Coca Cola Regular',   200, 15000.00,'KT0011','/assets/foodImages/coca-cola-reguler.jpg','Refreshing cold fountain carbonated beverage.'),
('PK0007','Sprite Regular',      190, 15000.00,'KT0011','/assets/foodImages/sprite-reguler.jpg','Crisp lemon-lime soda.'),
('PK0008','Orange Juice',         75, 20000.00,'KT0012','/assets/foodImages/orange-juice.jpg','Freshly squeezed sweet oranges.'),
('PK0009','Es Krim Vanilla',     100, 22000.00,'KT0009','/assets/foodImages/es-krim-vanilla.jpg','Creamy vanilla bean ice cream.'),
('PK0010','Boba Brown Sugar',     60, 28000.00,'KT0010','/assets/foodImages/boba-brown-sugar.jpg','Milk tea with brown sugar pearls.'),
('PK0011','Combo Popcorn+Soda',  150, 40000.00,'KT0006','/assets/foodImages/pop-corn+soda.jpg','Large Popcorn, 2 Medium Drinks, and a box of M&Ms.'),
('PK0012','Combo Nachos+Soda',    90, 45000.00,'KT0006','/assets/foodImages/nachos+soda.png','Crispy nachos with soda beverage combo.'),
('PK0013','Hot Dog Original',     70, 28000.00,'KT0014','/assets/foodImages/hot-dog.jpg','Grilled sausage in a warm bun with sauces.'),
('PK0014','Pizza Slice BBQ',      55, 30000.00,'KT0015','/assets/foodImages/pizza-bbq.jpg','BBQ chicken pizza slice with melted cheese.'),
('PK0015','Cokelat Batang',      200, 12000.00,'KT0019','/assets/foodImages/chocolate-bar.jpg','Your choice of classic cinema box candy.'),
('PK0016','Air Mineral 600ml',   300, 8000.00, 'KT0020','/assets/foodImages/air-mineral.webp','Pure bottled mineral water.'),
('PK0017','Kopi Susu Gula Aren', 100, 25000.00,'KT0004','/assets/foodImages/kopi-susu-gula-aren.jpeg','Iced milk coffee with local palm sugar.'),
('PK0018','Roti Bakar Cokelat',   80, 18000.00,'KT0016','/assets/foodImages/roti-bakar-cokelat.jpg','Grilled toast with sweet chocolate filling.'),
('PK0019','Es Krim Cokelat',      90, 22000.00,'KT0009','/assets/foodImages/es-krim-cokelat.jpg','Rich creamy chocolate ice cream.'),
('PK0020','Cheesecake Slice',     40, 35000.00,'KT0005','/assets/foodImages/cheesecake-slice.jpg','Decadent NY style cheesecake slice.');

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
-- SECTION 2.5 — Web Integration Enhancements (Initial Mapping)
-- ============================================================

-- Map PG0001 to default admin (Alex Mercer) and director@cinema.com
UPDATE pegawai 
SET nama_pegawai = 'Alex Mercer', email_pegawai = 'director@cinema.com', jabatan = 'Ops Director', password = 'admin'
WHERE id_pegawai = 'PG0001';


-- ============================================================
-- SECTION 3 — Query Cases (5 kasus kontekstual CineTrack)
-- ============================================================
-- CATATAN: Semua query kasus 1-5 dipindahkan ke MBD_D_FP_tests.sql
-- agar import skema database di phpMyAdmin berjalan bersih tanpa error out-of-sync.


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
-- CATATAN: Uji coba/contoh pemanggilan GetTotalTiketByPelanggan dipindahkan ke MBD_D_FP_tests.sql


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
-- CATATAN: Uji coba/contoh pemanggilan GetPendapatanByStudio dipindahkan ke MBD_D_FP_tests.sql


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
-- CATATAN: Uji coba/contoh pemanggilan GetDurasiTayang dipindahkan ke MBD_D_FP_tests.sql



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

DELIMITER ;
-- CATATAN: Uji coba CALL TambahJadwalMidnight dipindahkan ke MBD_D_FP_tests.sql

DELIMITER $$

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
-- CATATAN: Uji coba CALL TambahStokKantin dipindahkan ke MBD_D_FP_tests.sql

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

DELIMITER ;
-- CATATAN: Uji coba Trigger trg_cegah_double_booking dipindahkan ke MBD_D_FP_tests.sql

DELIMITER $$

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
-- CATATAN: Uji coba Trigger trg_kurangi_stok_kantin dipindahkan ke MBD_D_FP_tests.sql

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

-- CATATAN: Verifikasi EXPLAIN dipindahkan ke MBD_D_FP_tests.sql


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

-- CATATAN: Verifikasi EXPLAIN dipindahkan ke MBD_D_FP_tests.sql


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

-- CATATAN: Verifikasi EXPLAIN dipindahkan ke MBD_D_FP_tests.sql


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

-- CATATAN: Verifikasi EXPLAIN dipindahkan ke MBD_D_FP_tests.sql


-- ============================================================
-- INDEX 5: pelanggan(email_pelanggan)
-- ============================================================
-- Digunakan oleh:
--   • API Auth Login → WHERE email_pelanggan = ?
--   • API Auth Google → WHERE email_pelanggan = ?
--   • API Auth Signup → WHERE email_pelanggan = ?
--
-- Kolom VARCHAR non-PK tanpa index. Karena email digunakan sebagai
-- pengenal unik untuk autentikasi user (customer) pada web FP CineTrack,
-- pencarian baris berdasarkan email dilakukan pada setiap kali login,
-- signup, maupun autentikasi Google. Indeks UNIQUE BTREE sangat
-- efisien karena menghentikan pencarian begitu email yang cocok ditemukan.
--
-- Jenis: UNIQUE BTREE — optimal untuk pencarian presisi (equality lookup).
-- ============================================================

CREATE UNIQUE INDEX idx_pelanggan_email
    ON pelanggan (email_pelanggan);

-- CATATAN: Verifikasi EXPLAIN dipindahkan ke MBD_D_FP_tests.sql

-- ============================================================
-- SECTION 7 — Database Views
-- ============================================================


-- View 2: vw_transaksi_lengkap
-- Mempermudah laporan transaksi lengkap dengan informasi pelanggan, pegawai, dan pembayaran.
CREATE OR REPLACE VIEW vw_transaksi_lengkap AS
SELECT 
    t.id_transaksi,
    t.tanggal_transaksi,
    t.total_tagihan,
    pl.id_pelanggan,
    pl.nama_pelanggan,
    pg.id_pegawai,
    pg.nama_pegawai,
    pb.metode_pembayaran,
    pb.status_pembayaran
FROM transaksi t
JOIN pelanggan pl ON t.pelanggan_id_pelanggan = pl.id_pelanggan
JOIN pegawai pg ON t.pegawai_id_pegawai = pg.id_pegawai
JOIN pembayaran pb ON t.pembayaran_id_pembayaran = pb.id_pembayaran;

-- View 3: vw_film_genre
-- Menggabungkan genre film dalam satu string agar mudah ditampilkan di aplikasi frontend.
CREATE OR REPLACE VIEW vw_film_genre AS
SELECT 
    f.id_film,
    f.judul,
    f.sutradara,
    f.rating_usia,
    f.durasi,
    f.sinopsis,
    f.status_tayang,
    f.poster_url,
    f.rating_score,
    GROUP_CONCAT(g.nama_genre SEPARATOR ', ') AS daftar_genre
FROM film f
LEFT JOIN film_genre fg ON f.id_film = fg.film_id_film
LEFT JOIN genre g ON fg.genre_id_genre = g.id_genre
GROUP BY f.id_film;

-- ============================================================
-- SECTION 11 — Tambahan Khusus Maleka
-- ============================================================
-- Mengandung 2 Function, 2 Procedure, dan 2 Trigger baru yang 
-- belum ada di laporan sebelumnya.
-- ============================================================

DELIMITER $$

-- ------------------------------------------------------------
-- 1. FUNCTION: CekStatusKursi
-- ------------------------------------------------------------
CREATE FUNCTION CekStatusKursi(p_id_jadwal CHAR(6), p_id_kursi CHAR(6))
RETURNS VARCHAR(10)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM tiket
    WHERE jadwal_tayang_id_jadwal = p_id_jadwal 
      AND kursi_id_kursi = p_id_kursi;
      
    IF v_count > 0 THEN
        RETURN 'Terjual';
    ELSE
        RETURN 'Tersedia';
    END IF;
END$$

-- ------------------------------------------------------------
-- 2. FUNCTION: CekDiskonMember
-- ------------------------------------------------------------
CREATE FUNCTION CekDiskonMember(p_id_pelanggan CHAR(6))
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_jml_transaksi INT;
    
    SELECT COUNT(*) INTO v_jml_transaksi
    FROM transaksi
    WHERE pelanggan_id_pelanggan = p_id_pelanggan;
    
    IF v_jml_transaksi >= 3 THEN
        RETURN 10.00; -- Diskon 10%
    ELSE
        RETURN 0.00;  -- Tidak ada diskon
    END IF;
END$$

-- ------------------------------------------------------------
-- 3. PROCEDURE: BatalkanTransaksi
-- ------------------------------------------------------------
CREATE PROCEDURE BatalkanTransaksi(IN p_id_transaksi CHAR(6))
BEGIN
    DECLARE v_id_pembayaran CHAR(6);
    
    -- Ambil id_pembayaran dari transaksi tersebut
    SELECT pembayaran_id_pembayaran INTO v_id_pembayaran
    FROM transaksi
    WHERE id_transaksi = p_id_transaksi;
    
    -- 1. Kembalikan stok produk kantin jika ada
    UPDATE produk_kantin pk
    JOIN produk_kantin_transaksi pkt ON pk.id_produk = pkt.produk_kantin_id_produk
    SET pk.stok = pk.stok + pkt.qty
    WHERE pkt.transaksi_id_transaksi = p_id_transaksi;
    
    -- 2. Hapus tiket yang terkait dengan transaksi tersebut (agar kursi bisa dibeli orang lain)
    DELETE FROM tiket
    WHERE transaksi_id_transaksi = p_id_transaksi;
    
    -- 3. Ubah status pembayaran menjadi 'Batal'
    UPDATE pembayaran
    SET status_pembayaran = 'Batal'
    WHERE id_pembayaran = v_id_pembayaran;
    
END$$

-- ------------------------------------------------------------
-- 4. PROCEDURE: UpdateStatusFilmHarian
-- ------------------------------------------------------------
CREATE PROCEDURE UpdateStatusFilmHarian()
BEGIN
    -- Jika film berstatus 'Coming Soon' dan memiliki jadwal tayang <= hari ini,
    -- ubah statusnya menjadi 'Now Showing'
    UPDATE film f
    SET f.status_tayang = 'Now Showing'
    WHERE f.status_tayang = 'Coming Soon'
      AND EXISTS (
          SELECT 1 
          FROM jadwal_tayang_film jtf
          JOIN jadwal_tayang jt ON jtf.jadwal_tayang_id_jadwal = jt.id_jadwal
          WHERE jtf.film_id_film = f.id_film 
            AND DATE(jt.waktu_tayang) <= CURDATE()
      );
END$$

-- ------------------------------------------------------------
-- 5. TRIGGER: trg_cegah_stok_minus
-- ------------------------------------------------------------
CREATE TRIGGER trg_cegah_stok_minus
BEFORE INSERT ON produk_kantin_transaksi
FOR EACH ROW
BEGIN
    DECLARE v_sisa_stok INT;
    
    SELECT stok INTO v_sisa_stok
    FROM produk_kantin
    WHERE id_produk = NEW.produk_kantin_id_produk;
    
    IF NEW.qty > v_sisa_stok THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gagal: Stok kantin tidak mencukupi untuk jumlah yang diminta!';
    END IF;
END$$

-- ------------------------------------------------------------
-- 6. TRIGGER: trg_cegah_jadwal_bentrok
-- ------------------------------------------------------------
CREATE TRIGGER trg_cegah_jadwal_bentrok
BEFORE INSERT ON jadwal_tayang
FOR EACH ROW
BEGIN
    DECLARE v_bentrok INT;
    
    -- Pengecekan sederhana: Apakah ada jadwal tayang lain di studio yang sama pada jam yang sama
    -- (Dianggap jadwal tayang biasanya berjarak > 2 jam, kita cek dalam rentang 2 jam)
    SELECT COUNT(*) INTO v_bentrok
    FROM jadwal_tayang
    WHERE studio_id_studio = NEW.studio_id_studio
      AND ABS(TIMESTAMPDIFF(MINUTE, waktu_tayang, NEW.waktu_tayang)) < 120;
      
    IF v_bentrok > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gagal: Terdapat jadwal tayang yang bentrok (overlap) di studio ini!';
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- INDEX 1: film(status_tayang)
-- ============================================================
CREATE INDEX idx_film_status_tayang ON film (status_tayang);

-- ============================================================
-- INDEX 2: jadwal_tayang_film(film_id_film)
-- ============================================================
CREATE INDEX idx_jtf_film ON jadwal_tayang_film (film_id_film);

-- ============================================================
-- INDEX 3: transaksi(total_tagihan)
-- ============================================================
CREATE INDEX idx_transaksi_total_tagihan ON transaksi (total_tagihan);

-- ============================================================
-- INDEX 4: tiket(jadwal_tayang_id_jadwal, kursi_id_kursi)
-- ============================================================
CREATE INDEX idx_tiket_jadwal_kursi ON tiket (jadwal_tayang_id_jadwal, kursi_id_kursi);

-- ============================================================
-- INDEX 5: pelanggan(email_pelanggan)
-- ============================================================
CREATE UNIQUE INDEX idx_pelanggan_email ON pelanggan (email_pelanggan);

-- ============================================================
-- IMPLEMENTASI SQL VIEW (BERDASARKAN KASUS LAPORAN)
-- ============================================================

-- KASUS 1: vw_film_genre (Menampilkan Film beserta Genre-nya)
CREATE OR REPLACE VIEW vw_film_genre AS
SELECT 
    f.id_film, f.judul, f.sutradara, f.rating_usia, f.durasi, 
    f.sinopsis, f.status_tayang, f.poster_url, f.rating_score,
    GROUP_CONCAT(g.nama_genre SEPARATOR ', ') AS daftar_genre
FROM film f
LEFT JOIN film_genre fg ON f.id_film = fg.film_id_film
LEFT JOIN genre g ON fg.genre_id_genre = g.id_genre
GROUP BY f.id_film;

-- KASUS 2: vw_detail_jadwal (Menampilkan Jadwal Tayang Lengkap)
CREATE OR REPLACE VIEW vw_detail_jadwal AS
SELECT 
    j.id_jadwal, j.waktu_tayang, j.harga_dasar, 
    s.id_studio, s.nomor_studio, s.kelas_studio, 
    c.id_cabang, c.nama_cabang, c.alamat,
    f.id_film, f.judul, 
    GetDurasiTayang(j.id_jadwal) AS durasi,
    DATE_ADD(j.waktu_tayang, INTERVAL GetDurasiTayang(j.id_jadwal) MINUTE) AS estimasi_selesai,
    f.poster_url, f.rating_usia, f.status_tayang
FROM jadwal_tayang j
JOIN studio s ON j.studio_id_studio = s.id_studio
JOIN cabang c ON s.cabang_id_cabang = c.id_cabang
LEFT JOIN jadwal_tayang_film jtf ON j.id_jadwal = jtf.jadwal_tayang_id_jadwal
LEFT JOIN film f ON jtf.film_id_film = f.id_film;

-- KASUS 3: vw_transaksi_vip (Menampilkan Transaksi dengan Total Tagihan di Atas Rp200.000)
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

-- KASUS 4: vw_rekap_kantin_kategori (Rekap Penjualan Produk Kantin per Kategori)
CREATE OR REPLACE VIEW vw_rekap_kantin_kategori AS
SELECT 
    k.nama_kategori, 
    SUM(pkt.qty) AS total_item_terjual, 
    SUM(pkt.subtotal) AS total_pendapatan
FROM kategori k
JOIN produk_kantin pk ON k.id_kategori = pk.kategori_id_kategori
JOIN produk_kantin_transaksi pkt ON pk.id_produk = pkt.produk_kantin_id_produk
GROUP BY k.id_kategori, k.nama_kategori;

-- KASUS 5: vw_pelanggan_idle (Menampilkan Pelanggan yang Belum Pernah Bertransaksi)
CREATE OR REPLACE VIEW vw_pelanggan_idle AS
SELECT 
    pl.id_pelanggan, 
    pl.nama_pelanggan, 
    pl.email_pelanggan
FROM pelanggan pl
LEFT JOIN transaksi tx ON pl.id_pelanggan = tx.pelanggan_id_pelanggan
WHERE tx.id_transaksi IS NULL;

-- View Pendukung: vw_transaksi_lengkap
CREATE OR REPLACE VIEW vw_transaksi_lengkap AS
SELECT 
    t.id_transaksi, t.tanggal_transaksi, t.total_tagihan, 
    pl.id_pelanggan, pl.nama_pelanggan, 
    pg.id_pegawai, pg.nama_pegawai, 
    pb.metode_pembayaran, pb.status_pembayaran
FROM transaksi t
JOIN pelanggan pl ON t.pelanggan_id_pelanggan = pl.id_pelanggan
JOIN pegawai pg ON t.pegawai_id_pegawai = pg.id_pegawai
JOIN pembayaran pb ON t.pembayaran_id_pembayaran = pb.id_pembayaran;

-- ============================================================
-- END OF MBD_D_FP.sql
-- ============================================================