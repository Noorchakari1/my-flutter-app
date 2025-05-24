# SSL Certificate Handling

This document explains how SSL certificate verification is handled in the application.

## Problem

When connecting to government websites (like `aop.gov.af`) from personal internet connections, you may encounter SSL certificate verification errors:

```
ApiException: HandshakeException: Handshake error in client 
(OS Error: CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate(handshake.cc:391)) 
(Code: ssl_error, Status: null)
```

## Solution

The application now includes SSL configuration that allows trusted government domains to bypass certificate verification when needed.

## Configuration

### SSL Config (`lib/core/config/ssl_config.dart`)

- `allowSelfSignedCertificates`: Controls whether to allow self-signed certificates
- `trustedDomains`: List of government domains that are trusted
- `isTrustedDomain()`: Checks if a host is in the trusted list

### Trusted Domains

The following domains are configured as trusted:
- `aop.gov.af`
- `passport.moi.gov.af`
- `moi.gov.af`
- `gov.af`

## Usage

### API Services

All API services that extend `BaseApiService` automatically use SSL-enabled clients:

```dart
class MyApiService extends BaseApiService<MyModel, MyResponse> {
  // Automatically uses SSL-configured client
}
```

### Custom HTTP Requests

For custom HTTP requests, use the `SslHttpClient`:

```dart
import 'package:aop_sites/core/services/ssl_http_client.dart';

final client = SslHttpClient.instance;
final response = await client.get(Uri.parse('https://aop.gov.af/api/data'));
```

### Manual Configuration

You can also create a custom `ApiClient` with specific SSL settings:

```dart
final apiClient = ApiClient(
  baseUrl: 'https://aop.gov.af/api/v1',
  allowSelfSignedCertificates: true,
);
```

## Security Considerations

1. **Trusted Domains Only**: Certificate verification is only bypassed for government domains
2. **Host Validation**: The system checks that the host matches trusted domains
3. **Production Ready**: The configuration can be easily modified for production environments

## Error Handling

SSL-related errors are now properly categorized:
- `ssl_error`: SSL certificate verification failed
- `tls_error`: TLS/SSL connection error

These errors provide user-friendly messages while maintaining technical accuracy.

## Testing

To test SSL functionality:

1. **With SSL enabled**: Normal API calls should work
2. **With SSL disabled**: Set `allowSelfSignedCertificates = false` in `SslConfig`
3. **Custom domains**: Add test domains to `trustedDomains` list

## Troubleshooting

If you still encounter SSL errors:

1. Check that the domain is in the `trustedDomains` list
2. Verify that `allowSelfSignedCertificates` is `true`
3. Ensure you're using the SSL-enabled client
4. Check network connectivity and firewall settings
