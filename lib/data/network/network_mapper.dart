

import '../../domain/hero.dart';
import 'entity/hero_entity.dart';

class NetworkMapper {
  Hero toHero(HeroEntity e) => Hero(
    id: e.id,
    name: e.name,
    slug: e.slug,
    intelligence: e.powerstats.intelligence,
    strength: e.powerstats.strength,
    speed: e.powerstats.speed,
    durability: e.powerstats.durability,
    power: e.powerstats.power,
    combat: e.powerstats.combat,
    gender: e.appearance.gender,
    race: e.appearance.race,
    height: e.appearance.height,
    weight: e.appearance.weight,
    eyeColor: e.appearance.eyeColor,
    hairColor: e.appearance.hairColor,
    fullName: e.biography.fullName,
    alterEgos: e.biography.alterEgos,
    aliases: e.biography.aliases,
    placeOfBirth: e.biography.placeOfBirth,
    firstAppearance: e.biography.firstAppearance,
    publisher: e.biography.publisher,
    alignment: e.biography.alignment,
    occupation: e.work.occupation,
    base: e.work.base,
    groupAffiliation: e.connections.groupAffiliation,
    relatives: e.connections.relatives,
    imageXs: e.images.xs,
    imageSm: e.images.sm,
    imageMd: e.images.md,
    imageLg: e.images.lg,
  );

  List<Hero> toHeroes(List<HeroEntity> entities) =>
      entities.map(toHero).toList();
}
