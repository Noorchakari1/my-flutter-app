import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_button.dart';
import 'web_view_screen.dart';

class ServiceButtonScreen extends ConsumerStatefulWidget {
  final String passportURL;
  final String passportTitle;
  final String language;

  const ServiceButtonScreen({
    super.key,
    required this.passportURL,
    required this.passportTitle,
    required this.language,
  });

  @override
  ConsumerState<ServiceButtonScreen> createState() =>
      _ServiceButtonScreenState();
}

class _ServiceButtonScreenState extends ConsumerState<ServiceButtonScreen> {
  final int _page = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
    final languageText = widget.language == 'persian'
        ? AppConstants.persianText
        : widget.language == 'pashto'
            ? AppConstants.pashtoText
            : AppConstants.englishText;

    final textDirection =
        widget.language == 'english' ? TextDirection.ltr : TextDirection.rtl;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: languageText['selectService'] ?? languageText['publicServices'] ?? widget.passportTitle,
        showBackButton: true,
      ),
      body: Column(
        children: [
          AppHeader(
            title: languageText['selectService'] ?? languageText['publicServices'] ?? widget.passportTitle,
            logoPath: AppConstants.logoPath,
            logoHeight: AppConstants.headerImageHeight,
            logoColor: Colors.white,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.defaultPadding * 2,
              ),
              child: Directionality(
                textDirection: textDirection,
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppConstants.defaultPadding * 1.5,
                  crossAxisSpacing: AppConstants.defaultPadding * 1.5,
                  childAspectRatio: 1,
                  children: [
                    CustomButton(
                      title: widget.passportTitle,
                      iconData: Icons.perm_identity,
                      onPressed: () {
                        final passportUrl =
                            AppConstants.passportUrls[widget.language];
                        if (passportUrl != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebViewScreen(
                                url: passportUrl,
                                language: widget.language,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
