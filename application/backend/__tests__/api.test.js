import request from 'supertest';
import { app, db } from './server.js';

// Use PostgreSQL (test container should be set up separately)
// No setup needed for PostgreSQL test container (to be added later)

afterAll(() => {
  // Close the DB connection if needed
  db.close();
});

describe('FormFlow API', () => {
  test('POST /api/submit creates a submission', async () => {
    const response = await request(app)
      .post('/api/submit')
      .send({ name: 'Alice', email: 'alice@example.com', message: 'Hello' })
      .expect(201);
    expect(response.body).toHaveProperty('success', true);
    expect(response.body).toHaveProperty('id');
  });

  test('GET /api/submissions returns submissions', async () => {
    const response = await request(app)
      .get('/api/submissions')
      .expect(200);
    expect(Array.isArray(response.body)).toBe(true);
    // At least the submission we just added should be present
    const found = response.body.find((s) => s.email === 'alice@example.com');
    expect(found).toBeDefined();
  });
});
