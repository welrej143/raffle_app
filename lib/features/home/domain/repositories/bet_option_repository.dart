import 'package:raffle_app/features/home/domain/entities/bet_option.dart';

abstract class BetOptionRepository {
  Future<List<BetOption>> fetchBetOptions();
}
