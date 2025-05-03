import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_client.dart';
import '../../../../core/services/api_exception.dart';
import '../models/ministry_model.dart';

class MinistryService {
  static const String baseUrl = 'https://aop.gov.af/api/v1';
  final ApiClient _apiClient;
  
  MinistryService({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient(baseUrl: baseUrl);

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
      final queryParams = {'page': page.toString()};
      
      return await _apiClient.get<MinistryResponse>(
        endpoint: 'government/ministries',
        language: currentLanguage,
        queryParams: queryParams,
        converter: (data) => MinistryResponse.fromJson(data),
      );
    } catch (e) {
      // Convert to ApiException
      final apiException = ApiExceptionHandler.handleError(e);
      throw apiException;
    }
  }
  
  // For getting details of a specific ministry
  Future<MinistryItem> getMinistryDetail(int id, {String? currentLanguage}) async {
    try {
      // First try to get the ministry from the first page
      final response = await getMinistries(currentLanguage: currentLanguage);
      
      // Try to find the ministry in the first page
      final ministry = response.items.firstWhere(
        (ministry) => ministry.id == id,
        orElse: () => MinistryItem(id: -1), // Return a dummy ministry with id -1 if not found
      );
      
      // If ministry was found on the first page, return it
      if (ministry.id != -1) {
        return ministry;
      }
      
      // If ministry was not found on the first page, check if there are more pages
      if (response.pagination.currentPage < response.pagination.totalPages) {
        // Loop through remaining pages to find the ministry
        for (int page = 2; page <= response.pagination.totalPages; page++) {
          final nextPageResponse = await getMinistries(
            page: page,
            currentLanguage: currentLanguage
          );
          
          // Try to find the ministry in this page
          final ministryOnNextPage = nextPageResponse.items.firstWhere(
            (ministry) => ministry.id == id,
            orElse: () => MinistryItem(id: -1),
          );
          
          // If found on this page, return it
          if (ministryOnNextPage.id != -1) {
            return ministryOnNextPage;
          }
        }
      }
      
      // If we've checked all pages and still haven't found the ministry
      throw ApiException(
        message: 'Ministry not found with ID: $id',
        code: 'not_found',
        statusCode: 404,
      );
    } catch (e) {
      // Convert to ApiException
      final apiException = ApiExceptionHandler.handleError(e);
      throw apiException;
    }
  }
  
  // Search functionality
  Future<MinistryResponse> searchMinistries(String query, {int page = 1, String? currentLanguage}) async {
    try {
      final queryParams = {
        'search': query,
        'page': page.toString(),
      };
      
      return await _apiClient.get<MinistryResponse>(
        endpoint: 'government/ministries',
        language: currentLanguage,
        queryParams: queryParams,
        converter: (data) => MinistryResponse.fromJson(data),
      );
    } catch (e) {
      // Convert to ApiException
      final apiException = ApiExceptionHandler.handleError(e);
      throw apiException;
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