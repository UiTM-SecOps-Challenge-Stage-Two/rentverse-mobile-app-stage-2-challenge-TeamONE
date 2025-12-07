import 'package:rentverse/features/property/data/models/list_property_response_model.dart';
import 'package:rentverse/features/property/domain/entity/list_property_entity.dart';

class PropertyDetailResponseModel {
  final PropertyModel data;

  PropertyDetailResponseModel({required this.data});

  factory PropertyDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return PropertyDetailResponseModel(
      data: PropertyModel.fromJson(
        (json['data'] as Map<String, dynamic>? ?? {}),
      ),
    );
  }

  PropertyEntity toEntity() => data.toEntity();
}
