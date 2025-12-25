

import 'package:equatable/equatable.dart';
import '../../../features/auth/domain/entity/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AppInitialState extends AuthState {}


class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class UnAuthenticated extends AuthState {}

class FirstRun extends AuthState {}
