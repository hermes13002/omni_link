import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class AdminLoadDataRequested extends AdminEvent {}

class AdminToggleUserSuspensionRequested extends AdminEvent {
  final String userId;
  final bool suspend;

  const AdminToggleUserSuspensionRequested({required this.userId, required this.suspend});

  @override
  List<Object> get props => [userId, suspend];
}
