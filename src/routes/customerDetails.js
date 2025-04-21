const express = require('express');
const dotenv = require('dotenv');
const db = require('../config/db');

dotenv.config();

const app = express();
app.use(express.json());  

app.get('/test-db', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM customer');
        res.json(rows);
    } catch (err) {
        console.error('Error quering the database: ', err);
        res.status(500).json({ error: 'Error querying the database' });
    }
});

module.exports = app;