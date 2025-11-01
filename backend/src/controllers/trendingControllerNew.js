const Trending = require('../models/Trending');
const { TMDBService, CACHE_DURATION } = require('../services/tmdbService');

/**
 * Helper function to check if cache is valid
 */
function isCacheValid(lastFetched, cacheDuration) {
  if (!lastFetched) return false;
  const now = Date.now();
  const cacheAge = now - new Date(lastFetched).getTime();
  return cacheAge < cacheDuration;
}

/**
 * Helper function to transform TMDB trending data to our schema
 */
function transformTMDBTrending(tmdbItem, timeWindow = 'week') {
  const cacheExpiry = new Date(Date.now() + CACHE_DURATION.TRENDING);
  
  return {
    id: tmdbItem.id,
    poster_path: tmdbItem.poster_path,
    backdrop_path: tmdbItem.backdrop_path,
    title: tmdbItem.title || null, // For movies
    name: tmdbItem.name || null, // For TV series
    vote_average: tmdbItem.vote_average || 0,
    vote_count: tmdbItem.vote_count || 0,
    media_type: tmdbItem.media_type,
    overview: tmdbItem.overview || '',
    release_date: tmdbItem.release_date || null, // For movies
    first_air_date: tmdbItem.first_air_date || null, // For TV series
    popularity: tmdbItem.popularity || 0,
    genre_ids: tmdbItem.genre_ids || [],
    original_language: tmdbItem.original_language || 'en',
    adult: tmdbItem.adult || false,
    video: tmdbItem.video || false,
    timeWindow,
    lastFetched: new Date(),
    cacheExpiry
  };
}

/**
 * Get all trending (movies and TV series)
 * GET /api/trending?timeWindow=week
 */
async function getTrending(req, res) {
  try {
    const { timeWindow = 'week', forceRefresh = false } = req.query;
    
    // Validate timeWindow
    if (!['day', 'week'].includes(timeWindow)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid timeWindow. Must be "day" or "week"'
      });
    }
    
    // Check cache first
    if (!forceRefresh) {
      const cachedTrending = await Trending.find({ timeWindow })
        .sort({ popularity: -1, vote_average: -1 })
        .limit(10);
      
      if (cachedTrending.length > 0 && isCacheValid(cachedTrending[0].lastFetched, CACHE_DURATION.TRENDING)) {
        console.log(`✅ Serving trending (${timeWindow}) from cache`);
        return res.json({
          success: true,
          source: 'cache',
          results: cachedTrending,
          total: cachedTrending.length
        });
      }
    }
    
    // Fetch from TMDB
    console.log(`🔄 Fetching trending (${timeWindow}) from TMDB...`);
    const tmdbTrending = await TMDBService.getTrending('all', timeWindow);
    
    // Clear old trending for this timeWindow
    await Trending.deleteMany({ timeWindow });
    
    // Save new trending to cache
    const savePromises = tmdbTrending.map(async (tmdbItem) => {
      const trendingData = transformTMDBTrending(tmdbItem, timeWindow);
      return Trending.create(trendingData);
    });
    
    const savedTrending = await Promise.all(savePromises);
    console.log(`✅ Cached ${savedTrending.length} trending items (${timeWindow})`);
    
    res.json({
      success: true,
      source: 'tmdb',
      results: savedTrending,
      total: savedTrending.length
    });
  } catch (error) {
    console.error('Error in getTrending:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching trending',
      error: error.message
    });
  }
}

/**
 * Get trending movies only
 * GET /api/trending/movies?timeWindow=week
 */
async function getTrendingMovies(req, res) {
  try {
    const { timeWindow = 'week', forceRefresh = false } = req.query;
    
    // Validate timeWindow
    if (!['day', 'week'].includes(timeWindow)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid timeWindow. Must be "day" or "week"'
      });
    }
    
    // Check cache first
    if (!forceRefresh) {
      const cachedMovies = await Trending.find({ 
        timeWindow,
        media_type: 'movie'
      })
        .sort({ popularity: -1, vote_average: -1 })
        .limit(10);
      
      if (cachedMovies.length > 0 && isCacheValid(cachedMovies[0].lastFetched, CACHE_DURATION.TRENDING)) {
        console.log(`✅ Serving trending movies (${timeWindow}) from cache`);
        return res.json({
          success: true,
          source: 'cache',
          results: cachedMovies,
          total: cachedMovies.length
        });
      }
    }
    
    // Fetch from TMDB
    console.log(`🔄 Fetching trending movies (${timeWindow}) from TMDB...`);
    const tmdbMovies = await TMDBService.getTrending('movie', timeWindow);
    
    // Clear old trending movies for this timeWindow
    await Trending.deleteMany({ timeWindow, media_type: 'movie' });
    
    // Save to cache
    const savePromises = tmdbMovies.map(async (tmdbItem) => {
      const trendingData = transformTMDBTrending(tmdbItem, timeWindow);
      return Trending.create(trendingData);
    });
    
    const savedMovies = await Promise.all(savePromises);
    console.log(`✅ Cached ${savedMovies.length} trending movies (${timeWindow})`);
    
    res.json({
      success: true,
      source: 'tmdb',
      results: savedMovies,
      total: savedMovies.length
    });
  } catch (error) {
    console.error('Error in getTrendingMovies:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching trending movies',
      error: error.message
    });
  }
}

/**
 * Get trending TV series only
 * GET /api/trending/tv?timeWindow=week
 */
async function getTrendingTV(req, res) {
  try {
    const { timeWindow = 'week', forceRefresh = false } = req.query;
    
    // Validate timeWindow
    if (!['day', 'week'].includes(timeWindow)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid timeWindow. Must be "day" or "week"'
      });
    }
    
    // Check cache first
    if (!forceRefresh) {
      const cachedTV = await Trending.find({ 
        timeWindow,
        media_type: 'tv'
      })
        .sort({ popularity: -1, vote_average: -1 })
        .limit(10);
      
      if (cachedTV.length > 0 && isCacheValid(cachedTV[0].lastFetched, CACHE_DURATION.TRENDING)) {
        console.log(`✅ Serving trending TV (${timeWindow}) from cache`);
        return res.json({
          success: true,
          source: 'cache',
          results: cachedTV,
          total: cachedTV.length
        });
      }
    }
    
    // Fetch from TMDB
    console.log(`🔄 Fetching trending TV (${timeWindow}) from TMDB...`);
    const tmdbTV = await TMDBService.getTrending('tv', timeWindow);
    
    // Clear old trending TV for this timeWindow
    await Trending.deleteMany({ timeWindow, media_type: 'tv' });
    
    // Save to cache
    const savePromises = tmdbTV.map(async (tmdbItem) => {
      const trendingData = transformTMDBTrending(tmdbItem, timeWindow);
      return Trending.create(trendingData);
    });
    
    const savedTV = await Promise.all(savePromises);
    console.log(`✅ Cached ${savedTV.length} trending TV (${timeWindow})`);
    
    res.json({
      success: true,
      source: 'tmdb',
      results: savedTV,
      total: savedTV.length
    });
  } catch (error) {
    console.error('Error in getTrendingTV:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching trending TV',
      error: error.message
    });
  }
}

module.exports = {
  getTrending,
  getTrendingMovies,
  getTrendingTV
};
