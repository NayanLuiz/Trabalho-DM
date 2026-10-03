import '../../domain/hero.dart';
import 'entity/hero_database_entity.dart';

class DatabaseMapper {
  Hero toHero(HeroDatabaseEntity e) => Hero(
    id: e.id,
    name: e.name,
    slug: e.slug,
    intelligence: e.intelligence,
    strength: e.strength,
    speed: e.speed,
    durability: e.durability,
    power: e.power,
    combat: e.combat,
    gender: e.gender,
    race: e.race,
    height: e.height,
    weight: e.weight,
    eyeColor: e.eyeColor,
    hairColor: e.hairColor,
    fullName: e.fullName,
    alterEgos: e.alterEgos,
    aliases: e.aliases,
    placeOfBirth: e.placeOfBirth,
    firstAppearance: e.firstAppearance,
    publisher: e.publisher,
    alignment: e.alignment,
    occupation: e.occupation,
    base: e.base,
    groupAffiliation: e.groupAffiliation,
    relatives: e.relatives,
    imageXs: e.imageXs,
    imageSm: e.imageSm,
    imageMd: e.imageMd,
    imageLg: e.imageLg,
  );

  List<Hero> toHeroes(List<HeroDatabaseEntity> entities) =>
      entities.map(toHero).toList();

  HeroDatabaseEntity toHeroDatabaseEntity(Hero h) => HeroDatabaseEntity(
    id: h.id,
    name: h.name,
    slug: h.slug,
    intelligence: h.intelligence,
    strength: h.strength,
    speed: h.speed,
    durability: h.durability,
    power: h.power,
    combat: h.combat,
    gender: h.gender,
    race: h.race,
    height: h.height,
    weight: h.weight,
    eyeColor: h.eyeColor,
    hairColor: h.hairColor,
    fullName: h.fullName,
    alterEgos: h.alterEgos,
    aliases: h.aliases,
    placeOfBirth: h.placeOfBirth,
    firstAppearance: h.firstAppearance,
    publisher: h.publisher,
    alignment: h.alignment,
    occupation: h.occupation,
    base: h.base,
    groupAffiliation: h.groupAffiliation,
    relatives: h.relatives,
    imageXs: h.imageXs,
    imageSm: h.imageSm,
    imageMd: h.imageMd,
    imageLg: h.imageLg,
  );

  List<HeroDatabaseEntity> toHeroDatabaseEntities(List<Hero> heroes) =>
      heroes.map(toHeroDatabaseEntity).toList();
}
