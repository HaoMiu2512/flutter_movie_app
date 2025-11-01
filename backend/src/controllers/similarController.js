const Similar = require('../models/Similar');

/**
 * Get all similar movies
 * GET /api/similar
 */
async function getSimilarMovies(req, res) {
  try {
    // Get similar movies sorted by popularity and rating
    const similar = await Similar.find()
      .sort({ popularity: -1, rating: -1 })
      .limit(10); // Return up to 10 items

    if (!similar || similar.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No similar movies found'
      });
    }

    // Format response for Flutter app
    const formattedResults = similar.map(movie => ({
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
    console.error('Error fetching similar movies:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch similar movies',
      error: error.message
    });
  }
}

/**
 * Get similar movie by TMDB ID
 * GET /api/similar/:tmdbId
 */
async function getSimilarMovieByTmdbId(req, res) {
  try {
    const { tmdbId } = req.params;
    const movie = await Similar.findOne({ tmdbId: parseInt(tmdbId) });

    if (!movie) {
      return res.status(404).json({
        success: false,
        message: 'Similar movie not found'
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
    console.error('Error fetching similar movie:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch similar movie',
      error: error.message
    });
  }
}

module.exports = {
  getSimilarMovies,
  getSimilarMovieByTmdbId
};
