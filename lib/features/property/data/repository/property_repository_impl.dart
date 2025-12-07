import 'package:rentverse/features/property/data/source/property_api_service.dart';
import 'package:rentverse/features/property/domain/entity/list_property_entity.dart';
import 'package:rentverse/features/property/domain/repository/property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyApiService _apiService;

  PropertyRepositoryImpl(this._apiService);

  @override
  Future<ListPropertyEntity> getProperties({int? limit, String? cursor}) async {
    final response = await _apiService.getProperties(
      limit: limit,
      cursor: cursor,
    );
    return response.toEntity();
  }

  @override
  Future<PropertyEntity> getPropertyDetail(String id) async {
    final response = await _apiService.getPropertyDetail(id);
    return response.toEntity();
  }
}
