import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_exception.dart';
import '../../../../core/services/base_api_service.dart';
import '../models/ministry_model.dart';

/// Service for handling ministry-related API requests
class MinistryService extends BaseApiService<MinistryItem, MinistryResponse> {
  MinistryService({super.apiClient});

  @override
  String get endpoint => 'government/ministries';

  @override
  MinistryItem parseItem(Map<String, dynamic> json) {
    return MinistryItem.fromJson(json);
  }

  @override
  MinistryResponse parseResponse(Map<String, dynamic> json) {
    return MinistryResponse.fromJson(json);
  }

  /// Get a list of ministries with pagination
  Future<MinistryResponse> getMinistries({
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

  /// Get details of a specific ministry by ID
  Future<MinistryItem> getMinistryDetail(int id, {String? currentLanguage}) async {
    try {
      return await getItemById(id, currentLanguage ?? 'english');
    } catch (e) {
      // If direct API call fails, try to find the ministry in paginated results
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
        throw ApiException.fromError(e);
      }
    }
  }

  /// Search ministries by query
  Future<MinistryResponse> searchMinistries(String query, {int page = 1, String? currentLanguage}) async {
    return getItems(
      page: page,
      currentLanguage: currentLanguage ?? 'english',
      search: query,
    );
  }

  /// Search ministries locally (client-side filtering)
  List<MinistryItem> searchMinistriesLocally(String query, List<MinistryItem> ministryItems) {
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