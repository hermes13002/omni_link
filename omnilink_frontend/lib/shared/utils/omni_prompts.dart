import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/timeline/presentation/bloc/tags_bloc.dart';
import '../../features/timeline/presentation/bloc/tags_state.dart';

class OmniPrompts {
  static Future<(String?, List<String>)> promptForFileDetails(
    BuildContext context, {
    String? defaultTitle,
    List<String> initialTagIds = const [],
  }) async {
    final TextEditingController controller = TextEditingController(text: defaultTitle);
    final colorScheme = Theme.of(context).colorScheme;
    final selectedTagIds = Set<String>.from(initialTagIds);

    Color? hexToColor(String? hexString) {
      if (hexString == null || hexString.isEmpty) return null;
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }

    final tagsBloc = context.read<TagsBloc>();

    final result = await showDialog<(String?, List<String>)>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: tagsBloc,
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: colorScheme.surfaceContainer,
              title: const Text('File Upload Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Enter title (optional)',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Select Tags',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<TagsBloc, TagsState>(
                      builder: (context, state) {
                        if (state is TagsLoaded) {
                          if (state.tags.isEmpty) {
                            return Text(
                              'No tags available',
                              style: TextStyle(color: colorScheme.onSurfaceVariant.withAlpha(150)),
                            );
                          }
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: state.tags.map((tag) {
                              final isSelected = selectedTagIds.contains(tag.id);
                              final tagColor = hexToColor(tag.colorHex) ?? colorScheme.primary;
                              return FilterChip(
                                label: Text(tag.name),
                                selected: isSelected,
                                showCheckmark: false,
                                backgroundColor: tagColor.withAlpha(25),
                                selectedColor: tagColor.withAlpha(76),
                                side: BorderSide(
                                  color: isSelected ? tagColor : tagColor.withAlpha(51),
                                  width: 1,
                                ),
                                labelStyle: TextStyle(
                                  color: isSelected ? colorScheme.onSurface : tagColor,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedTagIds.add(tag.id);
                                    } else {
                                      selectedTagIds.remove(tag.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, (controller.text.trim(), selectedTagIds.toList())),
                  child: const Text('Upload'),
                ),
              ],
            );
          },
        ),
        );
      },
    );

    return result ?? (null, <String>[]);
  }
}
