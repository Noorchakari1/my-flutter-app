import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/localization_helper.dart';

/// A reusable search bar widget that can be used across different screens
class SearchBarWidget extends ConsumerStatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final Function()? onClear;
  final bool autofocus;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool showBorder;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? borderRadius;

  const SearchBarWidget({
    super.key,
    required this.hintText,
    required this.onSearch,
    this.onClear,
    this.autofocus = false,
    this.controller,
    this.focusNode,
    this.showBorder = true,
    this.backgroundColor,
    this.margin,
    this.height,
    this.borderRadius,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    
    _controller.addListener(() {
      setState(() {
        _showClearButton = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isRTL = LocalizationHelper.isRTL(ref);
    
    return Container(
      height: widget.height ?? 48,
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? 
          (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 24),
        border: widget.showBorder ? Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ) : null,
      ),
      child: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            suffixIcon: _showClearButton ? IconButton(
              icon: Icon(
                Icons.clear,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              onPressed: _clearSearch,
            ) : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            widget.onSearch(value);
          },
          onSubmitted: (value) {
            widget.onSearch(value);
            FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }
}
