const mysql = require('mysql2/promise');

async function generate() {
  const pool = mysql.createPool({
    host: '127.0.0.1',
    user: 'root',
    password: '',
    database: 'mbdfp_db',
    port: 3307
  });

  const [studios] = await pool.query('SELECT id_studio, nomor_studio, kelas_studio FROM studio');
  
  await pool.query('SET FOREIGN_KEY_CHECKS = 0');
  await pool.query('TRUNCATE TABLE kursi');
  
  let seatIdCounter = 1;
  const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
  
  for (const studio of studios) {
    let inserts = [];
    for (const row of rows) {
      let type = 'Reguler';
      let price = 45000;
      
      if (studio.kelas_studio === 'IMAX') {
        type = 'IMAX';
        price = 95000;
      } else if (studio.kelas_studio === 'Premiere' || row === 'F') {
        type = 'VIP';
        price = 85000;
      } else if (row === 'G') {
        type = 'Couple';
        price = 120000;
      }
      
      // 14 columns
      for (let col = 1; col <= 14; col++) {
        const id_kursi = 'KR' + String(seatIdCounter++).padStart(4, '0');
        const nomor_kursi = row + col;
        inserts.push([id_kursi, nomor_kursi, row, col.toString(), type, price, studio.id_studio]);
      }
    }
    
    await pool.query(
      'INSERT INTO kursi (id_kursi, nomor_kursi, baris, kolom, tipe_kursi, tarif_tipe, studio_id_studio) VALUES ?',
      [inserts]
    );
  }
  
  await pool.query('SET FOREIGN_KEY_CHECKS = 1');
  console.log('Successfully generated ' + (seatIdCounter - 1) + ' seats!');
  process.exit(0);
}
generate().catch(console.error);
