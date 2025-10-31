// File: lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  final String _apiKey = '8a61631043ac734940e2f203bc9c42c3'; // Ganti dengan API Key Anda
  final String _baseUrl = 'https://api.themoviedb.org/3';

  // Ambil daftar semua genre sekali saja
  Future<List<dynamic>> _fetchMovieGenres() async {
    final response = await http.get(Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['genres'];
    } else {
      throw Exception('Failed to load genres');
    }
  }

  Future<List<Movie>> fetchPopularMovies() async {
    final allGenres = await _fetchMovieGenres();
    final response = await http.get(Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((movieJson) => Movie.fromJson(movieJson, allGenres)).toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<Movie>> fetchUpcomingMovies() async {
    final allGenres = await _fetchMovieGenres();
    final response = await http.get(Uri.parse('$_baseUrl/movie/upcoming?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((movieJson) => Movie.fromJson(movieJson, allGenres)).toList();
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }
  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey&append_to_response=credits'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }
  Future<List<Movie>> searchMovies(String query) async {
    final allGenres = await _fetchMovieGenres();
    final response = await http.get(Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&query=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((movieJson) => Movie.fromJson(movieJson, allGenres)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }
}
