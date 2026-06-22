const mysql = require('mysql2/promise');

async function run() {
  const connection = await mysql.createConnection({host:'localhost', user:'root', port:3307, database:'MBD_FP'});
  try {
    console.log("Applying indexes...");
    await connection.query("CREATE INDEX idx_film_status_tayang ON film (status_tayang)");
    console.log("Index 1 created");
    await connection.query("CREATE INDEX idx_jtf_film ON jadwal_tayang_film (film_id_film)");
    console.log("Index 2 created");
    await connection.query("CREATE INDEX idx_transaksi_total_tagihan ON transaksi (total_tagihan)");
    console.log("Index 3 created");
    await connection.query("CREATE INDEX idx_tiket_jadwal_kursi ON tiket (jadwal_tayang_id_jadwal, kursi_id_kursi)");
    console.log("Index 4 created");
    await connection.query("CREATE UNIQUE INDEX idx_pelanggan_email ON pelanggan (email_pelanggan)");
    console.log("Index 5 created");
    console.log("All indexes applied successfully!");
  } catch (e) {
    if (e.code === 'ER_DUP_KEYNAME') {
      console.log("Some indexes already exist:", e.message);
    } else {
      console.error(e);
    }
  }
  process.exit();
}
run();
