import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/connectivity_service.dart';

/// A utility class for handling network requests with caching
class NetworkUtils {
  static const String _cachePrefix = 'network_cache_';
  static const Duration _defaultCacheValidity = Duration(hours: 24);

  /// Make a GET request with caching
  static Future<Map<String, dynamic>> getWithCache({
    required String url,
    required Map<String, String> headers,
    Duration cacheValidity = _defaultCacheValidity,
    bool forceRefresh = false,
    ConnectivityService? connectivityService,
  }) async {
    final cacheKey = _getCacheKey(url, headers);
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we have a valid cached response
    if (!forceRefresh) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final cachedResponse = json.decode(cachedData);
        final timestamp = cachedResponse['timestamp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // If cache is still valid, return it
        if (now - timestamp < cacheValidity.inMilliseconds) {
          return cachedResponse['data'];
        }
      }
    }
    
    // Check connectivity if service is provided
    if (connectivityService != null) {
      final isConnected = await connectivityService.checkConnectivity();
      if (!isConnected) {
        // If offline and we have any cached data (even expired), use it
        final cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          final cachedResponse = json.decode(cachedData);
          return cachedResponse['data'];
        }
        throw const SocketException('No internet connection');
      }
    }
    
    // Make the network request
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Cache the response
        final cacheData = {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'data': responseData,
        };
        await prefs.setString(cacheKey, json.encode(cacheData));
        
        return responseData;
      } else {
        throw HttpException('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // If request fails and we have cached data, use it as fallback
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final cachedResponse = json.decode(cachedData);
        return cachedResponse['data'];
      }
      rethrow;
    }
  }
  
  /// Clear all cached responses
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith(_cachePrefix)) {
        await prefs.remove(key);
      }
    }
  }
  
  /// Clear cached response for a specific URL
  static Future<void> clearCacheForUrl(String url, [Map<String, String>? headers]) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getCacheKey(url, headers ?? {});
    await prefs.remove(cacheKey);
  }
  
  /// Generate a cache key from URL and headers
  static String _getCacheKey(String url, Map<String, String> headers) {
    final headerString = headers.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    final key = '$url|$headerString';
    return '$_cachePrefix${key.hashCode}';
  }
}
