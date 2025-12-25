
class BaseResponseModel<T> {
  final String status;
  final String? message;
  final T? data;

  BaseResponseModel({required this.status, this.message, this.data});

  factory BaseResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return BaseResponseModel(
      status: json['status'] ?? 'failed',
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
