import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../config/ssl_config.dart';
import 'api_exception.dart';

/// Base API client with standardized error handling
class ApiClient {
  final String baseUrl;
  final http.Client _client;
  final Duration _timeout;
  final bool allowSelfSignedCertificates;

  ApiClient({
    required this.baseUrl,
    http.Client? client,
    Duration? timeout,
    this.allowSelfSignedCertificates = false,
  }) : _client = client ?? _createHttpClient(allowSelfSignedCertificates),
       _timeout = timeout ?? const Duration(seconds: 30);

  /// Creates an HTTP client with SSL configuration
  static http.Client _createHttpClient(bool allowSelfSignedCertificates) {
    if (!allowSelfSignedCertificates) {
      return http.Client();
    }

    // Create HttpClient with custom SSL configuration
    final httpClient = HttpClient();

    // Configure SSL context to allow self-signed certificates
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // Check if the host is in our trusted domains list
      return SslConfig.isTrustedDomain(host);
    };

    return IOClient(httpClient);
  }

  /// Helper method to get language header
  Map<String, String> _getHeaders(String? language) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (language != null) {
      headers['Accept-Language'] = _getLanguageCode(language);
    }

    return headers;
  }

  /// Convert app language to API language code
  String _getLanguageCode(String appLanguage) {
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

  /// GET request with standardized error handling
  Future<T> get<T>({
    required String endpoint,
    required T Function(dynamic data) converter,
    String? language,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = false,
  }) async {
    try {
      // Construct URL with query parameters if provided
      Uri uri;
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams);
      } else {
        uri = Uri.parse('$baseUrl/$endpoint');
      }

      // Add auth token if required (to be implemented)
      final headers = _getHeaders(language);
      if (requiresAuth) {
        // Add authorization header here if needed
      }

      // Execute request with timeout
      final response = await _client
          .get(uri, headers: headers)
          .timeout(_timeout, onTimeout: () {
        throw const TimeoutException();
      });

      // Handle response
      return await _handleResponse(response, converter);
    } catch (error) {
      // Convert to ApiException and rethrow
      throw _handleError(error);
    }
  }

  /// POST request with standardized error handling
  Future<T> post<T>({
    required String endpoint,
    required T Function(dynamic data) converter,
    String? language,
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final headers = _getHeaders(language);
      if (requiresAuth) {
        // Add authorization header here if needed
      }

      final uri = Uri.parse('$baseUrl/$endpoint');
      final jsonBody = body != null ? json.encode(body) : null;

      final response = await _client
          .post(uri, headers: headers, body: jsonBody)
          .timeout(_timeout, onTimeout: () {
        throw const TimeoutException();
      });

      return _handleResponse(response, converter);
    } catch (error) {
      throw _handleError(error);
    }
  }

  /// Common response handler
  T _handleResponse<T>(
    http.Response response,
    T Function(dynamic data) converter,
  ) {
    // Check for successful status code (200-299)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Try to parse and convert the response
      try {
        final dynamic responseData = json.decode(response.body);
        return converter(responseData);
      } catch (e) {
        throw ApiException(
          message: 'Failed to parse response: ${e.toString()}',
          statusCode: response.statusCode,
        );
      }
    } else {
      // For error status codes, throw standardized exception
      throw ApiException.fromResponse(response);
    }
  }

  /// Error handler to standardize exceptions
  ApiException _handleError(dynamic error) {
    return ApiException.fromError(error);
  }

  /// Close the http client when done
  void dispose() {
    _client.close();
  }
}