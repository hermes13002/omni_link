import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:any_link_preview/any_link_preview.dart';
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
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

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
  OmniDropZoneState createState() => OmniDropZoneState();
}

class OmniDropZoneState extends State<OmniDropZone> {
  bool _isSending = false;
  bool _showTags = false;
  
  // Make state static so it persists across responsive layout changes (desktop <-> mobile)
  static final Set<String> _selectedTagIds = {};
  static StagedFile? _stagedFile;
  static String? _stagedUrl;
  static String? _dismissedUrl;
  static final TextEditingController _textController = TextEditingController();
  static final TextEditingController _titleController = TextEditingController();
  static final FocusNode _textFocusNode = FocusNode();
  
  // Speech to text state
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  void focusTextField() {
    _textFocusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
      setState(() {});
    } catch (e) {
      if (mounted) OmniToast.showError(context, 'Speech recognition init failed: $e');
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _speechToText.cancel();
    super.dispose();
  }

  void _startListening() async {
    if (!_speechEnabled) {
      _initSpeech();
      return;
    }
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      // If we have previous text, ensure a space is added
      final currentText = _textController.text;
      if (_lastWords.isNotEmpty && currentText.endsWith(_lastWords)) {
        // Replace the last recognized segment with the updated one
        _textController.text = currentText.substring(0, currentText.length - _lastWords.length) + result.recognizedWords;
      } else {
        if (currentText.isNotEmpty && !currentText.endsWith(' ')) {
          _textController.text = '$currentText ${result.recognizedWords}';
        } else {
          _textController.text = currentText + result.recognizedWords;
        }
      }
      _lastWords = result.recognizedWords;
      _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
    });
    
    // When final result is received, stop listening
    if (result.finalResult) {
      _lastWords = '';
      _stopListening();
    }
  }

  void _onTextChanged() {
    final text = _textController.text;
    final RegExp urlRegex = RegExp(r'(https?:\/\/[^\s]+|(?:www\.)[^\s]+)', caseSensitive: false);
    final match = urlRegex.firstMatch(text);
    
    if (match != null) {
      String url = match.group(0)!;
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }
      if (_stagedUrl != url && _dismissedUrl != url) {
        setState(() {
          _stagedUrl = url;
        });
      }
    } else {
      if (_stagedUrl != null || _dismissedUrl != null) {
        setState(() {
          _stagedUrl = null;
          _dismissedUrl = null;
        });
      }
    }
  }

  void _clearSelection() {
    _textController.clear();
    _titleController.clear();
    setState(() {
      _selectedTagIds.clear();
      _showTags = false;
      _stagedFile = null;
      _stagedUrl = null;
      _dismissedUrl = null;
    });
  }

  void _handleSend() {
    final text = _textController.text.trim();
    final title = _titleController.text.trim();
    if (text.isEmpty && title.isEmpty && _stagedFile == null) return;
    
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
    
    final timelineBloc = context.read<TimelineBloc>();
    final cardsApi = getIt<CardsApi>();
    final selectedTagIds = _selectedTagIds.toList();

    if (_stagedFile != null) {
      if (_stagedFile!.path == null && _stagedFile!.bytes == null) {
        OmniToast.showError(context, 'Invalid file: No data available. Please remove and re-select the file.');
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
      timelineBloc.add(TimelineCardCreated(dummyCard));
      
      final filePath = _stagedFile!.path;
      final bytes = _stagedFile!.bytes;
      final fileName = _stagedFile!.name;

      Future(() async {
        try {
          final card = await cardsApi.createFileCard(
            filePath: filePath,
            bytes: bytes,
            fileName: fileName,
            title: finalTitle.isNotEmpty ? finalTitle : null,
            tagIds: selectedTagIds,
          );
          timelineBloc.add(TimelineCardResolved(tempId, card));
        } catch (e) {
          timelineBloc.add(TimelineCardFailed(tempId, e.toString()));
        }
      });
    } else {
      // Normalize 'www.' to 'https://www.' for the backend request if it matches the regex
      String normalizedText = text;
      final RegExp urlRegex = RegExp(r'(https?:\/\/[^\s]+|(?:www\.)[^\s]+)', caseSensitive: false);
      final match = urlRegex.firstMatch(text);
      if (match != null) {
        String url = match.group(0)!;
        if (!url.startsWith('http')) {
           normalizedText = text.replaceFirst(url, 'https://$url');
        }
      }

      final isUrl = Uri.tryParse(normalizedText)?.hasAbsolutePath ?? false;
      
      dummyCard = dummyCard.copyWith(
        cardType: isUrl ? 'metadata' : 'text',
        body: normalizedText.isNotEmpty ? normalizedText : null,
      );
      timelineBloc.add(TimelineCardCreated(dummyCard));

      Future(() async {
        try {
          CardModel card;
          if (isUrl) {
            card = await cardsApi.createMetadataCard(title.isNotEmpty ? title : normalizedText, body: normalizedText, tagIds: selectedTagIds);
          } else {
            card = await cardsApi.createTextCard(normalizedText, title: title.isNotEmpty ? title : null, tagIds: selectedTagIds);
          }
          timelineBloc.add(TimelineCardResolved(tempId, card));
        } catch (e) {
          timelineBloc.add(TimelineCardFailed(tempId, e.toString()));
        }
      });
    }

    _clearSelection();
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

  Future<void> handleDroppedFiles(List<XFile> files) async {
    if (files.isEmpty) return;
    try {
      final file = files.first;
      List<int>? bytes;
      if (kIsWeb) {
        bytes = await file.readAsBytes();
      }
      
      final titleLower = file.name.toLowerCase();
      final isImage = titleLower.endsWith('.jpg') || 
                      titleLower.endsWith('.png') || 
                      titleLower.endsWith('.jpeg') || 
                      titleLower.endsWith('.webp');

      setState(() {
        _stagedFile = StagedFile(
          name: file.name,
          path: kIsWeb ? null : file.path,
          bytes: bytes,
          isImage: isImage,
        );
        if (_titleController.text.isEmpty && _textController.text.isEmpty) {
          _titleController.text = file.name;
        }
      });
    } catch (e) {
      if (mounted) {
        OmniToast.showError(context, 'Failed to stage dropped file: $e');
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
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _stagedUrl != null ? _buildLinkPreview(context, colorScheme) : const SizedBox(width: double.infinity, height: 0),
          ),
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
                width: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  shape: BoxShape.circle,
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
                  focusNode: _textFocusNode,
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
                icon: Icon(
                  _isListening ? Icons.stop_rounded : Icons.mic_rounded, 
                  color: _isListening ? colorScheme.error : colorScheme.onSurfaceVariant,
                ),
                onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
                iconSize: 20,
              ),
              AnimatedBuilder(
                animation: Listenable.merge([_textController, _titleController]),
                builder: (context, child) {
                  final hasContent = _textController.text.trim().isNotEmpty || _titleController.text.trim().isNotEmpty || _stagedFile != null;
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: hasContent 
                      ? Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(left: 4),
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
                        )
                      : const SizedBox(width: 0, height: 40),
                  );
                },
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

  Widget _buildLinkPreview(BuildContext context, ColorScheme colorScheme) {
    if (_stagedUrl == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4, right: 4, top: 4),
      child: Stack(
        children: [
          FutureBuilder<Metadata?>(
            key: ValueKey(_stagedUrl!),
            future: AnyLinkPreview.getMetadata(
              link: kIsWeb ? '${getIt<Dio>().options.baseUrl}/api/v1/proxy?url=${Uri.encodeComponent(_stagedUrl!)}' : _stagedUrl!,
              cache: const Duration(hours: 1),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 90,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onSurfaceVariant),
                  ),
                );
              }

              final metadata = snapshot.data;
              if (metadata == null) {
                return Container(
                  height: 90,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(_stagedUrl!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: colorScheme.onSurface)),
                );
              }

              final imageUrl = metadata.image;
              final proxiedImageUrl = (kIsWeb && imageUrl != null && imageUrl.startsWith('http')) 
                  ? '${getIt<Dio>().options.baseUrl}/api/v1/proxy?url=${Uri.encodeComponent(imageUrl)}' 
                  : imageUrl;
              
              return Container(
                height: 90,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (proxiedImageUrl != null)
                      SizedBox(
                        width: 80,
                        child: Image.network(
                          proxiedImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              metadata.title ?? _stagedUrl!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              metadata.desc ?? metadata.url ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: () {
                setState(() {
                  _dismissedUrl = _stagedUrl;
                  _stagedUrl = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
