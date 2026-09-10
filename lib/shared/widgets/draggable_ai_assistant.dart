import 'package:flutter/material.dart';

/// A movable placeholder entry point for the future in-app AI assistant.
class DraggableAiAssistant extends StatefulWidget {
  const DraggableAiAssistant({super.key});

  @override
  State<DraggableAiAssistant> createState() => _DraggableAiAssistantState();
}

class _DraggableAiAssistantState extends State<DraggableAiAssistant> {
  static const _size = 58.0;
  Offset? _position;

  void _move(DragUpdateDetails details, Size bounds) {
    final proposed = (_position ?? Offset(bounds.width - _size - 16, bounds.height - _size - 16)) + details.delta;
    setState(() {
      _position = Offset(
        proposed.dx.clamp(10.0, bounds.width - _size - 10.0).toDouble(),
        proposed.dy.clamp(10.0, bounds.height - _size - 10.0).toDouble(),
      );
    });
  }

  void _showPlaceholder() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Your AI assistant is coming soon.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bounds = constraints.biggest;
        final position = _position ?? Offset(bounds.width - _size - 16, bounds.height - _size - 16);

        return Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy,
              child: Semantics(
                button: true,
                label: 'AI assistant, coming soon',
                child: GestureDetector(
                  onPanUpdate: (details) => _move(details, bounds),
                  onTap: _showPlaceholder,
                  child: Material(
                    color: Colors.transparent,
                    elevation: 8,
                    shadowColor: Colors.black.withAlpha(70),
                    shape: const CircleBorder(),
                    child: Ink(
                      width: _size,
                      height: _size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [const Color(0xFFE2BC60), const Color(0xFF956E27)]
                              : [primary, const Color(0xFF5A3CB0)],
                        ),
                        border: Border.all(color: Colors.white.withAlpha(isDark ? 80 : 150), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
