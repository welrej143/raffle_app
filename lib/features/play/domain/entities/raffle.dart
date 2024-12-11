import 'package:freezed_annotation/freezed_annotation.dart';

part 'raffle.freezed.dart';

@freezed
class Raffle with _$Raffle {
  const factory Raffle({
    required String id,
    required String title,
    required int totalSlots,
    required int availableSlots,
    required List<Map<String, dynamic>>? participants,
  }) = _Raffle;
}

