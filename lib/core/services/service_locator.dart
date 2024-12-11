import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:raffle_app/features/home/data/repository/BetOptionRepositoryImpl.dart';
import 'package:raffle_app/features/home/domain/repositories/bet_option_repository.dart';
import 'package:raffle_app/features/home/domain/use_cases/fetch_bet_options_usecase.dart';
import 'package:raffle_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:raffle_app/features/play/data/repository/raffle_repository_impl.dart';
import 'package:raffle_app/features/play/domain/repositories/raffle_repository.dart';
import 'package:raffle_app/features/play/domain/use_cases/book_slot_usecase.dart';
import 'package:raffle_app/features/play/domain/use_cases/fetch_raffle_usecase.dart';
import 'package:raffle_app/features/play/presentation/cubit/raffle_cubit.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Register FirebaseFirestore Instance
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Register Repositories
  sl.registerLazySingleton<BetOptionRepository>(
        () => BetOptionRepositoryImpl(),
  );
  sl.registerLazySingleton<RaffleRepository>(
        () => RaffleRepositoryImpl(sl<FirebaseFirestore>()),
  );

  // Register Use Cases
  sl.registerLazySingleton<FetchBetOptionsUseCase>(
        () => FetchBetOptionsUseCase(sl<BetOptionRepository>()),
  );
  sl.registerLazySingleton<BookSlotUseCase>(
        () => BookSlotUseCase(sl<RaffleRepository>()),
  );
  sl.registerLazySingleton<FetchRaffleUseCase>(
        () => FetchRaffleUseCase(sl<RaffleRepository>()),
  );

  // Register Cubits
  sl.registerFactory<HomeCubit>(
        () => HomeCubit(sl<FetchBetOptionsUseCase>()),
  );
  sl.registerFactory<RaffleCubit>(
        () => RaffleCubit(
      fetchRaffleUseCase: sl<FetchRaffleUseCase>(),
      bookSlotUseCase: sl<BookSlotUseCase>(),
    ),
  );
}
