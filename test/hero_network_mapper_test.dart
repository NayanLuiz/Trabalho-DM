import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/data/network/entity/hero_entity.dart';
import 'package:flutter_repository_example/data/network/network_mapper.dart';

void main() {
  test('todos os heróis do JSON são convertidos sem perda dos campos principais', () {
    final source = File('server/original/all.json').readAsStringSync();
    final records = jsonDecode(source) as List<dynamic>;
    final mapper = NetworkMapper();

    for (final value in records) {
      final json = value as Map<String, dynamic>;
      final hero = mapper.toHero(HeroEntity.fromJson(json));
      expect(hero.id, json['id']);
      expect(hero.name, json['name']);
      expect(hero.strength, (json['powerstats'] as Map)['strength']);
      expect(hero.aliases, (json['biography'] as Map)['aliases']);
      expect(hero.imageLg, (json['images'] as Map)['lg']);
    }
    expect(records.length, greaterThan(500));
  });

  test('aceita ID textual retornado pelo json-server', () {
    final source = File('server/original/all.json').readAsStringSync();
    final first = (jsonDecode(source) as List<dynamic>).first
        as Map<String, dynamic>;
    final response = Map<String, dynamic>.from(first)
      ..['id'] = first['id'].toString();
    final hero = NetworkMapper().toHero(HeroEntity.fromJson(response));
    expect(hero.id, first['id']);
  });
}
