const Trending = require('../models/Trending');

/**
 * Get all trending items (movies and TV series)
 * GET /api/trending
 */
async function getTrending(req, res) {
  try {
    const { timeWindow = 'week' } = req.query; // week or day (for future enhancement)
    
    // Get trending items sorted by popularity
    const trending = await Trending.find()
      .sort({ popularity: -1, vote_average: -1 })
      .limit(20); // Return up to 20 items

    if (!trending || trending.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No trending items found'
      });
    }

    // Format response similar to TMDB API
    const formattedResults = trending.map(item => ({
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
      genre_ids: item.genre_ids,
      original_language: item.original_language,
      adult: item.adult,
      video: item.video,
      vote_count: item.vote_count,
    }));

    res.json({
      success: true,
      results: formattedResults,
      total: formattedResults.length
    });
  } catch (error) {
    console.error('Error fetching trending:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch trending items',
      error: error.message
    });
  }
}

/**
 * Get trending movies only
 * GET /api/trending/movies
 */
async function getTrendingMovies(req, res) {
  try {
    const trending = await Trending.find({ media_type: 'movie' })
      .sort({ popularity: -1, vote_average: -1 })
      .limit(20);

    if (!trending || trending.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No trending movies found'
      });
    }

    const formattedResults = trending.map(item => ({
      id: item.id,
      poster_path: item.poster_path,
      backdrop_path: item.backdrop_path,
      title: item.title,
      vote_average: item.vote_average,
      media_type: item.media_type,
      overview: item.overview,
      release_date: item.release_date,
      popularity: item.popularity,
      genre_ids: item.genre_ids,
      original_language: item.original_language,
      adult: item.adult,
      video: item.video,
      vote_count: item.vote_count,
    }));

    res.json({
      success: true,
      results: formattedResults,
      total: formattedResults.length
    });
  } catch (error) {
    console.error('Error fetching trending movies:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch trending movies',
      error: error.message
    });
  }
}

/**
 * Get trending TV series only
 * GET /api/trending/tv
 */
async function getTrendingTv(req, res) {
  try {
    const trending = await Trending.find({ media_type: 'tv' })
      .sort({ popularity: -1, vote_average: -1 })
      .limit(20);

    if (!trending || trending.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No trending TV series found'
      });
    }

    const formattedResults = trending.map(item => ({
      id: item.id,
      poster_path: item.poster_path,
      backdrop_path: item.backdrop_path,
      name: item.name,
      vote_average: item.vote_average,
      media_type: item.media_type,
      overview: item.overview,
      first_air_date: item.first_air_date,
      popularity: item.popularity,
      genre_ids: item.genre_ids,
      original_language: item.original_language,
      adult: item.adult,
      vote_count: item.vote_count,
    }));

    res.json({
      success: true,
      results: formattedResults,
      total: formattedResults.length
    });
  } catch (error) {
    console.error('Error fetching trending TV series:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch trending TV series',
      error: error.message
    });
  }
}

module.exports = {
  getTrending,
  getTrendingMovies,
  getTrendingTv
};
