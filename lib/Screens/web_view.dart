// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

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
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  late InAppWebViewController webViewController;
  double downloadProgress = 0.0;
  bool isOffline = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _requestPermissions();
    _checkConnectivity();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("مجوز دسترسی به حافظه مورد نیاز است."),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isOffline = false;
        });
      }
    } on SocketException {
      setState(() {
        isOffline = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("اینترنت شما قطع است. لطفاً شبکه را بررسی کنید."),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (!isOffline)
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      isLoading = true;
                    });
                  },
                  onLoadStop: (controller, url) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                      resources: resources,
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
              if (isLoading && !isOffline)
                const Center(child: CircularProgressIndicator()),
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
        ),
      ),
    );
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("فایل با موفقیت دانلود شد: ${url.split('/').last}"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("خطا در دانلود فایل"),
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
}
