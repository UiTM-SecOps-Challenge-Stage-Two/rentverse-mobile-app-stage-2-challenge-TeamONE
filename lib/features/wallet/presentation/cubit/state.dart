import 'package:equatable/equatable.dart';
import 'package:rentverse/features/wallet/domain/entity/my_wallet_response_entity.dart';

enum WalletStatus { initial, loading, success, failure }

class WalletState extends Equatable {
  final WalletStatus status;
  final WalletEntity? wallet;
  final String? errorMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.wallet,
    this.errorMessage,
  });

  WalletState copyWith({
    WalletStatus? status,
    WalletEntity? wallet,
    String? errorMessage,
    bool resetError = false,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      errorMessage: resetError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, wallet, errorMessage];
}
