import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/core/resources/data_state.dart';
import 'package:rentverse/features/auth/domain/usecase/get_local_user_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/get_user_usecase.dart';

import 'state.dart';

class GetUserCubit extends Cubit<GetUserState> {
  final GetUserUseCase _getUserUseCase;
  final GetLocalUserUseCase _getLocalUserUseCase;

  GetUserCubit(this._getUserUseCase, this._getLocalUserUseCase)
    : super(const GetUserState());

  Future<void> load() async {
    emit(state.copyWith(status: GetUserStatus.loading));
    try {
      final remote = await _getUserUseCase();
      if (remote is DataSuccess && remote.data != null) {
        emit(state.copyWith(status: GetUserStatus.success, user: remote.data!));
        return;
      }
    } catch (_) {

    }


    try {
      final local = await _getLocalUserUseCase();
      if (local != null) {
        emit(state.copyWith(status: GetUserStatus.success, user: local));
        return;
      }
    } catch (e) {
      emit(state.copyWith(status: GetUserStatus.failure, error: e.toString()));
      return;
    }

    emit(
      state.copyWith(status: GetUserStatus.failure, error: 'User not found'),
    );
  }
}
