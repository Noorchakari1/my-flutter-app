import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';

class WebviewScreen extends StatefulWidget {
  final String url;

  const WebviewScreen({Key? key, required this.url}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  late InAppWebViewController webViewController;
  double downloadProgress = 0.0;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _requestPermissions();
    await _checkConnectivity();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isOffline = false;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        isOffline = true;
      });
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("اینترنت شما قطع است. لطفاً شبکه را بررسی کنید."),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _handleDownload(String url) async {
    try {
      final savePath = "/storage/emulated/0/Download/${url.split('/').last}";
      final dio = Dio();
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        },
      );

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Center(child: Text("فایل دانلود شد: ${url.split('/').last}")),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text("خطا در دانلود فایل")),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        downloadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (!isOffline)
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              onWebViewCreated: (controller) {
                webViewController = controller;
                webViewController.setSettings(
                  settings: InAppWebViewSettings(
                    cacheEnabled: true, // فعال کردن قابلیت کش
                  ),
                );
              },
              // ignore: deprecated_member_use
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                // ignore: deprecated_member_use
                return PermissionRequestResponse(
                  resources: resources,
                  // ignore: deprecated_member_use
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
              onDownloadStartRequest: (controller, request) async {
                await _handleDownload(request.url.toString());
              },
            )
          else
            const Center(
              child: Text(
                "اینترنت شما قطع است. لطفاً شبکه را بررسی کنید.",
                style: TextStyle(fontSize: 18, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          if (downloadProgress > 0.0 && downloadProgress < 1.0)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: LinearProgressIndicator(
                value: downloadProgress,
                backgroundColor: Colors.grey,
                color: Colors.blue,
              ),
            ),
        ],
      ),
    );
  }
}
