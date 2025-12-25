import 'package:logger/logger.dart';
import 'package:rentverse/core/network/dio_client.dart';
import 'package:rentverse/features/bookings/data/models/booking_list_model.dart';
import 'package:rentverse/features/bookings/data/models/booking_response_model.dart';
import 'package:rentverse/features/bookings/data/models/request_booking_model.dart';
import 'package:rentverse/features/bookings/data/models/booking_availability_model.dart';

abstract class BookingApiService {
  Future<BookingResponseModel> createBooking(RequestBookingModel request);
  Future<BookingListModel> getBookings({int limit = 10, String? cursor});
  Future<BookingResponseModel> confirmBooking(String bookingId);
  Future<BookingResponseModel> rejectBooking(String bookingId);
  Future<List<BookingAvailabilityModel>> getPropertyAvailability(
    String propertyId,
  );
}

class BookingApiServiceImpl implements BookingApiService {
  final DioClient _dioClient;

  BookingApiServiceImpl(this._dioClient);

  @override
  Future<BookingResponseModel> createBooking(
    RequestBookingModel request,
  ) async {
    try {
      final response = await _dioClient.post(
        '/bookings',
        data: request.toJson(),
      );
      Logger().i('Booking POST success -> ${response.data}');
      return BookingResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      Logger().e('Booking POST failed', error: e);
      rethrow;
    }
  }

  @override
  Future<BookingListModel> getBookings({int limit = 10, String? cursor}) async {
    try {
      final response = await _dioClient.get(
        '/bookings',
        queryParameters: {
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      Logger().i('Booking LIST success -> ${response.data}');
      return BookingListModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      Logger().e('Booking LIST failed', error: e);
      rethrow;
    }
  }

  @override
  Future<BookingResponseModel> confirmBooking(String bookingId) async {
    try {
      final response = await _dioClient.post('/bookings/$bookingId/confirm');
      Logger().i('Booking CONFIRM success -> ${response.data}');
      return BookingResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      Logger().e('Booking CONFIRM failed', error: e);
      rethrow;
    }
  }

  @override
  Future<BookingResponseModel> rejectBooking(String bookingId) async {
    try {

      final response = await _dioClient.post(
        '/bookings/$bookingId/reject',
        data: {'reason': 'Rejected by landlord'},
      );
      Logger().i('Booking REJECT success -> ${response.data}');
      return BookingResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      Logger().e('Booking REJECT failed', error: e);
      rethrow;
    }
  }

  @override
  Future<List<BookingAvailabilityModel>> getPropertyAvailability(
    String propertyId,
  ) async {
    try {
      final response = await _dioClient.get(
        '/bookings/availability/$propertyId',
      );
      final logger = Logger();
      final data = response.data;



      List<dynamic> rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map) {
        final maybe = data['data'];
        if (maybe is List) {
          rawList = maybe;
        } else {
          logger.w(
            'Unexpected availability response shape for property $propertyId: `data` is not a List. value=${maybe.runtimeType}',
          );
        }
      } else {
        logger.w(
          'Unexpected availability response type for property $propertyId: ${data.runtimeType}',
        );
      }

      return rawList
          .map(
            (e) => BookingAvailabilityModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      Logger().e('Availability LIST failed', error: e);
      rethrow;
    }
  }
}
