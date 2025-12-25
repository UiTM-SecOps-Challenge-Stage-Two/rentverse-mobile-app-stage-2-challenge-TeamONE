

import 'package:dio/dio.dart';
import '../utils/error_utils.dart';

abstract class DataState<T> {
  final T? data;
  final DioException? error;
  final T? paging;
  final T? links;

  const DataState({this.data, this.error, this.paging, this.links});


  String? get errorMessage =>
      error != null ? resolveApiErrorMessage(error!, fallback: '') : null;
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess({super.data, super.paging, super.links});
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(DioException error) : super(error: error);
}
