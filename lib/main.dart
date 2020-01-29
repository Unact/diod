import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:diod/app/app.dart';
import 'package:diod/config/app_config.dart';
import 'package:diod/config/app_env.dart' show appEnv;

void main() async {
  bool development = false;
  assert(development = true); // Метод выполняется только в debug режиме
  String developmentUrl = Platform.isIOS ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  // If you're running an application and need to access the binary messenger before `runApp()` has been called (for example, during plugin initialization), then you need to explicitly call the `WidgetsFlutterBinding.ensureInitialized()` first.
  WidgetsFlutterBinding.ensureInitialized();

  await appEnv.load();
  App.setup(AppConfig(
    env: development ? 'development' : 'production',
    databaseVersion: 1,
    apiBaseUrl: '${development ? developmentUrl : 'https://rapi.unact.ru'}/api/',
    sentryDsn: appEnv['SENTRY_DSN']
  )).run();
}
