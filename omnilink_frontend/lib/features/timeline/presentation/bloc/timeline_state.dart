import 'package:equatable/equatable.dart';
import '../../data/models/card_model.dart';

abstract class TimelineState extends Equatable {
  const TimelineState();

  @override
  List<Object?> get props => [];
}

class TimelineInitial extends TimelineState {}

class TimelineLoading extends TimelineState {}

class TimelineLoaded extends TimelineState {
  final List<CardModel> cards;
  final bool hasReachedMax;

  const TimelineLoaded(this.cards, {this.hasReachedMax = false});

  @override
  List<Object?> get props => [cards, hasReachedMax];
}

class TimelineError extends TimelineState {
  final String message;

  const TimelineError(this.message);

  @override
  List<Object?> get props => [message];
}
