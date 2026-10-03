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

  FakeHeroRepository(this.heroes);

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
