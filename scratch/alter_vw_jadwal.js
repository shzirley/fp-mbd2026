const fs = require('fs');

const sqlFile = 'Database/MBD_D_FP.sql';
let content = fs.readFileSync(sqlFile, 'utf8');

// 1. Remove the first definition (lines 2377-2396)
const firstDefRegex = /-- View 1: vw_detail_jadwal\r?\n-- Mempermudah pengambilan detail jadwal tayang lengkap dengan informasi studio, cabang, dan film\.\r?\nCREATE OR REPLACE VIEW vw_detail_jadwal AS\r?\nSELECT[\s\S]*?LEFT JOIN film f ON jtf\.film_id_film = f\.id_film;\r?\n/;

if (firstDefRegex.test(content)) {
    content = content.replace(firstDefRegex, '');
    console.log("Removed redundant vw_detail_jadwal");
}

// 2. Modify the second definition
const newView = `-- KASUS 2: vw_detail_jadwal (Menampilkan Jadwal Tayang Lengkap)
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
LEFT JOIN film f ON jtf.film_id_film = f.id_film;`;

const secondDefRegex = /-- KASUS 2: vw_detail_jadwal \(Menampilkan Jadwal Tayang Lengkap\)\r?\nCREATE OR REPLACE VIEW vw_detail_jadwal AS[\s\S]*?LEFT JOIN film f ON jtf\.film_id_film = f\.id_film;/;

if (secondDefRegex.test(content)) {
    content = content.replace(secondDefRegex, newView);
    console.log("Updated vw_detail_jadwal with GetDurasiTayang");
} else {
    console.log("Could not find second definition of vw_detail_jadwal");
}

fs.writeFileSync(sqlFile, content, 'utf8');
