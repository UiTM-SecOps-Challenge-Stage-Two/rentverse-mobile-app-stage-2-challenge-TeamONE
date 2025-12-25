

import 'package:equatable/equatable.dart';


class TenantProfileEntity extends Equatable {
  final String id;
  final double ttiScore;
  final String kycStatus;
  final int paymentFaults;

  const TenantProfileEntity({
    required this.id,
    required this.ttiScore,
    required this.kycStatus,
    required this.paymentFaults,
  });

  @override
  List<Object?> get props => [id, ttiScore, kycStatus, paymentFaults];
}


class LandlordProfileEntity extends Equatable {
  final String id;
  final double lrsScore;
  final double responseRate;
  final String kycStatus;

  const LandlordProfileEntity({
    required this.id,
    required this.lrsScore,
    required this.responseRate,
    required this.kycStatus,
  });

  @override
  List<Object?> get props => [id, lrsScore, responseRate, kycStatus];
}
