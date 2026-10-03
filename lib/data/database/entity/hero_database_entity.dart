import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'hero_database_entity.g.dart';

List<String> _decodeList(String value) =>
    (jsonDecode(value) as List<dynamic>).cast<String>();

String _encodeList(List<String> value) => jsonEncode(value);

@JsonSerializable(fieldRename: FieldRename.snake)
class HeroDatabaseEntity {
  final int id;
  final String name;
  final String slug;
  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;
  final String gender;
  final String? race;
  @JsonKey(fromJson: _decodeList, toJson: _encodeList)
  final List<String> height;
  @JsonKey(fromJson: _decodeList, toJson: _encodeList)
  final List<String> weight;
  final String eyeColor;
  final String hairColor;
  final String fullName;
  final String alterEgos;
  @JsonKey(fromJson: _decodeList, toJson: _encodeList)
  final List<String> aliases;
  final String placeOfBirth;
  final String firstAppearance;
  final String? publisher;
  final String alignment;
  final String occupation;
  final String base;
  final String groupAffiliation;
  final String relatives;
  final String imageXs;
  final String imageSm;
  final String imageMd;
  final String imageLg;

  const HeroDatabaseEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
    required this.gender,
    required this.race,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.hairColor,
    required this.fullName,
    required this.alterEgos,
    required this.aliases,
    required this.placeOfBirth,
    required this.firstAppearance,
    required this.publisher,
    required this.alignment,
    required this.occupation,
    required this.base,
    required this.groupAffiliation,
    required this.relatives,
    required this.imageXs,
    required this.imageSm,
    required this.imageMd,
    required this.imageLg,
  });

  factory HeroDatabaseEntity.fromJson(Map<String, dynamic> json) =>
      _$HeroDatabaseEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HeroDatabaseEntityToJson(this);
}

abstract class HeroDatabaseContract {
  static const table = 'hero_table';
  static const id = 'id';
  static const powerStatColumns = <String>{
    'intelligence',
    'strength',
    'speed',
    'durability',
    'power',
    'combat',
  };
}
