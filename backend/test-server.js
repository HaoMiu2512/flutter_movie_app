// Simple test server
const express = require('express');
const app = express();

app.get('/test', (req, res) => {
  res.json({ message: 'Test server working!' });
});

const server = app.listen(3000, '0.0.0.0', () => {
  console.log('✅ Test server listening on port 3000');
});

server.on('error', (err) => {
  console.error('❌ Server error:', err);
});

// Keep process alive
process.on('SIGINT', () => {
  console.log('\nShutting down...');
  server.close(() => {
    process.exit(0);
  });
});
