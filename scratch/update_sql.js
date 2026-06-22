const fs = require('fs');

const sqlContent = `-- ============================================================
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

-- CATATAN: Verifikasi EXPLAIN dipindahkan ke MBD_D_FP_tests.sql`;

const sqlFile = 'Database/MBD_D_FP.sql';
let content = fs.readFileSync(sqlFile, 'utf8');

const regex = /-- ============================================================\r?\n-- INDEX 1: film\(status_tayang\)[\s\S]*?-- CATATAN: Verifikasi semua index dipindahkan ke MBD_D_FP_tests\.sql\r?\n/;
if (regex.test(content)) {
    content = content.replace(regex, sqlContent + '\n');
    fs.writeFileSync(sqlFile, content, 'utf8');
    console.log("Updated MBD_D_FP.sql successfully.");
} else {
    console.log("Regex did not match MBD_D_FP.sql.");
}
