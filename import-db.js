const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

async function importDb() {
  try {
    console.log("Connecting to XAMPP MySQL...");
    const connection = await mysql.createConnection({
      host: '127.0.0.1',
      user: 'root',
      password: '',
      port: 3307,
      multipleStatements: true // Required to run a full SQL dump file
    });

    console.log("Creating database MBD_FP...");
    await connection.query('CREATE DATABASE IF NOT EXISTS MBD_FP');
    await connection.query('USE MBD_FP');

    console.log("Reading SQL file...");
    const sqlPath = path.join(__dirname, 'Database', 'MBD_D_FP.sql');
    const sqlScript = fs.readFileSync(sqlPath, 'utf8');

    console.log("Importing database (this might take a moment)...");
    await connection.query(sqlScript);

    console.log("Database imported successfully!");
    await connection.end();
  } catch (error) {
    console.error("Failed to import database:", error);
  }
}

importDb();
