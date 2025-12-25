

enum UserRole { tenant, owner }

class ChooseRoleState {
  final UserRole? selected;
  final bool isSubmitting;

  const ChooseRoleState({this.selected, this.isSubmitting = false});

  ChooseRoleState copyWith({UserRole? selected, bool? isSubmitting}) =>
      ChooseRoleState(
        selected: selected ?? this.selected,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}
