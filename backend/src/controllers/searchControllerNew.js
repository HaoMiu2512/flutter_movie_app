const Movie = require('../models/Movie');
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
 * Helper function to transform TMDB movie to our schema
 */
function transformTMDBMovie(tmdbMovie) {
  const cacheExpiry = new Date(Date.now() + CACHE_DURATION.SEARCH);
  
  return {
    tmdbId: tmdbMovie.id,
    title: tmdbMovie.title,
    originalTitle: tmdbMovie.original_title,
    overview: tmdbMovie.overview || '',
    posterPath: tmdbMovie.poster_path,
    backdropPath: tmdbMovie.backdrop_path,
    releaseDate: tmdbMovie.release_date,
    voteAverage: tmdbMovie.vote_average || 0,
    voteCount: tmdbMovie.vote_count || 0,
    popularity: tmdbMovie.popularity || 0,
    genreIds: tmdbMovie.genre_ids || [],
    adult: tmdbMovie.adult || false,
    video: tmdbMovie.video || false,
    originalLanguage: tmdbMovie.original_language || 'en',
    cacheType: 'search',
    lastFetched: new Date(),
    cacheExpiry
  };
}

/**
 * Helper function to transform TMDB TV series to our schema
 */
function transformTMDBTVSeries(tmdbTV) {
  const cacheExpiry = new Date(Date.now() + CACHE_DURATION.SEARCH);
  
  return {
    tmdbId: tmdbTV.id,
    name: tmdbTV.name,
    originalName: tmdbTV.original_name,
    overview: tmdbTV.overview || '',
    posterPath: tmdbTV.poster_path,
    backdropPath: tmdbTV.backdrop_path,
    firstAirDate: tmdbTV.first_air_date,
    voteAverage: tmdbTV.vote_average || 0,
    voteCount: tmdbTV.vote_count || 0,
    popularity: tmdbTV.popularity || 0,
    genreIds: tmdbTV.genre_ids || [],
    originCountry: tmdbTV.origin_country || [],
    originalLanguage: tmdbTV.original_language || 'en',
    cacheType: 'search',
    lastFetched: new Date(),
    cacheExpiry
  };
}

/**
 * Search multi (movies and TV series)
 * Enhanced: Search across ALL cached data (trending, popular, top rated, upcoming, etc.)
 * GET /api/search?q=avatar
 * GET /api/search/multi?query=avatar
 */
async function searchMulti(req, res) {
  try {
    // Accept both 'q' and 'query' parameters for flexibility
    const { query, q, forceRefresh = false } = req.query;
    const searchParam = query || q;
    
    if (!searchParam || searchParam.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }
    
    const searchQuery = searchParam.trim().toLowerCase();
    
    // Search in ALL cached data (not just 'search' type)
    // This includes: trending, popular, top_rated, upcoming, on_the_air, etc.
    if (!forceRefresh) {
      try {
        // Search movies - match title or overview (case-insensitive)
        const cachedMovies = await Movie.find({
          $or: [
            { title: { $regex: searchQuery, $options: 'i' } },
            { originalTitle: { $regex: searchQuery, $options: 'i' } },
            { overview: { $regex: searchQuery, $options: 'i' } }
          ]
        })
          .sort({ popularity: -1, voteAverage: -1 })
          .limit(10);
        
        // Search TV series - match name or overview (case-insensitive)
        const cachedTV = await TvSeries.find({
          $or: [
            { name: { $regex: searchQuery, $options: 'i' } },
            { originalName: { $regex: searchQuery, $options: 'i' } },
            { overview: { $regex: searchQuery, $options: 'i' } }
          ]
        })
          .sort({ popularity: -1, voteAverage: -1 })
          .limit(10);
        
        if (cachedMovies.length > 0 || cachedTV.length > 0) {
          const results = [
            ...cachedMovies.map(m => ({
              id: m.tmdbId,
              poster_path: m.posterPath,
              backdrop_path: m.backdropPath,
              title: m.title,
              overview: m.overview,
              vote_average: m.voteAverage,
              popularity: m.popularity,
          release_date: m.releaseDate,
              media_type: 'movie',
              genre_ids: m.genreIds || []
            })),
            ...cachedTV.map(t => ({
              id: t.tmdbId,
              poster_path: t.posterPath,
              backdrop_path: t.backdropPath,
              name: t.name,
              title: t.name, // For consistency
              overview: t.overview,
              vote_average: t.voteAverage,
              popularity: t.popularity,
              first_air_date: t.firstAirDate,
              media_type: 'tv',
              genre_ids: t.genreIds || []
            }))
          ];
          
          // Sort by popularity
          results.sort((a, b) => (b.popularity || 0) - (a.popularity || 0));
          
          console.log(`✅ Found ${results.length} results for "${searchQuery}" in cached database (${cachedMovies.length} movies, ${cachedTV.length} TV)`);
          return res.json({
            success: true,
            source: 'cache',
            query: searchQuery,
            results: results.slice(0, 20), // Limit to 20 total
            total: results.length
          });
        }
      } catch (cacheError) {
        console.error('Cache search error:', cacheError);
        // Continue to TMDB fallback
      }
    }
    
    // Fetch from TMDB if no cache results
    console.log(`🔄 Searching "${searchQuery}" on TMDB...`);
    const tmdbResults = await TMDBService.searchMulti(searchQuery);
    
    // Save to cache
    const savePromises = tmdbResults.slice(0, 10).map(async (item) => {
      if (item.media_type === 'movie') {
        const movieData = transformTMDBMovie(item);
        await Movie.findOneAndUpdate(
          { tmdbId: item.id },
          movieData,
          { upsert: true, new: true }
        );
        return { 
          id: item.id,
          poster_path: item.poster_path,
          backdrop_path: item.backdrop_path,
          title: item.title,
          overview: item.overview,
          vote_average: item.vote_average,
          popularity: item.popularity,
          release_date: item.release_date,
          media_type: 'movie',
          genre_ids: item.genre_ids || []
        };
      } else if (item.media_type === 'tv') {
        const tvData = transformTMDBTVSeries(item);
        await TvSeries.findOneAndUpdate(
          { tmdbId: item.id },
          tvData,
          { upsert: true, new: true }
        );
        return {
          id: item.id,
          poster_path: item.poster_path,
          backdrop_path: item.backdrop_path,
          name: item.name,
          title: item.name,
          overview: item.overview,
          vote_average: item.vote_average,
          popularity: item.popularity,
          first_air_date: item.first_air_date,
          media_type: 'tv',
          genre_ids: item.genre_ids || []
        };
      }
      return null;
    });
    
    const savedResults = (await Promise.all(savePromises)).filter(r => r !== null);
    console.log(`✅ Cached ${savedResults.length} search results from TMDB for "${searchQuery}"`);
    
    res.json({
      success: true,
      source: 'tmdb',
      query: searchQuery,
      results: savedResults,
      total: savedResults.length
    });
  } catch (error) {
    console.error('Error in searchMulti:', error);
    res.status(500).json({
      success: false,
      message: 'Error searching',
      error: error.message
    });
  }
}

/**
 * Search movies only
 * Enhanced: Search across ALL cached movies (trending, popular, top rated, upcoming, etc.)
 * GET /api/search/movies?query=avatar
 * GET /api/search/movies?q=avatar
 */
async function searchMovies(req, res) {
  try {
    // Accept both 'q' and 'query' parameters
    const { query, q, forceRefresh = false } = req.query;
    const searchParam = query || q;
    
    if (!searchParam || searchParam.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }
    
    const searchQuery = searchParam.trim().toLowerCase();
    
    // Search in ALL cached movies (not just 'search' type)
    if (!forceRefresh) {
      try {
        const cachedMovies = await Movie.find({
          $or: [
            { title: { $regex: searchQuery, $options: 'i' } },
            { originalTitle: { $regex: searchQuery, $options: 'i' } },
            { overview: { $regex: searchQuery, $options: 'i' } }
          ]
        })
          .sort({ popularity: -1, voteAverage: -1 })
          .limit(10);
        
        if (cachedMovies.length > 0) {
          const results = cachedMovies.map(m => ({
            id: m.tmdbId,
            poster_path: m.posterPath,
            backdrop_path: m.backdropPath,
            title: m.title,
            overview: m.overview,
            vote_average: m.voteAverage,
            popularity: m.popularity,
            release_date: m.releaseDate,
            media_type: 'movie',
            genre_ids: m.genreIds || []
          }));
          
          console.log(`✅ Found ${results.length} movie results for "${searchQuery}" in cached database`);
          return res.json({
            success: true,
            source: 'cache',
            query: searchQuery,
            results,
            total: results.length
          });
        }
      } catch (cacheError) {
        console.error('Cache search error:', cacheError);
        // Continue to TMDB fallback
      }
    }
    
    // Fetch from TMDB
    console.log(`🔄 Searching movies for "${searchQuery}" on TMDB...`);
    const tmdbMovies = await TMDBService.searchMovies(searchQuery);
    
    // Save to cache
    const savePromises = tmdbMovies.slice(0, 10).map(async (tmdbMovie) => {
      const movieData = transformTMDBMovie(tmdbMovie);
      await Movie.findOneAndUpdate(
        { tmdbId: tmdbMovie.id },
        movieData,
        { upsert: true, new: true }
      );
      return {
        id: tmdbMovie.id,
        poster_path: tmdbMovie.poster_path,
        backdrop_path: tmdbMovie.backdrop_path,
        title: tmdbMovie.title,
        overview: tmdbMovie.overview,
        vote_average: tmdbMovie.vote_average,
        popularity: tmdbMovie.popularity,
        release_date: tmdbMovie.release_date,
        media_type: 'movie',
        genre_ids: tmdbMovie.genre_ids || []
      };
    });
    
    const savedMovies = await Promise.all(savePromises);
    console.log(`✅ Cached ${savedMovies.length} movie search results from TMDB for "${searchQuery}"`);
    
    res.json({
      success: true,
      source: 'tmdb',
      query: searchQuery,
      results: savedMovies,
      total: savedMovies.length
    });
  } catch (error) {
    console.error('Error in searchMovies:', error);
    res.status(500).json({
      success: false,
      message: 'Error searching movies',
      error: error.message
    });
  }
}

/**
 * Search TV series only
 * Enhanced: Search across ALL cached TV series (popular, top rated, on the air, etc.)
 * GET /api/search/tv?query=game
 * GET /api/search/tv?q=game
 */
async function searchTV(req, res) {
  try {
    // Accept both 'q' and 'query' parameters
    const { query, q, forceRefresh = false } = req.query;
    const searchParam = query || q;
    
    if (!searchParam || searchParam.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }
    
    const searchQuery = searchParam.trim().toLowerCase();
    
    // Search in ALL cached TV series (not just 'search' type)
    if (!forceRefresh) {
      try {
        const cachedTV = await TvSeries.find({
          $or: [
            { name: { $regex: searchQuery, $options: 'i' } },
            { originalName: { $regex: searchQuery, $options: 'i' } },
            { overview: { $regex: searchQuery, $options: 'i' } }
          ]
        })
          .sort({ popularity: -1, voteAverage: -1 })
          .limit(10);
        
        if (cachedTV.length > 0) {
          const results = cachedTV.map(t => ({
            id: t.tmdbId,
            poster_path: t.posterPath,
            backdrop_path: t.backdropPath,
            name: t.name,
            title: t.name, // For consistency
            overview: t.overview,
            vote_average: t.voteAverage,
            popularity: t.popularity,
            first_air_date: t.firstAirDate,
            media_type: 'tv',
            genre_ids: t.genreIds || []
          }));
          
          console.log(`✅ Found ${results.length} TV results for "${searchQuery}" in cached database`);
          return res.json({
            success: true,
            source: 'cache',
            query: searchQuery,
            results,
            total: results.length
          });
        }
      } catch (cacheError) {
        console.error('Cache search error:', cacheError);
        // Continue to TMDB fallback
      }
    }
    
    // Fetch from TMDB
    console.log(`🔄 Searching TV for "${searchQuery}" on TMDB...`);
    const tmdbTV = await TMDBService.searchTV(searchQuery);
    
    // Save to cache
    const savePromises = tmdbTV.slice(0, 10).map(async (tmdbShow) => {
      const tvData = transformTMDBTVSeries(tmdbShow);
      await TvSeries.findOneAndUpdate(
        { tmdbId: tmdbShow.id },
        tvData,
        { upsert: true, new: true }
      );
      return {
        id: tmdbShow.id,
        poster_path: tmdbShow.poster_path,
        backdrop_path: tmdbShow.backdrop_path,
        name: tmdbShow.name,
        title: tmdbShow.name,
        overview: tmdbShow.overview,
        vote_average: tmdbShow.vote_average,
        popularity: tmdbShow.popularity,
        first_air_date: tmdbShow.first_air_date,
        media_type: 'tv',
        genre_ids: tmdbShow.genre_ids || []
      };
    });
    
    const savedTV = await Promise.all(savePromises);
    console.log(`✅ Cached ${savedTV.length} TV search results from TMDB for "${searchQuery}"`);
    
    res.json({
      success: true,
      source: 'tmdb',
      query: searchQuery,
      results: savedTV,
      total: savedTV.length
    });
  } catch (error) {
    console.error('Error in searchTV:', error);
    res.status(500).json({
      success: false,
      message: 'Error searching TV series',
      error: error.message
    });
  }
}

module.exports = {
  searchMulti,
  searchMovies,
  searchTV
};
