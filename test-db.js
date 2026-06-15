const mysql = require('mysql2/promise');
const pool = mysql.createPool({
  host: '127.0.0.1',
  user: 'root',
  password: '',
  database: 'mbdfp_db',
  port: 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

pool.query('SELECT 1')
  .then(() => console.log('Connected to 3306!'))
  .catch(err => console.error('Failed on 3306:', err.message));

const pool2 = mysql.createPool({
  host: '127.0.0.1',
  user: 'root',
  password: '',
  database: 'mbdfp_db',
  port: 3307,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

pool2.query('SELECT 1')
  .then(() => console.log('Connected to 3307!'))
  .catch(err => console.error('Failed on 3307:', err.message));
