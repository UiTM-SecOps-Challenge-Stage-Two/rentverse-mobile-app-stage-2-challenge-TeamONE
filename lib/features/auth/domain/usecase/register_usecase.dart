

import 'package:rentverse/core/resources/data_state.dart';
import 'package:rentverse/core/usecase/usecase.dart';
import 'package:rentverse/features/auth/domain/entity/user_entity.dart';
import 'package:rentverse/features/auth/domain/entity/register_request_enity.dart';
import 'package:rentverse/features/auth/domain/repository/auth_repository.dart';

class RegisterUsecase implements UseCase<DataState<UserEntity>, RegisterRequestEntity>{

  final AuthRepository _authRepository;
  RegisterUsecase(this._authRepository);
  @override
  Future<DataState<UserEntity>> call({RegisterRequestEntity? param}) {
    if (param == null) {
      throw const FormatException("Register Params tidak boleh null");
    }
    return _authRepository.register(param);
  }
}