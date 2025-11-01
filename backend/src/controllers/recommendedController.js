const Recommended = require('../models/Recommended');

/**
 * Get all recommended movies
 * GET /api/recommended
 */
async function getRecommendedMovies(req, res) {
  try {
    // Get recommended movies sorted by rating and popularity
    const recommended = await Recommended.find()
      .sort({ rating: -1, popularity: -1 })
      .limit(10); // Return up to 10 items

    if (!recommended || recommended.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No recommended movies found'
      });
    }

    // Format response for Flutter app
    const formattedResults = recommended.map(movie => ({
      id: movie.tmdbId,
      poster_path: movie.poster.replace('https://image.tmdb.org/t/p/w500', ''),
      title: movie.title,
      vote_average: movie.rating,
      overview: movie.overview,
      release_date: movie.year.toString(),
      popularity: movie.popularity,
      genre: movie.genre,
      runtime: movie.runtime,
      videos: movie.videos || []
    }));

    res.json({
      success: true,
      results: formattedResults,
      total: formattedResults.length
    });
  } catch (error) {
    console.error('Error fetching recommended movies:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch recommended movies',
      error: error.message
    });
  }
}

/**
 * Get recommended movie by TMDB ID
 * GET /api/recommended/:tmdbId
 */
async function getRecommendedMovieByTmdbId(req, res) {
  try {
    const { tmdbId } = req.params;
    const movie = await Recommended.findOne({ tmdbId: parseInt(tmdbId) });

    if (!movie) {
      return res.status(404).json({
        success: false,
        message: 'Recommended movie not found'
      });
    }

    res.json({
      success: true,
      data: {
        id: movie.tmdbId,
        title: movie.title,
        overview: movie.overview,
        poster: movie.poster,
        rating: movie.rating,
        year: movie.year,
        genre: movie.genre,
        runtime: movie.runtime,
        budget: movie.budget,
        revenue: movie.revenue,
        videos: movie.videos || [],
        productionCompanies: movie.productionCompanies || []
      }
    });
  } catch (error) {
    console.error('Error fetching recommended movie:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch recommended movie',
      error: error.message
    });
  }
}

module.exports = {
  getRecommendedMovies,
  getRecommendedMovieByTmdbId
};
