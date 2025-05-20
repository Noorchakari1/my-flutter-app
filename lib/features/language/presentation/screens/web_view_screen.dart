import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/modern_bottom_nav_bar.dart';
import '../widgets/download_dialog.dart';
import '../widgets/download_progress_indicator.dart';
import '../widgets/page_loading_indicator.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String language;
  final int initialPage;
  final bool showBottomNav;
  final bool showAppBar;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.language,
    this.initialPage = 1,
    this.showBottomNav = true,
    this.showAppBar = true,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> with SingleTickerProviderStateMixin {
  late WebViewController _webViewController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _currentFileName;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _setupWebViewController();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  void _setupWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _downloadProgress = 0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _downloadProgress = 1.0;
            });
          },
          onProgress: (progress) {
            setState(() {
              _downloadProgress = progress / 100;
            });
          },
          onNavigationRequest: (request) async {
            final url = request.url.toLowerCase();
            if (url.endsWith('.pdf') ||
                url.endsWith('.doc') ||
                url.endsWith('.docx') ||
                url.endsWith('.xls') ||
                url.endsWith('.xlsx') ||
                url.endsWith('.zip') ||
                url.endsWith('.rar') ||
                url.endsWith('.mp3') ||
                url.endsWith('.mp4') ||
                url.endsWith('.jpg') ||
                url.endsWith('.jpeg') ||
                url.endsWith('.png') ||
                url.endsWith('.gif') ||
                url.contains('download') ||
                url.contains('attachment')) {
              _handleFileDownload(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    if (Platform.isAndroid) {
      final androidController = _webViewController.platform as AndroidWebViewController;
      androidController.setOnShowFileSelector((params) async {
        return [];
      });
    }
  }

  Future<void> _handleFileDownload(String url) async {
    setState(() {
      _isDownloading = true;
      _currentFileName = url.split('/').last;
      _downloadProgress = 0;
    });

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalNonBrowserApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableDomStorage: true,
            enableJavaScript: true,
          ),
        );
        setState(() {
          _isDownloading = false;
          _showDownloadCompleteDialog();
        });
      }
    } catch (e) {
      debugPrint('Download error: $e');
      setState(() => _isDownloading = false);
    }
  }

  void _showDownloadCompleteDialog() {
    DownloadDialog.show(context, widget.language);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: AppConstants.primaryColor,
        leading: BackButton(
          color: Colors.white,
          onPressed: () async {
            if (await _webViewController.canGoBack()) {
              _webViewController.goBack();
            } else {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
        title: Text(
          widget.language == 'english'
              ? 'Website'
              : widget.language == 'persian'
                  ? 'وبسایت'
                  : 'ویبسایټ',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ) : null,
      body: FadeTransition(
        opacity: _animation,
        child: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(
                controller: _webViewController,
              ),
              PageLoadingIndicator(
                isLoading: _isLoading,
                progress: _downloadProgress,
              ),
              DownloadProgressIndicator(
                isDownloading: _isDownloading,
                downloadProgress: _downloadProgress,
                fileName: _currentFileName,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav ? ModernBottomNavBar(
        currentIndex: 1, // Always show the web tab as selected
        onTap: (index) {
          if (index != 1) {
            Navigator.pop(context);
          }
        },
        backgroundColor: AppConstants.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withAlpha(179),
        elevation: 8.0,
        iconSize: 24.0,
        height: 60.0,
        items: [
          BottomNavigationItem(
            icon: Icons.home,
            label: widget.language == 'english'
                ? 'Home'
                : widget.language == 'persian'
                    ? 'خانه'
                    : 'کور',
          ),
          BottomNavigationItem(
            icon: Icons.web,
            label: widget.language == 'english'
                ? 'Website'
                : widget.language == 'persian'
                    ? 'وبسایت'
                    : 'ویبسایټ',
          ),
          BottomNavigationItem(
            icon: Icons.feedback,
            label: widget.language == 'english'
                ? 'Contact'
                : widget.language == 'persian'
                    ? 'تماس'
                    : 'اړیکه',
          ),
        ],
      ) : null,
    );
  }
}