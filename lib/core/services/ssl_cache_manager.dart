import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'ssl_http_client.dart';

/// Custom cache manager that uses SSL-enabled HTTP client
class SslCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'sslCachedImageData';

  static SslCacheManager? _instance;

  /// Get singleton instance
  static SslCacheManager get instance {
    _instance ??= SslCacheManager._();
    return _instance!;
  }

  SslCacheManager._() : super(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(httpClient: SslHttpClient.instance),
    ),
  );
}
