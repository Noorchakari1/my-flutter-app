import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/news_model.dart';
import '../../data/providers/news_provider.dart';
import '../../data/providers/saved_news_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';

class NewsDetailScreen extends ConsumerWidget {
  final int newsId;
  
  const NewsDetailScreen({
    super.key,
    required this.newsId,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsDetailAsync = ref.watch(newsDetailProvider(newsId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Determine text direction based on current language
    final isRTL = ref.watch(themeNotifierProvider).currentLanguage != 'english';
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        body: newsDetailAsync.when(
          data: (newsDetail) => _buildNewsDetailView(context, ref, newsDetail),
          loading: () => _buildLoadingView(),
          error: (error, stackTrace) => _buildErrorView(context, error, ref),
        ),
      ),
    );
  }

  Widget _buildNewsDetailView(BuildContext context, WidgetRef ref, NewsDetail newsDetail) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context, newsDetail),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title card with shadow
              Container(
                margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
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
                      newsDetail.title ?? _getText(context, ref, 'noTitle'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMetadataRow(context, newsDetail),
                  ],
                ),
              ),
              
              // Content with modern styling
              Container(
                margin: const EdgeInsets.all(16),
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
                child: SelectionArea(
                  child: Html(
                    data: newsDetail.description ?? '',
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        lineHeight: const LineHeight(1.8),
                        direction: ref.watch(themeNotifierProvider).currentLanguage != 'english' ? 
                          TextDirection.rtl : TextDirection.ltr,
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
                  ),
                ),
              ),
              
              if (newsDetail.gallery != null && newsDetail.gallery!.isNotEmpty) ...[
                _buildGallery(context, ref, newsDetail),
              ],
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      ref,
                      icon: Icons.share,
                      label: _getText(context, ref, 'share'),
                      onTap: () {
                        Share.share('${newsDetail.title ?? _getText(context, ref, 'newsItem')}\n\n${_getText(context, ref, 'viewFullNews')}');
                      },
                    ),
                    _buildActionButton(
                      context,
                      ref,
                      icon: Icons.bookmark_border,
                      label: _getText(context, ref, 'save'),
                      onTap: () {
                        ref.read(savedNewsProvider.notifier).toggleSaveNews(newsDetail);
                        final isSaved = ref.read(savedNewsProvider.notifier).isNewsSaved(newsDetail.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isSaved 
                              ? _getText(context, ref, 'newsSaved')
                              : _getText(context, ref, 'newsUnsaved')),
                          ),
                        );
                      },
                    ),
                    _buildActionButton(
                      context,
                      ref,
                      icon: Icons.text_increase,
                      label: _getText(context, ref, 'changeTextSize'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_getText(context, ref, 'comingSoon'))),
                        );
                      },
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

  Widget _buildAppBar(BuildContext context, NewsDetail newsDetail) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image with gradient overlay
            if (newsDetail.image != null && newsDetail.image!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: newsDetail.image!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
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
            child: const Icon(Icons.share, size: 20),
          ),
          onPressed: () {
            Share.share('${newsDetail.title ?? 'News'}\n\nView full news in our app');
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context, NewsDetail newsDetail) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        // Date with card style
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
                Icons.calendar_today, 
                size: 14, 
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700
              ),
              const SizedBox(width: 6),
              Text(
                newsDetail.date ?? 'تاریخ نامشخص',
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
        // Views with card style
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
                Icons.remove_red_eye, 
                size: 14, 
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700
              ),
              const SizedBox(width: 6),
              Text(
                '${newsDetail.views ?? 0}',
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

  Widget _buildGallery(BuildContext context, WidgetRef ref, NewsDetail newsDetail) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final galleryImages = newsDetail.gallery ?? [];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Icons.photo_library,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getText(context, ref, 'imageGallery'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                _getText(context, ref, 'imageCount').replaceAll('{count}', '${galleryImages.length}'),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: galleryImages.isEmpty 
                ? Center(
                    child: Text(
                      _getText(context, ref, 'noImages'),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: galleryImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GestureDetector(
                            onTap: () {
                              // Show full screen gallery
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(_getText(context, ref, 'fullscreenComingSoon'))),
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: galleryImages[index],
                              width: 180,
                              height: 140,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.error, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
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
    );
  }

  Widget _buildLoadingView() {
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

  Widget _buildErrorView(BuildContext context, Object error, WidgetRef ref) {
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
              _getText(context, ref, 'errorLoadingNews'),
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
              onPressed: () => ref.refresh(newsDetailProvider(newsId)),
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
              child: Text(_getText(context, ref, 'goBack')),
            ),
          ],
        ),
      ),
    );
  }
} 