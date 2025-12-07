import 'package:rentverse/features/property/domain/entity/list_property_entity.dart';
import 'package:rentverse/features/property/domain/repository/property_repository.dart';

class GetPropertyDetailUseCase {
  final PropertyRepository _repository;

  GetPropertyDetailUseCase(this._repository);

  Future<PropertyEntity> call(String id) {
    return _repository.getPropertyDetail(id);
  }
}
