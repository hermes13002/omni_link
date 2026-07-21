import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:omnilink_frontend/core/events/event_bus.dart';

import '../../data/cards_api.dart';
import '../../data/models/isar_models.dart';
import 'timeline_event.dart';
import 'timeline_state.dart';

@injectable
class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  final CardsApi _cardsApi;
  final Isar _isar;
  final GlobalEventBus _eventBus;
  StreamSubscription? _eventSubscription;

  TimelineBloc(this._cardsApi, this._isar, this._eventBus) : super(TimelineInitial()) {
    on<TimelineLoadRequested>(_onLoadRequested);
    on<TimelineCardCreated>(_onCardCreated);
    on<TimelineCardDeleted>(_onCardDeleted);
    on<TimelineCardUpdated>(_onCardUpdated);
    on<TimelineTogglePinRequested>(_onTogglePinRequested);

    _eventSubscription = _eventBus.stream.listen((event) {
      if (event == 'reload') {
        // preserve current filters by reloading with current state
        if (state is TimelineLoaded) {
          // just trigger a generic reload
          add(const TimelineLoadRequested());
        }
      }
    });
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadRequested(
    TimelineLoadRequested event,
    Emitter<TimelineState> emit,
  ) async {
    // load from local Isar cache
    try {
      final isarCards = await _isar.isarCards.where().sortByCreatedAtDesc().findAll();
      var localCards = isarCards.map((c) => c.toModel()).toList();
      
      if (event.cardType != null) localCards = localCards.where((c) => c.cardType == event.cardType).toList();
      if (event.pinned != null) localCards = localCards.where((c) => c.pinned == event.pinned).toList();
      if (event.tagId != null) localCards = localCards.where((c) => c.tags.any((t) => t.id == event.tagId)).toList();
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        final q = event.searchQuery!.toLowerCase();
        localCards = localCards.where((c) => (c.title?.toLowerCase().contains(q) == true) || (c.body?.toLowerCase().contains(q) == true)).toList();
      }

      if (localCards.isNotEmpty) {
        emit(TimelineLoaded(localCards));
      } else if (state is! TimelineLoaded) {
        emit(TimelineLoading());
      }
    } catch (e) {
      if (state is! TimelineLoaded) emit(TimelineLoading());
    }

    // fetch fresh data from API in background
    try {
      final cards = await _cardsApi.getCards(
        cardType: event.cardType,
        tagId: event.tagId,
        pinned: event.pinned,
        search: event.searchQuery,
      );
      
      // update Isar cache
      await _isar.writeTxn(() async {
        if (event.cardType == null && event.tagId == null && event.pinned == null && (event.searchQuery == null || event.searchQuery!.isEmpty)) {
          await _isar.isarCards.clear();
        }
        await _isar.isarCards.putAll(cards.map((c) => IsarCard.fromModel(c)).toList());
      });

      emit(TimelineLoaded(cards));
    } catch (e) {
      if (state is! TimelineLoaded) {
        emit(TimelineError(e.toString()));
      }
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
