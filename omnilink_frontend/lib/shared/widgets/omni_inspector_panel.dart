import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'omni_drop_zone.dart';
import '../../core/di/injection.dart';
import '../../features/timeline/data/cards_api.dart';

// ... class definition

class OmniInspectorPanel extends StatefulWidget {
  const OmniInspectorPanel({super.key});

  @override
  State<OmniInspectorPanel> createState() => _OmniInspectorPanelState();
}

class _OmniInspectorPanelState extends State<OmniInspectorPanel> {
  bool _isDragging = false;
  bool _isUploading = false;

  Future<void> _handleDroppedFiles(List<XFile> files) async {
    setState(() {
      _isUploading = true;
    });

    try {
      for (final file in files) {
        await getIt<CardsApi>().createFileCard(file.path, tagIds: []);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded ${files.length} file(s)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload dropped files: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          left: BorderSide(
            color: colorScheme.onSurface.withAlpha(25),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [

                  Expanded(
                    child: DropTarget(
                      onDragEntered: (detail) => setState(() => _isDragging = true),
                      onDragExited: (detail) => setState(() => _isDragging = false),
                      onDragDone: (detail) {
                        setState(() => _isDragging = false);
                        _handleDroppedFiles(detail.files);
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isDragging
                              ? colorScheme.primaryContainer.withAlpha(100)
                              : colorScheme.surfaceContainerHighest.withAlpha(51),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isDragging
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant.withAlpha(51),
                            width: _isDragging ? 2 : 1,
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                child: IntrinsicHeight(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isUploading) ...[
                                        const CircularProgressIndicator(),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Uploading...',
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ] else ...[
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: _isDragging 
                                                ? colorScheme.primary 
                                                : colorScheme.surfaceContainerHighest,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.cloud,
                                            size: 32,
                                            color: _isDragging 
                                                ? colorScheme.onPrimary 
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Drop anything here',
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: _isDragging ? colorScheme.primary : colorScheme.onSurface,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'File, text, image, links, code,\nor voice note.',
                                          textAlign: TextAlign.center,
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: OmniDropZone(),
          ),
        ],
      ),
    );
  }
}
