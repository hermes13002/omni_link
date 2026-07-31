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
import '../../features/timeline/presentation/bloc/timeline_bloc.dart';
import '../../features/timeline/presentation/bloc/timeline_event.dart';
import '../../features/timeline/data/models/card_model.dart';
import 'package:omnilink_frontend/shared/utils/omni_toast.dart';
import 'package:uuid/uuid.dart';

class StagedFile {
  final String name;
  final String? path;
  final List<int>? bytes;
  final bool isImage;

  StagedFile({
    required this.name,
    this.path,
    this.bytes,
    required this.isImage,
  });
}

class OmniDropZone extends StatefulWidget {
  const OmniDropZone({super.key});

  @override
  State<OmniDropZone> createState() => _OmniDropZoneState();
}

class _OmniDropZoneState extends State<OmniDropZone> {
  bool _isSending = false;
  bool _showTags = false;
  
  // Make state static so it persists across responsive layout changes (desktop <-> mobile)
  static final Set<String> _selectedTagIds = {};
  static StagedFile? _stagedFile;
  static final TextEditingController _textController = TextEditingController();
  static final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    // Do not dispose static controllers
    super.dispose();
  }

  void _clearSelection() {
    _textController.clear();
    _titleController.clear();
    setState(() {
      _selectedTagIds.clear();
      _showTags = false;
      _stagedFile = null;
    });
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    final title = _titleController.text.trim();
    if (text.isEmpty && title.isEmpty && _stagedFile == null) return;

    setState(() => _isSending = true);
    
    try {
      final String tempId = const Uuid().v4();
      CardModel dummyCard = CardModel(
        id: tempId,
        cardType: 'text', // default to text, updated below
        title: title.isNotEmpty ? title : null,
        body: text.isNotEmpty ? text : null,
        pinned: false,
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: CardSyncStatus.pending,
      );

      if (_stagedFile != null) {
        if (_stagedFile!.path == null && _stagedFile!.bytes == null) {
          OmniToast.showError(context, 'Invalid file: No data available. Please remove and re-select the file.');
          setState(() => _isSending = false);
          return;
        }

        String finalTitle = title.isNotEmpty ? title : text;
        if (finalTitle.isEmpty) finalTitle = _stagedFile!.name;
        
        dummyCard = dummyCard.copyWith(
          cardType: 'file',
          title: finalTitle,
          localBytes: _stagedFile!.bytes != null ? Uint8List.fromList(_stagedFile!.bytes!) : null,
          mimeType: _stagedFile!.isImage ? 'image/jpeg' : null,
        );
        if (mounted) context.read<TimelineBloc>().add(TimelineCardCreated(dummyCard));

        try {
          final card = await getIt<CardsApi>().createFileCard(
            filePath: _stagedFile!.path,
            bytes: _stagedFile!.bytes,
            fileName: _stagedFile!.name,
            title: finalTitle.isNotEmpty ? finalTitle : null,
            tagIds: _selectedTagIds.toList(),
          );
          if (mounted) context.read<TimelineBloc>().add(TimelineCardResolved(tempId, card));
        } catch (e) {
          if (mounted) context.read<TimelineBloc>().add(TimelineCardFailed(tempId, e.toString()));
          rethrow;
        }
      } else {
        final isUrl = Uri.tryParse(text)?.hasAbsolutePath ?? false;
        
        dummyCard = dummyCard.copyWith(
          cardType: isUrl ? 'metadata' : 'text',
        );
        if (mounted) context.read<TimelineBloc>().add(TimelineCardCreated(dummyCard));

        try {
          CardModel card;
          if (isUrl) {
            card = await getIt<CardsApi>().createMetadataCard(title.isNotEmpty ? title : text, body: text, tagIds: _selectedTagIds.toList());
          } else {
            card = await getIt<CardsApi>().createTextCard(text, title: title.isNotEmpty ? title : null, tagIds: _selectedTagIds.toList());
          }
          if (mounted) context.read<TimelineBloc>().add(TimelineCardResolved(tempId, card));
        } catch (e) {
          if (mounted) context.read<TimelineBloc>().add(TimelineCardFailed(tempId, e.toString()));
          rethrow;
        }
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
        List<int>? bytes;
        if (kIsWeb) {
          bytes = await image.readAsBytes();
        }
        setState(() {
          _stagedFile = StagedFile(
            name: image.name,
            path: kIsWeb ? null : image.path,
            bytes: bytes,
            isImage: true,
          );
          if (_titleController.text.isEmpty && _textController.text.isEmpty) {
            _titleController.text = image.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        OmniToast.showError(context, 'Failed to upload image: $e');
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(withData: true);
      if (result != null) {
        final file = result.files.single;
        setState(() {
          _stagedFile = StagedFile(
            name: file.name,
            path: kIsWeb ? null : file.path,
            bytes: file.bytes,
            isImage: false,
          );
          if (_titleController.text.isEmpty && _textController.text.isEmpty) {
            _titleController.text = file.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        OmniToast.showError(context, 'Failed to upload file: $e');
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
        if (_stagedFile != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _stagedFile!.isImage ? Icons.image_rounded : Icons.insert_drive_file_rounded,
                          size: 16,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _stagedFile!.name,
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => setState(() => _stagedFile = null),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.add_rounded, color: colorScheme.onSurface),
                  iconSize: 20,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: colorScheme.surfaceContainerHighest,
                  offset: const Offset(0, -135),
                  onSelected: (value) {
                    if (value == 'camera') _pickImage(ImageSource.camera);
                    if (value == 'gallery') _pickImage(ImageSource.gallery);
                    if (value == 'file') _pickFile();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'camera',
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                          const SizedBox(width: 12),
                          Text('Camera', style: TextStyle(color: colorScheme.onSurface)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'gallery',
                      child: Row(
                        children: [
                          Icon(Icons.image_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                          const SizedBox(width: 12),
                          Text('Gallery', style: TextStyle(color: colorScheme.onSurface)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'file',
                      child: Row(
                        children: [
                          Icon(Icons.attach_file_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                          const SizedBox(width: 12),
                          Text('File', style: TextStyle(color: colorScheme.onSurface)),
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
            final showTitle = _textController.text.isNotEmpty || _titleController.text.isNotEmpty || _stagedFile != null;
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
