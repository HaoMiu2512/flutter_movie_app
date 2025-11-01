require('dotenv').config();
const mongoose = require('mongoose');
const axios = require('axios');
const Movie = require('../models/Movie');

// TMDB API Configuration
const TMDB_API_KEY = 'e956f0d34451feb0d2ac9e6b5dab6823'; // API key từ Flutter app
const TMDB_BASE_URL = 'https://api.themoviedb.org/3';
const TMDB_IMAGE_BASE = 'https://image.tmdb.org/t/p/w500';

// Sample video URLs (vì TMDB không cung cấp video stream URLs)
const sampleVideos = [
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
];

// Genre mapping từ TMDB ID sang tên
const genreMap = {
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Science Fiction',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
};

// Fetch movies from TMDB
async function fetchTMDBMovies(endpoint, page = 1) {
  try {
    const url = `${TMDB_BASE_URL}${endpoint}?api_key=${TMDB_API_KEY}&page=${page}`;
    const response = await axios.get(url);
    return response.data.results || [];
  } catch (error) {
    console.error(`Error fetching from TMDB ${endpoint}:`, error.message);
    return [];
  }
}

// Fetch movie details from TMDB (cast, crew, videos, etc.)
async function fetchMovieDetails(tmdbId) {
  try {
    // Fetch movie details
    const detailsUrl = `${TMDB_BASE_URL}/movie/${tmdbId}?api_key=${TMDB_API_KEY}`;
    const detailsResponse = await axios.get(detailsUrl);
    const details = detailsResponse.data;

    // Fetch credits (cast & crew)
    const creditsUrl = `${TMDB_BASE_URL}/movie/${tmdbId}/credits?api_key=${TMDB_API_KEY}`;
    const creditsResponse = await axios.get(creditsUrl);
    const credits = creditsResponse.data;

    // Fetch videos (trailers)
    const videosUrl = `${TMDB_BASE_URL}/movie/${tmdbId}/videos?api_key=${TMDB_API_KEY}`;
    const videosResponse = await axios.get(videosUrl);
    const videos = videosResponse.data;

    return {
      runtime: details.runtime || 0,
      budget: details.budget || 0,
      revenue: details.revenue || 0,
      tagline: details.tagline || '',
      homepage: details.homepage || '',
      status: details.status || 'Released',
      originalLanguage: details.original_language || 'en',
      cast: (credits.cast || []).slice(0, 20).map(person => ({
        id: person.id,
        name: person.name,
        character: person.character,
        profilePath: person.profile_path ? `${TMDB_IMAGE_BASE}${person.profile_path}` : '',
        order: person.order
      })),
      crew: (credits.crew || [])
        .filter(person => ['Director', 'Writer', 'Producer', 'Director of Photography', 'Music'].includes(person.job))
        .slice(0, 15)
        .map(person => ({
          id: person.id,
          name: person.name,
          job: person.job,
          department: person.department,
          profilePath: person.profile_path ? `${TMDB_IMAGE_BASE}${person.profile_path}` : ''
        })),
      videos: (videos.results || [])
        .filter(video => 
          video.site === 'YouTube' && 
          ['Trailer', 'Teaser'].includes(video.type) &&
          video.key && video.key.length > 0 // Only videos with valid YouTube key
        )
        .slice(0, 5)
        .map(video => {
          // Ensure all fields are proper types
          return {
            id: String(video.id || ''),
            key: String(video.key || ''),
            name: String(video.name || ''),
            site: 'YouTube',
            type: String(video.type || 'Trailer'),
            official: Boolean(video.official)
          };
        }),
      productionCompanies: (details.production_companies || []).slice(0, 5).map(company => ({
        id: company.id,
        name: company.name,
        logoPath: company.logo_path ? `${TMDB_IMAGE_BASE}${company.logo_path}` : ''
      }))
    };
  } catch (error) {
    console.error(`   ⚠️  Error fetching details for movie ${tmdbId}:`, error.message);
    return {
      runtime: 0,
      budget: 0,
      revenue: 0,
      tagline: '',
      homepage: '',
      status: 'Released',
      originalLanguage: 'en',
      cast: [],
      crew: [],
      videos: [],
      productionCompanies: []
    };
  }
}

// Convert TMDB movie to our format
async function convertTMDBMovie(tmdbMovie, index) {
  const genres = tmdbMovie.genre_ids 
    ? tmdbMovie.genre_ids.map(id => genreMap[id]).filter(Boolean)
    : ['Drama'];

  const releaseYear = tmdbMovie.release_date 
    ? new Date(tmdbMovie.release_date).getFullYear()
    : 2024;

  // Fetch detailed information
  const details = await fetchMovieDetails(tmdbMovie.id);

  return {
    tmdbId: tmdbMovie.id, // ✅ IMPORTANT: Store TMDB ID for details page
    title: tmdbMovie.title || tmdbMovie.original_title || 'Untitled',
    overview: tmdbMovie.overview || 'No description available.',
    poster: tmdbMovie.poster_path 
      ? `${TMDB_IMAGE_BASE}${tmdbMovie.poster_path}`
      : 'https://via.placeholder.com/500x750?text=No+Poster',
    video_url: sampleVideos[index % sampleVideos.length],
    rating: tmdbMovie.vote_average || 0,
    year: releaseYear,
    genre: genres.length > 0 ? genres : ['Drama'],
    isPro: tmdbMovie.vote_average >= 8.0, // Movies với rating >= 8.0 là Pro
    views: Math.floor(Math.random() * 10000), // Random views
    favoritesCount: 0,
    // Add detailed information
    ...details
  };
}

// Main import function
async function importMoviesFromTMDB() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    const categories = [
      { name: 'Popular Movies', endpoint: '/movie/popular', pages: 1 }, // 1 page = ~20 movies
    ];

    let totalImported = 0;
    let totalSkipped = 0;

    for (const category of categories) {
      console.log(`\n📥 Importing ${category.name}...`);
      
      for (let page = 1; page <= category.pages; page++) {
        const tmdbMovies = await fetchTMDBMovies(category.endpoint, page);
        
        for (let i = 0; i < tmdbMovies.length && totalImported < 10; i++) { // Stop at 10 movies
          const tmdbMovie = tmdbMovies[i];
          const movieData = await convertTMDBMovie(tmdbMovie, totalImported + i);

          try {
            // Check if movie already exists by title
            const existingMovie = await Movie.findOne({ 
              title: movieData.title,
              year: movieData.year 
            });

            if (existingMovie) {
              totalSkipped++;
              continue;
            }

            // Insert new movie
            await Movie.create(movieData);
            totalImported++;
            console.log(`   ✓ ${totalImported}. ${movieData.title} (${movieData.year})`);
            
            if (totalImported >= 10) {
              console.log(`\n   ✅ Reached 10 movies limit!`);
              break;
            }
          } catch (error) {
            if (error.code === 11000) {
              totalSkipped++;
            } else {
              console.error(`   ❌ Error importing ${movieData.title}:`, error.message);
            }
          }
          
          // Delay để tránh rate limit TMDB API (vì giờ gọi nhiều API hơn)
          await new Promise(resolve => setTimeout(resolve, 300));
        }
        
        if (totalImported >= 10) break; // Exit outer loop too

        console.log(`   Page ${page}/${category.pages} done`);
        
        // No need for extra delay between pages since we have delay per movie
      }
    }

    // Get final statistics
    const totalMovies = await Movie.countDocuments();
    
    console.log('\n');
    console.log('═══════════════════════════════════════════');
    console.log('✅ Import completed successfully!');
    console.log('═══════════════════════════════════════════');
    console.log(`📊 Statistics:`);
    console.log(`   - New movies imported: ${totalImported}`);
    console.log(`   - Skipped (duplicates): ${totalSkipped}`);
    console.log(`   - Total movies in DB: ${totalMovies}`);
    console.log('═══════════════════════════════════════════\n');

    // Show some sample movies
    const sampleMovies = await Movie.find().sort('-rating').limit(10);
    console.log('🎬 Top 10 Movies by Rating:');
    sampleMovies.forEach((movie, index) => {
      console.log(`   ${index + 1}. ${movie.title} (${movie.year}) - ⭐ ${movie.rating.toFixed(1)}`);
    });

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error importing movies:', error);
    process.exit(1);
  }
}

// Run import
console.log('🚀 Starting TMDB to MongoDB import...\n');
importMoviesFromTMDB();
