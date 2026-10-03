// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hero_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeroEntity _$HeroEntityFromJson(Map<String, dynamic> json) => HeroEntity(
  id: _readId(json['id']),
  name: json['name'] as String,
  slug: json['slug'] as String,
  powerstats: PowerstatsEntity.fromJson(
    json['powerstats'] as Map<String, dynamic>,
  ),
  appearance: AppearanceEntity.fromJson(
    json['appearance'] as Map<String, dynamic>,
  ),
  biography: BiographyEntity.fromJson(
    json['biography'] as Map<String, dynamic>,
  ),
  work: WorkEntity.fromJson(json['work'] as Map<String, dynamic>),
  connections: ConnectionsEntity.fromJson(
    json['connections'] as Map<String, dynamic>,
  ),
  images: ImagesEntity.fromJson(json['images'] as Map<String, dynamic>),
);

Map<String, dynamic> _$HeroEntityToJson(HeroEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'powerstats': instance.powerstats,
      'appearance': instance.appearance,
      'biography': instance.biography,
      'work': instance.work,
      'connections': instance.connections,
      'images': instance.images,
    };

PowerstatsEntity _$PowerstatsEntityFromJson(Map<String, dynamic> json) =>
    PowerstatsEntity(
      intelligence: (json['intelligence'] as num).toInt(),
      strength: (json['strength'] as num).toInt(),
      speed: (json['speed'] as num).toInt(),
      durability: (json['durability'] as num).toInt(),
      power: (json['power'] as num).toInt(),
      combat: (json['combat'] as num).toInt(),
    );

Map<String, dynamic> _$PowerstatsEntityToJson(PowerstatsEntity instance) =>
    <String, dynamic>{
      'intelligence': instance.intelligence,
      'strength': instance.strength,
      'speed': instance.speed,
      'durability': instance.durability,
      'power': instance.power,
      'combat': instance.combat,
    };

AppearanceEntity _$AppearanceEntityFromJson(
  Map<String, dynamic> json,
) => AppearanceEntity(
  gender: json['gender'] as String,
  race: json['race'] as String?,
  height: (json['height'] as List<dynamic>).map((e) => e as String).toList(),
  weight: (json['weight'] as List<dynamic>).map((e) => e as String).toList(),
  eyeColor: json['eyeColor'] as String,
  hairColor: json['hairColor'] as String,
);

Map<String, dynamic> _$AppearanceEntityToJson(AppearanceEntity instance) =>
    <String, dynamic>{
      'gender': instance.gender,
      'race': instance.race,
      'height': instance.height,
      'weight': instance.weight,
      'eyeColor': instance.eyeColor,
      'hairColor': instance.hairColor,
    };

BiographyEntity _$BiographyEntityFromJson(Map<String, dynamic> json) =>
    BiographyEntity(
      fullName: json['fullName'] as String,
      alterEgos: json['alterEgos'] as String,
      aliases: (json['aliases'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      placeOfBirth: json['placeOfBirth'] as String,
      firstAppearance: json['firstAppearance'] as String,
      publisher: json['publisher'] as String?,
      alignment: json['alignment'] as String,
    );

Map<String, dynamic> _$BiographyEntityToJson(BiographyEntity instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'alterEgos': instance.alterEgos,
      'placeOfBirth': instance.placeOfBirth,
      'firstAppearance': instance.firstAppearance,
      'alignment': instance.alignment,
      'aliases': instance.aliases,
      'publisher': instance.publisher,
    };

WorkEntity _$WorkEntityFromJson(Map<String, dynamic> json) => WorkEntity(
  occupation: json['occupation'] as String,
  base: json['base'] as String,
);

Map<String, dynamic> _$WorkEntityToJson(WorkEntity instance) =>
    <String, dynamic>{'occupation': instance.occupation, 'base': instance.base};

ConnectionsEntity _$ConnectionsEntityFromJson(Map<String, dynamic> json) =>
    ConnectionsEntity(
      groupAffiliation: json['groupAffiliation'] as String,
      relatives: json['relatives'] as String,
    );

Map<String, dynamic> _$ConnectionsEntityToJson(ConnectionsEntity instance) =>
    <String, dynamic>{
      'groupAffiliation': instance.groupAffiliation,
      'relatives': instance.relatives,
    };

ImagesEntity _$ImagesEntityFromJson(Map<String, dynamic> json) => ImagesEntity(
  xs: json['xs'] as String,
  sm: json['sm'] as String,
  md: json['md'] as String,
  lg: json['lg'] as String,
);

Map<String, dynamic> _$ImagesEntityToJson(ImagesEntity instance) =>
    <String, dynamic>{
      'xs': instance.xs,
      'sm': instance.sm,
      'md': instance.md,
      'lg': instance.lg,
    };
