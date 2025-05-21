import 'api_client.dart';
import 'api_exception.dart';

/// Base class for API services with common functionality
abstract class BaseApiService<T, R> {
  static const String baseUrl = 'https://aop.gov.af/api/v1';
  final ApiClient _apiClient;

  BaseApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: baseUrl);

  /// Map app language to API language code
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

  /// Abstract methods to be implemented by subclasses
  String get endpoint;
  T parseItem(Map<String, dynamic> json);
  R parseResponse(Map<String, dynamic> json);

  /// Get a list of items with pagination
  Future<R> getItems({
    required int page,
    required String currentLanguage,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint: endpoint,
        converter: (data) => data as Map<String, dynamic>,
        language: currentLanguage,
        queryParams: queryParams,
      );

      return parseResponse(response);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  /// Get a single item by ID
  Future<T> getItemById(int id, String currentLanguage) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint: '$endpoint/$id',
        converter: (data) => data as Map<String, dynamic>,
        language: currentLanguage,
      );

      return parseItem(response);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }
}
