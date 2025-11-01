const mongoose = require('mongoose');
const axios = require('axios');
require('dotenv').config();

// Import existing models
const Movie = require('../models/Movie');
const TvSeries = require('../models/TvSeries');
const Trending = require('../models/Trending');
const Upcoming = require('../models/Upcoming');

// MongoDB Connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/movie_app';

// TMDB API Key
const TMDB_API_KEY = process.env.TMDB_API_KEY;

if (!TMDB_API_KEY) {
  console.error('❌ TMDB_API_KEY not found in environment variables');
  process.exit(1);
}

/**
 * Fetch detailed movie/TV data from TMDB and import to main collections
 */
async function importTrendingToMainCollections() {
  console.log('\n📊 Importing Trending items to main collections...');
  
  try {
    const trendingItems = await Trending.find();
    console.log(`Found ${trendingItems.length} trending items to process`);

    let movieCount = 0;
    let tvCount = 0;
    let skippedCount = 0;

    for (const item of trendingItems) {
      try {
        if (item.media_type === 'movie') {
          // Fetch full movie details from TMDB
          const response = await axios.get(
            `https://api.themoviedb.org/3/movie/${item.id}?api_key=${TMDB_API_KEY}&append_to_response=videos,credits,images`
          );
          
          const movieData = response.data;

          // Check if movie already exists
          const existingMovie = await Movie.findOne({ id: item.id });
          if (existingMovie) {
            console.log(`  ⏭️  Movie already exists: ${movieData.title} (ID: ${item.id})`);
            skippedCount++;
            continue;
          }

          // Prepare movie document
          const movieDoc = {
            id: movieData.id,
            title: movieData.title,
            original_title: movieData.original_title,
            overview: movieData.overview,
            poster_path: movieData.poster_path,
            backdrop_path: movieData.backdrop_path,
            release_date: movieData.release_date,
            vote_average: movieData.vote_average,
            vote_count: movieData.vote_count,
            popularity: movieData.popularity,
            genres: movieData.genres || [],
            runtime: movieData.runtime,
            status: movieData.status,
            budget: movieData.budget,
            revenue: movieData.revenue,
            original_language: movieData.original_language,
            spoken_languages: movieData.spoken_languages || [],
            production_companies: movieData.production_companies || [],
            production_countries: movieData.production_countries || [],
            adult: movieData.adult,
            video: movieData.video,
            homepage: movieData.homepage,
            imdb_id: movieData.imdb_id,
            tagline: movieData.tagline,
            videos: movieData.videos?.results || [],
            credits: {
              cast: movieData.credits?.cast || [],
              crew: movieData.credits?.crew || []
            },
            images: {
              backdrops: movieData.images?.backdrops || [],
              posters: movieData.images?.posters || [],
              logos: movieData.images?.logos || []
            }
          };

          await Movie.create(movieDoc);
          console.log(`  ✅ MOVIE: ${movieData.title} (ID: ${item.id})`);
          movieCount++;

        } else if (item.media_type === 'tv') {
          // Fetch full TV series details from TMDB
          const response = await axios.get(
            `https://api.themoviedb.org/3/tv/${item.id}?api_key=${TMDB_API_KEY}&append_to_response=videos,credits,images`
          );
          
          const tvData = response.data;

          // Check if TV series already exists
          const existingTv = await TvSeries.findOne({ id: item.id });
          if (existingTv) {
            console.log(`  ⏭️  TV Series already exists: ${tvData.name} (ID: ${item.id})`);
            skippedCount++;
            continue;
          }

          // Prepare TV series document
          const tvDoc = {
            id: tvData.id,
            name: tvData.name,
            original_name: tvData.original_name,
            overview: tvData.overview,
            poster_path: tvData.poster_path,
            backdrop_path: tvData.backdrop_path,
            first_air_date: tvData.first_air_date,
            last_air_date: tvData.last_air_date,
            vote_average: tvData.vote_average,
            vote_count: tvData.vote_count,
            popularity: tvData.popularity,
            genres: tvData.genres || [],
            episode_run_time: tvData.episode_run_time || [],
            number_of_episodes: tvData.number_of_episodes,
            number_of_seasons: tvData.number_of_seasons,
            seasons: tvData.seasons || [],
            status: tvData.status,
            type: tvData.type,
            original_language: tvData.original_language,
            spoken_languages: tvData.spoken_languages || [],
            production_companies: tvData.production_companies || [],
            production_countries: tvData.production_countries || [],
            networks: tvData.networks || [],
            created_by: tvData.created_by || [],
            homepage: tvData.homepage,
            in_production: tvData.in_production,
            languages: tvData.languages || [],
            origin_country: tvData.origin_country || [],
            tagline: tvData.tagline,
            videos: tvData.videos?.results || [],
            credits: {
              cast: tvData.credits?.cast || [],
              crew: tvData.credits?.crew || []
            },
            images: {
              backdrops: tvData.images?.backdrops || [],
              posters: tvData.images?.posters || [],
              logos: tvData.images?.logos || []
            }
          };

          await TvSeries.create(tvDoc);
          console.log(`  ✅ TV: ${tvData.name} (ID: ${item.id})`);
          tvCount++;
        }

        // Add small delay to avoid rate limiting
        await new Promise(resolve => setTimeout(resolve, 300));

      } catch (error) {
        console.error(`  ❌ Error importing ${item.media_type} ${item.id}:`, error.message);
        skippedCount++;
      }
    }

    console.log(`\n✅ Trending import complete:`);
    console.log(`  - Movies imported: ${movieCount}`);
    console.log(`  - TV series imported: ${tvCount}`);
    console.log(`  - Skipped: ${skippedCount}`);

  } catch (error) {
    console.error('❌ Error importing trending items:', error.message);
    throw error;
  }
}

async function importUpcomingToMainCollections() {
  console.log('\n🎬 Importing Upcoming movies to main collection...');
  
  try {
    const upcomingItems = await Upcoming.find();
    console.log(`Found ${upcomingItems.length} upcoming movies to process`);

    let importedCount = 0;
    let skippedCount = 0;

    for (const item of upcomingItems) {
      try {
        // Fetch full movie details from TMDB
        const response = await axios.get(
          `https://api.themoviedb.org/3/movie/${item.id}?api_key=${TMDB_API_KEY}&append_to_response=videos,credits,images`
        );
        
        const movieData = response.data;

        // Check if movie already exists
        const existingMovie = await Movie.findOne({ id: item.id });
        if (existingMovie) {
          console.log(`  ⏭️  Already exists: ${movieData.title} (ID: ${item.id})`);
          skippedCount++;
          continue;
        }

        // Prepare movie document (same structure as above)
        const movieDoc = {
          id: movieData.id,
          title: movieData.title,
          original_title: movieData.original_title,
          overview: movieData.overview,
          poster_path: movieData.poster_path,
          backdrop_path: movieData.backdrop_path,
          release_date: movieData.release_date,
          vote_average: movieData.vote_average,
          vote_count: movieData.vote_count,
          popularity: movieData.popularity,
          genres: movieData.genres || [],
          runtime: movieData.runtime,
          status: movieData.status,
          budget: movieData.budget,
          revenue: movieData.revenue,
          original_language: movieData.original_language,
          spoken_languages: movieData.spoken_languages || [],
          production_companies: movieData.production_companies || [],
          production_countries: movieData.production_countries || [],
          adult: movieData.adult,
          video: movieData.video,
          homepage: movieData.homepage,
          imdb_id: movieData.imdb_id,
          tagline: movieData.tagline,
          videos: movieData.videos?.results || [],
          credits: {
            cast: movieData.credits?.cast || [],
            crew: movieData.credits?.crew || []
          },
          images: {
            backdrops: movieData.images?.backdrops || [],
            posters: movieData.images?.posters || [],
            logos: movieData.images?.logos || []
          }
        };

        await Movie.create(movieDoc);
        console.log(`  ✅ ${movieData.title} (ID: ${item.id}) - Release: ${movieData.release_date}`);
        importedCount++;

        // Add small delay to avoid rate limiting
        await new Promise(resolve => setTimeout(resolve, 300));

      } catch (error) {
        console.error(`  ❌ Error importing movie ${item.id}:`, error.message);
        skippedCount++;
      }
    }

    console.log(`\n✅ Upcoming import complete:`);
    console.log(`  - Movies imported: ${importedCount}`);
    console.log(`  - Skipped: ${skippedCount}`);

  } catch (error) {
    console.error('❌ Error importing upcoming movies:', error.message);
    throw error;
  }
}

async function main() {
  console.log('🚀 Starting Detailed Import for Trending & Upcoming...\n');
  console.log(`📡 Connecting to MongoDB: ${MONGODB_URI}`);

  try {
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // Import Trending items to main collections
    await importTrendingToMainCollections();

    // Import Upcoming movies to main collection
    await importUpcomingToMainCollections();

    console.log('\n🎉 All detailed imports completed successfully!');
    
    // Show summary
    const movieCount = await Movie.countDocuments();
    const tvCount = await TvSeries.countDocuments();
    
    console.log('\n📊 Database Summary:');
    console.log(`  - Total Movies: ${movieCount}`);
    console.log(`  - Total TV Series: ${tvCount}`);

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
