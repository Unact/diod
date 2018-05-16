import 'package:diod/app/app.dart';
import 'package:diod/config/app_config.dart';

void main() {
  App.setup(AppConfig(
    env: 'production',
    databaseVersion: 1,
    apiBaseUrl: 'https://rapi.unact.ru/api/',
    sentryDsn: ''
  )).run();
}
