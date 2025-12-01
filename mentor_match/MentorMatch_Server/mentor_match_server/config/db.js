const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

pool.query('SELECT * FROM mentor_match.users', (err, res) => {
  if (err) {
    console.error('LỖI KẾT NỐI DATABASE:', err.stack);
  } else {
    console.log('✅ Kết nối PostgreSQL thành công.');
  }
});

module.exports = pool;  