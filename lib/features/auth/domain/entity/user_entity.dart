

import 'package:equatable/equatable.dart';
import 'package:rentverse/features/auth/domain/entity/profile_entity.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final DateTime? emailVerifiedAt;
  final DateTime? phoneVerifiedAt;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime? createdAt;


  final List<UserRoleEntity>? roles;


  final TenantProfileEntity? tenantProfile;
  final LandlordProfileEntity? landlordProfile;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.avatarUrl,
    required this.isVerified,
    this.createdAt,
    this.roles,
    this.tenantProfile,
    this.landlordProfile,
  });



  bool get isTenant => _hasRole('TENANT');
  bool get isLandlord => _hasRole('LANDLORD');
  bool get isAdmin => _hasRole('ADMIN');


  bool _hasRole(String roleName) {
    return roles?.any((r) => r.role?.name == roleName) ?? false;
  }


  double get trustScore {
    if (isTenant) return tenantProfile?.ttiScore ?? 0.0;
    if (isLandlord) return landlordProfile?.lrsScore ?? 0.0;
    return 0.0;
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phone,
    emailVerifiedAt,
    phoneVerifiedAt,
    isVerified,
    createdAt,
    roles,
    tenantProfile,
    landlordProfile,
  ];
}


class UserRoleEntity extends Equatable {
  final String? roleId;
  final RoleEntity? role;

  const UserRoleEntity({this.roleId, this.role});

  @override
  List<Object?> get props => [roleId, role];
}


class RoleEntity extends Equatable {
  final String? id;
  final String? name;

  const RoleEntity({this.id, this.name});

  @override
  List<Object?> get props => [id, name];
}
