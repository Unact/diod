import 'dart:io';

import 'package:diod/app/app.dart';
import 'package:diod/config/app_config.dart';
import 'package:diod/config/app_env.dart' show appEnv;

void main() async {
  bool development = false;
  assert(development = true); // Метод выполняется только в debug режиме
  String developmentUrl = Platform.isIOS ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  await appEnv.load();
  App.setup(AppConfig(
    env: development ? 'development' : 'production',
    databaseVersion: 1,
    apiBaseUrl: '${development ? developmentUrl : 'https://rapi.unact.ru'}/api/',
    sentryDsn: appEnv['SENTRY_DSN']
  )).run();
}
