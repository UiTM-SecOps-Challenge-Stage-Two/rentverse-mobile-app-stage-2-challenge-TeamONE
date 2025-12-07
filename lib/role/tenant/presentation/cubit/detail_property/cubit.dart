import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/features/property/domain/usecase/get_property_detail_usecase.dart';
import 'package:rentverse/role/tenant/presentation/cubit/detail_property/state.dart';

class DetailPropertyCubit extends Cubit<DetailPropertyState> {
  DetailPropertyCubit(this._getPropertyDetailUseCase)
    : super(const DetailPropertyState());

  final GetPropertyDetailUseCase _getPropertyDetailUseCase;

  Future<void> fetch(String id) async {
    emit(state.copyWith(status: DetailPropertyStatus.loading, error: null));
    try {
      final property = await _getPropertyDetailUseCase(id);
      emit(
        state.copyWith(
          status: DetailPropertyStatus.success,
          property: property,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DetailPropertyStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }
}
