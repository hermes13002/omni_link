import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/device/presentation/bloc/device_bloc.dart';
import '../../features/device/presentation/bloc/device_state.dart';
import '../../features/device/presentation/bloc/device_event.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

class OmniSideNav extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const OmniSideNav({super.key, required this.navigationShell});

  @override
  State<OmniSideNav> createState() => _OmniSideNavState();
}

class _OmniSideNavState extends State<OmniSideNav> {
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    // Trigger a load if it's not already loaded
    final state = context.read<DeviceBloc>().state;
    if (state is DeviceInitial) {
      context.read<DeviceBloc>().add(DevicesLoadRequested());
    }
  }

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
                            child: Image.asset(
                              'assets/images/logo/infinity.png',
                              width: 32,
                              height: 32,
                              color: colorScheme.primary,
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
                              icon: Icon(Icons.chevron_left_rounded, size: 20, color: colorScheme.onSurfaceVariant),
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
                          icon: Icon(Icons.chevron_right_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                          onPressed: _toggleExpanded,
                        ),
                      ),
                    const SizedBox(height: 16),
                    _SideNavItem(
                      icon: Icons.content_paste_rounded,
                      label: 'Clip',
                      isExpanded: _isExpanded,
                      isSelected: widget.navigationShell.currentIndex == 0,
                      onTap: () {
                        widget.navigationShell.goBranch(
                          0,
                          initialLocation: 0 == widget.navigationShell.currentIndex,
                        );
                      },
                    ),
                    _SideNavItem(
                      icon: Icons.star_rounded,
                      label: 'Favorites',
                      isExpanded: _isExpanded,
                      isSelected: widget.navigationShell.currentIndex == 1,
                      onTap: () {
                        widget.navigationShell.goBranch(
                          1,
                          initialLocation: 1 == widget.navigationShell.currentIndex,
                        );
                      },
                    ),
                    // _SideNavItem(
                    //   icon: Icons.sync_rounded,
                    //   label: 'Sync',
                    //   isExpanded: _isExpanded,
                    //   onTap: () {},
                    // ),
                    _SideNavItem(
                      icon: Icons.manage_accounts_rounded,
                      label: 'Settings',
                      isExpanded: _isExpanded,
                      onTap: () {
                        context.push('/profile');
                      },
                    ),
                    const Spacer(),
                    _SideNavItem(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      isExpanded: _isExpanded,
                      onTap: () => _showLogoutDialog(context),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Log Out'),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Text('Are you sure you want to log out?'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isSelected;

  const _SideNavItem({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    final defaultIconColor = isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;
    final defaultTextColor = isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;
    final bgColor = isSelected ? colorScheme.primaryContainer : Colors.transparent;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16.0 : 8.0, vertical: 4.0),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}
