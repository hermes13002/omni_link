import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:omnilink_frontend/shared/widgets/omni_action_button.dart';

import '../../../device/presentation/bloc/device_bloc.dart';
import '../../../device/presentation/bloc/device_state.dart';
import '../../../device/presentation/bloc/device_event.dart';
import '../../../timeline/presentation/bloc/tags_bloc.dart';
import '../../../timeline/presentation/bloc/tags_state.dart';
import '../../../timeline/presentation/bloc/tags_event.dart';

import '../../../../shared/widgets/omni_glass_container.dart';
import '../../../../shared/widgets/omni_loaders.dart';
import '../../../../shared/widgets/omni_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _tagController = TextEditingController();
  bool _isAddingTag = false;

  @override
  void initState() {
    super.initState();
    context.read<DeviceBloc>().add(DevicesLoadRequested());
    context.read<TagsBloc>().add(TagsLoadRequested());
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _submitTag() {
    final text = _tagController.text.trim();
    if (text.isNotEmpty) {
      context.read<TagsBloc>().add(TagCreateRequested(text));
      _tagController.clear();
      setState(() {
        _isAddingTag = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
              onPressed: () => context.go('/'),
            ),
            title: Text(
              'Settings',
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle('Account', textTheme, colorScheme),
                const SizedBox(height: 12),
                _buildAccountCard(context, colorScheme, textTheme),
                
                const SizedBox(height: 32),
                
                _buildSectionTitle('Devices', textTheme, colorScheme),
                const SizedBox(height: 12),
                _buildDevicesCard(context, colorScheme, textTheme),
                
                const SizedBox(height: 32),
                
                _buildSectionTitle('Tags', textTheme, colorScheme),
                const SizedBox(height: 12),
                _buildTagsCard(context, colorScheme, textTheme),
                
                const SizedBox(height: 80), // Padding for bottom nav
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return OmniGlassContainer(
      padding: const EdgeInsets.all(8.0),
      borderRadius: 20,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(50),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: colorScheme.primary),
        ),
        title: Text(
          'Profile',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Manage your account details and logout',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        onTap: () => context.push('/profile'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  IconData _getDeviceIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('mac') || lower.contains('pc') || lower.contains('windows') || lower.contains('linux')) {
      return Icons.laptop_mac;
    } else if (lower.contains('iphone') || lower.contains('android') || lower.contains('phone')) {
      return Icons.phone_iphone;
    } else if (lower.contains('ipad') || lower.contains('tablet')) {
      return Icons.tablet_mac;
    } else if (lower.contains('web') || lower.contains('browser') || lower.contains('chrome') || lower.contains('safari')) {
      return Icons.language;
    }
    return Icons.devices;
  }

  void _showRenameDeviceDialog(BuildContext context, String deviceId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Device'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New device name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<DeviceBloc>().add(DeviceUpdateRequested(deviceId, controller.text.trim()));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesCard(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return OmniGlassContainer(
      padding: const EdgeInsets.all(16.0),
      borderRadius: 20,
      child: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          if (state is DeviceLoading || state is DeviceInitial) {
            return const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: OmniDotsLoader()),
            );
          } else if (state is DeviceError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('Error: ${state.message}', style: TextStyle(color: colorScheme.error))),
            );
          } else if (state is DevicesLoaded) {
            if (state.devices.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No devices found.')),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.devices.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: colorScheme.outlineVariant.withAlpha(100)),
              itemBuilder: (context, index) {
                final device = state.devices[index];
                final isCurrent = state.currentDevice?.id == device.id;
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(_getDeviceIcon(device.friendlyName), color: colorScheme.onPrimaryContainer),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          device.friendlyName, 
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrent)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'This Device',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    'Last seen: ${device.lastSeen ?? 'Unknown'}',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCurrent)
                        IconButton(
                          icon: const Icon(Icons.sensors),
                          tooltip: 'Ping Device',
                          color: colorScheme.primary,
                          iconSize: 20,
                          onPressed: () {
                            context.read<DeviceBloc>().add(DevicePingRequested(device.id));
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Rename Device',
                        color: colorScheme.onSurfaceVariant,
                        iconSize: 20,
                        onPressed: () => _showRenameDeviceDialog(context, device.id, device.friendlyName),
                      ),
                      OmniActionButton(
                        icon: Icons.delete_outline,
                        variant: OmniActionButtonVariant.error,
                        onPressed: () {
                          context.read<DeviceBloc>().add(DeviceDeleteRequested(device.id));
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTagsCard(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return OmniGlassContainer(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<TagsBloc, TagsState>(
            builder: (context, state) {
              if (state is TagsLoading || state is TagsInitial) {
                return const Center(child: OmniDotsLoader());
              } else if (state is TagsError) {
                return Text('Error: ${state.message}', style: TextStyle(color: colorScheme.error));
              } else if (state is TagsLoaded) {
                if (state.tags.isEmpty) {
                  return Text('No tags yet. Create one below.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant));
                }
                return Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...state.tags.map((tag) => Chip(
                      label: Text('#${tag.name}', style: textTheme.labelMedium),
                      backgroundColor: colorScheme.secondaryContainer.withAlpha(100),
                      side: BorderSide.none,
                      deleteIconColor: colorScheme.onSurfaceVariant,
                      onDeleted: () {
                        context.read<TagsBloc>().add(TagDeleteRequested(tag.id));
                      },
                    )),
                    if (!_isAddingTag)
                      ActionChip(
                        avatar: Icon(Icons.add, size: 16, color: colorScheme.primary),
                        label: Text('Add Tag', style: textTheme.labelMedium?.copyWith(color: colorScheme.primary)),
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: colorScheme.outlineVariant),
                        onPressed: () {
                          setState(() {
                            _isAddingTag = true;
                          });
                        },
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 24),
          
          if (_isAddingTag)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    maxLength: 10,
                    decoration: InputDecoration(
                      hintText: 'Enter tag name...',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withAlpha(150),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: textTheme.bodyMedium,
                    onSubmitted: (_) => _submitTag(),
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.check_circle, color: colorScheme.primary, size: 28),
                  onPressed: _submitTag,
                ),
                IconButton(
                  icon: Icon(Icons.cancel, color: colorScheme.onSurfaceVariant, size: 28),
                  onPressed: () {
                    setState(() {
                      _isAddingTag = false;
                      _tagController.clear();
                    });
                  },
                ),
              ],
            )
        ],
      ),
    );
  }
}
