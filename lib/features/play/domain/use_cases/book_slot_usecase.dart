import 'package:raffle_app/features/play/domain/repositories/raffle_repository.dart';

class BookSlotUseCase {
  final RaffleRepository repository;

  BookSlotUseCase(this.repository);

  Future<void> execute(String raffleId, int slotNumber) {
    return repository.bookSlot(raffleId, slotNumber);
  }
}