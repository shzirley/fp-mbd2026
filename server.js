const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const { OAuth2Client } = require('google-auth-library');
const jwt = require('jsonwebtoken');

dotenv.config();

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID || 'dummy_client_id');

const app = express();
app.use(cors());
app.use(express.json());

// Serve static frontend files
app.use(express.static(path.join(__dirname, 'frontend')));
// Serve static assets folder
app.use('/assets', express.static(path.join(__dirname, 'assets')));

// Redirect root to login page
app.get('/', (req, res) => {
  res.redirect('/login.html');
});

// Create MySQL connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'MBD_FP',
  port: process.env.DB_PORT || 3307,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test database connection
pool.query('SELECT 1')
  .then(() => console.log('MySQL Database Connected successfully.'))
  .catch(err => console.error('Database connection error:', err));

// Helper: Auto-increment ID generator
async function getNextId(prefix, tableName, columnName) {
  const [rows] = await pool.query(`SELECT ${columnName} FROM ${tableName} ORDER BY ${columnName} DESC LIMIT 1`);
  if (rows.length === 0) {
    // Determine target length based on standard seeds
    // Standard formats: PL0001 (6 chars), TX0001 (6 chars), FM0001 (6 chars)
    const padding = prefix.length === 2 ? 4 : 3;
    return prefix + '1'.padStart(padding, '0');
  }
  const lastId = rows[0][columnName];
  const lastNum = parseInt(lastId.substring(prefix.length), 10);
  const nextNum = lastNum + 1;
  const paddingLength = lastId.length - prefix.length;
  const nextId = prefix + String(nextNum).padStart(paddingLength, '0');
  return nextId;
}

// ------------------------------------------------------------
// AUTHENTICATION APIs
// ------------------------------------------------------------

// POST /api/auth/google
app.post('/api/auth/google', async (req, res) => {
  const { credential, role } = req.body;
  if (!credential) {
    return res.status(400).json({ message: 'Missing credential payload.' });
  }

  const requestedRole = role || 'user';

  try {
    // Verify Google ID Token
    const ticket = await client.verifyIdToken({
      idToken: credential,
      audience: process.env.GOOGLE_CLIENT_ID || 'dummy_client_id',
    });
    const payload = ticket.getPayload();
    const email = payload.email;
    const name = payload.name;

    if (requestedRole === 'admin') {
      // 1. Check if email belongs to an employee (admin)
      const [pegawai] = await pool.query('SELECT id_pegawai, nama_pegawai, jabatan FROM pegawai WHERE email_pegawai = ?', [email]);
      if (pegawai.length > 0) {
        const token = jwt.sign({ role: 'admin', id: pegawai[0].id_pegawai }, process.env.JWT_SECRET || 'cinetrack_secret', { expiresIn: '7d' });
        return res.json({ token, role: 'admin', user: { id: pegawai[0].id_pegawai, name: pegawai[0].nama_pegawai, email, jabatan: pegawai[0].jabatan } });
      }
      
      // Auto-register as new employee
      const newId = await getNextId('PG', 'pegawai', 'id_pegawai');
      await pool.query(
        'INSERT INTO pegawai (id_pegawai, nama_pegawai, email_pegawai, password, jabatan) VALUES (?, ?, ?, ?, ?)',
        [newId, name, email, 'google_oauth_no_password', 'Staff']
      );
      
      const token = jwt.sign({ role: 'admin', id: newId }, process.env.JWT_SECRET || 'cinetrack_secret', { expiresIn: '7d' });
      return res.status(201).json({ token, role: 'admin', user: { id: newId, name, email, jabatan: 'Staff' } });

    } else {
      // 2. Check if email belongs to an existing customer
      const [pelanggan] = await pool.query('SELECT id_pelanggan, nama_pelanggan FROM pelanggan WHERE email_pelanggan = ?', [email]);
      if (pelanggan.length > 0) {
        const token = jwt.sign({ role: 'user', id: pelanggan[0].id_pelanggan }, process.env.JWT_SECRET || 'cinetrack_secret', { expiresIn: '7d' });
        return res.json({ token, role: 'user', user: { id: pelanggan[0].id_pelanggan, name: pelanggan[0].nama_pelanggan, email, picture: payload.picture } });
      }

      // 3. Auto-register as new customer if not found
      const newId = await getNextId('PL', 'pelanggan', 'id_pelanggan');
      await pool.query(
        'INSERT INTO pelanggan (id_pelanggan, nama_pelanggan, email_pelanggan, password) VALUES (?, ?, ?, ?)',
        [newId, name, email, 'google_oauth_no_password']
      );
      
      const token = jwt.sign({ role: 'user', id: newId }, process.env.JWT_SECRET || 'cinetrack_secret', { expiresIn: '7d' });
      return res.status(201).json({ token, role: 'user', user: { id: newId, name, email, picture: payload.picture } });
    }

  } catch (err) {
    console.error('Google Auth Error:', err);
    return res.status(401).json({ message: 'Invalid Google Token.' });
  }
});

// POST /api/auth/bypass (dev/testing - bypass Google OAuth)
app.post('/api/auth/bypass', async (req, res) => {
  const role = req.body.role || 'user';
  try {
    if (role === 'admin') {
      const [pegawai] = await pool.query("SELECT id_pegawai, nama_pegawai, jabatan, email_pegawai FROM pegawai WHERE id_pegawai='PG0001'");
      if (pegawai.length > 0) {
        const token = jwt.sign({ role: 'admin', id: pegawai[0].id_pegawai }, process.env.JWT_SECRET || 'cinetrack_secret', { expiresIn: '7d' });
        return res.json({ token, role: 'admin', user: { id: pegawai[0].id_pegawai, name: pegawai[0].nama_pegawai, email: pegawai[0].email_pegawai, jabatan: pegawai[0].jabatan } });
      }
    } else {
      const [pelanggan] = await pool.query("SELECT id_pelanggan, nama_pelanggan, email_pelanggan FROM pelanggan WHERE id_pelanggan='PL0001'");
      if (pelanggan.length > 0) {
        const token = jwt.sign({ role: 'user', id: pelanggan[0].id_pelanggan }, process.env.JWT_SECRET || 'cinetrack_secret', { expiresIn: '7d' });
        return res.json({ token, role: 'user', user: { id: pelanggan[0].id_pelanggan, name: pelanggan[0].nama_pelanggan, email: pelanggan[0].email_pelanggan } });
      }
    }
    return res.status(404).json({ message: 'User not found' });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
});

// POST /api/auth/login
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  try {
    // 1. Check in pegawai (admin role)
    const [pegawai] = await pool.query(
      'SELECT id_pegawai, nama_pegawai, email_pegawai, jabatan FROM pegawai WHERE email_pegawai = ? AND password = ?',
      [email, password]
    );

    if (pegawai.length > 0) {
      return res.json({
        role: 'admin',
        id: pegawai[0].id_pegawai,
        name: pegawai[0].nama_pegawai,
        email: pegawai[0].email_pegawai,
        jabatan: pegawai[0].jabatan
      });
    }

    // 2. Check in pelanggan (customer role)
    const [pelanggan] = await pool.query(
      'SELECT id_pelanggan, nama_pelanggan, email_pelanggan, no_telp_pelanggan FROM pelanggan WHERE email_pelanggan = ? AND password = ?',
      [email, password]
    );

    if (pelanggan.length > 0) {
      return res.json({
        role: 'user',
        id: pelanggan[0].id_pelanggan,
        name: pelanggan[0].nama_pelanggan,
        email: pelanggan[0].email_pelanggan,
        phone: pelanggan[0].no_telp_pelanggan
      });
    }

    return res.status(401).json({ message: 'Invalid email or password.' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Internal server error.' });
  }
});

// DELETE /api/auth/delete-account
app.delete('/api/auth/delete-account', async (req, res) => {
  const { id, role } = req.body;
  if (!id || !role) return res.status(400).json({ message: 'Missing user id or role.' });

  try {
    if (role === 'admin') {
      await pool.query('DELETE FROM pegawai WHERE id_pegawai = ?', [id]);
    } else {
      await pool.query('DELETE FROM pelanggan WHERE id_pelanggan = ?', [id]);
    }
    return res.json({ message: 'Account deleted successfully.' });
  } catch (err) {
    console.error('Delete Account Error:', err);
    return res.status(500).json({ message: 'Failed to delete account. It might be tied to existing transactions.' });
  }
});

// POST /api/auth/signup
app.post('/api/auth/signup', async (req, res) => {
  const { name, phone, email, password } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ message: 'Name, email and password are required.' });
  }

  try {
    // Check if email already exists
    const [existingPegawai] = await pool.query('SELECT 1 FROM pegawai WHERE email_pegawai = ?', [email]);
    const [existingPelanggan] = await pool.query('SELECT 1 FROM pelanggan WHERE email_pelanggan = ?', [email]);

    if (existingPegawai.length > 0 || existingPelanggan.length > 0) {
      return res.status(400).json({ message: 'Email address is already registered.' });
    }

    // Generate new customer ID (prefix PL)
    const newId = await getNextId('PL', 'pelanggan', 'id_pelanggan');

    // Insert new customer
    await pool.query(
      'INSERT INTO pelanggan (id_pelanggan, nama_pelanggan, no_telp_pelanggan, email_pelanggan, password) VALUES (?, ?, ?, ?, ?)',
      [newId, name, phone || null, email, password]
    );

    return res.status(201).json({
      message: 'Account created successfully!',
      role: 'user',
      id: newId,
      name: name,
      email: email
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to create account.' });
  }
});


// ------------------------------------------------------------
// CUSTOMER APIs
// ------------------------------------------------------------

// GET /api/movies/now-showing
app.get('/api/movies/now-showing', async (req, res) => {
  try {
    const [movies] = await pool.query("SELECT * FROM film WHERE status_tayang = 'Now Showing'");
    return res.json(movies);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load movies.' });
  }
});

// GET /api/movies/coming-soon
app.get('/api/movies/coming-soon', async (req, res) => {
  try {
    const [movies] = await pool.query("SELECT * FROM film WHERE status_tayang = 'Coming Soon'");
    return res.json(movies);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load coming soon movies.' });
  }
});


// GET /api/movies/all (loads all movies for browse/search)
app.get('/api/movies/all', async (req, res) => {
  try {
    const [movies] = await pool.query('SELECT * FROM film');
    return res.json(movies);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load movies.' });
  }
});

// GET /api/movies/:id
app.get('/api/movies/:id', async (req, res) => {
  try {
    const [movies] = await pool.query('SELECT * FROM film WHERE id_film = ?', [req.params.id]);
    if (movies.length === 0) {
      return res.status(404).json({ message: 'Movie not found.' });
    }

    // Also get its genres
    const [genres] = await pool.query(
      'SELECT g.nama_genre FROM film_genre fg JOIN genre g ON fg.genre_id_genre = g.id_genre WHERE fg.film_id_film = ?',
      [req.params.id]
    );

    const movieDetails = {
      ...movies[0],
      genres: genres.map(g => g.nama_genre)
    };

    return res.json(movieDetails);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load movie details.' });
  }
});

// GET /api/movies/:id/schedules
app.get('/api/movies/:id/schedules', async (req, res) => {
  try {
    const [schedules] = await pool.query(
      `SELECT 
        jt.id_jadwal, 
        jt.waktu_tayang, 
        jt.harga_dasar, 
        st.id_studio,
        st.nomor_studio, 
        st.kelas_studio, 
        cb.id_cabang, 
        cb.nama_cabang, 
        cb.alamat
      FROM jadwal_tayang jt
      JOIN jadwal_tayang_film jtf ON jt.id_jadwal = jtf.jadwal_tayang_id_jadwal
      JOIN studio st ON jt.studio_id_studio = st.id_studio
      JOIN cabang cb ON st.cabang_id_cabang = cb.id_cabang
      WHERE jtf.film_id_film = ?
      ORDER BY cb.nama_cabang, jt.waktu_tayang`,
      [req.params.id]
    );

    // Group schedules by branch name
    const grouped = {};
    schedules.forEach(sched => {
      if (!grouped[sched.nama_cabang]) {
        grouped[sched.nama_cabang] = {
          id_cabang: sched.id_cabang,
          nama_cabang: sched.nama_cabang,
          alamat: sched.alamat,
          schedules: []
        };
      }
      grouped[sched.nama_cabang].schedules.push({
        id_jadwal: sched.id_jadwal,
        waktu_tayang: sched.waktu_tayang,
        harga_dasar: sched.harga_dasar,
        id_studio: sched.id_studio,
        nomor_studio: sched.nomor_studio,
        kelas_studio: sched.kelas_studio
      });
    });

    return res.json(Object.values(grouped));
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load schedules.' });
  }
});

// GET /api/schedules/:id/seats
app.get('/api/schedules/:id/seats', async (req, res) => {
  try {
    // 1. Get schedule info
    const [schedules] = await pool.query(
      `SELECT jt.*, st.kelas_studio, st.nomor_studio, cb.nama_cabang 
       FROM jadwal_tayang jt 
       JOIN studio st ON jt.studio_id_studio = st.id_studio 
       JOIN cabang cb ON st.cabang_id_cabang = cb.id_cabang
       WHERE jt.id_jadwal = ?`,
      [req.params.id]
    );
    if (schedules.length === 0) {
      return res.status(404).json({ message: 'Schedule not found.' });
    }
    const schedule = schedules[0];

    // 2. Get all seats for this studio
    const [seats] = await pool.query(
      'SELECT id_kursi, nomor_kursi, baris, kolom, tipe_kursi, tarif_tipe FROM kursi WHERE studio_id_studio = ? ORDER BY baris, CAST(kolom AS UNSIGNED), nomor_kursi',
      [schedule.studio_id_studio]
    );

    // 3. Get booked seat IDs for this schedule
    const [booked] = await pool.query(
      'SELECT kursi_id_kursi FROM tiket WHERE jadwal_tayang_id_jadwal = ?',
      [req.params.id]
    );
    const bookedIds = new Set(booked.map(b => b.kursi_id_kursi));

    // 4. Map seats with booking status
    const seatMap = seats.map(s => ({
      ...s,
      isBooked: bookedIds.has(s.id_kursi)
    }));

    return res.json({
      scheduleId: schedule.id_jadwal,
      waktu_tayang: schedule.waktu_tayang,
      harga_dasar: schedule.harga_dasar,
      kelas_studio: schedule.kelas_studio,
      seats: seatMap
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load seats.' });
  }
});

// GET /api/canteen/items
app.get('/api/canteen/items', async (req, res) => {
  try {
    const [items] = await pool.query(
      `SELECT 
        pk.id_produk, 
        pk.nama_produk, 
        pk.stok, 
        pk.harga_satuan, 
        pk.image_url, 
        pk.deskripsi, 
        kt.nama_kategori
      FROM produk_kantin pk
      JOIN kategori kt ON pk.kategori_id_kategori = kt.id_kategori
      ORDER BY kt.nama_kategori, pk.nama_produk`
    );
    return res.json(items);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load canteen items.' });
  }
});

// GET /api/user/:userId/tickets
app.get('/api/user/:userId/tickets', async (req, res) => {
  try {
    const [tickets] = await pool.query(
      `SELECT 
        tk.id_tiket, 
        tk.harga_beli, 
        jt.waktu_tayang, 
        f.judul AS judul_film, 
        f.poster_url,
        st.nomor_studio, 
        st.kelas_studio, 
        k.nomor_kursi, 
        tx.id_transaksi, 
        tx.tanggal_transaksi,
        c.nama_cabang
      FROM tiket tk
      JOIN jadwal_tayang jt ON tk.jadwal_tayang_id_jadwal = jt.id_jadwal
      JOIN jadwal_tayang_film jtf ON jt.id_jadwal = jtf.jadwal_tayang_id_jadwal
      JOIN film f ON jtf.film_id_film = f.id_film
      JOIN studio st ON jt.studio_id_studio = st.id_studio
      JOIN cabang c ON st.cabang_id_cabang = c.id_cabang
      JOIN kursi k ON tk.kursi_id_kursi = k.id_kursi
      JOIN transaksi tx ON tk.transaksi_id_transaksi = tx.id_transaksi
      JOIN pembayaran pb ON tx.pembayaran_id_pembayaran = pb.id_pembayaran
      WHERE tx.pelanggan_id_pelanggan = ? AND pb.status_pembayaran != 'Batal'
      ORDER BY jt.waktu_tayang ASC`,
      [req.params.userId]
    );
    return res.json(tickets);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load tickets.' });
  }
});

// POST /api/transactions/:id/cancel
app.post('/api/transactions/:id/cancel', async (req, res) => {
  try {
    await pool.query('CALL BatalkanTransaksi(?)', [req.params.id]);
    return res.json({ message: 'Transaction cancelled successfully.' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to cancel transaction.', error: err.message });
  }
});

// GET /api/user/:id/loyalty
app.get('/api/user/:id/loyalty', async (req, res) => {
  try {
    const [totalRes] = await pool.query('SELECT GetTotalTiketByPelanggan(?) AS totalTickets', [req.params.id]);
    const [discountRes] = await pool.query('SELECT CekDiskonMember(?) AS discount', [req.params.id]);
    return res.json({
      totalTickets: totalRes[0].totalTickets,
      discount: parseFloat(discountRes[0].discount)
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load loyalty data.' });
  }
});

// POST /api/checkout (Process ticket and food booking)
app.post('/api/checkout', async (req, res) => {
  const { userId, scheduleId, seats, canteenItems, paymentMethod, totalBill } = req.body;

  if (!userId || !scheduleId || !seats || !Array.isArray(seats) || seats.length === 0) {
    return res.status(400).json({ message: 'Invalid checkout parameters.' });
  }

  // Get a connection for transaction
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // Auto-restore missing user due to DB reset to fix FK constraint
    await connection.query(
      'INSERT IGNORE INTO pelanggan (id_pelanggan, nama_pelanggan, email_pelanggan) VALUES (?, ?, ?)',
      [userId, 'Restored User', 'restored@google.com']
    );


    // 1. Create a payment record
    const paymentId = await getNextId('PB', 'pembayaran', 'id_pembayaran');
    await connection.query(
      'INSERT INTO pembayaran (id_pembayaran, metode_pembayaran, status_pembayaran) VALUES (?, ?, ?)',
      [paymentId, paymentMethod || 'E-Wallet', 'Success']
    );

    // 2. Create the main transaction
    const transactionId = await getNextId('TX', 'transaksi', 'id_transaksi');
    
    // Check discount before inserting transaction
    const [discountRes] = await connection.query('SELECT CekDiskonMember(?) AS discount', [userId]);
    const discountPercent = parseFloat(discountRes[0].discount) || 0;
    const finalBill = discountPercent > 0 ? totalBill - (totalBill * (discountPercent / 100)) : totalBill;

    // Cashier default employee is PG0001 (Ops Director/Admin)
    await connection.query(
      'INSERT INTO transaksi (id_transaksi, tanggal_transaksi, total_tagihan, pelanggan_id_pelanggan, pembayaran_id_pembayaran, pegawai_id_pegawai) VALUES (?, NOW(), ?, ?, ?, ?)',
      [transactionId, finalBill, userId, paymentId, 'PG0001']
    );

    // 3. Create ticket records (Trigger trg_cegah_double_booking & trg_kalkulasi_harga_tiket will execute)
    // Pre-calculate base ticket ID once to avoid duplicate key when buying multiple seats
    // (getNextId uses pool, not transaction connection, so it can't see uncommitted rows)
    const baseTicketId = await getNextId('TK', 'tiket', 'id_tiket');
    const tkPrefix = 'TK';
    const tkPadding = baseTicketId.length - tkPrefix.length;
    const tkBaseNum = parseInt(baseTicketId.substring(tkPrefix.length), 10);

    for (let i = 0; i < seats.length; i++) {
      const ticketId = tkPrefix + String(tkBaseNum + i).padStart(tkPadding, '0');
      // Insert with temporary dummy price, which is automatically overwritten by the BEFORE INSERT trigger
      await connection.query(
        'INSERT INTO tiket (id_tiket, harga_beli, jadwal_tayang_id_jadwal, transaksi_id_transaksi, kursi_id_kursi) VALUES (?, 0, ?, ?, ?)',
        [ticketId, scheduleId, transactionId, seats[i]]
      );
    }

    // 4. Create canteen items order logs (Trigger trg_kurangi_stok_kantin will execute)
    if (canteenItems && Array.isArray(canteenItems)) {
      for (const item of canteenItems) {
        if (item.qty > 0) {
          await connection.query(
            'INSERT INTO produk_kantin_transaksi (produk_kantin_id_produk, transaksi_id_transaksi, qty, subtotal) VALUES (?, ?, ?, ?)',
            [item.productId || item.id_produk, transactionId, item.qty, item.subtotal]
          );
        }
      }
    }

    await connection.commit();
    return res.json({
      success: true,
      message: 'Booking checkout successful!',
      transactionId: transactionId,
      paymentId: paymentId
    });
  } catch (err) {
    await connection.rollback();
    console.error('Checkout Transaction Failure:', err);
    // Extract custom error message thrown by triggers
    const errMsg = err.sqlMessage || 'Booking transaction failed due to server error.';
    return res.status(400).json({ success: false, message: errMsg });
  } finally {
    connection.release();
  }
});


// ------------------------------------------------------------
// ADMIN MANAGEMENT APIs
// ------------------------------------------------------------

// GET /api/admin/dashboard-stats
app.get('/api/admin/dashboard-stats', async (req, res) => {
  try {
    const [salesResult] = await pool.query('SELECT COALESCE(SUM(total_tagihan), 0) AS total_sales FROM transaksi');
    const [ticketsResult] = await pool.query('SELECT COUNT(*) AS total_tickets FROM tiket');
    const [canteenResult] = await pool.query('SELECT COALESCE(SUM(subtotal), 0) AS total_canteen FROM produk_kantin_transaksi');
    const [moviesResult] = await pool.query("SELECT COUNT(*) AS active_movies FROM film WHERE status_tayang = 'Now Showing'");
    const [branchesResult] = await pool.query('SELECT COUNT(*) AS total_branches FROM cabang');

    return res.json({
      totalSales: parseFloat(salesResult[0].total_sales),
      totalTickets: parseInt(ticketsResult[0].total_tickets, 10),
      totalCanteen: parseFloat(canteenResult[0].total_canteen),
      activeMovies: parseInt(moviesResult[0].active_movies, 10),
      totalBranches: parseInt(branchesResult[0].total_branches, 10)
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to fetch dashboard stats.' });
  }
});

// POST /api/admin/inflation
app.post('/api/admin/inflation', async (req, res) => {
  const { percentage } = req.body;
  try {
    await pool.query('CALL NaikkanHargaInflasi(?)', [percentage || 10]);
    return res.json({ success: true, message: 'Inflation applied successfully!' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to apply inflation.' });
  }
});

// GET /api/admin/studios/revenue
app.get('/api/admin/studios/revenue', async (req, res) => {
  try {
    const [studios] = await pool.query('SELECT st.id_studio, st.nomor_studio, st.kelas_studio, cb.nama_cabang, GetPendapatanByStudio(st.id_studio) AS revenue FROM studio st JOIN cabang cb ON st.cabang_id_cabang = cb.id_cabang ORDER BY revenue DESC');
    return res.json(studios);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load studio revenues.' });
  }
});

// GET /api/admin/branches-performance
app.get('/api/admin/branches-performance', async (req, res) => {
  try {
    const [performance] = await pool.query(
      `SELECT 
        cb.id_cabang, 
        cb.nama_cabang, 
        cb.alamat,
        COUNT(DISTINCT st.id_studio) AS total_studios,
        COALESCE(SUM(tk.harga_beli), 0) AS total_revenue
      FROM cabang cb
      LEFT JOIN studio st ON cb.id_cabang = st.cabang_id_cabang
      LEFT JOIN jadwal_tayang jt ON st.id_studio = jt.studio_id_studio
      LEFT JOIN tiket tk ON jt.id_jadwal = tk.jadwal_tayang_id_jadwal
      GROUP BY cb.id_cabang
      ORDER BY total_revenue DESC`
    );
    return res.json(performance);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to fetch branches performance.' });
  }
});

// GET /api/admin/transactions
app.get('/api/admin/transactions', async (req, res) => {
  try {
    const [transactions] = await pool.query(
      `SELECT * FROM vw_transaksi_lengkap ORDER BY tanggal_transaksi DESC`
    );
    return res.json(transactions);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to fetch transactions.' });
  }
});

// 1. Movie CRUD
app.get('/api/admin/movies', async (req, res) => {
  try {
    const [movies] = await pool.query('SELECT * FROM vw_film_genre ORDER BY id_film DESC');
    return res.json(movies);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load movies.' });
  }
});

app.post('/api/admin/movies', async (req, res) => {
  const { judul, sutradara, rating_usia, durasi, sinopsis, status_tayang, poster_url, rating_score } = req.body;
  try {
    const newId = await getNextId('FM', 'film', 'id_film');
    await pool.query(
      'INSERT INTO film (id_film, judul, sutradara, rating_usia, durasi, sinopsis, status_tayang, poster_url, rating_score) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [newId, judul, sutradara || null, rating_usia || null, durasi || null, sinopsis || null, status_tayang || 'Now Showing', poster_url || null, rating_score || 0.0]
    );
    return res.json({ success: true, message: 'Movie added successfully!', id: newId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to add movie.' });
  }
});

app.put('/api/admin/movies/:id', async (req, res) => {
  const { judul, sutradara, rating_usia, durasi, sinopsis, status_tayang, poster_url, rating_score } = req.body;
  try {
    await pool.query(
      'UPDATE film SET judul=?, sutradara=?, rating_usia=?, durasi=?, sinopsis=?, status_tayang=?, poster_url=?, rating_score=? WHERE id_film=?',
      [judul, sutradara || null, rating_usia || null, durasi || null, sinopsis || null, status_tayang, poster_url || null, rating_score || 0.0, req.params.id]
    );
    return res.json({ success: true, message: 'Movie updated successfully!' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to update movie.' });
  }
});

app.delete('/api/admin/movies/:id', async (req, res) => {
  try {
    // Delete from junction tables first
    await pool.query('DELETE FROM film_genre WHERE film_id_film = ?', [req.params.id]);
    await pool.query('DELETE FROM jadwal_tayang_film WHERE film_id_film = ?', [req.params.id]);
    await pool.query('DELETE FROM film WHERE id_film = ?', [req.params.id]);
    return res.json({ success: true, message: 'Movie deleted successfully!' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to delete movie.' });
  }
});

// 2. Canteen FnB CRUD
app.get('/api/admin/fnb', async (req, res) => {
  try {
    const [items] = await pool.query(
      'SELECT pk.*, kt.nama_kategori FROM produk_kantin pk JOIN kategori kt ON pk.kategori_id_kategori = kt.id_kategori ORDER BY pk.id_produk DESC'
    );
    return res.json(items);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load canteen items.' });
  }
});

app.post('/api/admin/fnb', async (req, res) => {
  const { nama_produk, stok, harga_satuan, kategori_id_kategori, image_url, deskripsi } = req.body;
  try {
    const newId = await getNextId('PK', 'produk_kantin', 'id_produk');
    await pool.query(
      'INSERT INTO produk_kantin (id_produk, nama_produk, stok, harga_satuan, kategori_id_kategori, image_url, deskripsi) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [newId, nama_produk, stok || 0, harga_satuan || 0.00, kategori_id_kategori || 'KT0006', image_url || null, deskripsi || null]
    );
    return res.json({ success: true, message: 'Item added successfully!', id: newId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to add canteen item.' });
  }
});

app.put('/api/admin/fnb/:id', async (req, res) => {
  const { nama_produk, stok, harga_satuan, kategori_id_kategori, image_url, deskripsi } = req.body;
  try {
    await pool.query(
      'UPDATE produk_kantin SET nama_produk=?, stok=?, harga_satuan=?, kategori_id_kategori=?, image_url=?, deskripsi=? WHERE id_produk=?',
      [nama_produk, stok, harga_satuan, kategori_id_kategori, image_url || null, deskripsi || null, req.params.id]
    );
    return res.json({ success: true, message: 'Canteen item updated successfully!' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to update item.' });
  }
});

app.delete('/api/admin/fnb/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM produk_kantin_transaksi WHERE produk_kantin_id_produk = ?', [req.params.id]);
    await pool.query('DELETE FROM produk_kantin WHERE id_produk = ?', [req.params.id]);
    return res.json({ success: true, message: 'Item deleted successfully!' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to delete item.' });
  }
});

// POST /api/admin/fnb/restock
app.post('/api/admin/fnb/restock', async (req, res) => {
  const { id_produk, jumlah } = req.body;
  try {
    await pool.query('CALL TambahStokKantin(?, ?)', [id_produk, jumlah]);
    return res.json({ success: true, message: 'Stock added successfully!' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to restock item.' });
  }
});

// 3. Branches CRUD
app.get('/api/admin/branches', async (req, res) => {
  try {
    const [branches] = await pool.query('SELECT * FROM cabang ORDER BY id_cabang DESC');
    return res.json(branches);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load branches.' });
  }
});

app.post('/api/admin/branches', async (req, res) => {
  const { nama_cabang, alamat, nomor_telepon, email_cabang } = req.body;
  try {
    const newId = await getNextId('CB', 'cabang', 'id_cabang');
    await pool.query(
      'INSERT INTO cabang (id_cabang, nama_cabang, alamat, nomor_telepon, email_cabang) VALUES (?, ?, ?, ?, ?)',
      [newId, nama_cabang, alamat, nomor_telepon || null, email_cabang || null]
    );
    return res.json({ success: true, message: 'Branch added successfully!', id: newId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to add branch.' });
  }
});

app.put('/api/admin/branches/:id', async (req, res) => {
  const { nama_cabang, alamat, nomor_telepon, email_cabang } = req.body;
  try {
    await pool.query(
      'UPDATE cabang SET nama_cabang=?, alamat=?, nomor_telepon=?, email_cabang=? WHERE id_cabang=?',
      [nama_cabang, alamat, nomor_telepon || null, email_cabang || null, req.params.id]
    );
    return res.json({ success: true, message: 'Branch updated successfully!' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to update branch.' });
  }
});

app.delete('/api/admin/branches/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM cabang WHERE id_cabang = ?', [req.params.id]);
    return res.json({ success: true, message: 'Branch deleted successfully!' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to delete branch.' });
  }
});

// 4. Employees & HR CRUD
app.get('/api/admin/employees', async (req, res) => {
  try {
    const [employees] = await pool.query('SELECT * FROM pegawai ORDER BY id_pegawai DESC');
    return res.json(employees);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load employees.' });
  }
});

app.post('/api/admin/employees', async (req, res) => {
  const { nama_pegawai, nomor_telepon, email_pegawai, password, jabatan } = req.body;
  try {
    const newId = await getNextId('PG', 'pegawai', 'id_pegawai');
    await pool.query(
      'INSERT INTO pegawai (id_pegawai, nama_pegawai, nomor_telepon, email_pegawai, password, jabatan) VALUES (?, ?, ?, ?, ?, ?)',
      [newId, nama_pegawai, nomor_telepon || null, email_pegawai || null, password || 'admin123', jabatan || 'Staff']
    );
    return res.json({ success: true, message: 'Employee added successfully!', id: newId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to add employee.' });
  }
});

app.put('/api/admin/employees/:id', async (req, res) => {
  const { nama_pegawai, nomor_telepon, email_pegawai, password, jabatan } = req.body;
  try {
    await pool.query(
      'UPDATE pegawai SET nama_pegawai=?, nomor_telepon=?, email_pegawai=?, password=?, jabatan=? WHERE id_pegawai=?',
      [nama_pegawai, nomor_telepon || null, email_pegawai || null, password || 'admin123', jabatan || 'Staff', req.params.id]
    );
    return res.json({ success: true, message: 'Employee updated successfully!' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to update employee.' });
  }
});

app.delete('/api/admin/employees/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM pegawai_shift WHERE pegawai_id_pegawai = ?', [req.params.id]);
    await pool.query('DELETE FROM pegawai WHERE id_pegawai = ?', [req.params.id]);
    return res.json({ success: true, message: 'Employee deleted successfully!' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to delete employee.' });
  }
});

// 5. Schedules CRUD
app.post('/api/admin/schedules/midnight', async (req, res) => {
  const { tanggal, harga_dasar, studio_id_studio, film_id_film } = req.body;
  try {
    await pool.query('CALL TambahJadwalMidnight(?, ?, ?, ?)', [tanggal, harga_dasar, studio_id_studio, film_id_film]);
    return res.json({ success: true, message: 'Midnight schedule created successfully!' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to create midnight schedule.' });
  }
});

app.get('/api/admin/schedules', async (req, res) => {
  try {
    const [schedules] = await pool.query(
      `SELECT * FROM vw_detail_jadwal ORDER BY waktu_tayang DESC`
    );
    return res.json(schedules);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load schedules.' });
  }
});

app.post('/api/admin/schedules', async (req, res) => {
  const { waktu_tayang, harga_dasar, studio_id_studio, film_id_film } = req.body;
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const newId = await getNextId('JD', 'jadwal_tayang', 'id_jadwal');
    // Insert schedule
    await connection.query(
      'INSERT INTO jadwal_tayang (id_jadwal, waktu_tayang, harga_dasar, studio_id_studio) VALUES (?, ?, ?, ?)',
      [newId, waktu_tayang, harga_dasar, studio_id_studio]
    );

    // Insert junction film
    await connection.query(
      'INSERT INTO jadwal_tayang_film (jadwal_tayang_id_jadwal, film_id_film) VALUES (?, ?)',
      [newId, film_id_film]
    );

    await connection.commit();
    return res.json({ success: true, message: 'Schedule added successfully!', id: newId });
  } catch (err) {
    await connection.rollback();
    console.error(err);
    return res.status(500).json({ message: 'Failed to add schedule.' });
  } finally {
    connection.release();
  }
});

app.put('/api/admin/schedules/:id', async (req, res) => {
  const { waktu_tayang, harga_dasar, studio_id_studio, film_id_film } = req.body;
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // Update schedule
    await connection.query(
      'UPDATE jadwal_tayang SET waktu_tayang=?, harga_dasar=?, studio_id_studio=? WHERE id_jadwal=?',
      [waktu_tayang, harga_dasar, studio_id_studio, req.params.id]
    );

    // Update junction film (delete first, then re-insert)
    await connection.query('DELETE FROM jadwal_tayang_film WHERE jadwal_tayang_id_jadwal = ?', [req.params.id]);
    await connection.query(
      'INSERT INTO jadwal_tayang_film (jadwal_tayang_id_jadwal, film_id_film) VALUES (?, ?)',
      [req.params.id, film_id_film]
    );

    await connection.commit();
    return res.json({ success: true, message: 'Schedule updated successfully!' });
  } catch (err) {
    await connection.rollback();
    console.error(err);
    return res.status(500).json({ message: 'Failed to update schedule.' });
  } finally {
    connection.release();
  }
});

app.delete('/api/admin/schedules/:id', async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    await connection.query('DELETE FROM jadwal_tayang_film WHERE jadwal_tayang_id_jadwal = ?', [req.params.id]);
    await connection.query('DELETE FROM tiket WHERE jadwal_tayang_id_jadwal = ?', [req.params.id]);
    await connection.query('DELETE FROM jadwal_tayang WHERE id_jadwal = ?', [req.params.id]);
    await connection.commit();
    return res.json({ success: true, message: 'Schedule deleted successfully!' });
  } catch (err) {
    await connection.rollback();
    console.error(err);
    return res.status(500).json({ message: 'Failed to delete schedule.' });
  } finally {
    connection.release();
  }
});

// GET /api/admin/studios (used to populate dropdowns in schedule creation)
app.get('/api/admin/studios', async (req, res) => {
  try {
    const [studios] = await pool.query(
      'SELECT st.*, cb.nama_cabang FROM studio st JOIN cabang cb ON st.cabang_id_cabang = cb.id_cabang ORDER BY cb.nama_cabang, st.nomor_studio'
    );
    return res.json(studios);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to load studios.' });
  }
});


// Start server listener
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Express server running on http://localhost:${PORT}`);
});
