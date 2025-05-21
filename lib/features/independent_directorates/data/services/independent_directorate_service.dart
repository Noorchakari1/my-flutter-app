import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_exception.dart';
import '../../../../core/services/base_api_service.dart';
import '../models/independent_directorate_model.dart';

/// Service for handling independent directorate-related API requests
class IndependentDirectorateService extends BaseApiService<IndependentDirectorateItem, IndependentDirectorateResponse> {
  IndependentDirectorateService({super.apiClient});

  @override
  String get endpoint => 'government/independent-directorates';

  @override
  IndependentDirectorateItem parseItem(Map<String, dynamic> json) {
    return IndependentDirectorateItem.fromJson(json);
  }

  @override
  IndependentDirectorateResponse parseResponse(Map<String, dynamic> json) {
    return IndependentDirectorateResponse.fromJson(json);
  }

  /// Get a list of independent directorates with pagination
  Future<IndependentDirectorateResponse> getIndependentDirectorates({
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

  /// Get details of a specific independent directorate by ID
  Future<IndependentDirectorateItem> getIndependentDirectorateDetail(int id, {String? currentLanguage}) async {
    try {
      return await getItemById(id, currentLanguage ?? 'english');
    } catch (e) {
      // If direct API call fails, try to find the directorate in paginated results
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
        throw ApiException.fromError(e);
      }
    }
  }

  /// Search independent directorates by query
  Future<IndependentDirectorateResponse> searchIndependentDirectorates(String query, {int page = 1, String? currentLanguage}) async {
    return getItems(
      page: page,
      currentLanguage: currentLanguage ?? 'english',
      search: query,
    );
  }

  /// Search independent directorates locally (client-side filtering)
  List<IndependentDirectorateItem> searchIndependentDirectoratesLocally(String query, List<IndependentDirectorateItem> directorateItems) {
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