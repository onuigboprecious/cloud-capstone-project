import express from 'express';
import { DatabaseSync } from 'node:sqlite';
import path from 'node:path';
import fs from 'node:fs';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Ensure database directory exists
const dataDir = path.join(__dirname, 'data');
if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir, { recursive: true });
}

// Initialize SQLite database
const dbPath = path.join(dataDir, 'formflow.db');
const db = new DatabaseSync(dbPath);

// Create submissions table if it doesn't exist
db.exec(`
  CREATE TABLE IF NOT EXISTS submissions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    message TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
`);

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// Health check endpoint (for deployment monitoring)
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'formflow', timestamp: new Date().toISOString() });
});

// Submit a new form response
app.post('/api/submit', (req, res) => {
  const { name, email, message } = req.body;

  if (!name || !email || !message) {
    return res.status(400).json({
      error: 'Please provide all required fields: name, email, and message.'
    });
  }

  try {
    const insert = db.prepare(`
      INSERT INTO submissions (name, email, message)
      VALUES (?, ?, ?)
    `);
    const result = insert.run(name.trim(), email.trim(), message.trim());

    res.status(201).json({
      success: true,
      id: Number(result.lastInsertRowid),
      message: 'Submission saved successfully!'
    });
  } catch (err) {
    console.error('Failed to save submission:', err);
    res.status(500).json({ error: 'Failed to save submission to the database.' });
  }
});

// Retrieve all submissions
app.get('/api/submissions', (req, res) => {
  try {
    const query = db.prepare(`
      SELECT id, name, email, message, created_at
      FROM submissions
      ORDER BY id DESC
    `);
    const submissions = query.all();
    res.json(submissions);
  } catch (err) {
    console.error('Failed to fetch submissions:', err);
    res.status(500).json({ error: 'Failed to retrieve submissions.' });
  }
});

// HTML page routes
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/submissions', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'submissions.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`FormFlow server is running on http://0.0.0.0:${PORT}`);
  console.log(`Database initialized at ${dbPath}`);
});
