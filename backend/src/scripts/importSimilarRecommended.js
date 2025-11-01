const mongoose = require('mongoose');
const axios = require('axios');
require('dotenv').config();

// Import models
const Similar = require('../models/Similar');
const Recommended = require('../models/Recommended');

// MongoDB Connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/moviedb';

// TMDB API Key
const TMDB_API_KEY = process.env.TMDB_API_KEY;

if (!TMDB_API_KEY) {
  console.error('❌ TMDB_API_KEY not found in environment variables');
  process.exit(1);
}

/**
 * Fetch full movie details from TMDB
 */
async function fetchMovieDetails(movieId) {
  try {
    const response = await axios.get(
      `https://api.themoviedb.org/3/movie/${movieId}?api_key=${TMDB_API_KEY}&append_to_response=videos`
    );
    return response.data;
  } catch (error) {
    console.error(`  ❌ Error fetching movie ${movieId}:`, error.message);
    return null;
  }
}

/**
 * Transform TMDB movie data to our schema
 */
function transformMovieData(movieData) {
  // Extract year from release_date
  const year = movieData.release_date 
    ? parseInt(movieData.release_date.split('-')[0]) 
    : new Date().getFullYear();

  // Extract genres as array of strings
  const genres = movieData.genres 
    ? movieData.genres.map(g => g.name) 
    : [];

  // Transform videos array
  const videos = movieData.videos?.results 
    ? movieData.videos.results.map(v => ({
        id: v.id,
        key: v.key,
        name: v.name,
        site: v.site,
        type: v.type,
        official: v.official || false
      }))
    : [];

  // Transform production companies
  const productionCompanies = movieData.production_companies 
    ? movieData.production_companies.map(c => ({
        id: c.id,
        name: c.name,
        logoPath: c.logo_path
      }))
    : [];

  return {
    tmdbId: movieData.id,
    title: movieData.title,
    overview: movieData.overview || 'No overview available',
    poster: movieData.poster_path 
      ? `https://image.tmdb.org/t/p/w500${movieData.poster_path}` 
      : 'https://via.placeholder.com/500x750?text=No+Poster',
    rating: movieData.vote_average || 0,
    year: year,
    genre: genres,
    popularity: movieData.popularity || 0,
    runtime: movieData.runtime || 0,
    budget: movieData.budget || 0,
    revenue: movieData.revenue || 0,
    videos: videos,
    productionCompanies: productionCompanies
  };
}

/**
 * Import Similar movies (10 popular movies)
 */
async function importSimilarMovies() {
  console.log('\n🎬 Importing Similar movies...');
  
  try {
    // Clear existing data
    await Similar.deleteMany({});
    console.log('  🗑️  Cleared existing Similar movies');

    // Fetch popular movies from TMDB (page 1 = top 20, we'll take first 10)
    const popularResponse = await axios.get(
      `https://api.themoviedb.org/3/movie/popular?api_key=${TMDB_API_KEY}&language=en-US&page=1`
    );

    const popularMovies = popularResponse.data.results.slice(0, 10); // Take first 10
    console.log(`  📥 Fetching details for ${popularMovies.length} movies...`);

    let importedCount = 0;

    for (const movie of popularMovies) {
      try {
        // Fetch full details including videos
        const fullDetails = await fetchMovieDetails(movie.id);
        
        if (!fullDetails) {
          console.log(`  ⏭️  Skipping movie ${movie.id} - no details`);
          continue;
        }

        // Transform and save
        const movieDoc = transformMovieData(fullDetails);
        await Similar.create(movieDoc);
        
        console.log(`  ✅ ${fullDetails.title} (${movieDoc.year}) - Videos: ${movieDoc.videos.length}`);
        importedCount++;

        // Add delay to avoid rate limiting
        await new Promise(resolve => setTimeout(resolve, 300));

      } catch (error) {
        console.error(`  ❌ Error importing movie ${movie.id}:`, error.message);
      }
    }

    console.log(`\n✅ Similar import complete: ${importedCount} movies imported`);
    return importedCount;

  } catch (error) {
    console.error('❌ Error importing similar movies:', error.message);
    throw error;
  }
}

/**
 * Import Recommended movies (10 top rated movies)
 */
async function importRecommendedMovies() {
  console.log('\n⭐ Importing Recommended movies...');
  
  try {
    // Clear existing data
    await Recommended.deleteMany({});
    console.log('  🗑️  Cleared existing Recommended movies');

    // Fetch top rated movies from TMDB (page 1 = top 20, we'll take first 10)
    const topRatedResponse = await axios.get(
      `https://api.themoviedb.org/3/movie/top_rated?api_key=${TMDB_API_KEY}&language=en-US&page=1`
    );

    const topRatedMovies = topRatedResponse.data.results.slice(0, 10); // Take first 10
    console.log(`  📥 Fetching details for ${topRatedMovies.length} movies...`);

    let importedCount = 0;

    for (const movie of topRatedMovies) {
      try {
        // Fetch full details including videos
        const fullDetails = await fetchMovieDetails(movie.id);
        
        if (!fullDetails) {
          console.log(`  ⏭️  Skipping movie ${movie.id} - no details`);
          continue;
        }

        // Transform and save
        const movieDoc = transformMovieData(fullDetails);
        await Recommended.create(movieDoc);
        
        console.log(`  ✅ ${fullDetails.title} (${movieDoc.year}) - Videos: ${movieDoc.videos.length}`);
        importedCount++;

        // Add delay to avoid rate limiting
        await new Promise(resolve => setTimeout(resolve, 300));

      } catch (error) {
        console.error(`  ❌ Error importing movie ${movie.id}:`, error.message);
      }
    }

    console.log(`\n✅ Recommended import complete: ${importedCount} movies imported`);
    return importedCount;

  } catch (error) {
    console.error('❌ Error importing recommended movies:', error.message);
    throw error;
  }
}

async function main() {
  console.log('🚀 Starting Similar & Recommended Import...\n');
  console.log(`📡 Connecting to MongoDB: ${MONGODB_URI}`);

  try {
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // Import Similar movies
    const similarCount = await importSimilarMovies();

    // Import Recommended movies
    const recommendedCount = await importRecommendedMovies();

    console.log('\n🎉 All imports completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`  - Similar movies: ${similarCount}`);
    console.log(`  - Recommended movies: ${recommendedCount}`);

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
