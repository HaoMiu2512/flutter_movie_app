const TvSeries = require('../models/TvSeries');
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
 * Helper function to transform TMDB TV series data to our schema
 */
function transformTMDBTVSeries(tmdbTV, cacheType = 'details') {
  const cacheExpiry = new Date(Date.now() + CACHE_DURATION[cacheType.toUpperCase()] || CACHE_DURATION.DETAILS);
  
  return {
    tmdbId: tmdbTV.id,
    name: tmdbTV.name,
    originalName: tmdbTV.original_name,
    overview: tmdbTV.overview || '',
    posterPath: tmdbTV.poster_path,
    backdropPath: tmdbTV.backdrop_path,
    voteAverage: tmdbTV.vote_average || 0,
    voteCount: tmdbTV.vote_count || 0,
    popularity: tmdbTV.popularity || 0,
    firstAirDate: tmdbTV.first_air_date,
    originalLanguage: tmdbTV.original_language || 'en',
    genres: tmdbTV.genres || [],
    numberOfSeasons: tmdbTV.number_of_seasons || 0,
    numberOfEpisodes: tmdbTV.number_of_episodes || 0,
    episodeRunTime: tmdbTV.episode_run_time || [],
    status: tmdbTV.status || 'Ended',
    type: tmdbTV.type || 'Scripted',
    tagline: tmdbTV.tagline || '',
    homepage: tmdbTV.homepage || '',
    inProduction: tmdbTV.in_production || false,
    cacheType,
    lastFetched: new Date(),
    cacheExpiry
  };
}

/**
 * Get popular TV series (with caching)
 * GET /api/tv-series/popular?page=1
 */
async function getPopularTVSeries(req, res) {
  try {
    const { page = 1, forceRefresh = false } = req.query;
    const cacheType = 'popular';
    
    // Check cache first
    if (!forceRefresh) {
      const cachedTVSeries = await TvSeries.find({ cacheType })
        .sort({ popularity: -1 })
        .limit(10);
      
      if (cachedTVSeries.length > 0 && isCacheValid(cachedTVSeries[0].lastFetched, CACHE_DURATION.POPULAR)) {
        console.log('✅ Serving popular TV series from cache');
        return res.json({
          success: true,
          source: 'cache',
          data: cachedTVSeries,
          pagination: {
            page: parseInt(page),
            limit: 10,
            total: cachedTVSeries.length,
            pages: 1
          }
        });
      }
    }
    
    // Fetch from TMDB
    console.log('🔄 Fetching popular TV series from TMDB...');
    const tmdbTVSeries = await TMDBService.getPopularTVSeries(page);
    
    // Save to cache
    const savePromises = tmdbTVSeries.map(async (tmdbTV) => {
      const tvData = transformTMDBTVSeries(tmdbTV, cacheType);
      return TvSeries.findOneAndUpdate(
        { tmdbId: tmdbTV.id, cacheType },
        tvData,
        { upsert: true, new: true }
      );
    });
    
    const savedTVSeries = await Promise.all(savePromises);
    console.log(`✅ Cached ${savedTVSeries.length} popular TV series`);
    
    // Return only first 10 items
    const limitedTVSeries = savedTVSeries.slice(0, 10);
    
    res.json({
      success: true,
      source: 'tmdb',
      data: limitedTVSeries,
      pagination: {
        page: parseInt(page),
        limit: 10,
        total: limitedTVSeries.length,
        pages: 1
      }
    });
  } catch (error) {
    console.error('Error in getPopularTVSeries:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching popular TV series',
      error: error.message
    });
  }
}

/**
 * Get top rated TV series (with caching)
 * GET /api/tv-series/top-rated?page=1
 */
async function getTopRatedTVSeries(req, res) {
  try {
    const { page = 1, forceRefresh = false } = req.query;
    const cacheType = 'top_rated';
    
    // Check cache first
    if (!forceRefresh) {
      const cachedTVSeries = await TvSeries.find({ cacheType })
        .sort({ voteAverage: -1 })
        .limit(10);
      
      if (cachedTVSeries.length > 0 && isCacheValid(cachedTVSeries[0].lastFetched, CACHE_DURATION.POPULAR)) {
        console.log('✅ Serving top rated TV series from cache');
        return res.json({
          success: true,
          source: 'cache',
          data: cachedTVSeries,
          pagination: {
            page: parseInt(page),
            limit: 10,
            total: cachedTVSeries.length,
            pages: 1
          }
        });
      }
    }
    
    // Fetch from TMDB
    console.log('🔄 Fetching top rated TV series from TMDB...');
    const tmdbTVSeries = await TMDBService.getTopRatedTVSeries(page);
    
    // Save to cache
    const savePromises = tmdbTVSeries.map(async (tmdbTV) => {
      const tvData = transformTMDBTVSeries(tmdbTV, cacheType);
      return TvSeries.findOneAndUpdate(
        { tmdbId: tmdbTV.id, cacheType },
        tvData,
        { upsert: true, new: true }
      );
    });
    
    const savedTVSeries = await Promise.all(savePromises);
    console.log(`✅ Cached ${savedTVSeries.length} top rated TV series`);
    
    // Return only first 10 items
    const limitedTVSeries = savedTVSeries.slice(0, 10);
    
    res.json({
      success: true,
      source: 'tmdb',
      data: limitedTVSeries,
      pagination: {
        page: parseInt(page),
        limit: 10,
        total: limitedTVSeries.length,
        pages: 1
      }
    });
  } catch (error) {
    console.error('Error in getTopRatedTVSeries:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching top rated TV series',
      error: error.message
    });
  }
}

/**
 * Get on the air TV series (with caching)
 * GET /api/tv-series/on-the-air?page=1
 */
async function getOnTheAirTVSeries(req, res) {
  try {
    const { page = 1, forceRefresh = false } = req.query;
    const cacheType = 'on_the_air';
    
    // Check cache first
    if (!forceRefresh) {
      const cachedTVSeries = await TvSeries.find({ cacheType })
        .sort({ popularity: -1 })
        .limit(10);
      
      if (cachedTVSeries.length > 0 && isCacheValid(cachedTVSeries[0].lastFetched, CACHE_DURATION.POPULAR)) {
        console.log('✅ Serving on the air TV series from cache');
        return res.json({
          success: true,
          source: 'cache',
          data: cachedTVSeries,
          pagination: {
            page: parseInt(page),
            limit: 10,
            total: cachedTVSeries.length,
            pages: 1
          }
        });
      }
    }
    
    // Fetch from TMDB
    console.log('🔄 Fetching on the air TV series from TMDB...');
    const tmdbTVSeries = await TMDBService.getOnTheAirTVSeries(page);
    
    // Save to cache
    const savePromises = tmdbTVSeries.map(async (tmdbTV) => {
      const tvData = transformTMDBTVSeries(tmdbTV, cacheType);
      return TvSeries.findOneAndUpdate(
        { tmdbId: tmdbTV.id, cacheType },
        tvData,
        { upsert: true, new: true }
      );
    });
    
    const savedTVSeries = await Promise.all(savePromises);
    console.log(`✅ Cached ${savedTVSeries.length} on the air TV series`);
    
    // Return only first 10 items
    const limitedTVSeries = savedTVSeries.slice(0, 10);
    
    res.json({
      success: true,
      source: 'tmdb',
      data: limitedTVSeries,
      pagination: {
        page: parseInt(page),
        limit: 10,
        total: limitedTVSeries.length,
        pages: 1
      }
    });
  } catch (error) {
    console.error('Error in getOnTheAirTVSeries:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching on the air TV series',
      error: error.message
    });
  }
}

/**
 * Get TV series details by TMDB ID (with caching)
 * GET /api/tv-series/:tmdbId
 */
async function getTVSeriesDetails(req, res) {
  try {
    const { tmdbId } = req.params;
    const { forceRefresh = false } = req.query;
    const cacheType = 'details';
    
    // Check cache first
    if (!forceRefresh) {
      const cachedTV = await TvSeries.findOne({ tmdbId: parseInt(tmdbId), cacheType });
      
      if (cachedTV && isCacheValid(cachedTV.lastFetched, CACHE_DURATION.DETAILS)) {
        console.log(`✅ Serving TV series ${tmdbId} from cache`);
        return res.json({
          success: true,
          source: 'cache',
          data: cachedTV
        });
      }
    }
    
    // Fetch from TMDB
    console.log(`🔄 Fetching TV series ${tmdbId} from TMDB...`);
    const tmdbTV = await TMDBService.getTVSeriesDetails(tmdbId);
    
    // Transform and add additional data
    const tvData = transformTMDBTVSeries(tmdbTV, cacheType);
    
    // Add seasons
    if (tmdbTV.seasons) {
      tvData.seasons = tmdbTV.seasons.map(season => ({
        id: season.id,
        name: season.name,
        overview: season.overview,
        posterPath: season.poster_path,
        seasonNumber: season.season_number,
        episodeCount: season.episode_count,
        airDate: season.air_date
      }));
    }
    
    // Add cast
    if (tmdbTV.credits && tmdbTV.credits.cast) {
      tvData.cast = tmdbTV.credits.cast.slice(0, 20).map(person => ({
        id: person.id,
        name: person.name,
        character: person.character,
        profilePath: person.profile_path,
        order: person.order
      }));
    }
    
    // Add crew
    if (tmdbTV.credits && tmdbTV.credits.crew) {
      tvData.crew = tmdbTV.credits.crew.slice(0, 15).map(person => ({
        id: person.id,
        name: person.name,
        job: person.job,
        department: person.department,
        profilePath: person.profile_path
      }));
    }
    
    // Add videos
    if (tmdbTV.videos && tmdbTV.videos.results) {
      tvData.videos = tmdbTV.videos.results.slice(0, 5).map(video => ({
        id: video.id,
        key: video.key,
        name: video.name,
        site: video.site,
        type: video.type,
        official: video.official
      }));
    }
    
    // Add production companies
    if (tmdbTV.production_companies) {
      tvData.productionCompanies = tmdbTV.production_companies.map(company => ({
        id: company.id,
        name: company.name,
        logoPath: company.logo_path,
        originCountry: company.origin_country
      }));
    }
    
    // Save to cache
    const savedTV = await TvSeries.findOneAndUpdate(
      { tmdbId: parseInt(tmdbId), cacheType },
      tvData,
      { upsert: true, new: true }
    );
    
    console.log(`✅ Cached TV series ${tmdbId}`);
    
    res.json({
      success: true,
      source: 'tmdb',
      data: savedTV
    });
  } catch (error) {
    console.error('Error in getTVSeriesDetails:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching TV series details',
      error: error.message
    });
  }
}

/**
 * Get TV series videos by TMDB ID
 * GET /api/tv-series/:tmdbId/videos
 */
async function getTVSeriesVideos(req, res) {
  try {
    const { tmdbId } = req.params;
    
    // Check if TV series exists in cache with videos
    const cachedTV = await TvSeries.findOne({ tmdbId: parseInt(tmdbId), cacheType: 'details' });
    
    if (cachedTV && cachedTV.videos && cachedTV.videos.length > 0 && 
        isCacheValid(cachedTV.lastFetched, CACHE_DURATION.DETAILS)) {
      console.log(`✅ Serving videos for TV series ${tmdbId} from cache`);
      return res.json({
        success: true,
        source: 'cache',
        results: cachedTV.videos
      });
    }
    
    // Fetch from TMDB
    console.log(`🔄 Fetching videos for TV series ${tmdbId} from TMDB...`);
    const videos = await TMDBService.getTVSeriesVideos(tmdbId);
    
    // Update cache if TV series exists
    if (cachedTV) {
      cachedTV.videos = videos.slice(0, 5).map(video => ({
        id: video.id,
        key: video.key,
        name: video.name,
        site: video.site,
        type: video.type,
        official: video.official
      }));
      await cachedTV.save();
    }
    
    res.json({
      success: true,
      source: 'tmdb',
      results: videos
    });
  } catch (error) {
    console.error('Error in getTVSeriesVideos:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching TV series videos',
      error: error.message
    });
  }
}

module.exports = {
  getPopularTVSeries,
  getTopRatedTVSeries,
  getOnTheAirTVSeries,
  getTVSeriesDetails,
  getTVSeriesVideos
};
