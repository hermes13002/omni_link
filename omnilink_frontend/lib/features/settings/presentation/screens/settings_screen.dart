import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/omni_top_bar.dart';
import '../../../device/presentation/bloc/device_bloc.dart';
import '../../../device/presentation/bloc/device_state.dart';
import '../../../device/presentation/bloc/device_event.dart';
import '../../../timeline/presentation/bloc/tags_bloc.dart';
import '../../../timeline/presentation/bloc/tags_state.dart';
import '../../../timeline/presentation/bloc/tags_event.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DeviceBloc>().add(DevicesLoadRequested());
    context.read<TagsBloc>().add(TagsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Devices',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          BlocBuilder<DeviceBloc, DeviceState>(
            builder: (context, state) {
              if (state is DeviceLoading || state is DeviceInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DeviceError) {
                return Text('Error: ${state.message}', style: const TextStyle(color: Colors.red));
              } else if (state is DevicesLoaded) {
                if (state.devices.isEmpty) {
                  return const Text('No devices found.');
                }
                return Column(
                  children: state.devices.map((device) => ListTile(
                    leading: const Icon(Icons.devices),
                    title: Text(device.friendlyName),
                    subtitle: Text('Last seen: ${device.lastSeen ?? 'Unknown'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        context.read<DeviceBloc>().add(DeviceDeleteRequested(device.id));
                      },
                    ),
                  )).toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Divider(height: 32),
          const Text(
            'Tags',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          BlocBuilder<TagsBloc, TagsState>(
            builder: (context, state) {
              if (state is TagsLoading || state is TagsInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TagsError) {
                return Text('Error: ${state.message}', style: const TextStyle(color: Colors.red));
              } else if (state is TagsLoaded) {
                if (state.tags.isEmpty) {
                  return const Text('No tags found.');
                }
                return Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: state.tags.map((tag) => Chip(
                    label: Text(tag.name),
                    onDeleted: () {
                      context.read<TagsBloc>().add(TagDeleteRequested(tag.id));
                    },
                  )).toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showCreateTagDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Tag'),
          ),
        ],
      ),
    );
  }

  void _showCreateTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Tag'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Tag Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<TagsBloc>().add(TagCreateRequested(controller.text.trim()));
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
