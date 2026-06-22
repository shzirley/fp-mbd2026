const mysql = require('mysql2/promise');
async function run() {
  const c = await mysql.createConnection({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
  await c.query(`
    CREATE OR REPLACE VIEW vw_detail_jadwal AS
    SELECT 
        j.id_jadwal, j.waktu_tayang, j.harga_dasar, 
        s.id_studio, s.nomor_studio, s.kelas_studio, 
        c.id_cabang, c.nama_cabang, c.alamat,
        f.id_film, f.judul, f.durasi,
        f.poster_url, f.rating_usia, f.status_tayang
    FROM jadwal_tayang j
    JOIN studio s ON j.studio_id_studio = s.id_studio
    JOIN cabang c ON s.cabang_id_cabang = c.id_cabang
    LEFT JOIN jadwal_tayang_film jtf ON j.id_jadwal = jtf.jadwal_tayang_id_jadwal
    LEFT JOIN film f ON jtf.film_id_film = f.id_film;
  `);
  process.exit();
}
run();
