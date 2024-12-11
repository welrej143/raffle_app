import 'package:raffle_app/features/play/domain/entities/raffle.dart';
import 'package:raffle_app/features/play/domain/repositories/raffle_repository.dart';

class FetchRaffleUseCase {
  final RaffleRepository repository;

  FetchRaffleUseCase(this.repository);

  Stream<Raffle> execute(String raffleId) {
    return repository.getRaffleStream(raffleId);
  }
}