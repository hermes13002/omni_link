import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/device_bloc.dart';
import '../bloc/device_state.dart';
import '../bloc/device_event.dart';
import '../../../../shared/widgets/omni_glass_dialog.dart';
import '../../../../shared/widgets/omni_loaders.dart';
import '../../../../shared/widgets/omni_glass_container.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final Set<String> _selectedDevices = {};

  @override
  void initState() {
    super.initState();
    context.read<DeviceBloc>().add(DevicesLoadRequested());
  }

  IconData _getDeviceIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('mac') || lower.contains('pc') || lower.contains('windows') || lower.contains('linux')) {
      return Icons.monitor_rounded;
    } else if (lower.contains('iphone') || lower.contains('android') || lower.contains('phone')) {
      return Icons.smartphone_rounded;
    } else if (lower.contains('ipad') || lower.contains('tablet')) {
      return Icons.tablet_mac_rounded;
    } else if (lower.contains('web') || lower.contains('browser') || lower.contains('chrome') || lower.contains('safari')) {
      return Icons.language_rounded;
    }
    return Icons.devices_rounded;
  }

  void _showRenameDeviceDialog(BuildContext context, String deviceId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => OmniGlassDialog(
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

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Unknown';
    try {
      final localDt = dt.toLocal();
      return '${localDt.year}-${localDt.month.toString().padLeft(2, '0')}-${localDt.day.toString().padLeft(2, '0')} ${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dt.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _selectedDevices.isNotEmpty ? '${_selectedDevices.length} Selected' : 'Linked Devices',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          if (_selectedDevices.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_rounded, color: colorScheme.error),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => OmniGlassDialog(
                    title: const Text('Delete Selected Devices?'),
                    content: Text('Are you sure you want to delete ${_selectedDevices.length} devices?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                        onPressed: () {
                          for (final id in _selectedDevices) {
                            context.read<DeviceBloc>().add(DeviceDeleteRequested(id));
                          }
                          setState(() {
                            _selectedDevices.clear();
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          if (state is DeviceLoading || state is DeviceInitial) {
            return const Center(child: OmniDotsLoader());
          } else if (state is DeviceError) {
            return Center(child: Text('Error: ${state.message}', style: TextStyle(color: colorScheme.error)));
          } else if (state is DevicesLoaded) {
            if (state.devices.isEmpty) {
              return const Center(child: Text('No devices found.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.devices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final device = state.devices[index];
                final isCurrent = state.currentDevice?.id == device.id;
                
                return OmniGlassContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    onLongPress: () {
                      setState(() {
                        if (_selectedDevices.contains(device.id)) {
                          _selectedDevices.remove(device.id);
                        } else {
                          _selectedDevices.add(device.id);
                        }
                      });
                    },
                    onTap: _selectedDevices.isNotEmpty ? () {
                      setState(() {
                        if (_selectedDevices.contains(device.id)) {
                          _selectedDevices.remove(device.id);
                        } else {
                          _selectedDevices.add(device.id);
                        }
                      });
                    } : null,
                    leading: _selectedDevices.isNotEmpty
                        ? Checkbox(
                            value: _selectedDevices.contains(device.id),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedDevices.add(device.id);
                                } else {
                                  _selectedDevices.remove(device.id);
                                }
                              });
                            },
                          )
                        : CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(_getDeviceIcon(device.friendlyName), color: colorScheme.onPrimaryContainer),
                          ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            device.friendlyName, 
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                      'Last seen: ${_formatDate(device.lastSeen)}',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isCurrent && _selectedDevices.isEmpty)
                          IconButton(
                            icon: const Icon(Icons.rss_feed_rounded),
                            tooltip: 'Ping Device',
                            color: colorScheme.primary,
                            iconSize: 20,
                            onPressed: () {
                              context.read<DeviceBloc>().add(DevicePingRequested(device.id));
                            },
                          ),
                        if (_selectedDevices.isEmpty)
                          IconButton(
                            icon: const Icon(Icons.edit_rounded),
                            tooltip: 'Rename Device',
                            color: colorScheme.onSurfaceVariant,
                            iconSize: 20,
                            onPressed: () => _showRenameDeviceDialog(context, device.id, device.friendlyName),
                          ),
                      ],
                    ),
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
}
