require('dotenv').config();
const app        = require('./app');
const { getPool, closePool } = require('./config/database');

const PORT = process.env.PORT || 3000;

const start = async () => {
  try {
    // Verify DB connection on startup
    await getPool();

    const server = app.listen(PORT, () => {
      console.log('');
      console.log('╔══════════════════════════════════════╗');
      console.log('║      🏢  Syndic API  v1.0.0          ║');
      console.log(`║      🚀  Running on port ${PORT}         ║`);
      console.log(`║      🌍  http://localhost:${PORT}        ║`);
      console.log('╚══════════════════════════════════════╝');
      console.log('');
    });

    // Graceful shutdown
    const shutdown = async (signal) => {
      console.log(`\n[${signal}] Shutting down gracefully...`);
      server.close(async () => {
        await closePool();
        console.log('Server closed.');
        process.exit(0);
      });
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT',  () => shutdown('SIGINT'));

  } catch (err) {
    console.error('❌ Failed to start server:', err.message);
    process.exit(1);
  }
};

start();
