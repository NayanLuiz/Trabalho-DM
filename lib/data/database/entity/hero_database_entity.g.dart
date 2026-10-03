// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hero_database_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeroDatabaseEntity _$HeroDatabaseEntityFromJson(Map<String, dynamic> json) =>
    HeroDatabaseEntity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      intelligence: (json['intelligence'] as num).toInt(),
      strength: (json['strength'] as num).toInt(),
      speed: (json['speed'] as num).toInt(),
      durability: (json['durability'] as num).toInt(),
      power: (json['power'] as num).toInt(),
      combat: (json['combat'] as num).toInt(),
      gender: json['gender'] as String,
      race: json['race'] as String?,
      height: _decodeList(json['height'] as String),
      weight: _decodeList(json['weight'] as String),
      eyeColor: json['eye_color'] as String,
      hairColor: json['hair_color'] as String,
      fullName: json['full_name'] as String,
      alterEgos: json['alter_egos'] as String,
      aliases: _decodeList(json['aliases'] as String),
      placeOfBirth: json['place_of_birth'] as String,
      firstAppearance: json['first_appearance'] as String,
      publisher: json['publisher'] as String?,
      alignment: json['alignment'] as String,
      occupation: json['occupation'] as String,
      base: json['base'] as String,
      groupAffiliation: json['group_affiliation'] as String,
      relatives: json['relatives'] as String,
      imageXs: json['image_xs'] as String,
      imageSm: json['image_sm'] as String,
      imageMd: json['image_md'] as String,
      imageLg: json['image_lg'] as String,
    );

Map<String, dynamic> _$HeroDatabaseEntityToJson(HeroDatabaseEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'intelligence': instance.intelligence,
      'strength': instance.strength,
      'speed': instance.speed,
      'durability': instance.durability,
      'power': instance.power,
      'combat': instance.combat,
      'gender': instance.gender,
      'race': instance.race,
      'height': _encodeList(instance.height),
      'weight': _encodeList(instance.weight),
      'eye_color': instance.eyeColor,
      'hair_color': instance.hairColor,
      'full_name': instance.fullName,
      'alter_egos': instance.alterEgos,
      'aliases': _encodeList(instance.aliases),
      'place_of_birth': instance.placeOfBirth,
      'first_appearance': instance.firstAppearance,
      'publisher': instance.publisher,
      'alignment': instance.alignment,
      'occupation': instance.occupation,
      'base': instance.base,
      'group_affiliation': instance.groupAffiliation,
      'relatives': instance.relatives,
      'image_xs': instance.imageXs,
      'image_sm': instance.imageSm,
      'image_md': instance.imageMd,
      'image_lg': instance.imageLg,
    };
