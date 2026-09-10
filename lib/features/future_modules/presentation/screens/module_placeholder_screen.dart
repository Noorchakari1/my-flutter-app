import 'package:flutter/material.dart';

/// Temporary landing page for a module described in the product roadmap.
/// Replace this screen with the module's feature-specific implementation later.
class ModulePlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const ModulePlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.description = 'This section is planned and will be available soon.',
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: colors.primaryContainer,
                child: Icon(icon, size: 40, color: colors.primary),
              ),
              const SizedBox(height: 20),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Text(description, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
