import 'package:equatable/equatable.dart';
import '../../data/models/tag_model.dart';

abstract class TagsState extends Equatable {
  const TagsState();

  @override
  List<Object?> get props => [];
}

class TagsInitial extends TagsState {}

class TagsLoading extends TagsState {}

class TagsLoaded extends TagsState {
  final List<TagModel> tags;

  const TagsLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

class TagsError extends TagsState {
  final String message;

  const TagsError(this.message);

  @override
  List<Object?> get props => [message];
}
