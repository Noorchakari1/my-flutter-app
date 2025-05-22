import 'package:flutter/material.dart';

class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double elevation;
  final double iconSize;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final bool showSelectedLabels;
  final bool showUnselectedLabels;
  final double height;

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8.0,
    this.iconSize = 24.0,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.showSelectedLabels = true,
    this.showUnselectedLabels = true,
    this.height = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultSelectedColor = theme.colorScheme.primary;
    final defaultUnselectedColor = theme.colorScheme.onSurface.withAlpha(153); // 0.6 opacity = 153/255
    final defaultBackgroundColor = theme.colorScheme.surface;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // 0.1 opacity = 26/255
            blurRadius: elevation,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = index == currentIndex;
          return _buildNavItem(
            context,
            items[index],
            isSelected,
            index,
            defaultSelectedColor,
            defaultUnselectedColor,
          );
        }),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    BottomNavigationItem item,
    bool isSelected,
    int index,
    Color defaultSelectedColor,
    Color defaultUnselectedColor,
  ) {
    final itemColor = isSelected
        ? selectedItemColor ?? defaultSelectedColor
        : unselectedItemColor ?? defaultUnselectedColor;

    final labelStyle = isSelected
        ? selectedLabelStyle ??
            TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: itemColor,
            )
        : unselectedLabelStyle ??
            TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: itemColor,
            );

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated container for the icon
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: isSelected ? 0.8 : 1.0,
                end: isSelected ? 1.0 : 0.8,
              ),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    item.icon,
                    color: itemColor,
                    size: iconSize,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            // Show label based on configuration
            if ((isSelected && showSelectedLabels) ||
                (!isSelected && showUnselectedLabels))
              Text(
                item.label,
                style: labelStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationItem {
  final IconData icon;
  final String label;

  const BottomNavigationItem({
    required this.icon,
    required this.label,
  });
}
