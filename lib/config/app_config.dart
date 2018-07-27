import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:diod/app/app.dart';
import 'package:diod/app/pages/home_page.dart';
import 'package:diod/app/pages/login_page.dart';
import 'package:diod/app/pages/person_page.dart';
import 'package:diod/app/pages/schedule_request_page.dart';

class AppConfig {
  AppConfig({
    @required this.env,
    @required this.databaseVersion,
    @required this.apiBaseUrl,
    @required this.sentryDsn
  });

  final String env;
  String apiBaseUrl;
  final String sentryDsn;
  final String clientId = 'diod';
  final String secretKeyWord = '5005';
  final int databaseVersion;
  final routes = {
    '/': (BuildContext context) => new HomePage(),
    '/login': (BuildContext context) => new LoginPage(),
    '/person': (BuildContext context) => new PersonPage(),
    '/schedule_request': (BuildContext context) => new ScheduleRequestPage()
  };

  Future<void> save() async {
    await App.application.data.prefs.setString('apiBaseUrl', apiBaseUrl);
  }

  void loadSaved() {
    apiBaseUrl = App.application.data.prefs.getString('apiBaseUrl') ?? apiBaseUrl;
  }
}
