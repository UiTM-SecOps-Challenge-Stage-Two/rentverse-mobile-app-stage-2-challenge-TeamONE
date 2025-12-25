import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:rentverse/core/network/dio_client.dart';
import 'package:rentverse/features/property/data/models/list_property_by_owner_response_model.dart';
import 'package:rentverse/features/property/data/models/list_property_response_model.dart';
import 'package:rentverse/features/property/data/models/property_detail_response_model.dart';

abstract class PropertyApiService {
  Future<ListPropertyByOwnerResponseModel> getLandlordProperties({
    int? limit,
    String? cursor,
  });
  Future<ListPropertyResponseModel> getProperties({int? limit, String? cursor});
  Future<PropertyDetailResponseModel> getPropertyDetail(String id);
  Future<PropertyDetailResponseModel> createProperty(
    Map<String, dynamic> fields,
    List<String> imageFilePaths,
  );
  Future<PropertyDetailResponseModel> updateProperty(
    String id,
    Map<String, dynamic> fields,
  );
}

class PropertyApiServiceImpl implements PropertyApiService {
  final DioClient _dioClient;

  PropertyApiServiceImpl(this._dioClient);

  @override
  Future<ListPropertyByOwnerResponseModel> getLandlordProperties({
    int? limit,
    String? cursor,
  }) async {
    try {
      final response = await _dioClient.get(
        '/landlord/properties',
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );
      return ListPropertyByOwnerResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ListPropertyResponseModel> getProperties({
    int? limit,
    String? cursor,
  }) async {
    try {
      final response = await _dioClient.get(
        '/properties',
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );
      return ListPropertyResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PropertyDetailResponseModel> getPropertyDetail(String id) async {
    try {
      final response = await _dioClient.get('/properties/$id');
      return PropertyDetailResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PropertyDetailResponseModel> createProperty(
    Map<String, dynamic> fields,
    List<String> imageFilePaths,
  ) async {
    try {
      final formData = FormData();


      fields.forEach((key, value) {
        if (value == null) return;
        formData.fields.add(MapEntry(key, value.toString()));
      });


      for (final path in imageFilePaths) {
        if (path.isEmpty) continue;
        final filename = p.basename(path);
        final multipart = await MultipartFile.fromFile(
          path,
          filename: filename,
        );
        formData.files.add(MapEntry('images', multipart));
      }

      final response = await _dioClient.post(
        '/properties',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return PropertyDetailResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PropertyDetailResponseModel> updateProperty(
    String id,
    Map<String, dynamic> fields,
  ) async {
    try {
      final response = await _dioClient.patch(
        '/properties/$id',
        data: fields,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return PropertyDetailResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }
}
