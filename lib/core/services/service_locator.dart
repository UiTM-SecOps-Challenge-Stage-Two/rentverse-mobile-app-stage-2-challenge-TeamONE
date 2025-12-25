

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/web.dart';
import 'package:rentverse/common/bloc/auth/auth_cubit.dart';
import 'package:rentverse/core/network/dio_client.dart';
import 'package:rentverse/core/services/notification_service.dart';
import 'package:rentverse/features/auth/data/repository/auth_repository_impl.dart';
import 'package:rentverse/features/auth/data/source/auth_api_service.dart';
import 'package:rentverse/features/auth/data/source/auth_local_service.dart';
import 'package:rentverse/features/auth/domain/usecase/get_local_user_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/get_user_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/is_logged_in_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/send_otp_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/verify_otp_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/login_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/logout_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/register_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/update_profile_usecase.dart';
import 'package:rentverse/features/auth/domain/repository/auth_repository.dart';
import 'package:rentverse/features/bookings/data/repository/bookings_repository_impl.dart';
import 'package:rentverse/features/bookings/data/source/booking_api_service.dart';
import 'package:rentverse/features/bookings/domain/repository/bookings_repository.dart';
import 'package:rentverse/features/bookings/domain/usecase/create_booking_usecase.dart';
import 'package:rentverse/features/bookings/domain/usecase/get_bookings_usecase.dart';
import 'package:rentverse/features/bookings/domain/usecase/confirm_booking_usecase.dart';
import 'package:rentverse/features/bookings/domain/usecase/get_property_availability_usecase.dart';
import 'package:rentverse/features/bookings/domain/usecase/reject_booking_usecase.dart';
import 'package:rentverse/features/map/data/repository/map_repository_impl.dart';
import 'package:rentverse/features/map/data/source/open_map_remote_data_source.dart';
import 'package:rentverse/features/map/domain/repository/map_repository.dart';
import 'package:rentverse/features/map/domain/usecase/reverse_geocode_usecase.dart';
import 'package:rentverse/features/kyc/data/repository/kyc_repository_impl.dart';
import 'package:rentverse/features/kyc/data/source/kyc_api_service.dart';
import 'package:rentverse/features/kyc/domain/repository/kyc_repository.dart';
import 'package:rentverse/features/kyc/domain/usecase/submit_kyc_usecase.dart';
import 'package:rentverse/features/midtrans/data/repository/midtrans_repository_impl.dart';
import 'package:rentverse/features/midtrans/data/source/midtrans_api_service.dart';
import 'package:rentverse/features/midtrans/domain/repository/midtrans_repository.dart';
import 'package:rentverse/features/midtrans/domain/usecase/pay_invoice_usecase.dart';
import 'package:rentverse/features/notification/data/repository/notification_repository_impl.dart';
import 'package:rentverse/features/notification/data/source/notification_api_service.dart';
import 'package:rentverse/features/notification/domain/repository/notification_repository.dart';
import 'package:rentverse/features/notification/domain/usecase/get_notifications_usecase.dart';
import 'package:rentverse/features/notification/domain/usecase/mark_notification_read_usecase.dart';
import 'package:rentverse/features/notification/domain/usecase/mark_all_notifications_read_usecase.dart';
import 'package:rentverse/features/rental/data/repository/rental_repository_impl.dart';
import 'package:rentverse/features/rental/data/source/rental_api_service.dart';
import 'package:rentverse/features/rental/domain/repository/rental_repository.dart';
import 'package:rentverse/features/rental/domain/usecase/get_rent_references_usecase.dart';
import 'package:rentverse/features/wallet/data/repository/wallet_repository_impl.dart';
import 'package:rentverse/features/wallet/data/source/wallet_api_service.dart';
import 'package:rentverse/features/wallet/domain/repository/wallet_repository.dart';
import 'package:rentverse/features/wallet/domain/usecase/get_wallet_usecase.dart';
import 'package:rentverse/features/wallet/domain/usecase/request_payout_usecase.dart';
import 'package:rentverse/features/property/data/repository/property_repository_impl.dart';
import 'package:rentverse/features/property/data/source/property_api_service.dart';
import 'package:rentverse/features/property/domain/repository/property_repository.dart';
import 'package:rentverse/features/property/domain/usecase/get_landlord_properties_usecase.dart';
import 'package:rentverse/features/property/domain/usecase/get_properties_usecase.dart';
import 'package:rentverse/features/property/domain/usecase/get_property_detail_usecase.dart';
import 'package:rentverse/features/property/domain/usecase/create_property_usecase.dart';
import 'package:rentverse/features/property/domain/usecase/update_property_usecase.dart';
import 'package:rentverse/features/chat/data/source/chat_api_service.dart';
import 'package:rentverse/features/chat/data/source/chat_socket_service.dart';
import 'package:rentverse/features/chat/data/repository/chat_repository_impl.dart';
import 'package:rentverse/features/chat/domain/repository/chat_repository.dart';
import 'package:rentverse/features/chat/domain/usecase/get_conversations_usecase.dart';
import 'package:rentverse/features/chat/domain/usecase/get_messages_usecase.dart';
import 'package:rentverse/features/chat/domain/usecase/send_message_usecase.dart';
import 'package:rentverse/features/chat/domain/usecase/start_chat_usecase.dart';
import 'package:rentverse/features/review/data/source/review_api_service.dart';
import 'package:rentverse/features/review/data/repository/review_repository_impl.dart';
import 'package:rentverse/features/review/domain/repository/review_repository.dart';
import 'package:rentverse/features/review/domain/usecase/submit_review_usecase.dart';
import 'package:rentverse/features/review/domain/usecase/get_property_reviews_usecase.dart';
import 'package:rentverse/core/network/open_map_street_api.dart';
import 'package:rentverse/role/lanlord/data/source/landlord_dashboard_api_service.dart';
import 'package:rentverse/role/lanlord/data/repository/landlord_dashboard_repository_impl.dart';
import 'package:rentverse/role/lanlord/domain/repository/landlord_dashboard_repository.dart';
import 'package:rentverse/role/lanlord/domain/usecase/get_landlord_dashboard_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentverse/features/disputes/data/source/disputes_api_service.dart';
import 'package:rentverse/features/disputes/data/repository/disputes_repository_impl.dart';
import 'package:rentverse/features/disputes/domain/repository/dispute_repository.dart';
import 'package:rentverse/features/disputes/domain/usecase/get_my_disputes_usecase.dart';
import 'package:rentverse/features/disputes/domain/usecase/create_dispute_usecase.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton<DioClient>(() => DioClient(sl(), sl()));
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);
  sl.registerLazySingleton<Logger>(() => Logger());
  sl.registerLazySingleton<NotificationService>(
    () =>
        NotificationService(dio: sl<Dio>(), prefs: sl(), logger: sl<Logger>()),
  );
  sl.registerLazySingleton<NotificationApiService>(
    () => NotificationApiServiceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationApiService>()),
  );
  sl.registerLazySingleton(
    () => GetNotificationsUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => MarkNotificationReadUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => MarkAllNotificationsReadUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<ChatSocketService>(
    () => ChatSocketService(sl<Logger>(), sl()),
  );


  sl.registerLazySingleton<ReviewApiService>(
    () => ReviewApiServiceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl<ReviewApiService>()),
  );
  sl.registerLazySingleton(() => SubmitReviewUseCase(sl<ReviewRepository>()));
  sl.registerLazySingleton(
    () => GetPropertyReviewsUseCase(sl<ReviewRepository>()),
  );


  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiServiceImpl(sl<DioClient>()),
  );


  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthApiService>(), sl<AuthLocalDataSource>()),
  );
  sl.registerLazySingleton<PropertyApiService>(
    () => PropertyApiServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<LandlordDashboardApiService>(
    () => LandlordDashboardApiServiceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<LandlordDashboardRepository>(
    () => LandlordDashboardRepositoryImpl(sl<LandlordDashboardApiService>()),
  );
  sl.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(sl<PropertyApiService>()),
  );
  sl.registerLazySingleton<ChatApiService>(
    () => ChatApiServiceImpl(sl<DioClient>(), sl<Logger>()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl<ChatApiService>()),
  );

  sl.registerLazySingleton<DisputesApiService>(
    () => DisputesApiServiceImpl(sl<DioClient>(), sl<Logger>()),
  );
  sl.registerLazySingleton<DisputeRepository>(
    () => DisputesRepositoryImpl(sl<DisputesApiService>()),
  );
  sl.registerLazySingleton(() => GetMyDisputesUseCase(sl<DisputeRepository>()));
  sl.registerLazySingleton(() => CreateDisputeUseCase(sl<DisputeRepository>()));
  sl.registerLazySingleton<BookingApiService>(
    () => BookingApiServiceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<BookingsRepository>(
    () => BookingsRepositoryImpl(sl<BookingApiService>()),
  );

  sl.registerLazySingleton<OpenMapStreetApi>(() => OpenMapStreetApi());
  sl.registerLazySingleton<OpenMapRemoteDataSource>(
    () => OpenMapRemoteDataSourceImpl(sl<OpenMapStreetApi>()),
  );
  sl.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(sl<OpenMapRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => ReverseGeocodeUseCase(sl<MapRepository>()));
  sl.registerLazySingleton<KycApiService>(
    () => KycApiServiceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<KycRepository>(
    () => KycRepositoryImpl(sl<KycApiService>()),
  );
  sl.registerLazySingleton<RentalApiService>(
    () => RentalApiServiceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<RentalRepository>(
    () => RentalRepositoryImpl(sl<RentalApiService>()),
  );
  sl.registerLazySingleton<WalletApiService>(
    () => WalletApiServiceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl<WalletApiService>()),
  );
  if (!sl.isRegistered<RequestPayoutUseCase>()) {
    sl.registerLazySingleton(
      () => RequestPayoutUseCase(sl<WalletRepository>()),
    );
  }
  sl.registerLazySingleton<MidtransApiService>(
    () => MidtransApiServiceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<MidtransRepository>(
    () => MidtransRepositoryImpl(sl<MidtransApiService>()),
  );


  sl.registerLazySingleton(() => GetLocalUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => IsLoggedInUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SendOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl<AuthRepository>()));

  sl.registerLazySingleton(
    () => GetPropertiesUseCase(sl<PropertyRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPropertyDetailUseCase(sl<PropertyRepository>()),
  );
  sl.registerLazySingleton(
    () => GetLandlordPropertiesUseCase(sl<PropertyRepository>()),
  );
  sl.registerLazySingleton(
    () => CreatePropertyUseCase(sl<PropertyRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdatePropertyUseCase(sl<PropertyRepository>()),
  );
  sl.registerLazySingleton(() => StartChatUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => GetConversationsUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl<ChatRepository>()));

  sl.registerLazySingleton(
    () => CreateBookingUseCase(sl<BookingsRepository>()),
  );
  sl.registerLazySingleton(
    () => ConfirmBookingUseCase(sl<BookingsRepository>()),
  );
  sl.registerLazySingleton(
    () => RejectBookingUseCase(sl<BookingsRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPropertyAvailabilityUseCase(sl<BookingsRepository>()),
  );
  sl.registerLazySingleton(() => SubmitKycUseCase(sl<KycRepository>()));
  sl.registerLazySingleton(
    () => GetRentReferencesUseCase(sl<RentalRepository>()),
  );
  sl.registerLazySingleton(() => GetWalletUseCase(sl<WalletRepository>()));
  sl.registerLazySingleton(() => PayInvoiceUseCase(sl<MidtransRepository>()));

  sl.registerLazySingleton(() => GetBookingsUseCase(sl<BookingsRepository>()));

  sl.registerLazySingleton(
    () => GetLandlordDashboardUseCase(sl<LandlordDashboardRepository>()),
  );


  sl.registerLazySingleton(() => AuthCubit());
}
