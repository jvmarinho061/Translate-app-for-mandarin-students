import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.examples = const [],
    this.onExampleTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final List<String> examples;
  final ValueChanged<String>? onExampleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: theme.colorScheme.outline),
            const SizedBox(height: 14),
            Text(title, style: theme.textTheme.titleMedium),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
            if (examples.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final example in examples)
                    ActionChip(
                      label: Text(example),
                      onPressed: () => onExampleTap?.call(example),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
