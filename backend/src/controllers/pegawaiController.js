const db = require('../config/db');

// --- 1. MOVIES ---
exports.getMovies = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM vw_daftar_film');
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error getMovies:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// --- 2. SCHEDULES ---
exports.getSchedules = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM vw_jadwal_tayang');
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error getSchedules:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.addMidnightShow = async (req, res) => {
    try {
        const { tanggal, harga_dasar, id_studio, id_film } = req.body;
        // Panggil Procedure TambahJadwalMidnight
        await db.execute('CALL TambahJadwalMidnight(?, ?, ?, ?)', [tanggal, harga_dasar, id_studio, id_film]);
        res.json({ success: true, message: 'Midnight show berhasil ditambahkan!' });
    } catch (error) {
        console.error('Error addMidnightShow:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// --- 3. F&B (KANTIN) ---
exports.getFBStats = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM vw_rekap_kantin');
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error getFBStats:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.restockKantin = async (req, res) => {
    try {
        const { id_produk, jumlah_tambah } = req.body;
        // Panggil Procedure TambahStokKantin
        await db.execute('CALL TambahStokKantin(?, ?)', [id_produk, jumlah_tambah]);
        res.json({ success: true, message: 'Stok kantin berhasil ditambah!' });
    } catch (error) {
        console.error('Error restockKantin:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// --- 4. TRANSACTIONS ---
exports.getTransactions = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM vw_transaksi_tinggi');
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error getTransactions:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.getPassiveCustomers = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM vw_pelanggan_tanpa_transaksi');
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error getPassiveCustomers:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// --- 5. HR / SETTINGS ---
exports.applyInflation = async (req, res) => {
    try {
        const { persentase } = req.body;
        // Panggil Procedure NaikkanHargaInflasi
        await db.execute('CALL NaikkanHargaInflasi(?)', [persentase]);
        res.json({ success: true, message: `Harga berhasil dinaikkan sebesar ${persentase}%!` });
    } catch (error) {
        console.error('Error applyInflation:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};
