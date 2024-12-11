import 'package:raffle_app/features/home/domain/entities/bet_option.dart';
import 'package:raffle_app/features/home/domain/repositories/bet_option_repository.dart';
import 'package:raffle_app/utils/assets/asset_paths/asset_paths.dart';

class BetOptionRepositoryImpl implements BetOptionRepository {
  @override
  Future<List<BetOption>> fetchBetOptions() async {
    return const [
      BetOption(
        id: 'raffle_500',
        title: 'Bet 20 Coins to Win 500 PHP',
        imagePath: AssetPaths.image500,
      ),
      BetOption(
        id: 'raffle_1000',
        title: 'Bet 50 Coins to Win 1,000 PHP',
        imagePath: AssetPaths.image1000,
      ),
      BetOption(
        id: 'raffle_2000',
        title: 'Bet 100 Coins to Win 2,000 PHP',
        imagePath: AssetPaths.image2000,
      ),
      BetOption(
        id: 'raffle_25000',
        title: 'Bet 1000 Coins to Win 25,000 PHP',
        imagePath: AssetPaths.image25000,
      ),
    ];
  }
}
