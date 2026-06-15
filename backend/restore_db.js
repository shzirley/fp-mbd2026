const fs = require('fs');
const mysql = require('mysql2/promise');
const path = require('path');

async function restoreDB() {
    const connection = await mysql.createConnection({
        host: 'localhost',
        user: 'root',
        password: '',
        port: 3307,
        multipleStatements: true
    });

    try {
        console.log("Reading SQL file...");
        const sqlPath = path.join(__dirname, '../query/MBD_D_FP_Fiks.sql');
        const sqlQuery = fs.readFileSync(sqlPath, 'utf8');

        console.log("Executing SQL file...");
        await connection.query(sqlQuery);
        console.log("Database successfully restored to pristine condition!");
    } catch (err) {
        console.error("Error restoring database:", err);
    } finally {
        await connection.end();
    }
}

restoreDB();
