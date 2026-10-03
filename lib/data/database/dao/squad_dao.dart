import 'package:sqflite/sqflite.dart';

import '../entity/squad_member_database_entity.dart';
import 'base_dao.dart';

class SquadDao extends BaseDao {
  Future<void> insert(int heroId) async {
    final db = await getDb();
    final member = SquadMemberDatabaseEntity(
      heroId: heroId,
      recruitedAt: DateTime.now().toUtc().toIso8601String(),
    );
    await db.insert(
      SquadDatabaseContract.table,
      member.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> delete(int heroId) async {
    final db = await getDb();
    await db.delete(
      SquadDatabaseContract.table,
      where: 'hero_id = ?',
      whereArgs: [heroId],
    );
  }

  Future<List<int>> selectAllIds() async {
    final db = await getDb();
    final rows = await db.query(
      SquadDatabaseContract.table,
      columns: [SquadDatabaseContract.heroId],
      orderBy: 'recruited_at ASC, hero_id ASC',
    );
    return rows.map((row) => row[SquadDatabaseContract.heroId] as int).toList();
  }

  Future<bool> contains(int heroId) async {
    final db = await getDb();
    final rows = await db.query(
      SquadDatabaseContract.table,
      columns: [SquadDatabaseContract.heroId],
      where: 'hero_id = ?',
      whereArgs: [heroId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<int> count() async {
    final db = await getDb();
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM squad_table'),
        ) ??
        0;
  }
}
