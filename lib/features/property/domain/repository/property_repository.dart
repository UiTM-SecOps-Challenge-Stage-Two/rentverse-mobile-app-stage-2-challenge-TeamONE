import '../entity/list_property_entity.dart';

abstract class PropertyRepository {
  Future<ListPropertyEntity> getProperties({int? limit, String? cursor});
  Future<PropertyEntity> getPropertyDetail(String id);
}
