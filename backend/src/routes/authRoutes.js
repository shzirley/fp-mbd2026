const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Route untuk Pelanggan (Google OAuth)
router.post('/google', authController.loginGoogle);

// Route untuk Pegawai (Google OAuth)
router.post('/pegawai/google', authController.loginPegawaiGoogle);

// Route untuk Pegawai (Email/Password konvensional)
router.post('/pegawai', authController.loginPegawai);

module.exports = router;
