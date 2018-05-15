import 'package:diod/app/pages/home_page.dart';
import 'package:diod/app/pages/login_page.dart';
import 'package:diod/app/pages/info_page.dart';
import 'package:diod/app/pages/schedule_request_page.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class AppConfig {
  AppConfig({
    @required this.env,
    @required this.databaseVersion,
    @required this.apiBaseUrl
  });

  final String env;
  final String apiBaseUrl;
  final String clientId = 'diod';
  final int databaseVersion;
  final routes = {
    '/': (BuildContext context) => new HomePage(),
    '/login': (BuildContext context) => new LoginPage(),
    '/info': (BuildContext context) => new InfoPage(),
    '/schedule_request': (BuildContext context) => new ScheduleRequestPage()
  };
}
