const pool = require('../config/db');

const findAll = async () => {
  const result = await pool.query(
    'SELECT * FROM mentor_match.Subjects ORDER BY category, name'
  );
  return result.rows;
};

module.exports = {
  findAll,
};