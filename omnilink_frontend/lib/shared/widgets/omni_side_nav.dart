import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OmniSideNav extends StatefulWidget {
  const OmniSideNav({super.key});

  @override
  State<OmniSideNav> createState() => _OmniSideNavState();
}

class _OmniSideNavState extends State<OmniSideNav> {
  bool _isExpanded = true;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isExpanded ? 256 : 80,
      color: colorScheme.surfaceContainerLowest,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0).copyWith(
                        right: _isExpanded ? 16 : 24,
                        left: _isExpanded ? 24 : 0,
                      ),
                      child: Row(
                        mainAxisAlignment: _isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _toggleExpanded,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'OL',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_isExpanded) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Omnilink',
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                  ),
                                  Text(
                                    '3 Devices',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.chevron_left, size: 20, color: colorScheme.onSurfaceVariant),
                              onPressed: _toggleExpanded,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!_isExpanded)
                      Center(
                        child: IconButton(
                          icon: Icon(Icons.chevron_right, size: 20, color: colorScheme.onSurfaceVariant),
                          onPressed: _toggleExpanded,
                        ),
                      ),
                    const SizedBox(height: 16),
                    _SideNavItem(
                      icon: Icons.content_paste,
                      label: 'Clipboard',
                      isExpanded: _isExpanded,
                      onTap: () {},
                    ),
                    _SideNavItem(
                      icon: Icons.folder,
                      label: 'Files',
                      isExpanded: _isExpanded,
                      onTap: () {},
                    ),
                    _SideNavItem(
                      icon: Icons.devices,
                      label: 'Devices',
                      isExpanded: _isExpanded,
                      onTap: () {},
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 16.0 : 8.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _SideNavItem(
                          icon: Icons.history,
                          label: 'History',
                          isExpanded: _isExpanded,
                          iconColor: colorScheme.onSecondaryContainer,
                          textColor: colorScheme.onSecondaryContainer,
                          onTap: () {},
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 16.0 : 16.0),
                      child: _isExpanded 
                          ? ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Send New File'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                padding: EdgeInsets.zero,
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Icon(Icons.add, size: 20),
                            ),
                    ),
                    const SizedBox(height: 16),
                    _SideNavItem(
                      icon: Icons.menu_book,
                      label: 'Docs',
                      isExpanded: _isExpanded,
                      onTap: () {},
                    ),
                    _SideNavItem(
                      icon: Icons.help_outline,
                      label: 'Support',
                      isExpanded: _isExpanded,
                      onTap: () {},
                    ),
                    _SideNavItem(
                      icon: Icons.settings,
                      label: 'Settings',
                      isExpanded: _isExpanded,
                      onTap: () {
                        GoRouter.of(context).push('/settings');
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SideNavItem({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final defaultIconColor = iconColor ?? colorScheme.onSurfaceVariant;
    final defaultTextColor = textColor ?? colorScheme.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16.0 : 8.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: colorScheme.surfaceContainerHighest,
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16.0 : 0.0),
          alignment: isExpanded ? Alignment.centerLeft : Alignment.center,
          child: Row(
            mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(icon, color: defaultIconColor, size: 20),
              if (isExpanded) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: defaultTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
