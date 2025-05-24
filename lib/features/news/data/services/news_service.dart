import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/services/api_exception.dart';
import '../../../../core/services/ssl_http_client.dart';
import '../models/news_model.dart';

class NewsService {
  static const String baseUrl = 'https://aop.gov.af/api/v1';
  final http.Client _httpClient;

  NewsService({http.Client? httpClient})
      : _httpClient = httpClient ?? SslHttpClient.instance;

  // Map app language to API language code
  String getLanguageHeader(String appLanguage) {
    switch (appLanguage.toLowerCase()) {
      case 'english':
        return 'en';
      case 'persian':
        return 'dr';
      case 'uzbek':
        return 'uz';
      case 'pashto':
      default:
        return 'pa'; // Default to Pashto
    }
  }

  Future<NewsResponse> getNews({int page = 1, String? currentLanguage}) async {
    try {
      // Create headers with Accept-Language based on current app language
      final headers = {
        'Accept-Language': getLanguageHeader(currentLanguage ?? 'pashto')
      };

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/news?page=$page'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  // New method for searching news
  Future<NewsResponse> searchNews(String query, {int page = 1, String? currentLanguage}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      // Create headers with Accept-Language based on current app language
      final headers = {
        'Accept-Language': getLanguageHeader(currentLanguage ?? 'pashto')
      };

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/news?search=$encodedQuery&page=$page'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  // If API doesn't support search, here's a local search implementation
  Future<List<NewsItem>> searchNewsLocally(String query, List<NewsItem> newsItems) async {
    final lowercaseQuery = query.toLowerCase();
    return newsItems.where((news) =>
      (news.title != null && news.title!.toLowerCase().contains(lowercaseQuery)) ||
      (news.type != null && news.type!.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  Future<NewsDetail> getNewsDetail(int id, {String? currentLanguage}) async {
    try {
      // Create headers with Accept-Language based on current app language
      final headers = {
        'Accept-Language': getLanguageHeader(currentLanguage ?? 'pashto')
      };

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/news/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsDetail.fromJson(data);
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }
}

// Create a provider for the NewsService
final newsServiceProvider = Provider<NewsService>((ref) {
  return NewsService();
});