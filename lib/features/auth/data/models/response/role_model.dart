

import 'package:rentverse/features/auth/domain/entity/user_entity.dart';

class UserRoleModel extends UserRoleEntity {
  const UserRoleModel({super.roleId, super.role});

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      roleId: json['roleId'],

      role: json['role'] != null ? RoleModel.fromJson(json['role']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'role': role != null ? (role as RoleModel).toJson() : null,
    };
  }
}


class RoleModel extends RoleEntity {
  const RoleModel({super.id, super.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
