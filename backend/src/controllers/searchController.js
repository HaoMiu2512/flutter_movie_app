const Movie = require('../models/Movie');
const TvSeries = require('../models/TvSeries');
const Trending = require('../models/Trending');
const Upcoming = require('../models/Upcoming');

/**
 * Search across movies, TV series, trending, and upcoming collections
 * GET /api/search?q=query
 */
async function searchMulti(req, res) {
  try {
    const { q, limit = 20 } = req.query;

    if (!q || q.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }

    const searchQuery = q.trim();
    const searchLimit = parseInt(limit);

    // Search movies by title (case-insensitive regex)
    const moviePromise = Movie.find({
      title: { $regex: searchQuery, $options: 'i' }
    })
      .select('id title poster_path backdrop_path vote_average overview release_date popularity')
      .limit(searchLimit)
      .lean();

    // Search TV series by name (case-insensitive regex)
    const tvPromise = TvSeries.find({
      name: { $regex: searchQuery, $options: 'i' }
    })
      .select('id name poster_path backdrop_path vote_average overview first_air_date popularity')
      .limit(searchLimit)
      .lean();

    // Search trending (both movies and TV) by title or name
    const trendingPromise = Trending.find({
      $or: [
        { title: { $regex: searchQuery, $options: 'i' } },
        { name: { $regex: searchQuery, $options: 'i' } }
      ]
    })
      .select('id title name poster_path backdrop_path vote_average overview release_date first_air_date popularity media_type')
      .limit(searchLimit)
      .lean();

    // Search upcoming movies by title
    const upcomingPromise = Upcoming.find({
      title: { $regex: searchQuery, $options: 'i' }
    })
      .select('id title poster_path backdrop_path vote_average overview release_date popularity')
      .limit(searchLimit)
      .lean();

    // Execute all searches in parallel
    const [movies, tvSeries, trending, upcoming] = await Promise.all([
      moviePromise, 
      tvPromise, 
      trendingPromise, 
      upcomingPromise
    ]);

    // Format movies results
    const movieResults = movies.map(movie => ({
      id: movie.id,
      title: movie.title,
      poster_path: movie.poster_path,
      backdrop_path: movie.backdrop_path,
      vote_average: movie.vote_average,
      overview: movie.overview,
      release_date: movie.release_date,
      popularity: movie.popularity,
      media_type: 'movie'
    }));

    // Format TV series results
    const tvResults = tvSeries.map(tv => ({
      id: tv.id,
      name: tv.name,
      title: tv.name, // For consistency with frontend
      poster_path: tv.poster_path,
      backdrop_path: tv.backdrop_path,
      vote_average: tv.vote_average,
      overview: tv.overview,
      first_air_date: tv.first_air_date,
      release_date: tv.first_air_date, // For consistency
      popularity: tv.popularity,
      media_type: 'tv'
    }));

    // Format trending results (can be movies or TV)
    const trendingResults = trending.map(item => ({
      id: item.id,
      title: item.title || item.name,
      name: item.name || item.title,
      poster_path: item.poster_path,
      backdrop_path: item.backdrop_path,
      vote_average: item.vote_average,
      overview: item.overview,
      release_date: item.release_date || item.first_air_date,
      first_air_date: item.first_air_date || item.release_date,
      popularity: item.popularity,
      media_type: item.media_type
    }));

    // Format upcoming results (movies only)
    const upcomingResults = upcoming.map(movie => ({
      id: movie.id,
      title: movie.title,
      poster_path: movie.poster_path,
      backdrop_path: movie.backdrop_path,
      vote_average: movie.vote_average,
      overview: movie.overview,
      release_date: movie.release_date,
      popularity: movie.popularity,
      media_type: 'movie'
    }));

    // Combine all results and sort by popularity
    const combinedResults = [...movieResults, ...tvResults, ...trendingResults, ...upcomingResults]
      .sort((a, b) => (b.popularity || 0) - (a.popularity || 0))
      .slice(0, searchLimit);

    res.json({
      success: true,
      results: combinedResults,
      total: combinedResults.length,
      query: searchQuery
    });

  } catch (error) {
    console.error('Error searching:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to perform search',
      error: error.message
    });
  }
}

/**
 * Search movies only
 * GET /api/search/movies?q=query
 */
async function searchMovies(req, res) {
  try {
    const { q, limit = 20 } = req.query;

    if (!q || q.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }

    const searchQuery = q.trim();
    const searchLimit = parseInt(limit);

    const movies = await Movie.find({
      title: { $regex: searchQuery, $options: 'i' }
    })
      .select('id title poster_path backdrop_path vote_average overview release_date popularity')
      .limit(searchLimit)
      .sort({ popularity: -1 })
      .lean();

    const results = movies.map(movie => ({
      id: movie.id,
      title: movie.title,
      poster_path: movie.poster_path,
      backdrop_path: movie.backdrop_path,
      vote_average: movie.vote_average,
      overview: movie.overview,
      release_date: movie.release_date,
      popularity: movie.popularity,
      media_type: 'movie'
    }));

    res.json({
      success: true,
      results: results,
      total: results.length,
      query: searchQuery
    });

  } catch (error) {
    console.error('Error searching movies:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to search movies',
      error: error.message
    });
  }
}

/**
 * Search TV series only
 * GET /api/search/tv?q=query
 */
async function searchTvSeries(req, res) {
  try {
    const { q, limit = 20 } = req.query;

    if (!q || q.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }

    const searchQuery = q.trim();
    const searchLimit = parseInt(limit);

    const tvSeries = await TvSeries.find({
      name: { $regex: searchQuery, $options: 'i' }
    })
      .select('id name poster_path backdrop_path vote_average overview first_air_date popularity')
      .limit(searchLimit)
      .sort({ popularity: -1 })
      .lean();

    const results = tvSeries.map(tv => ({
      id: tv.id,
      name: tv.name,
      title: tv.name,
      poster_path: tv.poster_path,
      backdrop_path: tv.backdrop_path,
      vote_average: tv.vote_average,
      overview: tv.overview,
      first_air_date: tv.first_air_date,
      release_date: tv.first_air_date,
      popularity: tv.popularity,
      media_type: 'tv'
    }));

    res.json({
      success: true,
      results: results,
      total: results.length,
      query: searchQuery
    });

  } catch (error) {
    console.error('Error searching TV series:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to search TV series',
      error: error.message
    });
  }
}

module.exports = {
  searchMulti,
  searchMovies,
  searchTvSeries
};
