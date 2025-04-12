import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ministry_model.dart';

class MinistryService {
  static const String baseUrl = 'https://aop.gov.af/api/v1';

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

  Future<MinistryResponse> getMinistries({int page = 1, String? currentLanguage}) async {
    try {
      // Create headers with Accept-Language based on current app language
      final headers = {
        'Accept-Language': getLanguageHeader(currentLanguage ?? 'pashto')
      };
      
      final response = await http.get(
        Uri.parse('$baseUrl/government/ministries?page=$page'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MinistryResponse.fromJson(data);
      } else {
        throw Exception('Failed to load ministries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load ministries: $e');
    }
  }
  
  // For getting details of a specific ministry
  Future<MinistryItem> getMinistryDetail(int id, {String? currentLanguage}) async {
    try {
      // در حالت عادی، باید یک API مخصوص جزئیات وزارت‌خانه داشته باشیم
      // اما چون چنین API ای وجود ندارد، از همان API لیست وزارت‌خانه‌ها استفاده می‌کنیم
      
      // Create headers with Accept-Language based on current app language
      final headers = {
        'Accept-Language': getLanguageHeader(currentLanguage ?? 'pashto')
      };
      
      // در اینجا باید یک endpoint مخصوص جزئیات وزارت‌خانه باشد
      // اما فعلاً از همان endpoint لیست استفاده می‌کنیم و در کد آن را فیلتر می‌کنیم
      final response = await http.get(
        Uri.parse('$baseUrl/government/ministries'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final ministryResponse = MinistryResponse.fromJson(data);
        
        // یافتن وزارت‌خانه مورد نظر در لیست
        final ministry = ministryResponse.items.firstWhere(
          (ministry) => ministry.id == id,
          orElse: () => throw Exception('Ministry not found with ID: $id'),
        );
        
        return ministry;
      } else {
        throw Exception('Failed to load ministry details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load ministry details: $e');
    }
  }
  
  // Search functionality
  Future<MinistryResponse> searchMinistries(String query, {int page = 1, String? currentLanguage}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      // Create headers with Accept-Language based on current app language
      final headers = {
        'Accept-Language': getLanguageHeader(currentLanguage ?? 'pashto')
      };
      
      final response = await http.get(
        Uri.parse('$baseUrl/government/ministries?search=$encodedQuery&page=$page'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MinistryResponse.fromJson(data);
      } else {
        throw Exception('Failed to search ministries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search ministries: $e');
    }
  }
  
  // Local search implementation
  Future<List<MinistryItem>> searchMinistriesLocally(String query, List<MinistryItem> ministryItems) async {
    final lowercaseQuery = query.toLowerCase();
    return ministryItems.where((ministry) => 
      (ministry.title != null && ministry.title!.toLowerCase().contains(lowercaseQuery)) ||
      (ministry.description != null && ministry.description!.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }
}

// Create a provider for the MinistryService
final ministryServiceProvider = Provider<MinistryService>((ref) {
  return MinistryService();
}); 