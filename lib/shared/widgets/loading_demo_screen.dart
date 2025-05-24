import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/loading_manager.dart';
import '../../core/utils/navigation_helper.dart';
import '../../shared/constants/app_constants.dart';
import 'info_card.dart';
import 'loading_indicator.dart';

/// Demo screen to showcase the unified loading system
class LoadingDemoScreen extends ConsumerStatefulWidget {
  const LoadingDemoScreen({super.key});

  @override
  ConsumerState<LoadingDemoScreen> createState() => _LoadingDemoScreenState();
}

class _LoadingDemoScreenState extends ConsumerState<LoadingDemoScreen> {
  bool _isLoading = false;
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _items = [
          'Ministry of Education',
          'Ministry of Health',
          'Ministry of Defense',
          'Ministry of Interior',
          'Ministry of Finance',
        ];
      });
    }
  }

  Future<void> _simulateItemTap(String item) async {
    // This will show the enhanced loading overlay
    await LoadingManager.withGlobalLoading(
      context,
      () async {
        // Simulate processing time
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loaded details for: $item'),
              backgroundColor: AppConstants.primaryColor,
            ),
          );
        }
      },
      loadingMessage: 'Loading $item details...',
    );
  }

  Future<void> _simulateNavigation() async {
    await NavigationHelper.navigateWithLoading(
      context,
      destination: const _DemoDestinationScreen(),
      loadingMessage: 'Navigating to details...',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading System Demo'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(
              itemCount: 5,
              height: 110,
              showImage: true,
              showSubtitle: true,
            )
          : Column(
              children: [
                // Demo controls
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Loading System Demo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This demo shows the unified loading system that prevents multiple loading indicators from appearing simultaneously.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _simulateNavigation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Test Navigation Loading'),
                      ),
                    ],
                  ),
                ),
                
                // Items list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return InfoCard(
                        title: item,
                        subtitle: 'Tap to load details',
                        onTap: () => _simulateItemTap(item),
                        showLoadingOnTap: true,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

/// Simple destination screen for navigation demo
class _DemoDestinationScreen extends StatelessWidget {
  const _DemoDestinationScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destination Screen'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
              SizedBox(height: 24),
              Text(
                'Navigation Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'The loading overlay was shown during navigation and automatically hidden when the screen loaded.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
