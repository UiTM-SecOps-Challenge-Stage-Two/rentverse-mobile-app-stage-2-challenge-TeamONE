import 'package:logger/logger.dart';
import 'package:rentverse/core/network/dio_client.dart';
import 'package:rentverse/core/network/response/base_response_model.dart';

abstract class ReviewApiService {
  Future<BaseResponseModel<Map<String, dynamic>>> submitReview(
    Map<String, dynamic> body,
  );

  Future<BaseResponseModel<Map<String, dynamic>>> getPropertyReviews(
    String propertyId,
    int limit,
    String? cursor,
  );
}

class ReviewApiServiceImpl implements ReviewApiService {
  final DioClient _dioClient;
  ReviewApiServiceImpl(this._dioClient);

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> submitReview(
    Map<String, dynamic> body,
  ) async {
    final response = await _dioClient.post('/reviews', data: body);
    return BaseResponseModel.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> getPropertyReviews(
    String propertyId,
    int limit,
    String? cursor,
  ) async {
    final q = <String, dynamic>{'limit': limit};
    if (cursor != null) q['cursor'] = cursor;
    final response = await _dioClient.get(
      '/reviews/property/$propertyId',
      queryParameters: q,
    );

    final logger = Logger();
    final respData = response.data;



    List<dynamic> items = [];
    Map<String, dynamic> meta = {};

    if (respData is Map<String, dynamic>) {
      final maybeItems = respData['data'];
      if (maybeItems is List) {
        items = maybeItems;
      } else {
        logger.w(
          'Unexpected data shape for property reviews: ${maybeItems.runtimeType}',
        );
      }

      if (respData['meta'] is Map) {
        meta = Map<String, dynamic>.from(respData['meta'] as Map);
      }
    } else {
      logger.w(
        'Unexpected response type for property reviews: ${respData.runtimeType}',
      );
    }

    final normalized = {'items': items, 'meta': meta};
    final payload = respData is Map<String, dynamic>
        ? {...respData, 'data': normalized['items'], 'meta': normalized['meta']}
        : {
            'status': 'success',
            'data': normalized['items'],
            'meta': normalized['meta'],
          };

    return BaseResponseModel.fromJson(payload, (json) => normalized);
  }
}
