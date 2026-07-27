import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/device/presentation/bloc/device_bloc.dart';
import '../../features/device/presentation/bloc/device_state.dart';

class OmniSideNav extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const OmniSideNav({super.key, required this.navigationShell});

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
                                child: Icon(
                                  Icons.all_inclusive_rounded,
                                  size: 20,
                                  color: colorScheme.onPrimary,
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
                                    'OmniLink',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: colorScheme.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                  ),
                                  BlocBuilder<DeviceBloc, DeviceState>(
                                    builder: (context, state) {
                                      String deviceText = 'Loading...';
                                      if (state is DevicesLoaded) {
                                        deviceText = '${state.devices.length} Devices';
                                      } else if (state is DeviceError) {
                                        deviceText = 'Error';
                                      }
                                      return Text(
                                        deviceText,
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                      );
                                    },
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 16.0 : 8.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.navigationShell.currentIndex == 0 ? colorScheme.secondaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _SideNavItem(
                          icon: Icons.content_paste,
                          label: 'Clip',
                          isExpanded: _isExpanded,
                          iconColor: widget.navigationShell.currentIndex == 0 ? colorScheme.onSecondaryContainer : null,
                          textColor: widget.navigationShell.currentIndex == 0 ? colorScheme.onSecondaryContainer : null,
                          onTap: () {
                            widget.navigationShell.goBranch(
                              0,
                              initialLocation: 0 == widget.navigationShell.currentIndex,
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 16.0 : 8.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.navigationShell.currentIndex == 1 ? colorScheme.secondaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _SideNavItem(
                          icon: Icons.star,
                          label: 'Favorites',
                          isExpanded: _isExpanded,
                          iconColor: widget.navigationShell.currentIndex == 1 ? colorScheme.onSecondaryContainer : null,
                          textColor: widget.navigationShell.currentIndex == 1 ? colorScheme.onSecondaryContainer : null,
                          onTap: () {
                            widget.navigationShell.goBranch(
                              1,
                              initialLocation: 1 == widget.navigationShell.currentIndex,
                            );
                          },
                        ),
                      ),
                    ),
                    // _SideNavItem(
                    //   icon: Icons.refresh,
                    //   label: 'Sync',
                    //   isExpanded: _isExpanded,
                    //   onTap: () {},
                    // ),
                    _SideNavItem(
                      icon: Icons.person,
                      label: 'Profile',
                      isExpanded: _isExpanded,
                      onTap: () {
                        context.push('/profile');
                      },
                    ),
                    const Spacer(),
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
