import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Custom exception class for API-related errors
class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (Code: $code, Status: $statusCode)';

  // Factory to create appropriate exception from HTTP response
  static ApiException fromResponse(http.Response response) {
    try {
      final statusCode = response.statusCode;
      final responseBody = response.body;

      // Try to parse as JSON to get error details
      Map<String, dynamic>? errorData;
      try {
        errorData = json.decode(responseBody) as Map<String, dynamic>;
      } catch (_) {
        // If not valid JSON, we'll use raw response body
      }

      // Extract error message if exists in response
      final errorMessage = errorData?['message'] as String? ?? 
                          errorData?['error'] as String? ??
                          _getMessageFromStatusCode(statusCode);

      return ApiException(
        message: errorMessage,
        statusCode: statusCode,
        code: errorData?['code'] as String?,
        data: errorData,
      );
    } catch (e) {
      // Fallback for any parsing errors
      return ApiException(
        message: 'Failed to process error response: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  // Helper to get default message based on status code
  static String _getMessageFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 429:
        return 'Too many requests';
      case 500:
        return 'Server error';
      case 503:
        return 'Service unavailable';
      default:
        return 'HTTP Error $statusCode';
    }
  }
}

/// Helper class to handle all API errors
class ApiExceptionHandler {
  // Process any exception that can occur during API calls
  static ApiException handleError(dynamic error) {
    // If already an ApiException, return as is
    if (error is ApiException) {
      return error;
    }
    
    // Handle standard exceptions
    else if (error is SocketException) {
      return const ApiException(
        message: 'No internet connection',
        code: 'no_connection',
      );
    }
    else if (error is HttpException) {
      return ApiException(
        message: 'HTTP error: ${error.message}',
        code: 'http_error',
      );
    }
    else if (error is FormatException) {
      return ApiException(
        message: 'Invalid data format: ${error.message}',
        code: 'format_error',
      );
    }
    else if (error is TimeoutException) {
      return const ApiException(
        message: 'Connection timeout',
        code: 'timeout',
      );
    }
    // Default case for unknown errors
    else {
      return ApiException(
        message: error.toString(),
        code: 'unknown_error',
      );
    }
  }
}

/// Exception specific for timeout errors
class TimeoutException implements Exception {
  final String message;
  const TimeoutException([this.message = 'Connection timed out']);
  @override
  String toString() => message;
} 