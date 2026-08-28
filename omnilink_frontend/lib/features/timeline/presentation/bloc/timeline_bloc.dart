import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:convert';
import 'package:omnilink_frontend/core/events/event_bus.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/cards_api.dart';
import 'timeline_event.dart';
import 'timeline_state.dart';
import '../../data/models/card_model.dart';

@injectable
class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  final CardsApi _cardsApi;
  final LocalDatabase _localDb;
  late final _prefs = _localDb.prefs;
  final GlobalEventBus _eventBus;
  StreamSubscription? _eventSubscription;

  TimelineBloc(this._cardsApi, this._localDb, this._eventBus) : super(TimelineInitial()) {
    on<TimelineLoadRequested>(_onLoadRequested);
    on<TimelineCardCreated>(_onCardCreated);
    on<TimelineCardDeleted>(_onCardDeleted);
    on<TimelineCardUpdated>(_onCardUpdated);
    on<TimelineCardResolved>(_onCardResolved);
    on<TimelineCardFailed>(_onCardFailed);
    on<TimelineTogglePinRequested>(_onTogglePinRequested);
    on<TimelineDeleteCardsRequested>(_onDeleteCardsRequested);
    on<TimelineCardRetryRequested>(_onRetryRequested);

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
    // load from local SharedPreferences cache
    try {
      final cachedString = _prefs.getString('cached_timeline');
      if (cachedString != null) {
        final List<dynamic> decoded = jsonDecode(cachedString);
        var localCards = decoded.map((json) => CardModel.fromJson(json)).toList();
        localCards.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
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
      } else {
        if (state is! TimelineLoaded) emit(TimelineLoading());
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
      
      // update SharedPreferences cache
      if (event.cardType == null && event.tagId == null && event.pinned == null && (event.searchQuery == null || event.searchQuery!.isEmpty)) {
        await _prefs.setString('cached_timeline', jsonEncode(cards.map((c) => c.toJson()).toList()));
      }

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
      updatedCards.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      emit(TimelineLoaded(updatedCards));
    }
  }

  void _onCardResolved(
    TimelineCardResolved event,
    Emitter<TimelineState> emit,
  ) {
    if (state is TimelineLoaded) {
      final currentCards = (state as TimelineLoaded).cards;
      final updatedCards = currentCards.map((c) {
        return c.id == event.tempId ? event.realCard : c;
      }).toList();
      emit(TimelineLoaded(updatedCards));
    }
  }

  void _onCardFailed(
    TimelineCardFailed event,
    Emitter<TimelineState> emit,
  ) {
    if (state is TimelineLoaded) {
      final currentCards = (state as TimelineLoaded).cards;
      final updatedCards = currentCards.map((c) {
        if (c.id == event.tempId) {
          return c.copyWith(syncStatus: CardSyncStatus.error);
        }
        return c;
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

  Future<void> _onDeleteCardsRequested(
    TimelineDeleteCardsRequested event,
    Emitter<TimelineState> emit,
  ) async {
    if (state is TimelineLoaded) {
      final currentCards = (state as TimelineLoaded).cards;
      
      // Optimistic update
      final optimisticCards = currentCards.where((c) => !event.cardIds.contains(c.id)).toList();
      emit(TimelineLoaded(optimisticCards));

      try {
        // Run API deletes concurrently
        await Future.wait(
          event.cardIds.map((id) => _cardsApi.deleteCard(id)),
        );
        
        // Remove from SharedPreferences database
        final cachedString = _prefs.getString('cached_timeline');
        if (cachedString != null) {
          final List<dynamic> decoded = jsonDecode(cachedString);
          var cachedCards = decoded.map((json) => CardModel.fromJson(json)).toList();
          cachedCards.removeWhere((c) => event.cardIds.contains(c.id));
          await _prefs.setString('cached_timeline', jsonEncode(cachedCards.map((c) => c.toJson()).toList()));
        }
      } catch (e) {
        // Revert on failure
        emit(TimelineError("Failed to delete selected cards: $e"));
        emit(TimelineLoaded(currentCards));
      }
    }
  }

  Future<void> _onRetryRequested(
    TimelineCardRetryRequested event,
    Emitter<TimelineState> emit,
  ) async {
    if (state is TimelineLoaded) {
      final currentCards = (state as TimelineLoaded).cards;
      
      // Update status to pending
      final optimisticCards = currentCards.map((c) {
        if (c.id == event.card.id) {
          return c.copyWith(syncStatus: CardSyncStatus.pending);
        }
        return c;
      }).toList();
      emit(TimelineLoaded(optimisticCards));

      try {
        final tagIds = event.card.tags.map((t) => t.id).toList();
        CardModel resolvedCard;

        if (event.card.cardType == 'file') {
          resolvedCard = await _cardsApi.createFileCard(
            bytes: event.card.localBytes?.toList(),
            fileName: event.card.title ?? 'file',
            title: event.card.title,
            tagIds: tagIds,
          );
        } else if (event.card.cardType == 'metadata') {
          resolvedCard = await _cardsApi.createMetadataCard(
            event.card.title ?? event.card.body ?? '',
            body: event.card.body,
            tagIds: tagIds,
          );
        } else {
          resolvedCard = await _cardsApi.createTextCard(
            event.card.body ?? '',
            title: event.card.title,
            tagIds: tagIds,
          );
        }
        add(TimelineCardResolved(event.card.id, resolvedCard));
      } catch (e) {
        add(TimelineCardFailed(event.card.id, e.toString()));
      }
    }
  }
}
