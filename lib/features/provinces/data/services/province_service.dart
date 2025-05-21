import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_exception.dart';
import '../../../../core/services/base_api_service.dart';
import '../models/province_model.dart';

/// Service for handling province-related API requests
class ProvinceService extends BaseApiService<ProvinceItem, ProvinceResponse> {
  ProvinceService({super.apiClient});

  @override
  String get endpoint => 'government/provinces';

  @override
  ProvinceItem parseItem(Map<String, dynamic> json) {
    return ProvinceItem.fromJson(json);
  }

  @override
  ProvinceResponse parseResponse(Map<String, dynamic> json) {
    return ProvinceResponse.fromJson(json);
  }

  /// Get a list of provinces with pagination
  Future<ProvinceResponse> getProvinces({
    int page = 1,
    String? currentLanguage,
    String? search,
  }) async {
    return getItems(
      page: page,
      currentLanguage: currentLanguage ?? 'english',
      search: search,
    );
  }

  /// Get details of a specific province by ID
  Future<ProvinceItem> getProvinceDetail(int id, {String? currentLanguage}) async {
    try {
      return await getItemById(id, currentLanguage ?? 'english');
    } catch (e) {
      // If direct API call fails, try to find the province in paginated results
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
        throw ApiException.fromError(e);
      }
    }
  }

  /// Search provinces by query
  Future<ProvinceResponse> searchProvinces(String query, {int page = 1, String? currentLanguage}) async {
    return getItems(
      page: page,
      currentLanguage: currentLanguage ?? 'english',
      search: query,
    );
  }

  /// Search provinces locally (client-side filtering)
  List<ProvinceItem> searchProvincesLocally(String query, List<ProvinceItem> provinceItems) {
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