import 'package:json_annotation/json_annotation.dart';

part 'hero_entity.g.dart';

@JsonSerializable()
class HeroEntity {
  final int id;
  final String name;
  final String slug;
  final PowerstatsEntity powerstats;
  final AppearanceEntity appearance;
  final BiographyEntity biography;
  final WorkEntity work;
  final ConnectionsEntity connections;
  final ImagesEntity images;

  HeroEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.powerstats,
    required this.appearance,
    required this.biography,
    required this.work,
    required this.connections,
    required this.images,
  });

  factory HeroEntity.fromJson(Map<String, dynamic> json) =>
      _$HeroEntityFromJson(json);
}

@JsonSerializable()
class PowerstatsEntity {
  final int intelligence, strength, speed, durability, power, combat;
  PowerstatsEntity({
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
  });
  factory PowerstatsEntity.fromJson(Map<String, dynamic> json) =>
      _$PowerstatsEntityFromJson(json);
}

@JsonSerializable()
class AppearanceEntity {
  final String gender;
  final String? race;
  final List<String> height, weight;
  final String eyeColor, hairColor;
  AppearanceEntity({
    required this.gender,
    this.race,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.hairColor,
  });
  factory AppearanceEntity.fromJson(Map<String, dynamic> json) =>
      _$AppearanceEntityFromJson(json);
}

@JsonSerializable()
class BiographyEntity {
  final String fullName, alterEgos, placeOfBirth, firstAppearance, alignment;
  final List<String> aliases;
  final String? publisher;
  BiographyEntity({
    required this.fullName,
    required this.alterEgos,
    required this.aliases,
    required this.placeOfBirth,
    required this.firstAppearance,
    this.publisher,
    required this.alignment,
  });
  factory BiographyEntity.fromJson(Map<String, dynamic> json) =>
      _$BiographyEntityFromJson(json);
}

@JsonSerializable()
class WorkEntity {
  final String occupation, base;
  WorkEntity({required this.occupation, required this.base});
  factory WorkEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkEntityFromJson(json);
}

@JsonSerializable()
class ConnectionsEntity {
  final String groupAffiliation, relatives;
  ConnectionsEntity({required this.groupAffiliation, required this.relatives});
  factory ConnectionsEntity.fromJson(Map<String, dynamic> json) =>
      _$ConnectionsEntityFromJson(json);
}

@JsonSerializable()
class ImagesEntity {
  final String xs, sm, md, lg;
  ImagesEntity({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
  });
  factory ImagesEntity.fromJson(Map<String, dynamic> json) =>
      _$ImagesEntityFromJson(json);
}
