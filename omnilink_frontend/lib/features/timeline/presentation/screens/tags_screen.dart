import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/tags_bloc.dart';
import '../bloc/tags_state.dart';
import '../bloc/tags_event.dart';
import '../../../../shared/widgets/omni_faded_grid_background.dart';
import '../../../../shared/widgets/omni_glass_container.dart';
import '../../../../shared/widgets/omni_loaders.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final TextEditingController _tagController = TextEditingController();
  bool _isAddingTag = false;

  @override
  void initState() {
    super.initState();
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

    return OmniFadedGridBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Manage Tags',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: OmniGlassContainer(
          padding: const EdgeInsets.all(24.0),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Tags',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              BlocBuilder<TagsBloc, TagsState>(
                builder: (context, state) {
                  if (state is TagsLoading || state is TagsInitial) {
                    return const Center(child: OmniDotsLoader());
                  } else if (state is TagsError) {
                    return Text('Error: ${state.message}', style: TextStyle(color: colorScheme.error));
                  } else if (state is TagsLoaded) {
                    if (state.tags.isEmpty && !_isAddingTag) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No tags yet. Create one below.', 
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)
                        ),
                      );
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
                            avatar: Icon(Icons.add_rounded, size: 16, color: colorScheme.primary),
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
              if (_isAddingTag) ...[
                const SizedBox(height: 24),
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
                      icon: Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 28),
                      onPressed: _submitTag,
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant, size: 28),
                      onPressed: () {
                        setState(() {
                          _isAddingTag = false;
                          _tagController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ));
  }
}
