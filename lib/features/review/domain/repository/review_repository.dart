import 'package:rentverse/core/resources/data_state.dart';

abstract class ReviewRepository {
  Future<DataState<void>> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  });


  Future<DataState<Map<String, dynamic>>> getPropertyReviews(
    String propertyId,
    int limit,
    String? cursor,
  );
}
