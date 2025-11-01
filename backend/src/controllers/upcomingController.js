const Upcoming = require('../models/Upcoming');

/**
 * Get all upcoming movies
 * GET /api/movies/upcoming
 */
async function getUpcomingMovies(req, res) {
  try {
    // Get upcoming movies sorted by release date (nearest first)
    const upcoming = await Upcoming.find()
      .sort({ release_date: 1, popularity: -1 })
      .limit(20); // Return up to 20 items

    if (!upcoming || upcoming.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No upcoming movies found'
      });
    }

    // Format response similar to TMDB API
    const formattedResults = upcoming.map(movie => ({
      id: movie.id,
      poster_path: movie.poster_path,
      backdrop_path: movie.backdrop_path,
      title: movie.title,
      vote_average: movie.vote_average,
      overview: movie.overview,
      release_date: movie.release_date,
      popularity: movie.popularity,
      genre_ids: movie.genre_ids,
      original_language: movie.original_language,
      adult: movie.adult,
      video: movie.video,
      vote_count: movie.vote_count,
    }));

    res.json({
      success: true,
      results: formattedResults,
      total: formattedResults.length
    });
  } catch (error) {
    console.error('Error fetching upcoming movies:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch upcoming movies',
      error: error.message
    });
  }
}

module.exports = {
  getUpcomingMovies
};
