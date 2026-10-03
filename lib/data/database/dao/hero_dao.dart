import 'package:sqflite/sqflite.dart';

import '../entity/hero_database_entity.dart';
import 'base_dao.dart';

class HeroDao extends BaseDao {
  Future<List<HeroDatabaseEntity>> selectAll({int? limit, int? offset}) async {
    final db = await getDb();
    final rows = await db.query(
      HeroDatabaseContract.table,
      limit: limit,
      offset: offset,
      orderBy: 'id ASC',
    );
    return rows.map(HeroDatabaseEntity.fromJson).toList();
  }

  Future<HeroDatabaseEntity?> selectById(int id) async {
    final db = await getDb();
    final rows = await db.query(
      HeroDatabaseContract.table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : HeroDatabaseEntity.fromJson(rows.first);
  }

  Future<void> insert(HeroDatabaseEntity hero) async {
    final db = await getDb();
    await db.insert(
      HeroDatabaseContract.table,
      hero.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> insertAll(List<HeroDatabaseEntity> heroes) async {
    if (heroes.isEmpty) return;
    final db = await getDb();
    final batch = db.batch();
    for (final hero in heroes) {
      batch.insert(
        HeroDatabaseContract.table,
        hero.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> update(HeroDatabaseEntity hero) async {
    final db = await getDb();
    await db.update(
      HeroDatabaseContract.table,
      hero.toJson(),
      where: 'id = ?',
      whereArgs: [hero.id],
    );
  }

  Future<void> updatePowerStat(int heroId, String stat, int value) async {
    if (!HeroDatabaseContract.powerStatColumns.contains(stat)) {
      throw ArgumentError.value(stat, 'stat', 'Atributo inválido');
    }
    final db = await getDb();
    await db.update(
      HeroDatabaseContract.table,
      {stat: value},
      where: 'id = ?',
      whereArgs: [heroId],
    );
  }

  Future<void> deleteAll() async {
    final db = await getDb();
    await db.delete(HeroDatabaseContract.table);
  }

  Future<int> count() async {
    final db = await getDb();
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM hero_table'),
        ) ??
        0;
  }
}
