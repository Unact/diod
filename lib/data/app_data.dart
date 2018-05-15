import 'dart:async';
import 'package:diod/config/app_config.dart';
import 'package:diod/data/data_sync.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class AppData {
  AppData(AppConfig config) : env = config.env, version = config.databaseVersion;

  final String env;
  final int version;
  Database db;
  String dbPath;
  String schemaPath;
  SharedPreferences prefs;
  DataSync dataSync;

  Future<void> setup() async {
    String currentPath = (await getApplicationDocumentsDirectory()).path;

    dbPath = '$currentPath/$env.db';
    schemaPath = 'lib/data/schemas/v$version.sql';
    db = await openDatabase(dbPath, version: version,
      onCreate: (Database db, int version) async {
        await db.execute(await rootBundle.loadString(schemaPath));
      },
      onOpen: (Database db) async {
        print('Started database');
        print('Database version: $version');
      }
    );
    prefs = await SharedPreferences.getInstance();
    dataSync = new DataSync();

    print('Initialized AppData');
  }
}
