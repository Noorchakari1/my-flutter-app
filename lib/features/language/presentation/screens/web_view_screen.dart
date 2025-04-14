import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../../shared/constants/app_constants.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/download_dialog.dart';
import '../widgets/download_progress_indicator.dart';
import '../widgets/page_loading_indicator.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String language;
  final int initialPage;
  final bool showBottomNav;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.language,
    this.initialPage = 1,
    this.showBottomNav = true,
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
  bool _canGoBack = false;
  double _downloadProgress = 0;
  String? _currentFileName;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage;
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
            _updateCanGoBack();
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _downloadProgress = 1.0;
            });
            _updateCanGoBack();
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

  Future<void> _updateCanGoBack() async {
    final canGoBack = await _webViewController.canGoBack();
    setState(() {
      _canGoBack = canGoBack;
    });
  }

  Future<bool> _handleBackPress() async {
    if (_canGoBack) {
      _webViewController.goBack();
      return false;
    }
    return true;
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
    final languageText = widget.language == 'persian'
        ? AppConstants.persianText
        : widget.language == 'pashto'
            ? AppConstants.pashtoText
            : AppConstants.englishText;

    final textDirection =
        widget.language == 'english' ? TextDirection.ltr : TextDirection.rtl;

    return WillPopScope(
      onWillPop: _handleBackPress,
      child: FadeTransition(
        opacity: _animation,
        child: Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          bottomNavigationBar: null,
          body: SafeArea(
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
      ),
    );
  }
} 