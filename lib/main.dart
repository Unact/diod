import 'dart:io';

import 'package:diod/app/app.dart';
import 'package:diod/config/app_config.dart';

void main() {
  bool development = false;
  assert(development = true); // Метод выполняется только в debug режиме
  String developmentUrl = Platform.isIOS ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  App.setup(AppConfig(
    env: development ? 'development' : 'production',
    databaseVersion: 1,
    apiBaseUrl: '${development ? developmentUrl : 'https://rapi.unact.ru'}/api/',
    sentryDsn: ''
  )).run();
}
