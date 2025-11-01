const TvSeries = require('../models/TvSeries');

// Get all TV series with pagination
exports.getAllTvSeries = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const tvSeries = await TvSeries.find()
      .sort({ voteAverage: -1 })
      .skip(skip)
      .limit(limit);

    const total = await TvSeries.countDocuments();

    res.json({
      success: true,
      data: tvSeries,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching TV series:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching TV series'
    });
  }
};

// Get TV series by TMDB ID
exports.getTvSeriesByTmdbId = async (req, res) => {
  try {
    const { tmdbId } = req.params;
    
    const tvSeries = await TvSeries.findOne({ tmdbId: parseInt(tmdbId) });
    
    if (!tvSeries) {
      return res.status(404).json({
        success: false,
        message: 'TV series not found'
      });
    }

    // Increment views
    tvSeries.views += 1;
    await tvSeries.save();

    res.json({
      success: true,
      data: tvSeries
    });
  } catch (error) {
    console.error('Error fetching TV series:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching TV series'
    });
  }
};

// Get top rated TV series
exports.getTopRatedTvSeries = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const tvSeries = await TvSeries.find()
      .sort({ voteAverage: -1, voteCount: -1 })
      .skip(skip)
      .limit(limit);

    const total = await TvSeries.countDocuments();

    res.json({
      success: true,
      data: tvSeries,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching top rated TV series:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching top rated TV series'
    });
  }
};

// Get TV series by ID (MongoDB ID)
exports.getTvSeriesById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const tvSeries = await TvSeries.findById(id);
    
    if (!tvSeries) {
      return res.status(404).json({
        success: false,
        message: 'TV series not found'
      });
    }

    // Increment views
    tvSeries.views += 1;
    await tvSeries.save();

    res.json({
      success: true,
      data: tvSeries
    });
  } catch (error) {
    console.error('Error fetching TV series:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching TV series'
    });
  }
};

// Get on the air TV series (currently airing/in production)
exports.getOnTheAirTvSeries = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    // Find series that are in production or returning
    const tvSeries = await TvSeries.find({
      $or: [
        { inProduction: true },
        { status: 'Returning Series' }
      ]
    })
      .sort({ firstAirDate: -1 })
      .skip(skip)
      .limit(limit);

    const total = await TvSeries.countDocuments({
      $or: [
        { inProduction: true },
        { status: 'Returning Series' }
      ]
    });

    res.json({
      success: true,
      data: tvSeries,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching on the air TV series:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching on the air TV series'
    });
  }
};

// Get videos for a TV series
exports.getTvSeriesVideos = async (req, res) => {
  try {
    const { tmdbId } = req.params;
    const tvSeries = await TvSeries.findOne({ tmdbId: parseInt(tmdbId) });

    if (!tvSeries) {
      return res.status(404).json({
        success: false,
        message: 'TV series not found'
      });
    }

    // Return only videos in TMDB-compatible format
    res.json({
      success: true,
      data: {
        id: tvSeries.tmdbId,
        results: tvSeries.videos || []
      }
    });
  } catch (error) {
    console.error('Error fetching TV series videos:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching TV series videos',
      error: error.message
    });
  }
};
