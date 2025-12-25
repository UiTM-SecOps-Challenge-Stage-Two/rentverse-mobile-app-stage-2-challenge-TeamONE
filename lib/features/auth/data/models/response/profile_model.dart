


import 'package:rentverse/features/auth/domain/entity/profile_entity.dart';

class TenantProfileModel extends TenantProfileEntity {
  const TenantProfileModel({
    required super.id,
    required super.ttiScore,
    required super.kycStatus,
    required super.paymentFaults,
  });

  factory TenantProfileModel.fromJson(Map<String, dynamic> json) {
    return TenantProfileModel(
      id: json['id'],

      ttiScore: (json['tti_score'] as num?)?.toDouble() ?? 0.0,
      kycStatus: json['kyc_status'] ?? 'PENDING',
      paymentFaults: json['payment_faults'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tti_score': ttiScore,
      'kyc_status': kycStatus,
      'payment_faults': paymentFaults,
    };
  }
}


class LandlordProfileModel extends LandlordProfileEntity {
  const LandlordProfileModel({
    required super.id,
    required super.lrsScore,
    required super.responseRate,
    required super.kycStatus,
  });

  factory LandlordProfileModel.fromJson(Map<String, dynamic> json) {
    return LandlordProfileModel(
      id: json['id'],
      lrsScore: (json['lrs_score'] as num?)?.toDouble() ?? 0.0,
      responseRate: (json['response_rate'] as num?)?.toDouble() ?? 0.0,
      kycStatus: json['kyc_status'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lrs_score': lrsScore,
      'response_rate': responseRate,
      'kyc_status': kycStatus,
    };
  }
}
