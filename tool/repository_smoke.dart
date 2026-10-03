import 'package:flutter/material.dart';
import 'package:flutter_repository_example/data/database/dao/hero_dao.dart';
import 'package:flutter_repository_example/data/database/dao/squad_dao.dart';
import 'package:flutter_repository_example/data/database/database_mapper.dart';
import 'package:flutter_repository_example/data/network/client/api_client.dart';
import 'package:flutter_repository_example/data/network/network_mapper.dart';
import 'package:flutter_repository_example/data/repository/hero_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _offline = bool.fromEnvironment('SMOKE_OFFLINE');
const _pageOneKey = 'repository_smoke_page_one';
const _pageTwoKey = 'repository_smoke_page_two';
const _dailyIdKey = 'repository_smoke_daily_id';
const _previousDateKey = 'repository_smoke_previous_date';
const _previousIdKey = 'repository_smoke_previous_id';

void _check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Future<void> _online(
  HeroRepositoryImpl repository,
  SharedPreferences prefs,
) async {
  final previousDate = prefs.getString('daily_hero_date');
  final previousId = prefs.getInt('daily_hero_id');
  await prefs.setString(_previousDateKey, previousDate ?? '');
  await prefs.setInt(_previousIdKey, previousId ?? -1);
  await prefs.remove('daily_hero_date');
  await prefs.remove('daily_hero_id');
  await prefs.remove('hero_page_1_7');
  await prefs.remove('hero_page_2_7');
  await prefs.remove('hero_page_1_1000');

  final detail = await repository.getHeroById(100);
  _check(detail.id == 100, 'detail from API');

  final first = await repository.getHeroes(page: 1, limit: 7);
  final second = await repository.getHeroes(page: 2, limit: 7);
  _check(first.length == 7 && second.length == 7, 'API pagination');
  _check(first.first.id != second.first.id, 'distinct pages');
  await prefs.setStringList(
    _pageOneKey,
    first.map((hero) => hero.id.toString()).toList(),
  );
  await prefs.setStringList(
    _pageTwoKey,
    second.map((hero) => hero.id.toString()).toList(),
  );

  final repeated = await repository.getHeroes(page: 1, limit: 7);
  _check(
    repeated.map((hero) => hero.id).join(',') ==
        first.map((hero) => hero.id).join(','),
    'cached page order',
  );

  final squadBefore = await repository.getSquadCount();
  final recruit = first.firstWhere((hero) => hero.id != 100);
  final wasMember = await repository.isHeroInSquad(recruit.id);
  if (!wasMember) {
    await repository.recruitHero(recruit.id);
    try {
      _check(
        await repository.getSquadCount() == squadBefore + 1,
        'recruit count',
      );
      _check(await repository.isHeroInSquad(recruit.id), 'recruit contains');
      _check(
        (await repository.getSquad()).any((hero) => hero.id == recruit.id),
        'squad hydration',
      );
      var duplicateRejected = false;
      try {
        await repository.recruitHero(recruit.id);
      } on StateError {
        duplicateRejected = true;
      }
      _check(duplicateRejected, 'duplicate rejected');
      final boosted = recruit.copyWith(strength: recruit.strength + 1);
      await repository.updateHero(boosted);
      _check(
        (await repository.getHeroById(recruit.id)).strength ==
            recruit.strength + 1,
        'bonus persisted',
      );
    } finally {
      await repository.updateHero(recruit);
      await repository.dismissHero(recruit.id);
    }
    _check(await repository.getSquadCount() == squadBefore, 'dismiss count');
  }

  final daily = await repository.getDailyHero();
  _check((await repository.getDailyHero()).id == daily.id, 'same daily hero');
  await prefs.setInt(_dailyIdKey, daily.id);
  _check(await HeroDao().count() >= 563, 'full catalog cached');

  final originalSquadIds = (await repository.getSquad())
      .map((hero) => hero.id)
      .toSet();
  final catalogue = await repository.getHeroes(page: 1, limit: 1000);
  final available = catalogue
      .where((hero) => !originalSquadIds.contains(hero.id))
      .toList();
  final addedIds = <int>[];
  try {
    final freeSlots = HeroRepositoryImpl.maxSquadSize - originalSquadIds.length;
    for (final hero in available.take(freeSlots)) {
      await repository.recruitHero(hero.id);
      addedIds.add(hero.id);
    }
    _check(
      await repository.getSquadCount() == HeroRepositoryImpl.maxSquadSize,
      'squad limit reached',
    );
    var fullRejected = false;
    try {
      await repository.recruitHero(available[freeSlots].id);
    } on StateError {
      fullRejected = true;
    }
    _check(fullRejected, 'sixteenth agent rejected');
  } finally {
    for (final id in addedIds) {
      await repository.dismissHero(id);
    }
  }
  debugPrint('REPOSITORY_ONLINE_OK');
}

Future<void> _offlineCheck(
  HeroRepositoryImpl repository,
  SharedPreferences prefs,
) async {
  final first = await repository.getHeroes(page: 1, limit: 7);
  final second = await repository.getHeroes(page: 2, limit: 7);
  _check(
    first.map((hero) => hero.id.toString()).join(',') ==
        prefs.getStringList(_pageOneKey)?.join(','),
    'page one offline',
  );
  _check(
    second.map((hero) => hero.id.toString()).join(',') ==
        prefs.getStringList(_pageTwoKey)?.join(','),
    'page two offline',
  );
  _check((await repository.getHeroById(100)).id == 100, 'detail offline');
  _check(
    (await repository.getDailyHero()).id == prefs.getInt(_dailyIdKey),
    'daily hero offline',
  );
  final uncataloguedPage = await repository.getHeroes(page: 1, limit: 999);
  _check(uncataloguedPage.length >= 563, 'SQLite fallback without page index');

  final before = await repository.getSquadCount();
  final recruitedIds = (await repository.getSquad())
      .map((hero) => hero.id)
      .toSet();
  final recruit = first.firstWhere(
    (hero) => !recruitedIds.contains(hero.id),
    orElse: () => second.firstWhere((hero) => !recruitedIds.contains(hero.id)),
  );
  if (!await repository.isHeroInSquad(recruit.id)) {
    await repository.recruitHero(recruit.id);
    try {
      _check(await repository.getSquadCount() == before + 1, 'offline recruit');
      _check(
        (await repository.getSquad()).any((hero) => hero.id == recruit.id),
        'offline squad',
      );
    } finally {
      await repository.dismissHero(recruit.id);
    }
  }

  final previousDate = prefs.getString(_previousDateKey);
  final previousId = prefs.getInt(_previousIdKey);
  if (previousDate == null || previousDate.isEmpty) {
    await prefs.remove('daily_hero_date');
  } else {
    await prefs.setString('daily_hero_date', previousDate);
  }
  if (previousId == null || previousId < 0) {
    await prefs.remove('daily_hero_id');
  } else {
    await prefs.setInt('daily_hero_id', previousId);
  }
  for (final key in [
    _pageOneKey,
    _pageTwoKey,
    _dailyIdKey,
    _previousDateKey,
    _previousIdKey,
    'hero_page_1_7',
    'hero_page_2_7',
    'hero_page_1_1000',
  ]) {
    await prefs.remove(key);
  }
  debugPrint('REPOSITORY_OFFLINE_OK');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = HeroRepositoryImpl(
    apiClient: ApiClient(baseUrl: 'http://10.0.2.2:3000'),
    networkMapper: NetworkMapper(),
    heroDao: HeroDao(),
    squadDao: SquadDao(),
    databaseMapper: DatabaseMapper(),
  );
  final prefs = await SharedPreferences.getInstance();
  if (_offline) {
    await _offlineCheck(repository, prefs);
  } else {
    await _online(repository, prefs);
  }
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            _offline ? 'REPOSITORY_OFFLINE_OK' : 'REPOSITORY_ONLINE_OK',
          ),
        ),
      ),
    ),
  );
}
