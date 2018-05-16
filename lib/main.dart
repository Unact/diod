import 'package:diod/app/app.dart';
import 'package:diod/config/app_config.dart';

// В связи с https://github.com/flutter/flutter/issues/16787
// не возможно запускать флаттер через разные файлы.
// Пока багу не пофиксят, main() находится тут.
// Когда пофиксят убрать и использовать файлы сред
void main() {
  App.setup(AppConfig(
    env: 'development',
    databaseVersion: 1,
    apiBaseUrl: 'http://localhost:3000/api/',
    sentryDsn: ''
  )).run();
}
