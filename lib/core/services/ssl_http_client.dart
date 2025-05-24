import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../config/ssl_config.dart';

/// SSL-aware HTTP client factory for the application
class SslHttpClient {
  static http.Client? _instance;

  /// Get a singleton instance of the SSL-configured HTTP client
  static http.Client get instance {
    _instance ??= _createClient();
    return _instance!;
  }

  /// Create a new SSL-configured HTTP client
  static http.Client _createClient() {
    if (!SslConfig.shouldAllowSelfSignedCertificates()) {
      return http.Client();
    }

    final httpClient = HttpClient();
    
    // Configure SSL context for government domains
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return SslConfig.isTrustedDomain(host);
    };

    // Set connection timeout
    httpClient.connectionTimeout = const Duration(seconds: 30);
    
    // Set idle timeout
    httpClient.idleTimeout = const Duration(seconds: 30);

    return IOClient(httpClient);
  }

  /// Create a new client instance (useful for testing)
  static http.Client createNewClient() {
    return _createClient();
  }

  /// Dispose the singleton instance
  static void dispose() {
    _instance?.close();
    _instance = null;
  }
}
