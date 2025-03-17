import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../../../../shared/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';

class CustomWebView extends ConsumerStatefulWidget {
  final String url;
  final String title;

  const CustomWebView({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  ConsumerState<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends ConsumerState<CustomWebView> with SingleTickerProviderStateMixin {
  late WebViewController _controller;
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _downloadProgress = 0;
  bool _isDownloading = false;
  String? _currentFileName;

  @override
  void initState() {
    super.initState();
    _setupWebViewController();
    _setupAnimation();
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
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress / 100;
          });
        },
        onPageStarted: (url) {
          setState(() => _downloadProgress = 0);
        },
        onPageFinished: (url) {
          setState(() => _downloadProgress = 1.0);
        },
        onNavigationRequest: (request) async {
          if (request.url.endsWith('.pdf') || 
              request.url.endsWith('.doc') || 
              request.url.endsWith('.docx') ||
              request.url.endsWith('.xls') ||
              request.url.endsWith('.xlsx') ||
              request.url.endsWith('.zip')) {
            _handleFileDownload(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));

    if (Platform.isAndroid) {
      final androidController = _controller.platform as AndroidWebViewController;
      androidController.setOnShowFileSelector((params) async {
        // Return empty list when no file is selected
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
      final response = await _controller.runJavaScriptReturningResult('''
        fetch('$url')
          .then(response => response.blob())
          .then(blob => {
            const reader = new FileReader();
            reader.readAsDataURL(blob);
            reader.onloadend = () => {
              window.flutter_inappwebview.callHandler('onDownloadProgress', reader.result);
            };
          });
      ''');

      setState(() {
        _isDownloading = false;
        _showDownloadCompleteDialog();
      });
        } catch (e) {
      debugPrint('Download error: $e');
      setState(() => _isDownloading = false);
    }
  }

  void _showDownloadCompleteDialog() {
    final isDarkMode = ref.read(themeNotifierProvider).isDarkMode;
    String message = isDarkMode ? 'فایل با موفقیت دانلود شد' : 'File downloaded successfully';
    String buttonText = isDarkMode ? 'تایید' : 'OK';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

    return FadeTransition(
      opacity: _animation,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : AppConstants.primaryColor,
          elevation: 0,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_downloadProgress < 1.0 && !_isDownloading)
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? Colors.white : AppConstants.primaryColor,
                ),
              ),
            if (_isDownloading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentFileName ?? 'Downloading...',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          CircularProgressIndicator(
                            value: _downloadProgress,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDarkMode ? Colors.white : AppConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 