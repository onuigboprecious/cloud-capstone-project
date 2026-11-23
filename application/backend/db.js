import pg from 'pg';

const { Pool } = pg;

// Connection settings – can be overridden via env vars (see .env example)
const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'localhost',
  port: parseInt(process.env.POSTGRES_PORT || '5432', 10),
  user: process.env.POSTGRES_USER || 'formflow',
  password: process.env.POSTGRES_PASSWORD || 'formflow',
  database: process.env.POSTGRES_DB || 'formflow',
});

export async function runMigrations() {
  const client = await pool.connect();
  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS submissions (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TIMESTAMPTZ DEFAULT now()
      );
    `);
  } finally {
    client.release();
  }
}

export default pool;
