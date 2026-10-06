import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/hero.dart';
import '../database/dao/hero_dao.dart';
import '../database/dao/squad_dao.dart';
import '../database/database_mapper.dart';
import '../network/client/api_client.dart';
import '../network/entity/hero_entity.dart';
import '../network/network_mapper.dart';
import 'hero_repository.dart';

class HeroRepositoryImpl implements HeroRepository {
  static const _dailyDateKey = 'daily_hero_date';
  static const _dailyIdKey = 'daily_hero_id';
  static const maxSquadSize = 15;

  bool _useLocalUntilRestart = false;

  final ApiClient apiClient;
  final NetworkMapper networkMapper;
  final HeroDao heroDao;
  final SquadDao squadDao;
  final DatabaseMapper databaseMapper;

  HeroRepositoryImpl({
    required this.apiClient,
    required this.networkMapper,
    required this.heroDao,
    required this.squadDao,
    required this.databaseMapper,
  });

  @override
  Future<List<Hero>> getHeroes({required int page, required int limit}) async {
    if (page < 1) {
      throw ArgumentError.value(page, 'page', 'Deve ser maior que zero');
    }
    if (limit < 1) {
      throw ArgumentError.value(limit, 'limit', 'Deve ser maior que zero');
    }

    final preferences = await SharedPreferences.getInstance();
    final pageKey = 'hero_page_${page}_$limit';
    final cachedIds = preferences.getStringList(pageKey);
    if (cachedIds != null) {
      final cachedHeroes = <Hero>[];
      for (final textId in cachedIds) {
        final id = int.tryParse(textId);
        final row = id == null ? null : await heroDao.selectById(id);
        if (row == null) break;
        cachedHeroes.add(databaseMapper.toHero(row));
      }
      if (cachedHeroes.length == cachedIds.length) return cachedHeroes;
    }

    final offset = (page - 1) * limit;
    final localRows = await heroDao.selectAll(limit: limit, offset: offset);

    if (_useLocalUntilRestart) {
      return databaseMapper.toHeroes(localRows);
    }

    late final List<HeroEntity> remoteRows;
    try {
      remoteRows = await apiClient.getHeroes(page: page, limit: limit);
    } catch (_) {
      var seeded = false;
      try {
        // Completa também um cache parcial, preservando bônus já salvos.
        await _seedBundledHeroes();
        seeded = true;
      } catch (_) {
        if (localRows.isEmpty) rethrow;
      }
      final rows = seeded
          ? await heroDao.selectAll(limit: limit, offset: offset)
          : localRows;
      if (rows.isEmpty && await heroDao.count() == 0) rethrow;
      _useLocalUntilRestart = true;
      if (seeded) {
        await preferences.setStringList(
          pageKey,
          rows.map((hero) => hero.id.toString()).toList(),
        );
      }
      return databaseMapper.toHeroes(rows);
    }
    final heroes = networkMapper.toHeroes(remoteRows);
    await heroDao.insertAll(databaseMapper.toHeroDatabaseEntities(heroes));
    // Os dados recebidos não substituem bônus já salvos no SQLite.
    final savedRows = await heroDao.selectAll();
    final savedById = {
      for (final row in savedRows) row.id: databaseMapper.toHero(row),
    };
    await preferences.setStringList(
      pageKey,
      heroes.map((hero) => hero.id.toString()).toList(),
    );
    return [for (final hero in heroes) savedById[hero.id] ?? hero];
  }

  Future<void> _seedBundledHeroes() async {
    final json = jsonDecode(
      await rootBundle.loadString('server/db.json'),
    ) as Map<String, dynamic>;
    final rows = json['heroes'] as List<dynamic>;
    final heroes = networkMapper.toHeroes(
      rows
          .map((row) => HeroEntity.fromJson(row as Map<String, dynamic>))
          .toList(),
    );
    await heroDao.insertAll(databaseMapper.toHeroDatabaseEntities(heroes));
  }

  @override
  Future<Hero> getHeroById(int id) async {
    final local = await heroDao.selectById(id);
    if (local != null) return databaseMapper.toHero(local);

    final remote = networkMapper.toHero(await apiClient.getHeroById(id));
    await heroDao.insert(databaseMapper.toHeroDatabaseEntity(remote));
    return remote;
  }

  @override
  Future<List<Hero>> getSquad() async {
    final ids = await squadDao.selectAllIds();
    final members = <Hero>[];
    for (final id in ids) {
      final row = await heroDao.selectById(id);
      if (row != null) members.add(databaseMapper.toHero(row));
    }
    return members;
  }

  @override
  Future<int> getSquadCount() => squadDao.count();

  @override
  Future<bool> isHeroInSquad(int id) => squadDao.contains(id);

  @override
  Future<void> recruitHero(int id) async {
    if (await squadDao.contains(id)) {
      throw StateError('Este agente já está no esquadrão.');
    }
    if (await squadDao.count() >= maxSquadSize) {
      throw StateError('O esquadrão já tem 15 agentes.');
    }
    await getHeroById(id);
    await squadDao.insert(id);
  }

  @override
  Future<void> dismissHero(int id) => squadDao.delete(id);

  @override
  Future<void> updateHero(Hero hero) async {
    if (await heroDao.selectById(hero.id) == null) {
      throw StateError('Agente não encontrado no cache.');
    }
    await heroDao.update(databaseMapper.toHeroDatabaseEntity(hero));
  }

  @override
  Future<Hero> getDailyHero() async {
    final preferences = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final savedId = preferences.getInt(_dailyIdKey);
    if (preferences.getString(_dailyDateKey) == today && savedId != null) {
      return getHeroById(savedId);
    }

    // O arquivo do trabalho tem 563 heróis; uma página grande fornece
    // sorteio sobre todo o catálogo quando o servidor está disponível.
    // Sem servidor, getHeroes devolve os registros já presentes no SQLite.
    final candidates = await getHeroes(page: 1, limit: 1000);
    if (candidates.isEmpty) {
      throw StateError('Nenhum agente disponível para o contrato diário.');
    }
    final hero = candidates[Random().nextInt(candidates.length)];
    await preferences.setInt(_dailyIdKey, hero.id);
    await preferences.setString(_dailyDateKey, today);
    return hero;
  }
}
