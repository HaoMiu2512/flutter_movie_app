const mongoose = require('mongoose');
const axios = require('axios');
const TvSimilar = require('../models/TvSimilar');
const TvRecommended = require('../models/TvRecommended');

const TMDB_API_KEY = 'e956f0d34451feb0d2ac9e6b5dab6823';
const TMDB_BASE_URL = 'https://api.themoviedb.org/3';

// MongoDB connection - using flutter_movies database
mongoose.connect('mongodb://localhost:27017/flutter_movies', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ Connected to MongoDB'))
.catch(err => console.error('❌ MongoDB connection error:', err));

// Fetch TV series details with videos, credits, etc.
async function fetchTvSeriesDetails(tvId) {
  try {
    const response = await axios.get(
      `${TMDB_BASE_URL}/tv/${tvId}?api_key=${TMDB_API_KEY}&append_to_response=videos,credits,images`
    );
    return response.data;
  } catch (error) {
    console.error(`Error fetching TV ${tvId}:`, error.message);
    return null;
  }
}

// Transform TMDB TV data to our schema
function transformTvData(tv) {
  return {
    tmdbId: tv.id,
    title: tv.name || tv.original_name,
    overview: tv.overview,
    posterPath: tv.poster_path,
    backdropPath: tv.backdrop_path,
    voteAverage: tv.vote_average,
    voteCount: tv.vote_count,
    popularity: tv.popularity,
    firstAirDate: tv.first_air_date,
    originCountry: tv.origin_country || [],
    originalLanguage: tv.original_language,
    originalName: tv.original_name,
    genreIds: tv.genre_ids || [],
    genre: tv.genres ? tv.genres.map(g => g.name) : [],
    
    // Videos
    videos: tv.videos && tv.videos.results ? tv.videos.results.map(v => ({
      id: v.id,
      key: v.key,
      name: v.name,
      site: v.site,
      type: v.type,
      official: v.official,
      publishedAt: v.published_at
    })) : [],
    
    // Cast
    cast: tv.credits && tv.credits.cast ? tv.credits.cast.slice(0, 20).map(c => ({
      id: c.id,
      name: c.name,
      character: c.character,
      profilePath: c.profile_path,
      order: c.order
    })) : [],
    
    // Crew
    crew: tv.credits && tv.credits.crew ? tv.credits.crew.slice(0, 20).map(c => ({
      id: c.id,
      name: c.name,
      job: c.job,
      department: c.department,
      profilePath: c.profile_path
    })) : [],
    
    // Series-specific fields
    numberOfSeasons: tv.number_of_seasons,
    numberOfEpisodes: tv.number_of_episodes,
    episodeRunTime: tv.episode_run_time || [],
    status: tv.status,
    type: tv.type,
    
    createdBy: tv.created_by ? tv.created_by.map(c => ({
      id: c.id,
      name: c.name,
      profilePath: c.profile_path
    })) : [],
    
    networks: tv.networks ? tv.networks.map(n => ({
      id: n.id,
      name: n.name,
      logoPath: n.logo_path,
      originCountry: n.origin_country
    })) : [],
    
    productionCompanies: tv.production_companies ? tv.production_companies.map(p => ({
      id: p.id,
      name: p.name,
      logoPath: p.logo_path,
      originCountry: p.origin_country
    })) : [],
    
    seasons: tv.seasons ? tv.seasons.map(s => ({
      id: s.id,
      name: s.name,
      seasonNumber: s.season_number,
      episodeCount: s.episode_count,
      airDate: s.air_date,
      posterPath: s.poster_path,
      overview: s.overview
    })) : [],
    
    homepage: tv.homepage,
    inProduction: tv.in_production,
    languages: tv.languages || [],
    lastAirDate: tv.last_air_date,
    tagline: tv.tagline,
    adult: tv.adult || false
  };
}

// Import TV Similar (from TMDB Top Rated TV Shows)
async function importTvSimilar() {
  try {
    console.log('\n📺 Importing TV Similar series...');
    
    // Clear existing data
    await TvSimilar.deleteMany({});
    console.log('🗑️  Cleared existing TV Similar data');
    
    // Fetch top rated TV shows from TMDB
    const response = await axios.get(
      `${TMDB_BASE_URL}/tv/top_rated?api_key=${TMDB_API_KEY}&language=en-US&page=1`
    );
    
    const tvShows = response.data.results.slice(0, 10); // Get 10 TV shows
    console.log(`📥 Fetched ${tvShows.length} top rated TV shows from TMDB`);
    
    // Get detailed info for each TV show
    const tvDetailsPromises = tvShows.map(tv => fetchTvSeriesDetails(tv.id));
    const tvDetails = await Promise.all(tvDetailsPromises);
    
    // Transform and save
    const validTvShows = tvDetails.filter(tv => tv !== null);
    const transformedTvShows = validTvShows.map(transformTvData);
    
    for (const tv of transformedTvShows) {
      await TvSimilar.create(tv);
      console.log(`  ✅ Imported: ${tv.title} (ID: ${tv.tmdbId}) - ${tv.videos.length} videos`);
    }
    
    console.log(`\n✅ Successfully imported ${transformedTvShows.length} TV Similar series`);
  } catch (error) {
    console.error('❌ Error importing TV Similar:', error.message);
  }
}

// Import TV Recommended (from TMDB Popular TV Shows)
async function importTvRecommended() {
  try {
    console.log('\n📺 Importing TV Recommended series...');
    
    // Clear existing data
    await TvRecommended.deleteMany({});
    console.log('🗑️  Cleared existing TV Recommended data');
    
    // Fetch popular TV shows from TMDB
    const response = await axios.get(
      `${TMDB_BASE_URL}/tv/popular?api_key=${TMDB_API_KEY}&language=en-US&page=1`
    );
    
    const tvShows = response.data.results.slice(0, 10); // Get 10 TV shows
    console.log(`📥 Fetched ${tvShows.length} popular TV shows from TMDB`);
    
    // Get detailed info for each TV show
    const tvDetailsPromises = tvShows.map(tv => fetchTvSeriesDetails(tv.id));
    const tvDetails = await Promise.all(tvDetailsPromises);
    
    // Transform and save
    const validTvShows = tvDetails.filter(tv => tv !== null);
    const transformedTvShows = validTvShows.map(transformTvData);
    
    for (const tv of transformedTvShows) {
      await TvRecommended.create(tv);
      console.log(`  ✅ Imported: ${tv.title} (ID: ${tv.tmdbId}) - ${tv.videos.length} videos`);
    }
    
    console.log(`\n✅ Successfully imported ${transformedTvShows.length} TV Recommended series`);
  } catch (error) {
    console.error('❌ Error importing TV Recommended:', error.message);
  }
}

// Main execution
async function main() {
  try {
    console.log('🚀 Starting TV Similar & Recommended import...\n');
    
    await importTvSimilar();
    await importTvRecommended();
    
    console.log('\n🎉 All TV imports completed!');
    console.log('📊 Summary:');
    console.log(`  - TV Similar: ${await TvSimilar.countDocuments()} series`);
    console.log(`  - TV Recommended: ${await TvRecommended.countDocuments()} series`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Fatal error:', error);
    process.exit(1);
  }
}

main();
