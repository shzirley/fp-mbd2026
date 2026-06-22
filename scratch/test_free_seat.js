const mysql = require('mysql2/promise');
async function run() {
  try {
    const pool = mysql.createPool({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
    const [seats] = await pool.query("SELECT id_kursi FROM kursi k WHERE k.studio_id_studio = 'ST0001' AND NOT EXISTS (SELECT 1 FROM tiket t WHERE t.kursi_id_kursi = k.id_kursi AND t.jadwal_tayang_id_jadwal = 'JD0001') LIMIT 1");
    console.log(seats[0]);
  } catch(e) {
    console.error(e);
  }
  process.exit();
}
run();
