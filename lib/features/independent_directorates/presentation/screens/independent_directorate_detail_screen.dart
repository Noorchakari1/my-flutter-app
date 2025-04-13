import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../data/models/independent_directorate_model.dart';
import '../../data/services/independent_directorate_service.dart';
import '../../data/providers/independent_directorate_provider.dart';

class IndependentDirectorateDetailScreen extends ConsumerWidget {
  final int directorateId;
  final String language;

  const IndependentDirectorateDetailScreen({
    Key? key,
    required this.directorateId,
    required this.language,
  }) : super(key: key);

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
    
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getText(context, ref, 'cannotOpenWebsite').replaceAll('{url}', url))),
        );
      }
    }
  }

  // Make a phone call
  Future<void> _callDirectorate(BuildContext context, WidgetRef ref, String? phone) async {
    if (phone == null || phone.isEmpty) return;
    
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getText(context, ref, 'cannotMakeCall').replaceAll('{phone}', phone))),
        );
      }
    }
  }
  
  // Helper function to strip HTML tags from content
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
    final directorateDetailAsync = ref.watch(independentDirectorateDetailProvider(directorateId));
    
    // Get text direction based on language
    final isRTL = language != 'english';
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;
    
    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade100,
        body: directorateDetailAsync.when(
          data: (directorate) => _buildDirectorateDetail(context, ref, directorate, isDarkMode),
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
                child: CircularProgressIndicator(),
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
              _getText(context, ref, 'directorateLoadError'),
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
              onPressed: () => ref.refresh(independentDirectorateDetailProvider(directorateId)),
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

  Widget _buildDirectorateDetail(BuildContext context, WidgetRef ref, IndependentDirectorateItem directorate, bool isDarkMode) {
    return CustomScrollView(
      slivers: [
        // App bar with directorate image
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
                if (directorate.image != null && directorate.image!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: directorate.image!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.business, size: 80, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.business, size: 80, color: Colors.grey),
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
                if (directorate.link != null && directorate.link!.isNotEmpty) {
                  _launchURL(context, ref, directorate.link);
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

        // Directorate content
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
                        directorate.title ?? _getText(context, ref, 'directorate'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 16),
                      _buildMetadataRow(context, directorate),
                    ],
                  ),
                ),

                // Contact information card
                if (directorate.phone != null || directorate.link != null)
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
                        if (directorate.phone != null && directorate.phone!.isNotEmpty)
                          InkWell(
                            onTap: () => _callDirectorate(context, ref, directorate.phone),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.blue, size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                    directorate.phone!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                        // Website
                        if (directorate.link != null && directorate.link!.isNotEmpty)
                          InkWell(
                            onTap: () => _launchURL(context, ref, directorate.link),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.language, color: Colors.blue, size: 20),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      directorate.link!,
                                      style: TextStyle(
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
                if (directorate.description != null && directorate.description!.isNotEmpty)
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
                              _getText(context, ref, 'aboutDirectorate'),
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
                          child: directorate.description!.contains('<') && directorate.description!.contains('>')
                              ? Html(
                                  data: directorate.description!,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(16),
                                      lineHeight: LineHeight(1.8),
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
                                  directorate.description!,
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
                        onTap: () => _callDirectorate(context, ref, directorate.phone),
                        enabled: directorate.phone != null && directorate.phone!.isNotEmpty,
                      ),
                      _buildActionButton(
                        context,
                        icon: Icons.language,
                        label: _getText(context, ref, 'viewOfficialWebsite'),
                        onTap: () => _launchURL(context, ref, directorate.link),
                        enabled: directorate.link != null && directorate.link!.isNotEmpty,
                      ),
                      _buildActionButton(
                        context,
                        icon: Icons.share,
                        label: _getText(context, ref, 'share'),
                        onTap: () {
                          // Simple share implementation - can be expanded
                          final message = '${directorate.title}\n${directorate.link ?? ""}';
                          // Implement sharing functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sharing: $message')),
                          );
                        },
                      ),
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

  Widget _buildMetadataRow(BuildContext context, IndependentDirectorateItem directorate) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        // Contact info with card style
        if (directorate.phone != null && directorate.phone!.isNotEmpty)
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
                  directorate.phone!,
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
        if (directorate.link != null && directorate.link!.isNotEmpty)
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
    
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
    );
  }
} 