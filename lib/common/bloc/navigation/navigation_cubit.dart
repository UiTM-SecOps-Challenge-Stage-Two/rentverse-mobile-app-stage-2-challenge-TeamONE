

import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit({int initialIndex = 0}) : super(initialIndex);

  void updateIndex(int index) => emit(index);
}
