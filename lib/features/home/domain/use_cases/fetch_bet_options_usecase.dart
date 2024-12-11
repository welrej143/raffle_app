import 'package:raffle_app/features/home/domain/entities/bet_option.dart';
import 'package:raffle_app/features/home/domain/repositories/bet_option_repository.dart';

class FetchBetOptionsUseCase {
  final BetOptionRepository repository;

  FetchBetOptionsUseCase(this.repository);

  Future<List<BetOption>> execute() {
    return repository.fetchBetOptions();
  }
}
