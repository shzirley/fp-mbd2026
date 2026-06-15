const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');

// Route untuk mengambil statistik dashboard (misal: total pendapatan)
router.get('/stats', dashboardController.getDashboardStats);

module.exports = router;
