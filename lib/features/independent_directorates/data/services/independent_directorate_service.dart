import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/independent_directorate_model.dart';

class IndependentDirectorateService {
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

  Future<IndependentDirectorateResponse> getIndependentDirectorates({int page = 1, String? currentLanguage}) async {
    try {
      // Create headers with Accept-Language based on current app language
      final headers = {
        'Accept-Language': getLanguageHeader(currentLanguage ?? 'pashto')
      };
      
      final response = await http.get(
        Uri.parse('$baseUrl/government/independent-directorates?page=$page'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return IndependentDirectorateResponse.fromJson(data);
      } else {
        throw Exception('Failed to load independent directorates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load independent directorates: $e');
    }
  }
  
  // For getting details of a specific independent directorate
  Future<IndependentDirectorateItem> getIndependentDirectorateDetail(int id, {String? currentLanguage}) async {
    try {
      // Create headers with Accept-Language based on current app language
      final headers = {
        'Accept-Language': getLanguageHeader(currentLanguage ?? 'pashto')
      };
      
      // First try to get the independent directorate from the first page
      final response = await http.get(
        Uri.parse('$baseUrl/government/independent-directorates'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final directorateResponse = IndependentDirectorateResponse.fromJson(data);
        
        // Try to find the independent directorate in the first page
        final directorate = directorateResponse.items.firstWhere(
          (directorate) => directorate.id == id,
          orElse: () => IndependentDirectorateItem(id: -1), // Return a dummy directorate with id -1 if not found
        );
        
        // If directorate was found on the first page, return it
        if (directorate.id != -1) {
          return directorate;
        }
        
        // If directorate was not found on the first page, check if there are more pages
        if (directorateResponse.pagination.currentPage < directorateResponse.pagination.totalPages) {
          // Loop through remaining pages to find the directorate
          for (int page = 2; page <= directorateResponse.pagination.totalPages; page++) {
            final nextPageResponse = await http.get(
              Uri.parse('$baseUrl/government/independent-directorates?page=$page'),
              headers: headers,
            );
            
            if (nextPageResponse.statusCode == 200) {
              final Map<String, dynamic> nextPageData = json.decode(nextPageResponse.body);
              final nextPageDirectorates = IndependentDirectorateResponse.fromJson(nextPageData);
              
              // Try to find the directorate in this page
              final directorateOnNextPage = nextPageDirectorates.items.firstWhere(
                (directorate) => directorate.id == id,
                orElse: () => IndependentDirectorateItem(id: -1),
              );
              
              // If found on this page, return it
              if (directorateOnNextPage.id != -1) {
                return directorateOnNextPage;
              }
            }
          }
        }
        
        // If we've checked all pages and still haven't found the directorate
        throw Exception('Independent directorate not found with ID: $id');
      } else {
        throw Exception('Failed to load independent directorate details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load independent directorate details: $e');
    }
  }
  
  // Search functionality
  Future<IndependentDirectorateResponse> searchIndependentDirectorates(String query, {int page = 1, String? currentLanguage}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      // Create headers with Accept-Language based on current app language
      final headers = {
        'Accept-Language': getLanguageHeader(currentLanguage ?? 'pashto')
      };
      
      final response = await http.get(
        Uri.parse('$baseUrl/government/independent-directorates?search=$encodedQuery&page=$page'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return IndependentDirectorateResponse.fromJson(data);
      } else {
        throw Exception('Failed to search independent directorates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search independent directorates: $e');
    }
  }
  
  // Local search implementation
  Future<List<IndependentDirectorateItem>> searchIndependentDirectoratesLocally(String query, List<IndependentDirectorateItem> directorateItems) async {
    final lowercaseQuery = query.toLowerCase();
    return directorateItems.where((directorate) => 
      (directorate.title != null && directorate.title!.toLowerCase().contains(lowercaseQuery)) ||
      (directorate.description != null && directorate.description!.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }
}

// Create a provider for the IndependentDirectorateService
final independentDirectorateServiceProvider = Provider<IndependentDirectorateService>((ref) {
  return IndependentDirectorateService();
}); 