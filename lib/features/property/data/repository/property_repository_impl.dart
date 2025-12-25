import 'dart:convert';

import 'package:rentverse/features/property/data/source/property_api_service.dart';
import 'package:rentverse/features/property/domain/entity/create_property_params.dart';
import 'package:rentverse/features/property/domain/entity/list_property_by_owner.dart';
import 'package:rentverse/features/property/domain/entity/list_property_entity.dart';
import 'package:rentverse/features/property/domain/repository/property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyApiService _apiService;

  PropertyRepositoryImpl(this._apiService);

  @override
  Future<ListPropertyByOwnerEntity> getLandlordProperties({
    int? limit,
    String? cursor,
  }) async {
    final response = await _apiService.getLandlordProperties(
      limit: limit,
      cursor: cursor,
    );
    return response.toEntity();
  }

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

  @override
  Future<PropertyEntity> createProperty(CreatePropertyParams params) async {

    final Map<String, dynamic> fields = {
      'title': params.title,
      if (params.description != null) 'description': params.description,
      'propertyTypeId': params.propertyTypeId.toString(),
      'listingTypeId': params.listingTypeId.toString(),
      'price': params.price,
      if (params.currency != null) 'currency': params.currency,
      'address': params.address,
      'city': params.city,
      if (params.country != null) 'country': params.country,
      if (params.latitude != null) 'latitude': params.latitude.toString(),
      if (params.longitude != null) 'longitude': params.longitude.toString(),

      'billingPeriodIds': jsonEncode(params.billingPeriodIds),
      if (params.amenities != null) 'amenities': jsonEncode(params.amenities),
      if (params.attributes != null)
        'attributes': jsonEncode(params.attributes),
    };

    final response = await _apiService.createProperty(
      fields,
      params.imageFilePaths,
    );

    return response.toEntity();
  }

  @override
  Future<PropertyEntity> updateProperty(
    String id,
    Map<String, dynamic> fields,
  ) async {
    final response = await _apiService.updateProperty(id, fields);
    return response.toEntity();
  }
}
