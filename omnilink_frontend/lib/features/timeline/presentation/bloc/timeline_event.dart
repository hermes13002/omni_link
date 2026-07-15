import 'package:equatable/equatable.dart';
import '../../data/models/card_model.dart';

abstract class TimelineEvent extends Equatable {
  const TimelineEvent();

  @override
  List<Object?> get props => [];
}

class TimelineLoadRequested extends TimelineEvent {
  final String? cardType;
  final String? tagId;
  final bool? pinned;

  const TimelineLoadRequested({this.cardType, this.tagId, this.pinned});

  @override
  List<Object?> get props => [cardType, tagId, pinned];
}

class TimelineCardCreated extends TimelineEvent {
  final CardModel card;
  const TimelineCardCreated(this.card);

  @override
  List<Object?> get props => [card];
}

class TimelineCardDeleted extends TimelineEvent {
  final String cardId;

  const TimelineCardDeleted(this.cardId);

  @override
  List<Object?> get props => [cardId];
}

class TimelineCardUpdated extends TimelineEvent {
  final CardModel card;

  const TimelineCardUpdated(this.card);

  @override
  List<Object?> get props => [card];
}
