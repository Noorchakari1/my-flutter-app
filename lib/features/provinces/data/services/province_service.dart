import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/province_model.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/api_exception.dart';

class ProvinceService {
  static const String baseUrl = 'https://aop.gov.af/api/v1';
  final ApiClient _apiClient;
  
  ProvinceService({ApiClient? apiClient}) 
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

  Future<ProvinceResponse> getProvinces({int page = 1, String? currentLanguage}) async {
    try {
      final queryParams = {'page': page.toString()};
      
      return await _apiClient.get<ProvinceResponse>(
        endpoint: 'government/provinces',
        language: currentLanguage,
        queryParams: queryParams,
        converter: (data) => ProvinceResponse.fromJson(data),
      );
    } catch (e) {
      // Convert to ApiException
      final apiException = ApiExceptionHandler.handleError(e);
      throw apiException;
    }
  }
  
  // For getting details of a specific province
  Future<ProvinceItem> getProvinceDetail(int id, {String? currentLanguage}) async {
    try {
      // First try to get the province from the first page
      final response = await getProvinces(currentLanguage: currentLanguage);
      
      // Try to find the province in the first page
      final province = response.items.firstWhere(
        (province) => province.id == id,
        orElse: () => ProvinceItem(id: -1), // Return a dummy province with id -1 if not found
      );
      
      // If province was found on the first page, return it
      if (province.id != -1) {
        return province;
      }
      
      // If province was not found on the first page, check if there are more pages
      if (response.pagination.currentPage < response.pagination.totalPages) {
        // Loop through remaining pages to find the province
        for (int page = 2; page <= response.pagination.totalPages; page++) {
          final nextPageResponse = await getProvinces(
            page: page,
            currentLanguage: currentLanguage
          );
          
          // Try to find the province in this page
          final provinceOnNextPage = nextPageResponse.items.firstWhere(
            (province) => province.id == id,
            orElse: () => ProvinceItem(id: -1),
          );
          
          // If found on this page, return it
          if (provinceOnNextPage.id != -1) {
            return provinceOnNextPage;
          }
        }
      }
      
      // If we've checked all pages and still haven't found the province
      throw ApiException(
        message: 'Province not found with ID: $id',
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
  Future<ProvinceResponse> searchProvinces(String query, {int page = 1, String? currentLanguage}) async {
    try {
      final queryParams = {
        'search': query,
        'page': page.toString(),
      };
      
      return await _apiClient.get<ProvinceResponse>(
        endpoint: 'government/provinces',
        language: currentLanguage,
        queryParams: queryParams,
        converter: (data) => ProvinceResponse.fromJson(data),
      );
    } catch (e) {
      // Convert to ApiException
      final apiException = ApiExceptionHandler.handleError(e);
      throw apiException;
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