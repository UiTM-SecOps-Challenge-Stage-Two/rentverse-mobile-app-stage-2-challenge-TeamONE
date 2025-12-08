import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/features/wallet/domain/usecase/get_wallet_usecase.dart';
import 'package:rentverse/features/wallet/presentation/cubit/state.dart';

class WalletCubit extends Cubit<WalletState> {
  final GetWalletUseCase _getWalletUseCase;

  WalletCubit(this._getWalletUseCase) : super(const WalletState());

  Future<void> loadWallet() async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      final wallet = await _getWalletUseCase.call();
      emit(state.copyWith(status: WalletStatus.success, wallet: wallet));
    } catch (e) {
      emit(
        state.copyWith(
          status: WalletStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refreshWallet() async {
    try {
      final wallet = await _getWalletUseCase.call();
      emit(state.copyWith(status: WalletStatus.success, wallet: wallet));
    } catch (e) {
      emit(
        state.copyWith(
          status: WalletStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
