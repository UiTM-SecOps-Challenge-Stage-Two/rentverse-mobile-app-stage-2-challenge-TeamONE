

import 'package:rentverse/core/resources/data_state.dart';
import 'package:rentverse/core/usecase/usecase.dart';
import 'package:rentverse/features/auth/domain/entity/user_entity.dart';
import 'package:rentverse/features/auth/domain/repository/auth_repository.dart';

class GetUserUseCase implements UseCase<DataState<UserEntity>, void> {
  final AuthRepository _authRepository;

  GetUserUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call({void param}) {
    return _authRepository.getUserProfile();
  }
}
