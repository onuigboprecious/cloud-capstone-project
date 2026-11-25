import express from 'express';
import cors from 'cors';
import pool, { runMigrations } from './db.js';

// Run migrations on startup (creates the submissions table if missing)
await runMigrations();
import path from 'node:path';
import fs from 'node:fs';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
// Allow overriding port via env, default to 5000 for compatibility
const PORT = process.env.PORT || 5000;

// Ensure database directory exists (not needed for PostgreSQL)
// const dataDir = path.join(__dirname, 'data');
// if (!fs.existsSync(dataDir)) {
//   fs.mkdirSync(dataDir, { recursive: true });
// }

// Allow overriding DB path for testing
// (No file‑based DB when using PostgreSQL)



// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint (for deployment monitoring)
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'formflow-backend',
    timestamp: new Date().toISOString()
  });
});

// Version endpoint (used by CI/CD deploy verification)
app.get('/version', (req, res) => {
  res.json({
    version: process.env.GIT_SHA || 'dev'
  });
});

// Submit a new form response
app.post('/api/submit', async (req, res) => {
  const { name, email, message } = req.body;

  if (!name || !email || !message) {
    return res.status(400).json({
      error: 'Please provide all required fields: name, email, and message.'
    });
  }

  try {
    const insertResult = await pool.query(
      `INSERT INTO submissions (name, email, message) VALUES ($1, $2, $3) RETURNING id`,
      [name.trim(), email.trim(), message.trim()]
    );
    const newId = insertResult.rows[0].id;

    res.status(201).json({
      success: true,
      id: newId,
      message: 'Submission saved successfully!'
    });
  } catch (err) {
    console.error('Failed to save submission:', err);
    res.status(500).json({ error: 'Failed to save submission to the database.' });
  }
});

// Retrieve all submissions
app.get('/api/submissions', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, name, email, message, created_at
      FROM submissions
      ORDER BY id DESC
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('Failed to fetch submissions:', err);
    res.status(500).json({ error: 'Failed to retrieve submissions.' });
  }
});

// Serve frontend when running locally without Nginx
const frontendDir = path.join(__dirname, '..', 'frontend');
if (fs.existsSync(frontendDir)) {
  app.use(express.static(frontendDir));
  app.get('/', (req, res) => res.sendFile(path.join(frontendDir, 'index.html')));
  app.get('/submissions', (req, res) => res.sendFile(path.join(frontendDir, 'submissions.html')));
}

function startServer(port) {
  const server = app.listen(port, '0.0.0.0', () => {
    console.log(`\n=================================================`);
    console.log(`⚡ FormFlow is running!`);
    console.log(`👉 Open in browser:  http://localhost:${port}`);
    console.log(`👉 View submissions: http://localhost:${port}/submissions`);
    console.log(`=================================================\n`);
    // No file‑based DB path for PostgreSQL
  });

  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE' && !process.env.PORT) {
      console.warn(`⚠️  Port ${port} is already in use. Trying port ${port + 1}...`);
      startServer(port + 1);
    } else {
      console.error('Server error:', err);
    }
  });
}

// Only start the server when not in a test environment
if (process.env.NODE_ENV !== 'test') {
  const initialPort = process.env.PORT ? parseInt(process.env.PORT, 10) : PORT;
  startServer(initialPort);
}

export { app, pool as db, startServer };
