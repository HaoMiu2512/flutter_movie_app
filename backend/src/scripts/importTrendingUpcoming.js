const mongoose = require('mongoose');
const axios = require('axios');
require('dotenv').config();

// MongoDB Connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/movie_app';

// TMDB API Key
const TMDB_API_KEY = process.env.TMDB_API_KEY;

if (!TMDB_API_KEY) {
  console.error('❌ TMDB_API_KEY not found in environment variables');
  process.exit(1);
}

// Trending Schema (can be movies or TV series)
const trendingSchema = new mongoose.Schema({
  id: { type: Number, required: true, unique: true },
  poster_path: String,
  backdrop_path: String,
  title: String, // For movies
  name: String, // For TV series
  vote_average: Number,
  media_type: { type: String, enum: ['movie', 'tv'], required: true },
  overview: String,
  release_date: String, // For movies
  first_air_date: String, // For TV series
  popularity: Number,
  genre_ids: [Number],
  original_language: String,
  adult: Boolean,
  video: Boolean,
  vote_count: Number,
}, { timestamps: true });

// Upcoming Movies Schema
const upcomingSchema = new mongoose.Schema({
  id: { type: Number, required: true, unique: true },
  poster_path: String,
  backdrop_path: String,
  title: { type: String, required: true },
  vote_average: Number,
  overview: String,
  release_date: String,
  popularity: Number,
  genre_ids: [Number],
  original_language: String,
  adult: Boolean,
  video: Boolean,
  vote_count: Number,
}, { timestamps: true });

const Trending = mongoose.model('Trending', trendingSchema);
const Upcoming = mongoose.model('Upcoming', upcomingSchema);

async function importTrendingMovies() {
  console.log('\n📊 Importing Trending Movies/TV Series...');
  
  try {
    // Fetch trending (week) from TMDB
    const response = await axios.get(
      `https://api.themoviedb.org/3/trending/all/week?api_key=${TMDB_API_KEY}`
    );

    const trendingData = response.data.results.slice(0, 10); // Get first 10

    console.log(`Found ${trendingData.length} trending items from TMDB`);

    let importedCount = 0;
    let skippedCount = 0;

    for (const item of trendingData) {
      try {
        const trendingDoc = {
          id: item.id,
          poster_path: item.poster_path,
          backdrop_path: item.backdrop_path,
          title: item.title,
          name: item.name,
          vote_average: item.vote_average,
          media_type: item.media_type,
          overview: item.overview,
          release_date: item.release_date,
          first_air_date: item.first_air_date,
          popularity: item.popularity,
          genre_ids: item.genre_ids || [],
          original_language: item.original_language,
          adult: item.adult,
          video: item.video,
          vote_count: item.vote_count,
        };

        await Trending.updateOne(
          { id: item.id },
          { $set: trendingDoc },
          { upsert: true }
        );

        const displayName = item.media_type === 'movie' ? item.title : item.name;
        console.log(`  ✅ ${item.media_type.toUpperCase()}: ${displayName} (ID: ${item.id})`);
        importedCount++;
      } catch (error) {
        console.error(`  ❌ Error importing ${item.id}:`, error.message);
        skippedCount++;
      }
    }

    console.log(`\n✅ Trending import complete: ${importedCount} imported, ${skippedCount} skipped`);
  } catch (error) {
    console.error('❌ Error fetching trending from TMDB:', error.message);
    throw error;
  }
}

async function importUpcomingMovies() {
  console.log('\n🎬 Importing Upcoming Movies...');
  
  try {
    // Fetch upcoming movies from TMDB
    const response = await axios.get(
      `https://api.themoviedb.org/3/movie/upcoming?api_key=${TMDB_API_KEY}`
    );

    const upcomingData = response.data.results.slice(0, 10); // Get first 10

    console.log(`Found ${upcomingData.length} upcoming movies from TMDB`);

    let importedCount = 0;
    let skippedCount = 0;

    for (const movie of upcomingData) {
      try {
        const upcomingDoc = {
          id: movie.id,
          poster_path: movie.poster_path,
          backdrop_path: movie.backdrop_path,
          title: movie.title,
          vote_average: movie.vote_average,
          overview: movie.overview,
          release_date: movie.release_date,
          popularity: movie.popularity,
          genre_ids: movie.genre_ids || [],
          original_language: movie.original_language,
          adult: movie.adult,
          video: movie.video,
          vote_count: movie.vote_count,
        };

        await Upcoming.updateOne(
          { id: movie.id },
          { $set: upcomingDoc },
          { upsert: true }
        );

        console.log(`  ✅ ${movie.title} (ID: ${movie.id}) - Release: ${movie.release_date}`);
        importedCount++;
      } catch (error) {
        console.error(`  ❌ Error importing ${movie.id}:`, error.message);
        skippedCount++;
      }
    }

    console.log(`\n✅ Upcoming import complete: ${importedCount} imported, ${skippedCount} skipped`);
  } catch (error) {
    console.error('❌ Error fetching upcoming from TMDB:', error.message);
    throw error;
  }
}

async function main() {
  console.log('🚀 Starting Trending & Upcoming Import Script...\n');
  console.log(`📡 Connecting to MongoDB: ${MONGODB_URI}`);

  try {
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // Import Trending
    await importTrendingMovies();

    // Import Upcoming
    await importUpcomingMovies();

    console.log('\n🎉 All imports completed successfully!');
    
    // Show summary
    const trendingCount = await Trending.countDocuments();
    const upcomingCount = await Upcoming.countDocuments();
    
    console.log('\n📊 Database Summary:');
    console.log(`  - Trending items: ${trendingCount}`);
    console.log(`  - Upcoming movies: ${upcomingCount}`);

  } catch (error) {
    console.error('\n❌ Import failed:', error);
    process.exit(1);
  } finally {
    await mongoose.disconnect();
    console.log('\n👋 Disconnected from MongoDB');
    process.exit(0);
  }
}

// Run the import
main();
