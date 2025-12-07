// lib/core/services/service_locator.dart

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
import 'package:rentverse/features/auth/domain/usecase/login_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/logout_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/register_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/update_profile_usecase.dart';
import 'package:rentverse/features/auth/domain/repository/auth_repository.dart';
import 'package:rentverse/features/bookings/data/repository/bookings_repository_impl.dart';
import 'package:rentverse/features/bookings/data/source/booking_api_service.dart';
import 'package:rentverse/features/bookings/domain/repository/bookings_repository.dart';
import 'package:rentverse/features/bookings/domain/usecase/create_booking_usecase.dart';
import 'package:rentverse/features/map/data/repository/map_repository_impl.dart';
import 'package:rentverse/features/map/data/source/open_map_remote_data_source.dart';
import 'package:rentverse/features/map/domain/repository/map_repository.dart';
import 'package:rentverse/features/map/domain/usecase/reverse_geocode_usecase.dart';
import 'package:rentverse/features/kyc/data/repository/kyc_repository_impl.dart';
import 'package:rentverse/features/kyc/data/source/kyc_api_service.dart';
import 'package:rentverse/features/kyc/domain/repository/kyc_repository.dart';
import 'package:rentverse/features/kyc/domain/usecase/submit_kyc_usecase.dart';
import 'package:rentverse/features/rental/data/repository/rental_repository_impl.dart';
import 'package:rentverse/features/rental/data/source/rental_api_service.dart';
import 'package:rentverse/features/rental/domain/repository/rental_repository.dart';
import 'package:rentverse/features/rental/domain/usecase/get_rent_references_usecase.dart';
import 'package:rentverse/features/property/data/repository/property_repository_impl.dart';
import 'package:rentverse/features/property/data/source/property_api_service.dart';
import 'package:rentverse/features/property/domain/repository/property_repository.dart';
import 'package:rentverse/features/property/domain/usecase/get_properties_usecase.dart';
import 'package:rentverse/features/property/domain/usecase/get_property_detail_usecase.dart';
import 'package:rentverse/core/network/open_map_street_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Auth data sources & services
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiServiceImpl(sl<DioClient>()),
  );

  // Auth repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthApiService>(), sl<AuthLocalDataSource>()),
  );
  sl.registerLazySingleton<PropertyApiService>(
    () => PropertyApiServiceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(sl<PropertyApiService>()),
  );
  sl.registerLazySingleton<BookingApiService>(
    () => BookingApiServiceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<BookingsRepository>(
    () => BookingsRepositoryImpl(sl<BookingApiService>()),
  );
  // OpenStreetMap / Nominatim
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

  // Auth usecases
  sl.registerLazySingleton(() => GetLocalUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => IsLoggedInUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  // Property usecases
  sl.registerLazySingleton(
    () => GetPropertiesUseCase(sl<PropertyRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPropertyDetailUseCase(sl<PropertyRepository>()),
  );
  // Booking usecases
  sl.registerLazySingleton(
    () => CreateBookingUseCase(sl<BookingsRepository>()),
  );
  sl.registerLazySingleton(() => SubmitKycUseCase(sl<KycRepository>()));
  sl.registerLazySingleton(
    () => GetRentReferencesUseCase(sl<RentalRepository>()),
  );

  // cubits
  sl.registerLazySingleton(() => AuthCubit());
}
