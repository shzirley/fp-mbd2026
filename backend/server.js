require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

// Middlewares
app.use(cors());
app.use(express.json());

// Basic Route for Testing
app.get('/', (req, res) => {
    res.json({ message: 'Welcome to CineTrack API' });
});

// Import Routes (Nanti Shirley & Jorell akan menambahkan route masing-masing di sini)
// const authRoutes = require('./src/routes/authRoutes');
// app.use('/api/auth', authRoutes);

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
