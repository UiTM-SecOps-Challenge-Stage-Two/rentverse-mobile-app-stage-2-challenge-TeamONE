import 'package:equatable/equatable.dart';
import 'package:rentverse/features/property/domain/entity/list_property_entity.dart';

enum DetailPropertyStatus { initial, loading, success, failure }

class DetailPropertyState extends Equatable {
  final DetailPropertyStatus status;
  final PropertyEntity? property;
  final String? error;

  const DetailPropertyState({
    this.status = DetailPropertyStatus.initial,
    this.property,
    this.error,
  });

  DetailPropertyState copyWith({
    DetailPropertyStatus? status,
    PropertyEntity? property,
    String? error,
  }) {
    return DetailPropertyState(
      status: status ?? this.status,
      property: property ?? this.property,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, property, error];
}
