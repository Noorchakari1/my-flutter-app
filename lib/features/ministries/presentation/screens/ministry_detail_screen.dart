import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../data/models/ministry_model.dart';
import '../../data/providers/ministry_provider.dart';
import '../../data/services/ministry_service.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';

class MinistryDetailScreen extends ConsumerWidget {
  final int ministryId;
  
  const MinistryDetailScreen({
    Key? key,
    required this.ministryId,
  }) : super(key: key);

  // برای باز کردن وب‌سایت وزارت‌خانه
  Future<void> _launchURL(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) return;
    
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('متاسفانه نمی‌توان وب‌سایت را باز کرد: $url')),
        );
      }
    }
  }

  // برای تماس با وزارت‌خانه
  Future<void> _callMinistry(BuildContext context, String? phone) async {
    if (phone == null || phone.isEmpty) return;
    
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('متاسفانه نمی‌توان تماس برقرار کرد: $phone')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final ministryDetailAsync = ref.watch(ministryDetailProvider(ministryId));
    
    // تعیین جهت متن بر اساس زبان
    final isRTL = ref.watch(themeNotifierProvider).currentLanguage != 'english';
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;
    
    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade100,
        body: ministryDetailAsync.when(
          data: (ministry) => _buildMinistryDetail(context, ministry, isDarkMode),
          loading: () => _buildLoadingState(),
          error: (error, stackTrace) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('در حال بارگیری اطلاعات وزارت‌خانه...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'خطا در بارگیری اطلاعات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(error.toString()),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Refresh the provider
              context.findAncestorStateOfType<ConsumerState>()?.ref
                  .refresh(ministryDetailProvider(ministryId));
            },
            icon: Icon(Icons.refresh),
            label: Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildMinistryDetail(BuildContext context, MinistryItem ministry, bool isDarkMode) {
    return CustomScrollView(
      slivers: [
        // اپ‌بار با تصویر وزارت‌خانه
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: ministry.image != null && ministry.image!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: ministry.image!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.account_balance,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.account_balance,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                  ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),

        // محتوای وزارت‌خانه
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان وزارت‌خانه
                Text(
                  ministry.title ?? 'وزارت‌خانه',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 24),

                // کارت اطلاعات تماس
                if (ministry.phone != null || ministry.link != null)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اطلاعات تماس',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          
                          // شماره تلفن
                          if (ministry.phone != null && ministry.phone!.isNotEmpty)
                            InkWell(
                              onTap: () => _callMinistry(context, ministry.phone),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.phone, color: Colors.blue, size: 20),
                                    SizedBox(width: 12),
                                    Text(
                                      ministry.phone!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                          // وب‌سایت
                          if (ministry.link != null && ministry.link!.isNotEmpty)
                            InkWell(
                              onTap: () => _launchURL(context, ministry.link),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.language, color: Colors.blue, size: 20),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        ministry.link!,
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
                  ),

                // توضیحات وزارت‌خانه
                if (ministry.description != null && ministry.description!.isNotEmpty) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'درباره وزارت‌خانه',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          SelectionArea(
                            child: Html(
                              data: ministry.description!,
                              style: {
                                "body": Style(
                                  fontSize: FontSize(16),
                                  lineHeight: LineHeight(1.5),
                                  direction: TextDirection.rtl,
                                  textAlign: TextAlign.justify,
                                  color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
                                ),
                                "p": Style(
                                  margin: Margins.only(bottom: 16),
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
                        ],
                      ),
                    ),
                  ),
                ],

                // دکمه باز کردن وب‌سایت
                if (ministry.link != null && ministry.link!.isNotEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchURL(context, ministry.link),
                      icon: Icon(Icons.open_in_new),
                      label: Text('مشاهده وب‌سایت رسمی'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 