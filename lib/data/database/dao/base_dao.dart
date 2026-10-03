import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../entity/hero_database_entity.dart';
import '../entity/squad_member_database_entity.dart';

abstract class BaseDao {
  static const databaseVersion = 1;
  static const _databaseName = 'hero_database.db';

  static Future<Database>? _database;

  @protected
  Future<Database> getDb() => _database ??= _getDatabase();

  Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        final batch = db.batch();
        _createHeroTable(batch);
        _createSquadTable(batch);
        await batch.commit();
      },
      version: databaseVersion,
    );
  }

  void _createHeroTable(Batch batch) {
    batch.execute('''
      CREATE TABLE ${HeroDatabaseContract.table}(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        slug TEXT NOT NULL,
        intelligence INTEGER NOT NULL,
        strength INTEGER NOT NULL,
        speed INTEGER NOT NULL,
        durability INTEGER NOT NULL,
        power INTEGER NOT NULL,
        combat INTEGER NOT NULL,
        gender TEXT NOT NULL,
        race TEXT,
        height TEXT NOT NULL,
        weight TEXT NOT NULL,
        eye_color TEXT NOT NULL,
        hair_color TEXT NOT NULL,
        full_name TEXT NOT NULL,
        alter_egos TEXT NOT NULL,
        aliases TEXT NOT NULL,
        place_of_birth TEXT NOT NULL,
        first_appearance TEXT NOT NULL,
        publisher TEXT,
        alignment TEXT NOT NULL,
        occupation TEXT NOT NULL,
        base TEXT NOT NULL,
        group_affiliation TEXT NOT NULL,
        relatives TEXT NOT NULL,
        image_xs TEXT NOT NULL,
        image_sm TEXT NOT NULL,
        image_md TEXT NOT NULL,
        image_lg TEXT NOT NULL
      )
      ''');
  }

  void _createSquadTable(Batch batch) {
    batch.execute('''
      CREATE TABLE ${SquadDatabaseContract.table}(
        ${SquadDatabaseContract.heroId} INTEGER PRIMARY KEY,
        ${SquadDatabaseContract.recruitedAt} TEXT NOT NULL,
        FOREIGN KEY (${SquadDatabaseContract.heroId})
          REFERENCES ${HeroDatabaseContract.table}(${HeroDatabaseContract.id})
          ON DELETE CASCADE
      )
      ''');
  }
}
