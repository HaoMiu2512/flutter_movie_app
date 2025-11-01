require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const axios = require('axios');
const mongoose = require('mongoose');
const TvSeries = require('../models/TvSeries');

// TMDB API Configuration
const TMDB_API_KEY = 'e956f0d34451feb0d2ac9e6b5dab6823'; // API key từ Flutter app
const TMDB_BASE_URL = 'https://api.themoviedb.org/3';

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('✅ Connected to MongoDB'))
.catch(err => {
  console.error('❌ MongoDB connection error:', err);
  process.exit(1);
});

// Delay helper
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Fetch TV series details from TMDB
async function fetchTvSeriesDetails(tmdbId) {
  try {
    // 1. Get basic TV series details
    const detailsResponse = await axios.get(
      `${TMDB_BASE_URL}/tv/${tmdbId}`,
      { params: { api_key: TMDB_API_KEY } }
    );
    const details = detailsResponse.data;
    
    // Delay before next request
    await delay(300);
    
    // 2. Get credits (cast and crew)
    const creditsResponse = await axios.get(
      `${TMDB_BASE_URL}/tv/${tmdbId}/credits`,
      { params: { api_key: TMDB_API_KEY } }
    );
    const credits = creditsResponse.data;
    
    // Delay before next request
    await delay(300);
    
    // 3. Get videos (trailers, teasers)
    const videosResponse = await axios.get(
      `${TMDB_BASE_URL}/tv/${tmdbId}/videos`,
      { params: { api_key: TMDB_API_KEY } }
    );
    const videos = videosResponse.data;
    
    // Process cast (top 20)
    const cast = (credits.cast || []).slice(0, 20).map(member => ({
      id: member.id,
      name: String(member.name || ''),
      character: String(member.character || ''),
      profilePath: member.profile_path ? String(member.profile_path) : null,
      order: Number(member.order || 0)
    }));
    
    // Process crew (top 15 key crew members)
    const crew = (credits.crew || []).slice(0, 15).map(member => ({
      id: member.id,
      name: String(member.name || ''),
      job: String(member.job || ''),
      department: String(member.department || ''),
      profilePath: member.profile_path ? String(member.profile_path) : null
    }));
    
    // Process videos (YouTube trailers/teasers only, max 5)
    const processedVideos = (videos.results || [])
      .filter(video => 
        video.site === 'YouTube' && 
        video.key && 
        (video.type === 'Trailer' || video.type === 'Teaser')
      )
      .slice(0, 5)
      .map(video => ({
        id: String(video.id || ''),
        key: String(video.key),
        name: String(video.name || ''),
        site: String(video.site),
        type: String(video.type),
        official: Boolean(video.official)
      }));
    
    // Process seasons
    const seasons = (details.seasons || []).map(season => ({
      id: season.id,
      name: String(season.name || ''),
      overview: String(season.overview || ''),
      posterPath: season.poster_path ? String(season.poster_path) : null,
      seasonNumber: Number(season.season_number || 0),
      episodeCount: Number(season.episode_count || 0),
      airDate: season.air_date ? String(season.air_date) : null
    }));
    
    // Process production companies
    const productionCompanies = (details.production_companies || []).map(company => ({
      id: company.id,
      name: String(company.name || ''),
      logoPath: company.logo_path ? String(company.logo_path) : null,
      originCountry: String(company.origin_country || '')
    }));
    
    // Process genres
    const genres = (details.genres || []).map(genre => ({
      id: genre.id,
      name: String(genre.name || '')
    }));
    
    return {
      tmdbId: Number(details.id),
      name: String(details.name || ''),
      overview: String(details.overview || ''),
      posterPath: details.poster_path ? String(details.poster_path) : null,
      backdropPath: details.backdrop_path ? String(details.backdrop_path) : null,
      voteAverage: Number(details.vote_average || 0),
      voteCount: Number(details.vote_count || 0),
      firstAirDate: details.first_air_date ? String(details.first_air_date) : null,
      genres,
      seasons,
      cast,
      crew,
      videos: processedVideos,
      productionCompanies,
      episodeRunTime: Array.isArray(details.episode_run_time) 
        ? details.episode_run_time.map(Number) 
        : [],
      numberOfSeasons: Number(details.number_of_seasons || 0),
      numberOfEpisodes: Number(details.number_of_episodes || 0),
      status: String(details.status || ''),
      type: String(details.type || ''),
      originalLanguage: String(details.original_language || ''),
      tagline: String(details.tagline || ''),
      homepage: String(details.homepage || ''),
      inProduction: Boolean(details.in_production)
    };
  } catch (error) {
    console.error(`❌ Error fetching details for TV series ${tmdbId}:`, error.message);
    return null;
  }
}

// Fetch TV series from multiple categories
async function fetchTvSeriesFromCategory(category, page = 1) {
  try {
    const response = await axios.get(
      `${TMDB_BASE_URL}/tv/${category}`,
      {
        params: {
          api_key: TMDB_API_KEY,
          page
        }
      }
    );
    return response.data.results || [];
  } catch (error) {
    console.error(`❌ Error fetching ${category} TV series:`, error.message);
    return [];
  }
}

// Main import function
async function importTvSeriesFromTMDB() {
  console.log('🚀 Starting TV series import from TMDB...\n');
  
  try {
    // Define categories and pages to fetch from
    const categories = [
      { name: 'popular', pages: 1 },
      { name: 'top_rated', pages: 1 }
    ];
    
    let allTvSeries = [];
    
    // Fetch TV series from each category
    for (const category of categories) {
      console.log(`📺 Fetching ${category.name} TV series...`);
      for (let page = 1; page <= category.pages; page++) {
        const series = await fetchTvSeriesFromCategory(category.name, page);
        allTvSeries = [...allTvSeries, ...series];
        await delay(300);
      }
    }
    
    // Remove duplicates based on TMDB ID
    const uniqueTvSeries = Array.from(
      new Map(allTvSeries.map(series => [series.id, series])).values()
    );
    
    console.log(`\n✅ Found ${uniqueTvSeries.length} unique TV series`);
    console.log('📥 Starting detailed import (limited to 10 for testing)...\n');
    
    let imported = 0;
    let skipped = 0;
    let failed = 0;
    let totalImported = 0;
    
    for (const series of uniqueTvSeries) {
      // Limit to 10 TV series for testing
      if (totalImported >= 10) {
        console.log('\n⚠️  Reached limit of 10 TV series (for testing)');
        break;
      }
      
      try {
        // Check if TV series already exists
        const existingSeries = await TvSeries.findOne({ tmdbId: series.id });
        if (existingSeries) {
          console.log(`⏭️  Skipping "${series.name}" (already exists)`);
          skipped++;
          continue;
        }
        
        // Fetch detailed information
        console.log(`📥 Importing "${series.name}" (ID: ${series.id})...`);
        const detailedSeries = await fetchTvSeriesDetails(series.id);
        
        if (!detailedSeries) {
          console.log(`   ❌ Failed to fetch details`);
          failed++;
          continue;
        }
        
        // Save to database
        const newSeries = new TvSeries(detailedSeries);
        await newSeries.save();
        
        console.log(`   ✅ Imported successfully`);
        console.log(`   - Cast: ${detailedSeries.cast.length} members`);
        console.log(`   - Crew: ${detailedSeries.crew.length} members`);
        console.log(`   - Videos: ${detailedSeries.videos.length} trailers/teasers`);
        console.log(`   - Seasons: ${detailedSeries.seasons.length} seasons`);
        console.log(`   - Episodes: ${detailedSeries.numberOfEpisodes} total episodes\n`);
        
        imported++;
        totalImported++;
        
        // Delay between imports
        await delay(1000);
      } catch (error) {
        console.error(`   ❌ Error importing "${series.name}":`, error.message);
        failed++;
      }
    }
    
    console.log('\n' + '='.repeat(50));
    console.log('📊 Import Summary:');
    console.log(`   ✅ Successfully imported: ${imported}`);
    console.log(`   ⏭️  Skipped (already exists): ${skipped}`);
    console.log(`   ❌ Failed: ${failed}`);
    console.log('='.repeat(50) + '\n');
    
  } catch (error) {
    console.error('❌ Fatal error during import:', error);
  } finally {
    await mongoose.connection.close();
    console.log('👋 Database connection closed');
  }
}

// Run the import
importTvSeriesFromTMDB();
