const Movie = require('../models/Movie');

// Get all movies with optional filters
const getAllMovies = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      genre,
      year,
      isPro,
      sort = '-createdAt'
    } = req.query;

    const query = {};

    // Apply filters
    if (genre) {
      query.genre = genre;
    }
    if (year) {
      query.year = parseInt(year);
    }
    if (isPro !== undefined) {
      query.isPro = isPro === 'true';
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const movies = await Movie.find(query)
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Movie.countDocuments(query);

    res.json({
      success: true,
      data: movies,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching movies',
      error: error.message
    });
  }
};

// Get single movie by ID
const getMovieById = async (req, res) => {
  try {
    const movie = await Movie.findById(req.params.id);

    if (!movie) {
      return res.status(404).json({
        success: false,
        message: 'Movie not found'
      });
    }

    // Increment views count
    movie.views += 1;
    await movie.save();

    res.json({
      success: true,
      data: movie
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching movie',
      error: error.message
    });
  }
};

// Get movie by TMDB ID (for details page)
const getMovieByTmdbId = async (req, res) => {
  try {
    const { tmdbId } = req.params;
    const movie = await Movie.findOne({ tmdbId: parseInt(tmdbId) });

    if (!movie) {
      return res.status(404).json({
        success: false,
        message: 'Movie not found'
      });
    }

    // Increment views count
    movie.views += 1;
    await movie.save();

    res.json({
      success: true,
      data: movie
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching movie',
      error: error.message
    });
  }
};

// Search movies
const searchMovies = async (req, res) => {
  try {
    const { q, page = 1, limit = 20 } = req.query;

    if (!q) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const movies = await Movie.find({
      $or: [
        { title: { $regex: q, $options: 'i' } },
        { overview: { $regex: q, $options: 'i' } }
      ]
    })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Movie.countDocuments({
      $or: [
        { title: { $regex: q, $options: 'i' } },
        { overview: { $regex: q, $options: 'i' } }
      ]
    });

    res.json({
      success: true,
      data: movies,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error searching movies',
      error: error.message
    });
  }
};

// Get trending movies (most viewed)
const getTrendingMovies = async (req, res) => {
  try {
    const { limit = 10 } = req.query;

    const movies = await Movie.find()
      .sort('-views')
      .limit(parseInt(limit));

    res.json({
      success: true,
      data: movies
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching trending movies',
      error: error.message
    });
  }
};

// Get top rated movies
const getTopRatedMovies = async (req, res) => {
  try {
    const { limit = 10 } = req.query;

    const movies = await Movie.find()
      .sort('-rating')
      .limit(parseInt(limit));

    res.json({
      success: true,
      data: movies
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching top rated movies',
      error: error.message
    });
  }
};

// Get videos for a movie
const getMovieVideos = async (req, res) => {
  try {
    const { tmdbId } = req.params;
    const movie = await Movie.findOne({ tmdbId: parseInt(tmdbId) });

    if (!movie) {
      return res.status(404).json({
        success: false,
        message: 'Movie not found'
      });
    }

    // Return only videos in TMDB-compatible format
    res.json({
      success: true,
      data: {
        id: movie.tmdbId,
        results: movie.videos || []
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching movie videos',
      error: error.message
    });
  }
};

module.exports = {
  getAllMovies,
  getMovieById,
  getMovieByTmdbId,
  searchMovies,
  getTrendingMovies,
  getTopRatedMovies,
  getMovieVideos
};
