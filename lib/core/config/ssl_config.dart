/// SSL Configuration for the application
class SslConfig {
  const SslConfig._();

  /// Whether to allow self-signed certificates in development
  static const bool allowSelfSignedCertificates = true;

  /// List of trusted government domains
  static const List<String> trustedDomains = [
    'aop.gov.af',
    'passport.moi.gov.af',
    'moi.gov.af',
    'arcsa.aop.gov.af',
    'gov.af',
  ];

  /// Check if a host is in the trusted domains list
  static bool isTrustedDomain(String host) {
    return trustedDomains.any((domain) => 
      host.contains(domain) || host.endsWith(domain));
  }

  /// Get SSL configuration based on environment
  static bool shouldAllowSelfSignedCertificates() {
    // In production, you might want to make this configurable
    // For now, we allow it for government domains
    return allowSelfSignedCertificates;
  }
}
