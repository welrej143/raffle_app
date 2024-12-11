import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raffle_app/features/play/domain/use_cases/book_slot_usecase.dart';
import 'package:raffle_app/features/play/domain/use_cases/fetch_raffle_usecase.dart';
import 'raffle_state.dart';

class RaffleCubit extends Cubit<RaffleState> {
  final FetchRaffleUseCase fetchRaffleUseCase;
  final BookSlotUseCase bookSlotUseCase;

  RaffleCubit({
    required this.fetchRaffleUseCase,
    required this.bookSlotUseCase,
  }) : super(const RaffleState.initial());

  void fetchRaffle(String raffleId) {
    emit(const RaffleState.loading());
    fetchRaffleUseCase.execute(raffleId).listen(
          (raffle) {
        emit(RaffleState.loaded(raffle));
      },
      onError: (error) {
        emit(RaffleState.error(error.toString()));
      },
    );
  }

  Future<void> bookSlot(String raffleId, int slotNumber) async {
    try {
      await bookSlotUseCase.execute(raffleId, slotNumber);
    } catch (e) {
      emit(RaffleState.error(e.toString()));
    }
  }
}
