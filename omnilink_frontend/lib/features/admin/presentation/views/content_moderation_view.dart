import 'package:flutter/material.dart';
import '../../../../../shared/widgets/omni_glass_container.dart';

class ContentModerationView extends StatelessWidget {
  const ContentModerationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Content Moderation Queue',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Review flagged items or unusually large files. Actions are logged.',
            style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return OmniGlassContainer(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.warning_amber_rounded, color: colorScheme.onErrorContainer, size: 40),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Flagged: Large File',
                                  style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Uploaded 2 hours ago',
                                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'User: us***@example.com',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'File: suspicious_binary.exe (2.4 GB)',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () {},
                          icon: const Icon(Icons.remove_red_eye),
                          label: const Text('Review'),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
