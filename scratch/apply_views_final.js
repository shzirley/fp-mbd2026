require('dotenv').config();
const mysql = require('mysql2/promise');

async function run() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || '127.0.0.1',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'mbd_fp',
    port: process.env.DB_PORT || 3307
  });

  const sql = `
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
`;

  try {
      await connection.query(sql);
      console.log('Successfully updated vw_detail_jadwal in DB.');
  } catch (err) {
      console.error(err);
  } finally {
      await connection.end();
  }
}
run();
