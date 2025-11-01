/**
 * Fix MongoDB Index - Remove old unique tmdbId index and create compound index
 * Run: node fix-index.js
 */

const mongoose = require('mongoose');
require('dotenv').config();

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/flutter_movies';

async function fixIndexes() {
  try {
    console.log('🔌 Connecting to MongoDB...');
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Connected!');

    const db = mongoose.connection.db;
    const collection = db.collection('movies');

    // Get existing indexes
    console.log('\n📋 Current indexes:');
    const indexes = await collection.indexes();
    indexes.forEach(idx => {
      console.log(`  - ${idx.name}:`, JSON.stringify(idx.key));
    });

    // Drop old tmdbId_1 unique index if it exists
    try {
      console.log('\n🗑️  Attempting to drop old tmdbId_1 index...');
      await collection.dropIndex('tmdbId_1');
      console.log('✅ Dropped tmdbId_1 index');
    } catch (error) {
      if (error.code === 27 || error.codeName === 'IndexNotFound') {
        console.log('ℹ️  Index tmdbId_1 not found (already dropped or never existed)');
      } else {
        throw error;
      }
    }

    // Create new compound unique index
    console.log('\n🔨 Creating new compound index...');
    await collection.createIndex(
      { tmdbId: 1, cacheType: 1 },
      { unique: true, name: 'tmdbId_1_cacheType_1' }
    );
    console.log('✅ Created compound index: tmdbId_1_cacheType_1');

    // Verify new indexes
    console.log('\n📋 Updated indexes:');
    const newIndexes = await collection.indexes();
    newIndexes.forEach(idx => {
      console.log(`  - ${idx.name}:`, JSON.stringify(idx.key));
    });

    console.log('\n✨ Index fix complete!');
    console.log('\n💡 Next steps:');
    console.log('   1. Restart backend server');
    console.log('   2. Test: curl "http://localhost:3000/api/movies/popular?forceRefresh=true"');
    console.log('   3. Should see 10 movies cached successfully\n');

  } catch (error) {
    console.error('❌ Error fixing indexes:', error);
  } finally {
    await mongoose.connection.close();
    console.log('👋 Disconnected from MongoDB');
  }
}

fixIndexes();
