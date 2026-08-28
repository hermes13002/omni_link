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
  final String? searchQuery;

  const TimelineLoadRequested({this.cardType, this.tagId, this.pinned, this.searchQuery});

  @override
  List<Object?> get props => [cardType, tagId, pinned, searchQuery];
}

class TimelineCardCreated extends TimelineEvent {
  final CardModel card;
  const TimelineCardCreated(this.card);

  @override
  List<Object?> get props => [card];
}

class TimelineCardResolved extends TimelineEvent {
  final String tempId;
  final CardModel realCard;
  
  const TimelineCardResolved(this.tempId, this.realCard);

  @override
  List<Object?> get props => [tempId, realCard];
}

class TimelineCardFailed extends TimelineEvent {
  final String tempId;
  final String error;

  const TimelineCardFailed(this.tempId, this.error);

  @override
  List<Object?> get props => [tempId, error];
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

class TimelineTogglePinRequested extends TimelineEvent {
  final CardModel card;

  const TimelineTogglePinRequested(this.card);

  @override
  List<Object?> get props => [card];
}

class TimelineDeleteCardsRequested extends TimelineEvent {
  final List<String> cardIds;

  const TimelineDeleteCardsRequested(this.cardIds);

  @override
  List<Object?> get props => [cardIds];
}

class TimelineCardRetryRequested extends TimelineEvent {
  final CardModel card;

  const TimelineCardRetryRequested(this.card);

  @override
  List<Object?> get props => [card];
}
