import 'dart:convert';
import 'dart:io';

import 'package:flutter_repository_example/data/network/entity/hero_entity.dart';
import 'package:flutter_repository_example/data/network/network_mapper.dart';
import 'package:flutter_repository_example/data/repository/hero_repository.dart';
import 'package:flutter_repository_example/domain/hero.dart' as domain;

List<domain.Hero> loadTestHeroes(int count) {
  final source = jsonDecode(
    File('server/original/all.json').readAsStringSync(),
  ) as List<dynamic>;
  return source
      .take(count)
      .map((item) => HeroEntity.fromJson(item as Map<String, dynamic>))
      .map(NetworkMapper().toHero)
      .toList();
}

class FakeHeroRepository implements HeroRepository {
  final List<domain.Hero> heroes;
  final List<int> requestedPages = [];
  final Set<int> recruitedIds;
  int recruitCalls = 0;
  int dismissCalls = 0;
  int squadReads = 0;
  int updateCalls = 0;
  domain.Hero? updatedHero;

  FakeHeroRepository(this.heroes, {Set<int>? initialSquadIds})
    : recruitedIds = {...?initialSquadIds};

  @override
  Future<List<domain.Hero>> getHeroes({
    required int page,
    required int limit,
  }) async {
    requestedPages.add(page);
    final start = (page - 1) * limit;
    if (start >= heroes.length) return [];
    return heroes.skip(start).take(limit).toList();
  }

  @override
  Future<domain.Hero> getDailyHero() async {
    if (heroes.isEmpty) throw StateError('Nenhum agente disponível.');
    return heroes.first;
  }

  @override
  Future<List<domain.Hero>> getSquad() async {
    squadReads++;
    return heroes.where((hero) => recruitedIds.contains(hero.id)).toList();
  }

  @override
  Future<int> getSquadCount() async => recruitedIds.length;

  @override
  Future<bool> isHeroInSquad(int id) async => recruitedIds.contains(id);

  @override
  Future<void> recruitHero(int id) async {
    recruitCalls++;
    if (recruitedIds.contains(id)) throw StateError('Agente duplicado.');
    if (recruitedIds.length >= 15) throw StateError('Esquadrão cheio.');
    recruitedIds.add(id);
  }

  @override
  Future<void> dismissHero(int id) async {
    dismissCalls++;
    recruitedIds.remove(id);
  }

  @override
  Future<void> updateHero(domain.Hero hero) async {
    final index = heroes.indexWhere((saved) => saved.id == hero.id);
    if (index < 0) throw StateError('Agente não encontrado.');
    heroes[index] = hero;
    updatedHero = hero;
    updateCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
