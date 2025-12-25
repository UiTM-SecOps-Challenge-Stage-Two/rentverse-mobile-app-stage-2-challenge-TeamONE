import '../entity/dispute_entity.dart';

abstract class DisputeRepository {
  Future<List<DisputeEntity>> getMyDisputes();


  Future<DisputeEntity> createDispute(
    String bookingId,
    String reason,
    String? description,
  );
}
