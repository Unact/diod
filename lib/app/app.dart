import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry/sentry.dart';

import 'package:diod/app/modules/api.dart';
import 'package:diod/config/app_config.dart';
import 'package:diod/data/app_data.dart';

class App {
  App.setup(this.config) :
    data = new AppData(config),
    api = new Api(config),
    sentry = new SentryClient(dsn: config.sentryDsn)
  {
    _setupEnv();
    _application = this;
  }


  static App _application;
  static App get application => _application;
  final String name = 'Diod';
  final String title = 'График разработчиков';
  final AppConfig config;
  final AppData data;
  final Api api;
  final SentryClient sentry;
  Widget widget;

  Future<void> run() async {
    await data.setup();
    widget = _buildWidget();

    print('Started $name in ${config.env} environment');
    runApp(widget);
  }

  void _setupEnv() {
    if (config.env != 'development') {
      FlutterError.onError = (errorDetails) async {
        await sentry.captureException(
          exception: errorDetails.exception,
          stackTrace: errorDetails.stack,
        );
      };
    }
  }

  Widget _buildWidget() {
    return new MaterialApp(
      title: title,
      theme: new ThemeData(
        primarySwatch: Colors.blue
      ),
      initialRoute: api.isLogged() ? '/' : '/login',
      routes: config.routes,
      locale: const Locale('ru', 'RU'),
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
