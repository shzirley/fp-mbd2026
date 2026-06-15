const { OAuth2Client } = require('google-auth-library');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const generateToken = (payload) => {
    return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });
};

// --- AUTH UNTUK PELANGGAN (Google Login) ---
exports.loginGoogle = async (req, res) => {
    try {
        const { access_token } = req.body;
        
        if (!access_token) {
            return res.status(400).json({ message: 'Access Token is required' });
        }

        // Fetch user info from Google using access token
        const googleResponse = await fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
            headers: { Authorization: `Bearer ${access_token}` }
        });
        
        const userInfo = await googleResponse.json();
        
        if (!userInfo.email) {
            return res.status(400).json({ message: 'Invalid Google Token' });
        }

        const email = userInfo.email;
        const name = userInfo.name || 'Pelanggan';

        // Cek apakah pelanggan sudah terdaftar
        const [rows] = await db.execute('SELECT * FROM pelanggan WHERE email_pelanggan = ?', [email]);
        
        let pelanggan = rows[0];

        if (!pelanggan) {
            // Register Pelanggan Baru secara otomatis (Upsert)
            // Generate Random ID for Pelanggan (Cus + 3 random digits)
            const randomId = 'CUS' + Math.floor(100 + Math.random() * 900);
            
            await db.execute(
                'INSERT INTO pelanggan (id_pelanggan, nama_pelanggan, email_pelanggan) VALUES (?, ?, ?)',
                [randomId, name, email]
            );
            
            pelanggan = { id_pelanggan: randomId, nama_pelanggan: name, email_pelanggan: email };
        }

        const token = generateToken({ id: pelanggan.id_pelanggan, role: 'pelanggan' });

        res.json({
            message: 'Google Login Success',
            token,
            user: {
                id: pelanggan.id_pelanggan,
                name: pelanggan.nama_pelanggan,
                email: pelanggan.email_pelanggan,
                role: 'pelanggan'
            }
        });

    } catch (error) {
        console.error('Google Auth Error:', error);
        res.status(500).json({ message: 'Server error during Google Authentication' });
    }
};

// --- AUTH UNTUK PEGAWAI (Google Login) ---
exports.loginPegawaiGoogle = async (req, res) => {
    try {
        const { access_token } = req.body;
        
        if (!access_token) {
            return res.status(400).json({ message: 'Access Token is required' });
        }

        const googleResponse = await fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
            headers: { Authorization: `Bearer ${access_token}` }
        });
        
        const userInfo = await googleResponse.json();
        
        if (!userInfo.email) {
            return res.status(400).json({ message: 'Invalid Google Token' });
        }

        const email = userInfo.email;
        const name = userInfo.name || 'Pegawai';

        const [rows] = await db.execute('SELECT * FROM pegawai WHERE email_pegawai = ?', [email]);
        let pegawai = rows[0];

        if (!pegawai) {
            // Register Pegawai Baru secara otomatis (Khusus untuk keperluan simulasi FP)
            const randomId = 'PEG' + Math.floor(100 + Math.random() * 900);
            
            await db.execute(
                'INSERT INTO pegawai (id_pegawai, nama_pegawai, email_pegawai, password) VALUES (?, ?, ?, ?)',
                [randomId, name, email, 'google_sso_no_password']
            );
            
            pegawai = { id_pegawai: randomId, nama_pegawai: name, email_pegawai: email };
        }

        const token = generateToken({ id: pegawai.id_pegawai, role: 'pegawai' });

        res.json({
            message: 'Pegawai Google Login Success',
            token,
            user: {
                id: pegawai.id_pegawai,
                name: pegawai.nama_pegawai,
                email: pegawai.email_pegawai,
                role: 'pegawai'
            }
        });

    } catch (error) {
        console.error('Pegawai Google Auth Error:', error);
        res.status(500).json({ message: 'Server error during Pegawai Authentication' });
    }
};

// --- AUTH UNTUK PEGAWAI (Email/Password konvensional) ---
exports.loginPegawai = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: 'Email and password are required' });
        }

        const [rows] = await db.execute('SELECT * FROM pegawai WHERE email_pegawai = ?', [email]);
        const pegawai = rows[0];

        if (!pegawai) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Note: Asumsi saat mendaftarkan pegawai (oleh admin), password di-hash dengan bcrypt.
        // Jika database saat ini menggunakan plaintext (karena dummy data), kita harus handle.
        // Untuk FP ini, mari kita anggap passwordnya plaintext sementara jika gagal bcrypt, 
        // atau kita gunakan bcrypt.compare().
        
        let isMatch = false;
        
        // Cek apakah password di database di-hash (panjang string hash bcrypt = 60 char)
        if (pegawai.password.length === 60 && pegawai.password.startsWith('$2')) {
             isMatch = await bcrypt.compare(password, pegawai.password);
        } else {
             // Fallback to plaintext comparison (Hanya untuk testing/dummy data MySQL awal)
             isMatch = (password === pegawai.password);
        }

        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const token = generateToken({ id: pegawai.id_pegawai, role: 'pegawai' });

        res.json({
            message: 'Pegawai Login Success',
            token,
            user: {
                id: pegawai.id_pegawai,
                name: pegawai.nama_pegawai,
                email: pegawai.email_pegawai,
                role: 'pegawai'
            }
        });

    } catch (error) {
        console.error('Pegawai Auth Error:', error);
        res.status(500).json({ message: 'Server error during Pegawai Authentication' });
    }
};
