import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/cards_api.dart';
import '../../data/models/card_model.dart';
import 'timeline_event.dart';
import 'timeline_state.dart';

@lazySingleton
class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  final CardsApi _cardsApi;

  TimelineBloc(this._cardsApi) : super(TimelineInitial()) {
    on<TimelineLoadRequested>(_onLoadRequested);
    on<TimelineCardCreated>(_onCardCreated);
    on<TimelineCardDeleted>(_onCardDeleted);
    on<TimelineCardUpdated>(_onCardUpdated);
    on<TimelineTogglePinRequested>(_onTogglePinRequested);
  }

  Future<void> _onLoadRequested(
    TimelineLoadRequested event,
    Emitter<TimelineState> emit,
  ) async {
    emit(TimelineLoading());
    try {
      final cards = await _cardsApi.getCards(
        cardType: event.cardType,
        tagId: event.tagId,
        pinned: event.pinned,
        search: event.searchQuery,
      );
      emit(TimelineLoaded(cards));
    } catch (e) {
      emit(TimelineError(e.toString()));
    }
  }

  void _onCardCreated(
    TimelineCardCreated event,
    Emitter<TimelineState> emit,
  ) {
    if (state is TimelineLoaded) {
      final currentCards = (state as TimelineLoaded).cards;
      emit(TimelineLoaded([event.card, ...currentCards]));
    }
  }

  void _onCardDeleted(
    TimelineCardDeleted event,
    Emitter<TimelineState> emit,
  ) {
    if (state is TimelineLoaded) {
      final currentCards = (state as TimelineLoaded).cards;
      final updatedCards = currentCards.where((c) => c.id != event.cardId).toList();
      emit(TimelineLoaded(updatedCards));
    }
  }

  void _onCardUpdated(
    TimelineCardUpdated event,
    Emitter<TimelineState> emit,
  ) {
    if (state is TimelineLoaded) {
      final currentCards = (state as TimelineLoaded).cards;
      final updatedCards = currentCards.map((c) {
        return c.id == event.card.id ? event.card : c;
      }).toList();
      emit(TimelineLoaded(updatedCards));
    }
  }

  Future<void> _onTogglePinRequested(
    TimelineTogglePinRequested event,
    Emitter<TimelineState> emit,
  ) async {
    if (state is TimelineLoaded) {
      final currentCards = (state as TimelineLoaded).cards;
      
      // Optimistic update
      final newPinnedState = !event.card.pinned;
      final optimisticCard = event.card.copyWith(pinned: newPinnedState);
      
      final optimisticCards = currentCards.map((c) {
        return c.id == event.card.id ? optimisticCard : c;
      }).toList();
      emit(TimelineLoaded(optimisticCards));

      try {
        final updatedCard = await _cardsApi.updateCard(event.card.id, pinned: newPinnedState);
        add(TimelineCardUpdated(updatedCard));
      } catch (e) {
        // Revert optimistic update on failure
        final revertCards = currentCards.map((c) {
          return c.id == event.card.id ? event.card : c;
        }).toList();
        emit(TimelineLoaded(revertCards));
        emit(TimelineError("Failed to pin card: $e"));
        emit(TimelineLoaded(revertCards));
      }
    }
  }
}
