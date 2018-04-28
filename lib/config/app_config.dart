import 'package:diod/app/pages/home_page.dart';
import 'package:diod/app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class AppConfig {
  AppConfig({
    @required this.env,
    @required this.databaseVersion
  });

  final String env;
  final int databaseVersion;
  final routes = {
    '/': (BuildContext context) => new HomePage(),
    '/login': (BuildContext context) => new LoginPage()
  };
}
