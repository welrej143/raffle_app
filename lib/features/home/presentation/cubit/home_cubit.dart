import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:raffle_app/features/home/domain/entities/bet_option.dart';
import 'package:raffle_app/features/home/domain/use_cases/fetch_bet_options_usecase.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FetchBetOptionsUseCase fetchBetOptionsUseCase;

  HomeCubit(this.fetchBetOptionsUseCase) : super(const HomeState.initial());

  Future<void> fetchBetOptions() async {
    emit(const HomeState.loading());
    try {
      final options = await fetchBetOptionsUseCase.execute();
      emit(HomeState.loaded(options));
    } catch (e) {
      emit(HomeState.error(e.toString()));
    }
  }
}
