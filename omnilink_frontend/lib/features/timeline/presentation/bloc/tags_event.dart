import 'package:equatable/equatable.dart';

abstract class TagsEvent extends Equatable {
  const TagsEvent();

  @override
  List<Object?> get props => [];
}

class TagsLoadRequested extends TagsEvent {}

class TagCreateRequested extends TagsEvent {
  final String name;
  final String? colorHex;

  const TagCreateRequested(this.name, {this.colorHex});

  @override
  List<Object?> get props => [name, colorHex];
}

class TagDeleteRequested extends TagsEvent {
  final String tagId;

  const TagDeleteRequested(this.tagId);

  @override
  List<Object?> get props => [tagId];
}
