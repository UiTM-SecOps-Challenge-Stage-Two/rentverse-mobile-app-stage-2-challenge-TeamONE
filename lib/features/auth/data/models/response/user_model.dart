

import 'package:rentverse/features/auth/domain/entity/user_entity.dart';

import 'profile_model.dart';
import 'role_model.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.phone,
    super.emailVerifiedAt,
    super.phoneVerifiedAt,
    super.avatarUrl,
    required super.isVerified,
    super.createdAt,
    super.roles,
    super.tenantProfile,
    super.landlordProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {

    List<UserRoleModel>? parsedRoles;
    if (json['roles'] != null) {
      parsedRoles = (json['roles'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => UserRoleModel.fromJson(e))
          .toList();
    } else if (json['role'] is String && (json['role'] as String).isNotEmpty) {

      parsedRoles = [
        UserRoleModel(role: RoleModel(name: json['role'] as String)),
      ];
    }

    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      emailVerifiedAt: json['emailVerifiedAt'] != null
          ? DateTime.tryParse(json['emailVerifiedAt'] as String)
          : null,
      phoneVerifiedAt: json['phoneVerifiedAt'] != null
          ? DateTime.tryParse(json['phoneVerifiedAt'] as String)
          : null,
      avatarUrl: json['avatarUrl'] as String?,
      isVerified: (json['isVerified'] as bool?) ?? false,


      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,


      roles: parsedRoles,


      tenantProfile: json['tenantProfile'] != null
          ? TenantProfileModel.fromJson(
              json['tenantProfile'] as Map<String, dynamic>,
            )
          : null,


      landlordProfile: json['landlordProfile'] != null
          ? LandlordProfileModel.fromJson(
              json['landlordProfile'] as Map<String, dynamic>,
            )
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'phoneVerifiedAt': phoneVerifiedAt?.toIso8601String(),
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),


      'roles': roles?.map((e) => (e as UserRoleModel).toJson()).toList(),


      'tenantProfile': tenantProfile != null
          ? (tenantProfile as TenantProfileModel).toJson()
          : null,
      'landlordProfile': landlordProfile != null
          ? (landlordProfile as LandlordProfileModel).toJson()
          : null,
    };
  }
}
