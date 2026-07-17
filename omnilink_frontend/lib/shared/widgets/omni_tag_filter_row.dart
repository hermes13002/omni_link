import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/timeline/presentation/bloc/tags_bloc.dart';
import '../../features/timeline/presentation/bloc/tags_state.dart';
import '../../features/timeline/presentation/bloc/tags_event.dart';

import 'omni_filter_chip.dart';
import 'omni_button.dart';
import 'omni_text_field.dart';
import 'omni_glass_container.dart';
import 'package:omnilink_frontend/shared/utils/omni_toast.dart';

class OmniTagFilterRow extends StatefulWidget {
  final String? activeTagId;
  final ValueChanged<String?> onTagSelected;

  const OmniTagFilterRow({
    super.key,
    required this.activeTagId,
    required this.onTagSelected,
  });

  @override
  State<OmniTagFilterRow> createState() => _OmniTagFilterRowState();
}

class _OmniTagFilterRowState extends State<OmniTagFilterRow> {
  Color? _hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void _showAddTagDialog(BuildContext context) {
    final TextEditingController tagController = TextEditingController();
    bool isSubmitting = false;
    String? selectedColor;
    final tagsBloc = context.read<TagsBloc>();

    final List<String> presetColors = [
      '#ef4444', '#f97316', '#eab308', '#22c55e', '#3b82f6', '#a855f7', '#ec4899'
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: tagsBloc,
        child: StatefulBuilder(
          builder: (ctx, setState) => BlocConsumer<TagsBloc, TagsState>(
            listener: (context, state) {
              if (isSubmitting && state is TagsLoaded) {
                Navigator.pop(ctx);
              } else if (isSubmitting && state is TagsError) {
                setState(() => isSubmitting = false);
                OmniToast.showError(context, state.message);
              }
            },
            builder: (context, state) {
              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: OmniGlassContainer(
                  padding: const EdgeInsets.all(24.0),
                  borderRadius: 24.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Tag',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OmniTextField(
                        controller: tagController,
                        hintText: 'e.g. workspace, ideas',
                        prefixIcon: Icons.tag,
                        autofocus: true,
                        maxLength: 10,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tag Color (Optional)',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: presetColors.map((colorHex) {
                          final color = _hexToColor(colorHex)!;
                          final isSelected = selectedColor == colorHex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedColor = null;
                                } else {
                                  selectedColor = colorHex;
                                }
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected 
                                    ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                                    : null,
                                boxShadow: isSelected 
                                    ? [BoxShadow(color: color.withAlpha(100), blurRadius: 8, spreadRadius: 2)]
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                            child: Text(
                              'Cancel',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OmniButton(
                            text: 'Create',
                            isLoading: isSubmitting,
                            onPressed: isSubmitting
                                ? () {}
                                : () {
                                    if (tagController.text.trim().isNotEmpty) {
                                      setState(() => isSubmitting = true);
                                      context.read<TagsBloc>().add(TagCreateRequested(
                                        tagController.text.trim(), 
                                        colorHex: selectedColor
                                      ));
                                    }
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: BlocBuilder<TagsBloc, TagsState>(
          builder: (context, state) {
            final tags = (state is TagsLoaded) ? state.tags : [];
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _showAddTagDialog(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: tags.isEmpty ? 12 : 6, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: colorScheme.primaryContainer,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 20, color: colorScheme.onPrimaryContainer),
                        if (tags.isEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            'Add Tag',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (tags.isNotEmpty) ...[
                  OmniFilterChip(
                    label: 'All Stream',
                    isActive: widget.activeTagId == null,
                    onTap: () => widget.onTagSelected(null),
                  ),
                  const SizedBox(width: 8),
                ],
                ...tags.map((tag) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OmniFilterChip(
                    label: '#${tag.name}',
                    isActive: widget.activeTagId == tag.id,
                    onTap: () => widget.onTagSelected(tag.id),
                    tagColor: _hexToColor(tag.colorHex),
                  ),
                )),
              ],
            );
          },
        ),
      ),
    );
  }
}
