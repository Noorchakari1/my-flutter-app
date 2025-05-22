import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A reusable widget for displaying cached network images with loading and error states
class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Widget? loadingWidget;
  final Color? backgroundColor;
  final bool showShimmerOnLoading;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.loadingWidget,
    this.backgroundColor,
    this.showShimmerOnLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Default background color based on theme
    final bgColor = backgroundColor ?? 
      (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200);
    
    // Default shimmer colors
    final baseColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100;
    
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => loadingWidget ?? (
          showShimmerOnLoading
              ? Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: width,
                    height: height,
                    color: baseColor,
                  ),
                )
              : Container(
                  width: width,
                  height: height,
                  color: bgColor,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
        ),
        errorWidget: (context, url, error) => errorWidget ?? Container(
          width: width,
          height: height,
          color: bgColor,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 32,
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }
}
