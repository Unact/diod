import 'package:diod/config/app_config.dart';
import 'package:diod/data/database.dart';

class AppData {
  AppData(AppConfig config) :
    appDatabase = new AppDatabase(env: config.env, version: config.databaseVersion);

  final appDatabase;
}
