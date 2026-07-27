import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';

import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthOnboardingCompleted>(_onAuthOnboardingCompleted);
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repository.checkAuth();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        await _handleUnauthenticated(emit);
      }
    } catch (e) {
      await _handleUnauthenticated(emit);
    }
  }

  Future<void> _handleUnauthenticated(Emitter<AuthState> emit) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final hasSeen = await _repository.hasSeenOnboarding();
      if (!hasSeen) {
        emit(AuthOnboardingRequired());
        return;
      }
    }
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repository.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (e is DioException && e.error != null) {
        emit(AuthError(e.error.toString()));
      } else {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> _onAuthRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repository.register(
          event.email, event.password, event.displayName);
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (e is DioException && e.error != null) {
        emit(AuthError(e.error.toString()));
      } else {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> _onAuthLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _repository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthOnboardingCompleted(
      AuthOnboardingCompleted event, Emitter<AuthState> emit) async {
    await _repository.completeOnboarding();
    emit(AuthUnauthenticated());
  }
}
