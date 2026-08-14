import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

@injectable
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;

  AdminBloc({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(AdminInitial()) {
    on<AdminLoadDataRequested>(_onLoadDataRequested);
    on<AdminToggleUserSuspensionRequested>(_onToggleUserSuspensionRequested);
  }

  Future<void> _onLoadDataRequested(
      AdminLoadDataRequested event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final metrics = await _adminRepository.getOverviewMetrics();
      final users = await _adminRepository.getAllUsers();
      final auditLogs = await _adminRepository.getAuditLogs();
      emit(AdminLoaded(metrics: metrics, users: users, auditLogs: auditLogs));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onToggleUserSuspensionRequested(
      AdminToggleUserSuspensionRequested event, Emitter<AdminState> emit) async {
    if (state is AdminLoaded) {
      final currentState = state as AdminLoaded;
      try {
        await _adminRepository.toggleUserSuspension(event.userId, event.suspend);
        // Refresh users list
        final users = await _adminRepository.getAllUsers();
        emit(currentState.copyWith(users: users));
      } catch (e) {
        emit(AdminError(e.toString()));
      }
    }
  }
}
