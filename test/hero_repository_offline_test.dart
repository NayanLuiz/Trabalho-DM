import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/data/database/dao/hero_dao.dart';
import 'package:flutter_repository_example/data/database/dao/squad_dao.dart';
import 'package:flutter_repository_example/data/database/database_mapper.dart';
import 'package:flutter_repository_example/data/database/entity/hero_database_entity.dart';
import 'package:flutter_repository_example/data/network/client/api_client.dart';
import 'package:flutter_repository_example/data/network/entity/hero_entity.dart';
import 'package:flutter_repository_example/data/network/network_mapper.dart';
import 'package:flutter_repository_example/data/repository/hero_repository.dart';
import 'package:flutter_repository_example/data/repository/hero_repository_impl.dart';
import 'package:flutter_repository_example/ui/page/mission_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OfflineApiClient extends ApiClient {
  final List<HeroEntity> heroes;
  bool online = true;

  _OfflineApiClient(this.heroes) : super(baseUrl: 'http://localhost:3000');

  @override
  Future<List<HeroEntity>> getHeroes({required int page, required int limit}) {
    if (!online) throw StateError('Servidor desligado');
    return Future.value(heroes.skip((page - 1) * limit).take(limit).toList());
  }

  @override
  Future<HeroEntity> getHeroById(int id) {
    if (!online) throw StateError('Servidor desligado');
    return Future.value(heroes.firstWhere((hero) => hero.id == id));
  }
}

class _MemoryHeroDao extends HeroDao {
  final Map<int, HeroDatabaseEntity> rows = {};

  @override
  Future<List<HeroDatabaseEntity>> selectAll({int? limit, int? offset}) async {
    final sorted = rows.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    return sorted.skip(offset ?? 0).take(limit ?? sorted.length).toList();
  }

  @override
  Future<HeroDatabaseEntity?> selectById(int id) async => rows[id];

  @override
  Future<void> insert(HeroDatabaseEntity hero) async {
    rows.putIfAbsent(hero.id, () => hero);
  }

  @override
  Future<void> insertAll(List<HeroDatabaseEntity> heroes) async {
    for (final hero in heroes) {
      rows.putIfAbsent(hero.id, () => hero);
    }
  }

  @override
  Future<void> update(HeroDatabaseEntity hero) async {
    rows[hero.id] = hero;
  }

  @override
  Future<int> count() async => rows.length;
}

class _MemorySquadDao extends SquadDao {
  final Set<int> ids = {};

  @override
  Future<void> insert(int heroId) async {
    ids.add(heroId);
  }

  @override
  Future<void> delete(int heroId) async {
    ids.remove(heroId);
  }

  @override
  Future<List<int>> selectAllIds() async => ids.toList();

  @override
  Future<bool> contains(int heroId) async => ids.contains(heroId);

  @override
  Future<int> count() async => ids.length;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  _OfflineApiClient api() {
    final source = jsonDecode(
      File('server/original/all.json').readAsStringSync(),
    ) as List<dynamic>;
    return _OfflineApiClient(
      source
          .take(6)
          .map((item) => HeroEntity.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  HeroRepositoryImpl repository(
    _OfflineApiClient client,
    _MemoryHeroDao heroes,
    _MemorySquadDao squad,
  ) => HeroRepositoryImpl(
    apiClient: client,
    networkMapper: NetworkMapper(),
    heroDao: heroes,
    squadDao: squad,
    databaseMapper: DatabaseMapper(),
  );

  testWidgets('catálogo, detalhe, contrato e missão usam cache offline', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final client = api();
    final heroDao = _MemoryHeroDao();
    final squadDao = _MemorySquadDao();
    final onlineRepo = repository(client, heroDao, squadDao);
    final loaded = await onlineRepo.getHeroes(page: 1, limit: 10);
    expect(loaded.length, 6);
    for (final hero in loaded.take(5)) {
      await onlineRepo.recruitHero(hero.id);
    }

    final upgraded = loaded.first.copyWith(strength: loaded.first.strength + 1);
    await onlineRepo.updateHero(upgraded);
    client.online = false;
    final offlineRepo = repository(client, heroDao, squadDao);
    final cached = await offlineRepo.getHeroes(page: 1, limit: 10);
    expect(cached.length, 6);
    expect(cached.first.strength, upgraded.strength);
    expect(
      (await offlineRepo.getHeroById(upgraded.id)).strength,
      upgraded.strength,
    );
    expect((await offlineRepo.getSquad()).length, 5);
    final daily = await tester.runAsync(offlineRepo.getDailyHero);
    expect((await offlineRepo.getDailyHero()).id, daily!.id);

    await tester.pumpWidget(
      Provider<HeroRepository>.value(
        value: offlineRepo,
        child: const MaterialApp(home: MissionPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('ROUND 1 /'), findsOneWidget);

    client.online = true;
    final refetched = await offlineRepo.getHeroes(page: 1, limit: 1000);
    expect(refetched.first.strength, upgraded.strength);
  });

  test('instalação nova sem servidor carrega heróis do APK', () async {
    SharedPreferences.setMockInitialValues({});
    final client = api()..online = false;
    final heroDao = _MemoryHeroDao();
    final squadDao = _MemorySquadDao();
    final offlineRepo = repository(client, heroDao, squadDao);

    final firstPage = await offlineRepo.getHeroes(page: 1, limit: 10);
    expect(firstPage.length, 10);
    expect(await heroDao.count(), 563);
    expect((await offlineRepo.getHeroes(page: 2, limit: 10)).length, 10);
    expect(
      (await offlineRepo.getHeroById(firstPage.first.id)).name,
      firstPage.first.name,
    );
    final daily = await offlineRepo.getDailyHero();
    expect((await offlineRepo.getDailyHero()).id, daily.id);
    await offlineRepo.recruitHero(firstPage.first.id);
    expect(await offlineRepo.getSquadCount(), 1);
  });

  test('cache parcial recebe restante dos heróis quando API cai', () async {
    SharedPreferences.setMockInitialValues({});
    final client = api();
    final heroDao = _MemoryHeroDao();
    final offlineRepo = repository(client, heroDao, _MemorySquadDao());

    final firstPage = await offlineRepo.getHeroes(page: 1, limit: 3);
    expect(firstPage.length, 3);
    await offlineRepo.updateHero(
      firstPage.first.copyWith(strength: firstPage.first.strength + 1),
    );
    client.online = false;
    expect((await offlineRepo.getHeroes(page: 2, limit: 3)).length, 3);
    expect(await heroDao.count(), 563);
    expect(
      (await offlineRepo.getHeroById(firstPage.first.id)).strength,
      firstPage.first.strength + 1,
    );
  });

  test('falha da API completa página local parcial sem perder bônus', () async {
    SharedPreferences.setMockInitialValues({});
    final client = api();
    final heroDao = _MemoryHeroDao();
    final offlineRepo = repository(client, heroDao, _MemorySquadDao());

    final loaded = await offlineRepo.getHeroes(page: 1, limit: 3);
    final boosted = loaded.first.copyWith(strength: loaded.first.strength + 1);
    await offlineRepo.updateHero(boosted);

    client.online = false;
    final catalog = await offlineRepo.getHeroes(page: 1, limit: 1000);
    expect(catalog.length, 563);
    expect(await heroDao.count(), 563);
    expect(
      catalog.firstWhere((hero) => hero.id == boosted.id).strength,
      boosted.strength,
    );
  });
}
