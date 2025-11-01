const axios = require('axios');

const TMDB_API_KEY = process.env.TMDB_API_KEY || 'e956f0d34451feb0d2ac9e6b5dab6823';
const TMDB_BASE_URL = 'https://api.themoviedb.org/3';

// Cache duration in milliseconds
const CACHE_DURATION = {
  TRENDING: 24 * 60 * 60 * 1000,      // 24 hours
  POPULAR: 7 * 24 * 60 * 60 * 1000,   // 7 days
  UPCOMING: 24 * 60 * 60 * 1000,      // 24 hours
  DETAILS: 30 * 24 * 60 * 60 * 1000,  // 30 days
  SEARCH: 7 * 24 * 60 * 60 * 1000,    // 7 days
};

/**
 * TMDB Service - Fetch data from TMDB API
 */
class TMDBService {
  /**
   * Fetch trending movies and TV shows
   * @param {string} mediaType - 'all', 'movie', or 'tv'
   * @param {string} timeWindow - 'day' or 'week'
   */
  static async getTrending(mediaType = 'all', timeWindow = 'week') {
    try {
      const url = `${TMDB_BASE_URL}/trending/${mediaType}/${timeWindow}?api_key=${TMDB_API_KEY}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getTrending):', error.message);
      throw new Error('Failed to fetch trending from TMDB');
    }
  }

  /**
   * Fetch popular movies
   * @param {number} page - Page number
   */
  static async getPopularMovies(page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/movie/popular?api_key=${TMDB_API_KEY}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getPopularMovies):', error.message);
      throw new Error('Failed to fetch popular movies from TMDB');
    }
  }

  /**
   * Fetch top rated movies
   * @param {number} page - Page number
   */
  static async getTopRatedMovies(page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/movie/top_rated?api_key=${TMDB_API_KEY}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getTopRatedMovies):', error.message);
      throw new Error('Failed to fetch top rated movies from TMDB');
    }
  }

  /**
   * Fetch upcoming movies
   * @param {number} page - Page number
   */
  static async getUpcomingMovies(page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/movie/upcoming?api_key=${TMDB_API_KEY}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getUpcomingMovies):', error.message);
      throw new Error('Failed to fetch upcoming movies from TMDB');
    }
  }

  /**
   * Fetch now playing movies
   * @param {number} page - Page number
   */
  static async getNowPlayingMovies(page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/movie/now_playing?api_key=${TMDB_API_KEY}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getNowPlayingMovies):', error.message);
      throw new Error('Failed to fetch now playing movies from TMDB');
    }
  }

  /**
   * Fetch movie details by ID
   * @param {number} movieId - TMDB movie ID
   */
  static async getMovieDetails(movieId) {
    try {
      const url = `${TMDB_BASE_URL}/movie/${movieId}?api_key=${TMDB_API_KEY}&append_to_response=videos,credits,images,similar,recommendations`;
      const response = await axios.get(url);
      return response.data;
    } catch (error) {
      console.error('TMDB API Error (getMovieDetails):', error.message);
      throw new Error('Failed to fetch movie details from TMDB');
    }
  }

  /**
   * Fetch popular TV series
   * @param {number} page - Page number
   */
  static async getPopularTVSeries(page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/tv/popular?api_key=${TMDB_API_KEY}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getPopularTVSeries):', error.message);
      throw new Error('Failed to fetch popular TV series from TMDB');
    }
  }

  /**
   * Fetch top rated TV series
   * @param {number} page - Page number
   */
  static async getTopRatedTVSeries(page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/tv/top_rated?api_key=${TMDB_API_KEY}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getTopRatedTVSeries):', error.message);
      throw new Error('Failed to fetch top rated TV series from TMDB');
    }
  }

  /**
   * Fetch on the air TV series
   * @param {number} page - Page number
   */
  static async getOnTheAirTVSeries(page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/tv/on_the_air?api_key=${TMDB_API_KEY}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getOnTheAirTVSeries):', error.message);
      throw new Error('Failed to fetch on the air TV series from TMDB');
    }
  }

  /**
   * Fetch TV series details by ID
   * @param {number} tvId - TMDB TV series ID
   */
  static async getTVSeriesDetails(tvId) {
    try {
      const url = `${TMDB_BASE_URL}/tv/${tvId}?api_key=${TMDB_API_KEY}&append_to_response=videos,credits,images,similar,recommendations`;
      const response = await axios.get(url);
      return response.data;
    } catch (error) {
      console.error('TMDB API Error (getTVSeriesDetails):', error.message);
      throw new Error('Failed to fetch TV series details from TMDB');
    }
  }

  /**
   * Search movies and TV shows
   * @param {string} query - Search query
   * @param {number} page - Page number
   */
  static async searchMulti(query, page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/search/multi?api_key=${TMDB_API_KEY}&query=${encodeURIComponent(query)}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (searchMulti):', error.message);
      throw new Error('Failed to search TMDB');
    }
  }

  /**
   * Search movies only
   * @param {string} query - Search query
   * @param {number} page - Page number
   */
  static async searchMovies(query, page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/search/movie?api_key=${TMDB_API_KEY}&query=${encodeURIComponent(query)}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (searchMovies):', error.message);
      throw new Error('Failed to search movies from TMDB');
    }
  }

  /**
   * Search TV series only
   * @param {string} query - Search query
   * @param {number} page - Page number
   */
  static async searchTV(query, page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/search/tv?api_key=${TMDB_API_KEY}&query=${encodeURIComponent(query)}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (searchTV):', error.message);
      throw new Error('Failed to search TV series from TMDB');
    }
  }

  /**
   * Get movie videos (trailers, teasers)
   * @param {number} movieId - TMDB movie ID
   */
  static async getMovieVideos(movieId) {
    try {
      const url = `${TMDB_BASE_URL}/movie/${movieId}/videos?api_key=${TMDB_API_KEY}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getMovieVideos):', error.message);
      throw new Error('Failed to fetch movie videos from TMDB');
    }
  }

  /**
   * Get TV series videos
   * @param {number} tvId - TMDB TV series ID
   */
  static async getTVSeriesVideos(tvId) {
    try {
      const url = `${TMDB_BASE_URL}/tv/${tvId}/videos?api_key=${TMDB_API_KEY}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getTVSeriesVideos):', error.message);
      throw new Error('Failed to fetch TV series videos from TMDB');
    }
  }

  /**
   * Get similar movies
   * @param {number} movieId - TMDB movie ID
   * @param {number} page - Page number
   */
  static async getSimilarMovies(movieId, page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/movie/${movieId}/similar?api_key=${TMDB_API_KEY}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getSimilarMovies):', error.message);
      throw new Error('Failed to fetch similar movies from TMDB');
    }
  }

  /**
   * Get recommended movies
   * @param {number} movieId - TMDB movie ID
   * @param {number} page - Page number
   */
  static async getRecommendedMovies(movieId, page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/movie/${movieId}/recommendations?api_key=${TMDB_API_KEY}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getRecommendedMovies):', error.message);
      throw new Error('Failed to fetch recommended movies from TMDB');
    }
  }

  /**
   * Get similar TV series
   * @param {number} tvId - TMDB TV series ID
   * @param {number} page - Page number
   */
  static async getSimilarTVSeries(tvId, page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/tv/${tvId}/similar?api_key=${TMDB_API_KEY}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getSimilarTVSeries):', error.message);
      throw new Error('Failed to fetch similar TV series from TMDB');
    }
  }

  /**
   * Get recommended TV series
   * @param {number} tvId - TMDB TV series ID
   * @param {number} page - Page number
   */
  static async getRecommendedTVSeries(tvId, page = 1) {
    try {
      const url = `${TMDB_BASE_URL}/tv/${tvId}/recommendations?api_key=${TMDB_API_KEY}&page=${page}`;
      const response = await axios.get(url);
      return response.data.results;
    } catch (error) {
      console.error('TMDB API Error (getRecommendedTVSeries):', error.message);
      throw new Error('Failed to fetch recommended TV series from TMDB');
    }
  }
}

module.exports = { TMDBService, CACHE_DURATION };
