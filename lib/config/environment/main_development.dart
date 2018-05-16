import 'package:diod/app/app.dart';
import 'package:diod/config/app_config.dart';

void main() {
  App.setup(AppConfig(
    env: 'development',
    databaseVersion: 1,
    apiBaseUrl: 'http://localhost:3000/api/'
  )).run();
}
