import '../../domain/hero.dart';

abstract class HeroRepository {
  Future<List<Hero>> getHeroes({required int page, required int limit});
  Future<Hero> getHeroById(int id);

  Future<List<Hero>> getSquad();
  Future<int> getSquadCount();
  Future<bool> isHeroInSquad(int id);
  Future<void> recruitHero(int id);
  Future<void> dismissHero(int id);

  Future<void> updateHero(Hero hero);
  Future<Hero> getDailyHero();
}
