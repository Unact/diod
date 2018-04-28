import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppDatabase  {
  AppDatabase({
    @required this.env,
    @required this.version
  }) {
    _initDb();
  }

  final String env;
  final int version;
  Database db;
  String dbPath;
  String schemaPath;

  void _initDb() async {
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
  }
}
