import 'package:freezed_annotation/freezed_annotation.dart';

part 'hero.freezed.dart';

@freezed
abstract class Hero with _$Hero {
  const factory Hero({
    required int id,
    required String name,
    required String slug,
    required int intelligence,
    required int strength,
    required int speed,
    required int durability,
    required int power,
    required int combat,
    required String gender,
    String? race,
    required List<String> height,
    required List<String> weight,
    required String eyeColor,
    required String hairColor,
    required String fullName,
    required String alterEgos,
    required List<String> aliases,
    required String placeOfBirth,
    required String firstAppearance,
    String? publisher,
    required String alignment,
    required String occupation,
    required String base,
    required String groupAffiliation,
    required String relatives,
    required String imageXs,
    required String imageSm,
    required String imageMd,
    required String imageLg,
  }) = _Hero;
}
