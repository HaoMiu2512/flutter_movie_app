const Movie = require('../models/Movie');
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
 * Helper function to transform TMDB movie data to our schema
 */
function transformTMDBMovie(tmdbMovie, cacheType = 'details') {
  const cacheExpiry = new Date(Date.now() + CACHE_DURATION[cacheType.toUpperCase()] || CACHE_DURATION.DETAILS);
  
  return {
    tmdbId: tmdbMovie.id,
    title: tmdbMovie.title,
    originalTitle: tmdbMovie.original_title,
    overview: tmdbMovie.overview || '',
    posterPath: tmdbMovie.poster_path,
    backdropPath: tmdbMovie.backdrop_path,
    poster: tmdbMovie.poster_path ? `https://image.tmdb.org/t/p/w500${tmdbMovie.poster_path}` : null,
    voteAverage: tmdbMovie.vote_average || 0,
    voteCount: tmdbMovie.vote_count || 0,
    rating: tmdbMovie.vote_average || 0, // Legacy field
    popularity: tmdbMovie.popularity || 0,
    releaseDate: tmdbMovie.release_date,
    year: tmdbMovie.release_date ? new Date(tmdbMovie.release_date).getFullYear() : null,
    genreIds: tmdbMovie.genre_ids || [],
    genre: tmdbMovie.genres ? tmdbMovie.genres.map(g => g.name) : [], // Legacy field
    adult: tmdbMovie.adult || false,
    originalLanguage: tmdbMovie.original_language || 'en',
    runtime: tmdbMovie.runtime || 0,
    budget: tmdbMovie.budget || 0,
    revenue: tmdbMovie.revenue || 0,
    tagline: tmdbMovie.tagline || '',
    homepage: tmdbMovie.homepage || '',
    status: tmdbMovie.status || 'Released',
    cacheType,
    lastFetched: new Date(),
    cacheExpiry
  };
}

/**
 * Get popular movies (with caching)
 * GET /api/movies/popular?page=1
 */
async function getPopularMovies(req, res) {
  try {
    const { page = 1, forceRefresh = false, limit = 10 } = req.query;
    const cacheType = 'popular';
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);
    
    // Check cache first (unless force refresh)
    if (!forceRefresh) {
      // Get total count for pagination
      const totalCount = await Movie.countDocuments({ cacheType });
      console.log(`📊 Found ${totalCount} popular movies in cache`);
      
      // Calculate pagination with skip
      const skip = (pageNum - 1) * limitNum;
      const cachedMovies = await Movie.find({ cacheType })
        .sort({ popularity: -1 })
        .skip(skip)
        .limit(limitNum);
      
      if (cachedMovies.length > 0 && isCacheValid(cachedMovies[0].lastFetched, CACHE_DURATION.POPULAR)) {
        console.log(`✅ Serving popular movies from cache (page ${pageNum}, ${cachedMovies.length} items of ${totalCount} total)`);
        return res.json({
          success: true,
          source: 'cache',
          data: cachedMovies,
          pagination: {
            page: pageNum,
            limit: limitNum,
            total: totalCount,
            pages: Math.ceil(totalCount / limitNum)
          }
        });
      } else if (cachedMovies.length > 0) {
        console.log(`⚠️ Cache expired for popular movies. Refreshing from TMDB...`);
      } else {
        console.log(`⚠️ No cached popular movies found. Fetching from TMDB...`);
      }
    }
    
    // Fetch from TMDB
    console.log('🔄 Fetching popular movies from TMDB...');
    const tmdbMovies = await TMDBService.getPopularMovies(page);
    
    // Save to cache (upsert)
    const savePromises = tmdbMovies.map(async (tmdbMovie) => {
      const movieData = transformTMDBMovie(tmdbMovie, cacheType);
      return Movie.findOneAndUpdate(
        { tmdbId: tmdbMovie.id, cacheType },
        movieData,
        { upsert: true, new: true }
      );
    });
    
    const savedMovies = await Promise.all(savePromises);
    console.log(`✅ Cached ${savedMovies.length} popular movies`);
    
    // Return only first 10 items
    const limitedMovies = savedMovies.slice(0, 10);
    
    res.json({
      success: true,
      source: 'tmdb',
      data: limitedMovies,
      pagination: {
        page: parseInt(page),
        limit: 10,
        total: limitedMovies.length,
        pages: 1
      }
    });
  } catch (error) {
    console.error('Error in getPopularMovies:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching popular movies',
      error: error.message
    });
  }
}

/**
 * Get top rated movies (with caching)
 * GET /api/movies/top-rated?page=1
 */
async function getTopRatedMovies(req, res) {
  try {
    const { page = 1, forceRefresh = false, limit = 10 } = req.query;
    const cacheType = 'top_rated';
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);
    
    // Check cache first
    if (!forceRefresh) {
      // Get total count for pagination
      const totalCount = await Movie.countDocuments({ cacheType });
      
      // Calculate pagination with skip
      const skip = (pageNum - 1) * limitNum;
      const cachedMovies = await Movie.find({ cacheType })
        .sort({ voteAverage: -1 })
        .skip(skip)
        .limit(limitNum);
      
      if (cachedMovies.length > 0 && isCacheValid(cachedMovies[0].lastFetched, CACHE_DURATION.POPULAR)) {
        console.log(`✅ Serving top rated movies from cache (page ${pageNum}, ${cachedMovies.length} items)`);
        return res.json({
          success: true,
          source: 'cache',
          data: cachedMovies,
          pagination: {
            page: pageNum,
            limit: limitNum,
            total: totalCount,
            pages: Math.ceil(totalCount / limitNum)
          }
        });
      }
    }
    
    // Fetch from TMDB
    console.log('🔄 Fetching top rated movies from TMDB...');
    const tmdbMovies = await TMDBService.getTopRatedMovies(page);
    
    // Save to cache
    const savePromises = tmdbMovies.map(async (tmdbMovie) => {
      const movieData = transformTMDBMovie(tmdbMovie, cacheType);
      return Movie.findOneAndUpdate(
        { tmdbId: tmdbMovie.id, cacheType },
        movieData,
        { upsert: true, new: true }
      );
    });
    
    const savedMovies = await Promise.all(savePromises);
    console.log(`✅ Cached ${savedMovies.length} top rated movies`);
    
    // Return only first 10 items
    const limitedMovies = savedMovies.slice(0, 10);
    
    res.json({
      success: true,
      source: 'tmdb',
      data: limitedMovies,
      pagination: {
        page: parseInt(page),
        limit: 10,
        total: limitedMovies.length,
        pages: 1
      }
    });
  } catch (error) {
    console.error('Error in getTopRatedMovies:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching top rated movies',
      error: error.message
    });
  }
}

/**
 * Get upcoming movies (with caching)
 * GET /api/movies/upcoming?page=1
 */
async function getUpcomingMovies(req, res) {
  try {
    const { page = 1, forceRefresh = false, limit = 10 } = req.query;
    const cacheType = 'upcoming';
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);
    
    // Check cache first
    if (!forceRefresh) {
      // Get total count for pagination
      const totalCount = await Movie.countDocuments({ cacheType });
      
      // Calculate pagination with skip
      const skip = (pageNum - 1) * limitNum;
      const cachedMovies = await Movie.find({ cacheType })
        .sort({ releaseDate: -1 })
        .skip(skip)
        .limit(limitNum);
      
      if (cachedMovies.length > 0 && isCacheValid(cachedMovies[0].lastFetched, CACHE_DURATION.UPCOMING)) {
        console.log(`✅ Serving upcoming movies from cache (page ${pageNum}, ${cachedMovies.length} items)`);
        return res.json({
          success: true,
          source: 'cache',
          data: cachedMovies,
          pagination: {
            page: pageNum,
            limit: limitNum,
            total: totalCount,
            pages: Math.ceil(totalCount / limitNum)
          }
        });
      }
    }
    
    // Fetch from TMDB
    console.log('🔄 Fetching upcoming movies from TMDB...');
    const tmdbMovies = await TMDBService.getUpcomingMovies(page);
    
    // Save to cache
    const savePromises = tmdbMovies.map(async (tmdbMovie) => {
      const movieData = transformTMDBMovie(tmdbMovie, cacheType);
      return Movie.findOneAndUpdate(
        { tmdbId: tmdbMovie.id, cacheType },
        movieData,
        { upsert: true, new: true }
      );
    });
    
    const savedMovies = await Promise.all(savePromises);
    console.log(`✅ Cached ${savedMovies.length} upcoming movies`);
    
    // Return only first 10 items
    const limitedMovies = savedMovies.slice(0, 10);
    
    res.json({
      success: true,
      source: 'tmdb',
      data: limitedMovies,
      pagination: {
        page: parseInt(page),
        limit: 10,
        total: limitedMovies.length,
        pages: 1
      }
    });
  } catch (error) {
    console.error('Error in getUpcomingMovies:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching upcoming movies',
      error: error.message
    });
  }
}

/**
 * Get now playing movies (with caching)
 * GET /api/movies/now-playing?page=1
 */
async function getNowPlayingMovies(req, res) {
  try {
    const { page = 1, forceRefresh = false, limit = 10 } = req.query;
    const cacheType = 'now_playing';
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);
    
    // Check cache first
    if (!forceRefresh) {
      // Get total count for pagination
      const totalCount = await Movie.countDocuments({ cacheType });
      
      // Calculate pagination with skip
      const skip = (pageNum - 1) * limitNum;
      const cachedMovies = await Movie.find({ cacheType })
        .sort({ popularity: -1 })
        .skip(skip)
        .limit(limitNum);
      
      if (cachedMovies.length > 0 && isCacheValid(cachedMovies[0].lastFetched, CACHE_DURATION.POPULAR)) {
        console.log(`✅ Serving now playing movies from cache (page ${pageNum}, ${cachedMovies.length} items)`);
        return res.json({
          success: true,
          source: 'cache',
          data: cachedMovies,
          pagination: {
            page: pageNum,
            limit: limitNum,
            total: totalCount,
            pages: Math.ceil(totalCount / limitNum)
          }
        });
      }
    }
    
    // Fetch from TMDB
    console.log('🔄 Fetching now playing movies from TMDB...');
    const tmdbMovies = await TMDBService.getNowPlayingMovies(page);
    
    // Save to cache
    const savePromises = tmdbMovies.map(async (tmdbMovie) => {
      const movieData = transformTMDBMovie(tmdbMovie, cacheType);
      return Movie.findOneAndUpdate(
        { tmdbId: tmdbMovie.id, cacheType },
        movieData,
        { upsert: true, new: true }
      );
    });
    
    const savedMovies = await Promise.all(savePromises);
    console.log(`✅ Cached ${savedMovies.length} now playing movies`);
    
    // Return only first 10 items
    const limitedMovies = savedMovies.slice(0, 10);
    
    res.json({
      success: true,
      source: 'tmdb',
      data: limitedMovies,
      pagination: {
        page: parseInt(page),
        limit: 10,
        total: limitedMovies.length,
        pages: 1
      }
    });
  } catch (error) {
    console.error('Error in getNowPlayingMovies:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching now playing movies',
      error: error.message
    });
  }
}

/**
 * Get movie details by TMDB ID (with caching)
 * GET /api/movies/:tmdbId
 */
async function getMovieDetails(req, res) {
  try {
    const { tmdbId } = req.params;
    const { forceRefresh = false } = req.query;
    const cacheType = 'details';
    
    // Check cache first
    if (!forceRefresh) {
      const cachedMovie = await Movie.findOne({ tmdbId: parseInt(tmdbId), cacheType });
      
      if (cachedMovie && isCacheValid(cachedMovie.lastFetched, CACHE_DURATION.DETAILS)) {
        console.log(`✅ Serving movie ${tmdbId} from cache`);
        return res.json({
          success: true,
          source: 'cache',
          data: cachedMovie
        });
      }
    }
    
    // Fetch from TMDB
    console.log(`🔄 Fetching movie ${tmdbId} from TMDB...`);
    const tmdbMovie = await TMDBService.getMovieDetails(tmdbId);
    
    // Transform and add additional data
    const movieData = transformTMDBMovie(tmdbMovie, cacheType);
    
    // Add cast, crew, videos
    if (tmdbMovie.credits && tmdbMovie.credits.cast) {
      movieData.cast = tmdbMovie.credits.cast.slice(0, 20).map(person => ({
        id: person.id,
        name: person.name,
        character: person.character,
        profilePath: person.profile_path,
        order: person.order
      }));
    }
    
    if (tmdbMovie.credits && tmdbMovie.credits.crew) {
      movieData.crew = tmdbMovie.credits.crew.slice(0, 15).map(person => ({
        id: person.id,
        name: person.name,
        job: person.job,
        department: person.department,
        profilePath: person.profile_path
      }));
    }
    
    if (tmdbMovie.videos && tmdbMovie.videos.results) {
      movieData.videos = tmdbMovie.videos.results.slice(0, 5).map(video => ({
        id: video.id,
        key: video.key,
        name: video.name,
        site: video.site,
        type: video.type,
        official: video.official
      }));
    }
    
    if (tmdbMovie.production_companies) {
      movieData.productionCompanies = tmdbMovie.production_companies.map(company => ({
        id: company.id,
        name: company.name,
        logoPath: company.logo_path
      }));
    }
    
    // Save to cache
    const savedMovie = await Movie.findOneAndUpdate(
      { tmdbId: parseInt(tmdbId), cacheType },
      movieData,
      { upsert: true, new: true }
    );
    
    console.log(`✅ Cached movie ${tmdbId}`);
    
    res.json({
      success: true,
      source: 'tmdb',
      data: savedMovie
    });
  } catch (error) {
    console.error('Error in getMovieDetails:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching movie details',
      error: error.message
    });
  }
}

/**
 * Get movie videos by TMDB ID
 * GET /api/movies/:tmdbId/videos
 */
async function getMovieVideos(req, res) {
  try {
    const { tmdbId } = req.params;
    
    // Check if movie exists in cache with videos
    const cachedMovie = await Movie.findOne({ tmdbId: parseInt(tmdbId), cacheType: 'details' });
    
    if (cachedMovie && cachedMovie.videos && cachedMovie.videos.length > 0 && 
        isCacheValid(cachedMovie.lastFetched, CACHE_DURATION.DETAILS)) {
      console.log(`✅ Serving videos for movie ${tmdbId} from cache`);
      return res.json({
        success: true,
        source: 'cache',
        results: cachedMovie.videos
      });
    }
    
    // Fetch from TMDB
    console.log(`🔄 Fetching videos for movie ${tmdbId} from TMDB...`);
    const videos = await TMDBService.getMovieVideos(tmdbId);
    
    // Update cache if movie exists
    if (cachedMovie) {
      cachedMovie.videos = videos.slice(0, 5).map(video => ({
        id: video.id,
        key: video.key,
        name: video.name,
        site: video.site,
        type: video.type,
        official: video.official
      }));
      cachedMovie.lastFetched = new Date(); // ✅ Update timestamp!
      await cachedMovie.save();
      console.log(`💾 Cached ${cachedMovie.videos.length} videos for movie ${tmdbId}`);
    }
    
    res.json({
      success: true,
      source: 'tmdb',
      results: videos
    });
  } catch (error) {
    console.error('Error in getMovieVideos:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching movie videos',
      error: error.message
    });
  }
}

module.exports = {
  getPopularMovies,
  getTopRatedMovies,
  getUpcomingMovies,
  getNowPlayingMovies,
  getMovieDetails,
  getMovieVideos
};
