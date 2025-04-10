import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/news_model.dart';

class NewsService {
  static const String baseUrl = 'https://aop.gov.af/api/v1';

  Future<NewsResponse> getNews({int page = 1}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/news?page=$page'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }

  Future<NewsDetail> getNewsDetail(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/news/$id'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsDetail.fromJson(data);
      } else {
        throw Exception('Failed to load news detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load news detail: $e');
    }
  }
}

// Create a provider for the NewsService
final newsServiceProvider = Provider<NewsService>((ref) {
  return NewsService();
}); 