const TvSimilar = require('../models/TvSimilar');

/**
 * Get all TV Similar series
 * Returns all similar TV series from the database
 */
exports.getTvSimilarSeries = async (req, res) => {
  try {
    console.log('🔍 Querying TV Similar series...');
    const tvSimilarSeries = await TvSimilar.find()
      .sort({ voteAverage: -1, popularity: -1 })
      .limit(10);

    console.log(`📺 Found ${tvSimilarSeries ? tvSimilarSeries.length : 0} TV Similar series`);

    if (!tvSimilarSeries || tvSimilarSeries.length === 0) {
      console.log('⚠️ No TV Similar series found in database');
      return res.status(404).json({
        success: false,
        message: 'No similar TV series found'
      });
    }

    // Transform to TMDB-compatible format
    const results = tvSimilarSeries.map(tv => ({
      id: tv.tmdbId,
      name: tv.title,
      original_name: tv.originalName,
      overview: tv.overview,
      poster_path: tv.posterPath,
      backdrop_path: tv.backdropPath,
      vote_average: tv.voteAverage,
      vote_count: tv.voteCount,
      popularity: tv.popularity,
      first_air_date: tv.firstAirDate,
      origin_country: tv.originCountry,
      original_language: tv.originalLanguage,
      genre_ids: tv.genreIds,
      genre: tv.genre,
      videos: tv.videos,
      cast: tv.cast,
      crew: tv.crew,
      number_of_seasons: tv.numberOfSeasons,
      number_of_episodes: tv.numberOfEpisodes,
      episode_run_time: tv.episodeRunTime,
      status: tv.status,
      type: tv.type,
      created_by: tv.createdBy,
      networks: tv.networks,
      production_companies: tv.productionCompanies,
      seasons: tv.seasons,
      homepage: tv.homepage,
      in_production: tv.inProduction,
      languages: tv.languages,
      last_air_date: tv.lastAirDate,
      tagline: tv.tagline,
      adult: tv.adult
    }));

    res.json({
      success: true,
      results,
      total: tvSimilarSeries.length,
      page: 1,
      total_pages: 1
    });
  } catch (error) {
    console.error('Error fetching TV similar series:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch similar TV series',
      error: error.message
    });
  }
};
