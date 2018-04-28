import 'package:diod/config/app_config.dart';
import 'package:diod/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App {
  App.setup(this.config) :
    env = config.env,
    data = new AppData(config)
  {
    widget = _buildWidget();
    _application = this;
  }

  static App _application;
  static App get application => _application;
  final String env;
  final String name = 'Diod';
  final String title = 'График разработчиков';
  final AppConfig config;
  final AppData data;
  Widget widget;

  run() {
    print('Started $name in $env environment');
    runApp(widget);
  }

  Widget _buildWidget() {
    return new MaterialApp(
      title: title,
      theme: new ThemeData(
        primarySwatch: Colors.blue
      ),
      routes: config.routes,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('ru', 'RU'),
      ],
    );
  }
}
