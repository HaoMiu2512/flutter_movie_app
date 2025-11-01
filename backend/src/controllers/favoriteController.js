const UserFavorite = require('../models/UserFavorite');
const Movie = require('../models/Movie');

// Get user's favorite movies
const getUserFavorites = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { page = 1, limit = 20 } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const favorites = await UserFavorite.find({ userId })
      .populate('movieId')
      .sort('-createdAt')
      .skip(skip)
      .limit(parseInt(limit));

    const total = await UserFavorite.countDocuments({ userId });

    // Extract movie data
    const movies = favorites.map(fav => fav.movieId);

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
      message: 'Error fetching favorites',
      error: error.message
    });
  }
};

// Add movie to favorites
const addToFavorites = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { movieId } = req.body;

    if (!movieId) {
      return res.status(400).json({
        success: false,
        message: 'Movie ID is required'
      });
    }

    // Check if movie exists
    const movie = await Movie.findById(movieId);
    if (!movie) {
      return res.status(404).json({
        success: false,
        message: 'Movie not found'
      });
    }

    // Check if already favorited
    const existingFavorite = await UserFavorite.findOne({ userId, movieId });
    if (existingFavorite) {
      return res.status(400).json({
        success: false,
        message: 'Movie already in favorites'
      });
    }

    // Create favorite
    const favorite = await UserFavorite.create({ userId, movieId });

    // Increment favoritesCount on movie
    movie.favoritesCount += 1;
    await movie.save();

    res.status(201).json({
      success: true,
      message: 'Movie added to favorites',
      data: favorite
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error adding to favorites',
      error: error.message
    });
  }
};

// Remove movie from favorites
const removeFromFavorites = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { movieId } = req.params;

    // Find and delete favorite
    const favorite = await UserFavorite.findOneAndDelete({ userId, movieId });

    if (!favorite) {
      return res.status(404).json({
        success: false,
        message: 'Favorite not found'
      });
    }

    // Decrement favoritesCount on movie
    const movie = await Movie.findById(movieId);
    if (movie && movie.favoritesCount > 0) {
      movie.favoritesCount -= 1;
      await movie.save();
    }

    res.json({
      success: true,
      message: 'Movie removed from favorites'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error removing from favorites',
      error: error.message
    });
  }
};

// Check if movie is favorited by user
const checkFavorite = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { movieId } = req.params;

    const favorite = await UserFavorite.findOne({ userId, movieId });

    res.json({
      success: true,
      isFavorite: !!favorite
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error checking favorite status',
      error: error.message
    });
  }
};

module.exports = {
  getUserFavorites,
  addToFavorites,
  removeFromFavorites,
  checkFavorite
};
