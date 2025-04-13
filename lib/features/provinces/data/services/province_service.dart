import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/province_model.dart';

class ProvinceService {
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

  Future<ProvinceResponse> getProvinces({int page = 1, String? currentLanguage}) async {
    try {
      // Create headers with Accept-Language based on current app language
      final headers = {
        'Accept-Language': getLanguageHeader(currentLanguage ?? 'pashto')
      };
      
      final response = await http.get(
        Uri.parse('$baseUrl/government/provinces?page=$page'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ProvinceResponse.fromJson(data);
      } else {
        throw Exception('Failed to load provinces: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load provinces: $e');
    }
  }
  
  // For getting details of a specific province
  Future<ProvinceItem> getProvinceDetail(int id, {String? currentLanguage}) async {
    try {
      // Create headers with Accept-Language based on current app language
      final headers = {
        'Accept-Language': getLanguageHeader(currentLanguage ?? 'pashto')
      };
      
      // First try to get the province from the first page
      final response = await http.get(
        Uri.parse('$baseUrl/government/provinces'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final provinceResponse = ProvinceResponse.fromJson(data);
        
        // Try to find the province in the first page
        final province = provinceResponse.items.firstWhere(
          (province) => province.id == id,
          orElse: () => ProvinceItem(id: -1), // Return a dummy province with id -1 if not found
        );
        
        // If province was found on the first page, return it
        if (province.id != -1) {
          return province;
        }
        
        // If province was not found on the first page, check if there are more pages
        if (provinceResponse.pagination.currentPage < provinceResponse.pagination.totalPages) {
          // Loop through remaining pages to find the province
          for (int page = 2; page <= provinceResponse.pagination.totalPages; page++) {
            final nextPageResponse = await http.get(
              Uri.parse('$baseUrl/government/provinces?page=$page'),
              headers: headers,
            );
            
            if (nextPageResponse.statusCode == 200) {
              final Map<String, dynamic> nextPageData = json.decode(nextPageResponse.body);
              final nextPageProvinces = ProvinceResponse.fromJson(nextPageData);
              
              // Try to find the province in this page
              final provinceOnNextPage = nextPageProvinces.items.firstWhere(
                (province) => province.id == id,
                orElse: () => ProvinceItem(id: -1),
              );
              
              // If found on this page, return it
              if (provinceOnNextPage.id != -1) {
                return provinceOnNextPage;
              }
            }
          }
        }
        
        // If we've checked all pages and still haven't found the province
        throw Exception('Province not found with ID: $id');
      } else {
        throw Exception('Failed to load province details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load province details: $e');
    }
  }
  
  // Search functionality
  Future<ProvinceResponse> searchProvinces(String query, {int page = 1, String? currentLanguage}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      // Create headers with Accept-Language based on current app language
      final headers = {
        'Accept-Language': getLanguageHeader(currentLanguage ?? 'pashto')
      };
      
      final response = await http.get(
        Uri.parse('$baseUrl/government/provinces?search=$encodedQuery&page=$page'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ProvinceResponse.fromJson(data);
      } else {
        throw Exception('Failed to search provinces: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search provinces: $e');
    }
  }
  
  // Local search implementation
  Future<List<ProvinceItem>> searchProvincesLocally(String query, List<ProvinceItem> provinceItems) async {
    final lowercaseQuery = query.toLowerCase();
    return provinceItems.where((province) => 
      (province.title != null && province.title!.toLowerCase().contains(lowercaseQuery)) ||
      (province.description != null && province.description!.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }
}

// Create a provider for the ProvinceService
final provinceServiceProvider = Provider<ProvinceService>((ref) {
  return ProvinceService();
}); 