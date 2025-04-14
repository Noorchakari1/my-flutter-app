import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';

class SavedNewsNotifier extends StateNotifier<List<NewsDetail>> {
  SavedNewsNotifier() : super([]) {
    _loadSavedNews();
  }

  static const String _savedNewsKey = 'saved_news';

  Future<void> _loadSavedNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedNewsJson = prefs.getStringList(_savedNewsKey) ?? [];
      
      final savedNews = savedNewsJson
          .map((json) => NewsDetail.fromJson({'data': jsonDecode(json)}))
          .toList();
      
      state = savedNews;
    } catch (e) {
      // If there's an error loading, just keep the state empty
      state = [];
    }
  }

  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.map((news) {
        final Map<String, dynamic> newsMap = {
          'id': news.id,
          'title': news.title,
          'description': news.description,
          'date': news.date,
          'type': news.type,
          'status': news.status,
          'created_at': news.createdAt,
          'image': news.image,
          'video': news.video,
          'tags': news.tags,
          'views': news.views,
          'gallery': news.gallery,
        };
        return jsonEncode(newsMap);
      }).toList();
      
      await prefs.setStringList(_savedNewsKey, jsonList);
    } catch (e) {
      // If saving fails, at least we tried
    }
  }

  bool isNewsSaved(int newsId) {
    return state.any((news) => news.id == newsId);
  }

  Future<void> toggleSaveNews(NewsDetail newsDetail) async {
    if (isNewsSaved(newsDetail.id)) {
      state = state.where((news) => news.id != newsDetail.id).toList();
    } else {
      state = [...state, newsDetail];
    }
    await _saveToDisk();
  }

  Future<void> removeNews(int newsId) async {
    state = state.where((news) => news.id != newsId).toList();
    await _saveToDisk();
  }

  Future<void> clearAllSavedNews() async {
    state = [];
    await _saveToDisk();
  }
}

final savedNewsProvider = StateNotifierProvider<SavedNewsNotifier, List<NewsDetail>>((ref) {
  return SavedNewsNotifier();
}); 