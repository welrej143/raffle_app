import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:raffle_app/features/play/domain/entities/raffle.dart';

part 'raffle_state.freezed.dart';

@freezed
class RaffleState with _$RaffleState {
  const factory RaffleState.initial() = _Initial;
  const factory RaffleState.loading() = _Loading;
  const factory RaffleState.loaded(Raffle raffle) = _Loaded;
  const factory RaffleState.error(String message) = _Error;
}
