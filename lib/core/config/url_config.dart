/// URL Configuration for the application
/// 
/// This class manages all URL configurations including the base URL for images
/// and other resources that need to be dynamically configurable.
class UrlConfig {
  const UrlConfig._();

  /// Base URL for the API and resources
  /// This can be changed to point to different environments
  static const String baseUrl = 'https://arcsa.aop.gov.af';
  
  /// API base URL
  static const String apiBaseUrl = '$baseUrl/api';
  
  /// Storage base URL for images and files
  static const String storageBaseUrl = '$baseUrl/storage';
  
  /// Build full URL for logo path
  static String buildLogoUrl(String? logoPath) {
    if (logoPath == null || logoPath.isEmpty) {
      return '';
    }
    
    // If logoPath already contains the full URL, return as is
    if (logoPath.startsWith('http://') || logoPath.startsWith('https://')) {
      return logoPath;
    }
    
    // Remove leading slash if present to avoid double slashes
    final cleanPath = logoPath.startsWith('/') ? logoPath.substring(1) : logoPath;
    
    return '$storageBaseUrl/$cleanPath';
  }
  
  /// Build full URL for any storage path
  static String buildStorageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    
    // If path already contains the full URL, return as is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // Remove leading slash if present to avoid double slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    
    return '$storageBaseUrl/$cleanPath';
  }
  
  /// Get the current base URL (useful for runtime configuration)
  static String getCurrentBaseUrl() {
    return baseUrl;
  }
  
  /// Get the current storage base URL
  static String getCurrentStorageBaseUrl() {
    return storageBaseUrl;
  }
} 