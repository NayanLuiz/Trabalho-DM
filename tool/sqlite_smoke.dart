import 'package:flutter/material.dart';
import 'package:flutter_repository_example/data/database/dao/hero_dao.dart';
import 'package:flutter_repository_example/data/database/dao/squad_dao.dart';
import 'package:flutter_repository_example/data/database/entity/hero_database_entity.dart';

const _firstId = 900000001;
const _secondId = 900000002;

class _SmokeHeroDao extends HeroDao {
  Future<void> removeTestRows() async {
    final db = await getDb();
    await db.delete(
      HeroDatabaseContract.table,
      where: 'id IN (?, ?)',
      whereArgs: [_firstId, _secondId],
    );
  }
}

HeroDatabaseEntity _hero(int id, String name, {int strength = 100}) =>
    HeroDatabaseEntity(
      id: id,
      name: name,
      slug: name.toLowerCase(),
      intelligence: 38,
      strength: strength,
      speed: 17,
      durability: 80,
      power: 24,
      combat: 64,
      gender: 'Male',
      race: null,
      height: const ['6 ft', '183 cm'],
      weight: const ['200 lb', '91 kg'],
      eyeColor: 'Blue',
      hairColor: 'Black',
      fullName: name,
      alterEgos: '-',
      aliases: const ['Test Agent'],
      placeOfBirth: '-',
      firstAppearance: '-',
      publisher: null,
      alignment: 'good',
      occupation: '-',
      base: '-',
      groupAffiliation: '-',
      relatives: '-',
      imageXs: 'https://example.com/xs.jpg',
      imageSm: 'https://example.com/sm.jpg',
      imageMd: 'https://example.com/md.jpg',
      imageLg: 'https://example.com/lg.jpg',
    );

void _check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final heroes = _SmokeHeroDao();
  final squad = SquadDao();
  try {
    await heroes.removeTestRows();
    final before = await heroes.count();
    await heroes.insertAll([
      _hero(_firstId, 'Primeiro'),
      _hero(_secondId, 'Segundo'),
    ]);
    _check(await heroes.count() == before + 2, 'insertAll/count');
    final page = await heroes.selectAll(limit: 2, offset: before);
    _check(
      page.map((hero) => hero.id).join(',') == '$_firstId,$_secondId',
      'selectAll/limit/offset',
    );
    await heroes.insert(_hero(_firstId, 'Duplicado'));
    _check(await heroes.count() == before + 2, 'duplicate ignored');
    _check(
      (await heroes.selectById(_firstId))?.name == 'Primeiro',
      'selectById',
    );
    await heroes.update(_hero(_firstId, 'Atualizado'));
    await heroes.updatePowerStat(_firstId, 'strength', 101);
    final updated = await heroes.selectById(_firstId);
    _check(
      updated?.name == 'Atualizado' && updated?.strength == 101,
      'update/updatePowerStat',
    );
    final squadBefore = await squad.count();
    await squad.insert(_firstId);
    await squad.insert(_firstId);
    _check(await squad.count() == squadBefore + 1, 'squad insert/duplicate');
    _check(await squad.contains(_firstId), 'squad contains');
    _check(
      (await squad.selectAllIds()).contains(_firstId),
      'squad selectAllIds',
    );
    await squad.delete(_firstId);
    _check(!await squad.contains(_firstId), 'squad delete');
    debugPrint('SQLITE_SMOKE_OK');
    runApp(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('SQLITE_SMOKE_OK'))),
      ),
    );
  } finally {
    await squad.delete(_firstId);
    await heroes.removeTestRows();
  }
}
