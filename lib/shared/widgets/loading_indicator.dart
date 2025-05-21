import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A reusable loading indicator widget with shimmer effect
class LoadingIndicator extends StatelessWidget {
  final int itemCount;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool showImage;
  final bool showSubtitle;
  final bool isGrid;
  final int? gridCrossAxisCount;
  final double? gridCrossAxisSpacing;
  final double? gridMainAxisSpacing;
  final double? gridChildAspectRatio;

  const LoadingIndicator({
    super.key,
    this.itemCount = 5,
    this.height = 110,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.showImage = true,
    this.showSubtitle = true,
    this.isGrid = false,
    this.gridCrossAxisCount,
    this.gridCrossAxisSpacing,
    this.gridMainAxisSpacing,
    this.gridChildAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Base color and highlight color for shimmer effect
    final baseColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100;
    
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: isGrid
          ? _buildGridShimmer(context)
          : _buildListShimmer(context),
    );
  }

  Widget _buildListShimmer(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: height,
          width: width ?? double.infinity,
          margin: margin ?? const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Row(
            children: [
              if (showImage)
                Container(
                  width: 110,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      bottomLeft: Radius.circular(borderRadius),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      if (showSubtitle) ...[
                        const SizedBox(height: 16),
                        Container(
                          height: 16,
                          width: double.infinity * 0.7,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridShimmer(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCrossAxisCount ?? 2,
        crossAxisSpacing: gridCrossAxisSpacing ?? 16,
        mainAxisSpacing: gridMainAxisSpacing ?? 16,
        childAspectRatio: gridChildAspectRatio ?? 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showImage)
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      if (showSubtitle) ...[
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: double.infinity * 0.7,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
