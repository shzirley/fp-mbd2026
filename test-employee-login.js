const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

async function test() {
  const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'MBD_FP',
    port: process.env.DB_PORT || 3307
  });

  try {
    const email = 'angelasugiyono95@gmail.com';
    const name = 'Angela';

    // Auto-register as new employee simulation
    const [rows] = await pool.query(`SELECT id_pegawai FROM pegawai ORDER BY id_pegawai DESC LIMIT 1`);
    let newId = 'PG0001';
    if (rows.length > 0) {
      const lastId = rows[0].id_pegawai;
      const lastNum = parseInt(lastId.substring(2), 10);
      newId = 'PG' + String(lastNum + 1).padStart(4, '0');
    }

    console.log("Next ID:", newId);

    // Try insert
    await pool.query(
      'INSERT INTO pegawai (id_pegawai, nama_pegawai, email_pegawai, password, jabatan) VALUES (?, ?, ?, ?, ?)',
      [newId, name, email, 'google_oauth_no_password', 'Staff']
    );

    console.log("Insert successful!");
    
    // Cleanup
    await pool.query('DELETE FROM pegawai WHERE id_pegawai = ?', [newId]);

  } catch (err) {
    console.error("Error:", err);
  } finally {
    pool.end();
  }
}

test();
