const express = require('express');
const router = express.Router();
const pegawaiController = require('../controllers/pegawaiController');

router.get('/movies', pegawaiController.getMovies);
router.get('/schedules', pegawaiController.getSchedules);
router.post('/schedules/midnight', pegawaiController.addMidnightShow);
router.get('/fb', pegawaiController.getFBStats);
router.post('/fb/restock', pegawaiController.restockKantin);
router.get('/transactions', pegawaiController.getTransactions);
router.get('/transactions/passive', pegawaiController.getPassiveCustomers);
router.post('/inflation', pegawaiController.applyInflation);

module.exports = router;
