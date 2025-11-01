require('dotenv').config();
const mongoose = require('mongoose');
const Movie = require('../models/Movie');

async function clearAndReimport() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Delete all movies
    const result = await Movie.deleteMany({});
    console.log(`🗑️  Deleted ${result.deletedCount} movies`);

    console.log('\n✅ Database cleared! Now run: npm run import-tmdb');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

clearAndReimport();
