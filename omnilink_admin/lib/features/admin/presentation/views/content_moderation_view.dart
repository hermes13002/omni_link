import 'package:flutter/material.dart';

class ContentModerationView extends StatelessWidget {
  const ContentModerationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Text(
              'Moderation Queue',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '24 items pending your review.',
              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('Audit Log'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Moderation Queue',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '24 items pending your review.',
                      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.history),
                      label: const Text('Audit Log'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Queue'),
                    ),
                  ],
                )
              ],
            ),
          const SizedBox(height: 32),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: isMobile ? 140 : 200,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      image: const DecorationImage(
                        image: NetworkImage('https://picsum.photos/600/200'),
                        fit: BoxFit.cover,
                      )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(isMobile ? 20.0 : 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.orange.withOpacity(0.5)),
                              ),
                              child: const Text('Reported: Spam', style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            Text('Reported 2 hrs ago', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Suspicious Crypto Link',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'https://free-crypto-giveaway.scam/login',
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(radius: 12, backgroundColor: colorScheme.primaryContainer, child: const Icon(Icons.person, size: 14)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text('user_93842 (3 previous strikes)', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        if (isMobile) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                foregroundColor: Colors.greenAccent,
                                side: BorderSide(color: Colors.greenAccent.withOpacity(0.5)),
                              ),
                              child: const Text('APPROVE'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('DELETE CARD'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('BAN USER'),
                            ),
                          ),
                        ] else
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    foregroundColor: Colors.greenAccent,
                                    side: BorderSide(color: Colors.greenAccent.withOpacity(0.5)),
                                  ),
                                  child: const Text('APPROVE'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {},
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                  ),
                                  child: const Text('DELETE CARD'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {},
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                  ),
                                  child: const Text('BAN USER'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
