import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/tags_api.dart';
import 'tags_event.dart';
import 'tags_state.dart';

@lazySingleton
class TagsBloc extends Bloc<TagsEvent, TagsState> {
  final TagsApi _tagsApi;

  TagsBloc(this._tagsApi) : super(TagsInitial()) {
    on<TagsLoadRequested>(_onLoadRequested);
    on<TagCreateRequested>(_onCreateRequested);
    on<TagDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    TagsLoadRequested event,
    Emitter<TagsState> emit,
  ) async {
    emit(TagsLoading());
    try {
      final tags = await _tagsApi.getTags();
      emit(TagsLoaded(tags));
    } catch (e) {
      emit(TagsError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    TagCreateRequested event,
    Emitter<TagsState> emit,
  ) async {
    if (state is TagsLoaded) {
      final currentTags = (state as TagsLoaded).tags;
      try {
        final newTag = await _tagsApi.createTag(event.name, colorHex: event.colorHex);
        emit(TagsLoaded([...currentTags, newTag]));
      } catch (e) {
        emit(TagsError(e.toString()));
        emit(TagsLoaded(currentTags));
      }
    }
  }

  Future<void> _onDeleteRequested(
    TagDeleteRequested event,
    Emitter<TagsState> emit,
  ) async {
    if (state is TagsLoaded) {
      final currentTags = (state as TagsLoaded).tags;
      try {
        await _tagsApi.deleteTag(event.tagId);
        emit(TagsLoaded(currentTags.where((t) => t.id != event.tagId).toList()));
      } catch (e) {
        emit(TagsError(e.toString()));
        emit(TagsLoaded(currentTags));
      }
    }
  }
}
