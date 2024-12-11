import 'package:freezed_annotation/freezed_annotation.dart';

part 'bet_option.freezed.dart';

@freezed
class BetOption with _$BetOption {
  const factory BetOption({
    required String id,
    required String title,
    required String imagePath,
  }) = _BetOption;
}
