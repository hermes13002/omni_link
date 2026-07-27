import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'omni_glass_container.dart';
import '../../core/di/injection.dart';
import '../../features/timeline/data/cards_api.dart';
import '../../features/timeline/presentation/bloc/tags_bloc.dart';
import '../../features/timeline/presentation/bloc/tags_state.dart';
import 'package:omnilink_frontend/shared/utils/omni_toast.dart';
import 'package:omnilink_frontend/shared/utils/omni_prompts.dart';

class OmniDropZone extends StatefulWidget {
  const OmniDropZone({super.key});

  @override
  State<OmniDropZone> createState() => _OmniDropZoneState();
}

class _OmniDropZoneState extends State<OmniDropZone> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isSending = false;
  bool _showTags = false;
  final Set<String> _selectedTagIds = {};
  
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _clearSelection() {
    _textController.clear();
    _titleController.clear();
    setState(() {
      _selectedTagIds.clear();
      _showTags = false;
    });
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    final title = _titleController.text.trim();
    if (text.isEmpty && title.isEmpty) return;

    setState(() => _isSending = true);
    
    try {
      final isUrl = Uri.tryParse(text)?.hasAbsolutePath ?? false;
      if (isUrl) {
        await getIt<CardsApi>().createMetadataCard(title.isNotEmpty ? title : text, body: text, tagIds: _selectedTagIds.toList());
      } else {
        await getIt<CardsApi>().createTextCard(text, title: title.isNotEmpty ? title : null, tagIds: _selectedTagIds.toList());
      }
      
      if (mounted) {
        _clearSelection();
      }
    } catch (e) {
      if (mounted) {
        OmniToast.showError(context, 'Failed to send: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() => _isSending = true);
        final initialTitle = _titleController.text.trim();
        final defaultTitle = initialTitle.isNotEmpty ? initialTitle : image.name;
        final result = await OmniPrompts.promptForFileDetails(context, defaultTitle: defaultTitle, initialTagIds: _selectedTagIds.toList());
        final finalTitle = result.$1;
        final finalTagIds = result.$2;
        if (finalTitle == null) {
          setState(() => _isSending = false);
          return;
        }

        List<int>? bytes;
        if (kIsWeb) {
          bytes = await image.readAsBytes();
        }

        await getIt<CardsApi>().createFileCard(
          filePath: kIsWeb ? null : image.path,
          bytes: bytes,
          fileName: image.name,
          title: finalTitle.isNotEmpty ? finalTitle : null,
          tagIds: finalTagIds,
        );
        if (mounted) _clearSelection();
        if (_isExpanded) _toggleMenu();
      }
    } catch (e) {
      if (mounted) {
        OmniToast.showError(context, 'Failed to upload image: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() => _isSending = true);
        final initialTitle = _titleController.text.trim();
        final defaultTitle = initialTitle.isNotEmpty ? initialTitle : result.files.single.name;
        final promptResult = await OmniPrompts.promptForFileDetails(context, defaultTitle: defaultTitle, initialTagIds: _selectedTagIds.toList());
        final finalTitle = promptResult.$1;
        final finalTagIds = promptResult.$2;
        if (finalTitle == null) {
          setState(() => _isSending = false);
          return;
        }
        
        final file = result.files.single;
        await getIt<CardsApi>().createFileCard(
          filePath: kIsWeb ? null : file.path,
          bytes: file.bytes,
          fileName: file.name,
          title: finalTitle.isNotEmpty ? finalTitle : null, 
          tagIds: finalTagIds,
        );
        if (mounted) _clearSelection();
        if (_isExpanded) _toggleMenu();
      }
    } catch (e) {
      if (mounted) {
        OmniToast.showError(context, 'Failed to upload file: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OmniGlassContainer(
      borderRadius: 24.0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(178),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<TagsBloc, TagsState>(
            builder: (context, state) {
              if (state is TagsLoaded) {
                final visibleTags = _showTags 
                    ? state.tags 
                    : state.tags.where((t) => _selectedTagIds.contains(t.id)).toList();
                
                if (visibleTags.isEmpty) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: visibleTags.map((tag) {
                        final isSelected = _selectedTagIds.contains(tag.id);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text('#${tag.name}'),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTagIds.add(tag.id);
                                } else {
                                  _selectedTagIds.remove(tag.id);
                                }
                              });
                            },
                            selectedColor: colorScheme.secondaryContainer,
                            checkmarkColor: colorScheme.onSecondaryContainer,
                            labelStyle: TextStyle(
                              color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          Row(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RotationTransition(
                      turns: _rotateAnimation,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add_rounded, color: colorScheme.onSurface),
                          onPressed: _toggleMenu,
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      axis: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: Icon(Icons.camera_alt_rounded, color: colorScheme.onSurface),
                              onPressed: () => _pickImage(ImageSource.camera),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: Icon(Icons.image_rounded, color: colorScheme.onSurface),
                              onPressed: () => _pickImage(ImageSource.gallery),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: Icon(Icons.attach_file_rounded, color: colorScheme.onSurface),
                              onPressed: _pickFile,
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _showTags ? colorScheme.primaryContainer : colorScheme.surfaceContainerLowest,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.local_offer_rounded, 
                    color: _showTags ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _showTags = !_showTags),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Type, paste link...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.mic_rounded, color: colorScheme.onSurfaceVariant),
                onPressed: () {},
                iconSize: 20,
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primaryContainer.withAlpha(102),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: _isSending
                    ? SizedBox(
                        width: 18, 
                        height: 18, 
                        child: CircularProgressIndicator(
                          strokeWidth: 2, 
                          color: colorScheme.onPrimaryContainer,
                        )
                      )
                    : IconButton(
                        icon: Icon(Icons.send_rounded, color: colorScheme.onPrimaryContainer),
                        onPressed: _handleSend,
                        iconSize: 18,
                      ),
              ),
            ],
          ),
        ],
      ),
        ),
        AnimatedBuilder(
          animation: Listenable.merge([_textController, _titleController]),
          builder: (context, child) {
            final showTitle = _textController.text.isNotEmpty || _titleController.text.isNotEmpty;
            return AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: showTitle
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OmniGlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        borderRadius: 16.0,
                        backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(128),
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Title (optional)',
                            hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withAlpha(150),
                              fontWeight: FontWeight.bold,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            );
          },
        ),
      ],
    );
  }
}
