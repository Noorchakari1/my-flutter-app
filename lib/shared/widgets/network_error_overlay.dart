import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/theme_provider.dart';
import '../../core/services/connectivity_service.dart';
import '../constants/app_constants.dart';

/// A widget that shows a banner when network connectivity is lost
class NetworkErrorOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const NetworkErrorOverlay({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<NetworkErrorOverlay> createState() => _NetworkErrorOverlayState();
}

class _NetworkErrorOverlayState extends ConsumerState<NetworkErrorOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getLocalizedText(String key) {
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
    return textMap[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    // Listen to connectivity changes
    ref.listen(connectivityStatusProvider, (previous, current) {
      current.when(
        data: (isConnected) {
          setState(() {
            _isVisible = !isConnected;
          });
          if (_isVisible) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    });

    // Show banner if not connected
    return Stack(
      children: [
        widget.child,
        if (_isVisible)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(_animation),
              child: Material(
                elevation: 4,
                color: Colors.red.shade700,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: SafeArea(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.signal_wifi_off,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getLocalizedText('offline'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final isConnected = await ref.read(connectivityServiceProvider).checkConnectivity();
                            if (isConnected && mounted) {
                              setState(() {
                                _isVisible = false;
                              });
                              _controller.reverse();
                            }
                          },
                          child: Text(
                            _getLocalizedText('retry'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
} 