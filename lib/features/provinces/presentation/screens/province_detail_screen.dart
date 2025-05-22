import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../data/models/province_model.dart';
import '../../data/providers/province_provider.dart';

class ProvinceDetailScreen extends ConsumerWidget {
  final int provinceId;
  final String language;

  const ProvinceDetailScreen({
    super.key,
    required this.provinceId,
    required this.language,
  });

  // Helper function to get localized text
  String _getText(BuildContext context, WidgetRef ref, String key) {
    final language = ref.watch(themeNotifierProvider).currentLanguage;
    Map<String, String> textMap;
    switch (language) {
      case 'pashto':
        textMap = AppConstants.pashtoText;
        break;
      case 'persian':
        textMap = AppConstants.persianText;
        break;
      default:
        textMap = AppConstants.englishText;
    }
    return textMap[key] ?? key; // Return key if translation not found
  }

  // Launch website
  Future<void> _launchURL(BuildContext context, WidgetRef ref, String? url) async {
    if (url == null || url.isEmpty) return;

    try {
      // Ensure URL has proper scheme
      String urlToLaunch = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        urlToLaunch = 'https://$url';
      }

      final Uri uri = Uri.parse(urlToLaunch);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_getText(context, ref, 'cannotOpenWebsite').replaceAll('{url}', url))),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening website: ${e.toString()}')),
        );
      }
    }
  }

  // Make a phone call
  Future<void> _callProvince(BuildContext context, WidgetRef ref, String? phone) async {
    if (phone == null || phone.isEmpty) return;

    try {
      // Clean phone number - remove spaces, dashes, etc.
      final cleanPhone = phone.replaceAll(RegExp(r'\s+|-|\(|\)'), '');

      final Uri uri = Uri(scheme: 'tel', path: cleanPhone);
      if (!await launchUrl(uri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_getText(context, ref, 'cannotMakeCall').replaceAll('{phone}', phone))),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error making call: ${e.toString()}')),
        );
      }
    }
  }

  // Helper function to strip HTML tags from content
  // This method is kept for future use but currently not used
  // ignore: unused_element
  String _stripHtmlTags(String htmlString) {
    // Basic HTML tag removal for cases where we want plain text
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Use the provider from the provider file instead of the map parameter version
    final provinceDetailAsync = ref.watch(provinceDetailProvider(provinceId));

    // Get text direction based on language
    final isRTL = language != 'english';
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade100,
        body: provinceDetailAsync.when(
          data: (province) => _buildProvinceDetail(context, ref, province, isDarkMode),
          loading: () => _buildLoadingState(),
          error: (error, stackTrace) => _buildErrorState(context, ref, error),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          expandedHeight: 300,
          pinned: true,
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add circular progress indicator in the center
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 40, bottom: 30),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getText(context, ref, 'provinceLoadError'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(provinceDetailProvider(provinceId)),
              icon: const Icon(Icons.refresh),
              label: Text(_getText(context, ref, 'tryAgain')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_getText(context, ref, 'back')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinceDetail(BuildContext context, WidgetRef ref, ProvinceItem province, bool isDarkMode) {
    return CustomScrollView(
      slivers: [
        // App bar with province image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Image with gradient overlay
                if (province.image != null && province.image!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: province.image!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.location_city, size: 80, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.location_city, size: 80, color: Colors.grey),
                    ),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.language, size: 20),
              ),
              onPressed: () {
                if (province.link != null && province.link!.isNotEmpty) {
                  _launchURL(context, ref, province.link);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_getText(context, ref, 'noWebsite'))),
                  );
                }
              },
            ),
          ],
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),

        // Province content
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title card with shadow
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        province.title ?? _getText(context, ref, 'province'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 16),
                      _buildMetadataRow(context, province),
                    ],
                  ),
                ),

                // Contact information card
                if (province.phone != null || province.link != null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.contact_phone,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getText(context, ref, 'contactInfo'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Phone number
                        if (province.phone != null && province.phone!.isNotEmpty)
                          InkWell(
                            onTap: () => _callProvince(context, ref, province.phone),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone, color: Colors.blue, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    province.phone!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Website
                        if (province.link != null && province.link!.isNotEmpty)
                          InkWell(
                            onTap: () => _launchURL(context, ref, province.link),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.language, color: Colors.blue, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      province.link!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Description
                if (province.description != null && province.description!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getText(context, ref, 'aboutProvince'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SelectionArea(
                          child: province.description!.contains('<') && province.description!.contains('>')
                              ? Html(
                                  data: province.description!,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(16),
                                      lineHeight: const LineHeight(1.8),
                                      direction: TextDirection.rtl,
                                      textAlign: TextAlign.justify,
                                      color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
                                    ),
                                    "p": Style(
                                      margin: Margins.only(bottom: 20),
                                    ),
                                    "h1, h2, h3, h4, h5, h6": Style(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    "a": Style(
                                      color: Theme.of(context).primaryColor,
                                      textDecoration: TextDecoration.none,
                                    ),
                                    "img": Style(
                                      margin: Margins.all(8),
                                    ),
                                  },
                                )
                              : Text(
                                  province.description!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.8,
                                    color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
                                  ),
                                  textAlign: TextAlign.justify,
                                  textDirection: TextDirection.rtl,
                                ),
                        ),
                      ],
                    ),
                  ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        icon: Icons.phone,
                        label: _getText(context, ref, 'phone'),
                        onTap: () => _callProvince(context, ref, province.phone),
                        enabled: province.phone != null && province.phone!.isNotEmpty,
                      ),
                      _buildActionButton(
                        context,
                        icon: Icons.language,
                        label: _getText(context, ref, 'viewOfficialWebsite'),
                        onTap: () => _launchURL(context, ref, province.link),
                        enabled: province.link != null && province.link!.isNotEmpty,
                      ),
                      // Removed share button as per user requirements
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(BuildContext context, ProvinceItem province) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Contact info with card style
        if (province.phone != null && province.phone!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 14,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700
                ),
                const SizedBox(width: 6),
                Text(
                  province.phone!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 8),
        // Website with card style
        if (province.link != null && province.link!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  size: 14,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700
                ),
                const SizedBox(width: 6),
                Text(
                  'Website',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13), // ~0.05 opacity
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}