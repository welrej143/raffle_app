import 'package:raffle_app/features/play/domain/entities/raffle.dart';

abstract class RaffleRepository {
  Stream<Raffle> getRaffleStream(String raffleId);
  Future<void> bookSlot(String raffleId, int slotNumber);
}
