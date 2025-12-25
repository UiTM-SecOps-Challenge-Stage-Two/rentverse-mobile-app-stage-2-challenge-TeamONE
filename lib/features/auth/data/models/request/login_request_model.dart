

import 'package:rentverse/features/auth/domain/entity/login_request_entity.dart';

class LoginRequestModel extends LoginRequestEntity {
  LoginRequestModel({required super.email, required super.password});

  factory LoginRequestModel.fromEntity(LoginRequestEntity entity) {
    return LoginRequestModel(email: entity.email, password: entity.password);
  }


  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
