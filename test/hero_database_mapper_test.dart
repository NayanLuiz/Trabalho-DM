import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/data/database/database_mapper.dart';
import 'package:flutter_repository_example/data/database/entity/hero_database_entity.dart';
import 'package:flutter_repository_example/data/network/entity/hero_entity.dart';
import 'package:flutter_repository_example/data/network/network_mapper.dart';

void main() {
  test('todos os heróis preservam dados ao passar por uma linha SQLite', () {
    final source = File('server/original/all.json').readAsStringSync();
    final records = jsonDecode(source) as List<dynamic>;
    final networkMapper = NetworkMapper();
    final databaseMapper = DatabaseMapper();

    for (final value in records) {
      final hero = networkMapper.toHero(
        HeroEntity.fromJson(value as Map<String, dynamic>),
      );
      final row = databaseMapper.toHeroDatabaseEntity(hero).toJson();
      expect(row['height'], isA<String>());
      expect(row['weight'], isA<String>());
      expect(row['aliases'], isA<String>());
      final restored = databaseMapper.toHero(HeroDatabaseEntity.fromJson(row));
      expect(restored, hero);
    }
    expect(records.length, 563);
  });
}
