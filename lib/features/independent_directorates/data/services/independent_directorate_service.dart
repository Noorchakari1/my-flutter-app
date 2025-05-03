import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_client.dart';
import '../../../../core/services/api_exception.dart';
import '../models/independent_directorate_model.dart';

class IndependentDirectorateService {
  static const String baseUrl = 'https://aop.gov.af/api/v1';
  final ApiClient _apiClient;
  
  IndependentDirectorateService({ApiClient? apiClient}) 
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

  Future<IndependentDirectorateResponse> getIndependentDirectorates({int page = 1, String? currentLanguage}) async {
    try {
      final queryParams = {'page': page.toString()};
      
      return await _apiClient.get<IndependentDirectorateResponse>(
        endpoint: 'government/independent-directorates',
        language: currentLanguage,
        queryParams: queryParams,
        converter: (data) => IndependentDirectorateResponse.fromJson(data),
      );
    } catch (e) {
      // Convert to ApiException
      final apiException = ApiExceptionHandler.handleError(e);
      throw apiException;
    }
  }
  
  // For getting details of a specific independent directorate
  Future<IndependentDirectorateItem> getIndependentDirectorateDetail(int id, {String? currentLanguage}) async {
    try {
      // First try to get the independent directorate from the first page
      final response = await getIndependentDirectorates(currentLanguage: currentLanguage);
      
      // Try to find the independent directorate in the first page
      final directorate = response.items.firstWhere(
        (directorate) => directorate.id == id,
        orElse: () => IndependentDirectorateItem(id: -1), // Return a dummy directorate with id -1 if not found
      );
      
      // If directorate was found on the first page, return it
      if (directorate.id != -1) {
        return directorate;
      }
      
      // If directorate was not found on the first page, check if there are more pages
      if (response.pagination.currentPage < response.pagination.totalPages) {
        // Loop through remaining pages to find the directorate
        for (int page = 2; page <= response.pagination.totalPages; page++) {
          final nextPageResponse = await getIndependentDirectorates(
            page: page,
            currentLanguage: currentLanguage
          );
          
          // Try to find the directorate in this page
          final directorateOnNextPage = nextPageResponse.items.firstWhere(
            (directorate) => directorate.id == id,
            orElse: () => IndependentDirectorateItem(id: -1),
          );
          
          // If found on this page, return it
          if (directorateOnNextPage.id != -1) {
            return directorateOnNextPage;
          }
        }
      }
      
      // If we've checked all pages and still haven't found the directorate
      throw ApiException(
        message: 'Independent directorate not found with ID: $id',
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
  Future<IndependentDirectorateResponse> searchIndependentDirectorates(String query, {int page = 1, String? currentLanguage}) async {
    try {
      final queryParams = {
        'search': query,
        'page': page.toString(),
      };
      
      return await _apiClient.get<IndependentDirectorateResponse>(
        endpoint: 'government/independent-directorates',
        language: currentLanguage,
        queryParams: queryParams,
        converter: (data) => IndependentDirectorateResponse.fromJson(data),
      );
    } catch (e) {
      // Convert to ApiException
      final apiException = ApiExceptionHandler.handleError(e);
      throw apiException;
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