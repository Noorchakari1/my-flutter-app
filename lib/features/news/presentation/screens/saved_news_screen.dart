import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../news/data/providers/saved_news_provider.dart';
import '../../data/models/news_model.dart';
import 'news_detail_screen.dart';

class SavedNewsScreen extends ConsumerWidget {
  const SavedNewsScreen({super.key});

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
    final savedNews = ref.watch(savedNewsProvider);
    
    // Determine text direction based on current language
    final isRTL = ref.watch(themeNotifierProvider).currentLanguage != 'english';
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getText(context, ref, 'savedNews')),
          backgroundColor: AppConstants.primaryColor,
          centerTitle: true,
          elevation: 0,
          actions: [
            if (savedNews.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () {
                  _showClearAllDialog(context, ref);
                },
              ),
          ],
        ),
        body: savedNews.isEmpty
            ? _buildEmptyState(context, ref)
            : _buildSavedNewsList(context, ref, savedNews),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _getText(context, ref, 'noSavedNews'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.newspaper),
            label: Text(_getText(context, ref, 'browseNews')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedNewsList(BuildContext context, WidgetRef ref, List<NewsDetail> savedNews) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: savedNews.length,
      itemBuilder: (context, index) {
        return _buildNewsCard(context, ref, savedNews[index]);
      },
    );
  }

  Widget _buildNewsCard(BuildContext context, WidgetRef ref, NewsDetail news) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Dismissible(
      key: Key('saved-news-${news.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        ref.read(savedNewsProvider.notifier).removeNews(news.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(context, ref, 'newsRemoved')),
            action: SnackBarAction(
              label: _getText(context, ref, 'undo'),
              onPressed: () {
                ref.read(savedNewsProvider.notifier).toggleSaveNews(news);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NewsDetailScreen(newsId: news.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // News image
              if (news.image != null && news.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: news.image!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey.shade400,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              // News details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title ?? _getText(context, ref, 'noTitle'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Date
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                news.date ?? 'تاریخ نامشخص',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Views
                        if (news.views != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.remove_red_eye,
                                  size: 12,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${news.views}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.bookmark_remove),
                          color: Theme.of(context).primaryColor,
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            ref.read(savedNewsProvider.notifier).removeNews(news.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_getText(context, ref, 'newsRemoved')),
                                action: SnackBarAction(
                                  label: _getText(context, ref, 'undo'),
                                  onPressed: () {
                                    ref.read(savedNewsProvider.notifier).toggleSaveNews(news);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getText(context, ref, 'clearAllSavedNews')),
        content: Text(_getText(context, ref, 'clearAllSavedNewsConfirm')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(_getText(context, ref, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              ref.read(savedNewsProvider.notifier).clearAllSavedNews();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_getText(context, ref, 'allNewsRemoved')),
                ),
              );
            },
            child: Text(
              _getText(context, ref, 'clear'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 