

import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class ChooseRoleCubit extends Cubit<ChooseRoleState> {
  ChooseRoleCubit() : super(const ChooseRoleState());

  void selectTenant() => emit(state.copyWith(selected: UserRole.tenant));
  void selectOwner() => emit(state.copyWith(selected: UserRole.owner));

  Future<void> submit(void Function(UserRole role) onSelected) async {
    if (state.selected == null) return;
    emit(state.copyWith(isSubmitting: true));
    try {
      onSelected(state.selected!);
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }
}
