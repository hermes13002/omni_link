import 'package:equatable/equatable.dart';
import '../../data/models/admin_overview_metrics.dart';
import '../../data/models/admin_user_item.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final AdminOverviewMetrics metrics;
  final List<AdminUserItem> users;

  const AdminLoaded({required this.metrics, required this.users});

  @override
  List<Object?> get props => [metrics, users];
  
  AdminLoaded copyWith({
    AdminOverviewMetrics? metrics,
    List<AdminUserItem>? users,
  }) {
    return AdminLoaded(
      metrics: metrics ?? this.metrics,
      users: users ?? this.users,
    );
  }
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
