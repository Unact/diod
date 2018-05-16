import 'dart:async';

import 'package:diod/app/app.dart';

class User {
  String username;
  String password;
  String email;
  String personName;
  String beginning;
  int personId;
  User(this.username, this.password, {this.personId, this.personName, this.email, this.beginning});

  static User currentUser() {
    User user;
    String username = App.application.data.prefs.getString('username');

    if (username != null) {
      user = User(
        username,
        App.application.data.prefs.getString('password'),
        personName: App.application.data.prefs.getString('personName'),
        personId: App.application.data.prefs.getInt('personId'),
        email: App.application.data.prefs.getString('email'),
        beginning: App.application.data.prefs.getString('beginning')
      );
    }

    return user;
  }

  User.create(Map<String, dynamic> values) :
    username = values['username'],
    password = values['password'],
    personId = values['personId'],
    personName = values['personName'],
    email = values['email'],
    beginning = values['beginning']
  {
    save();
  }

  Future<void> save() async {
    await App.application.data.prefs.setString('username', username);
    await App.application.data.prefs.setString('password', password);
    await App.application.data.prefs.setString('email', email);
    await App.application.data.prefs.setString('personName', personName);
    await App.application.data.prefs.setInt('personId', personId);
    await App.application.data.prefs.setString('beginning', beginning);
  }

  Future<void> delete() async {
    await App.application.data.prefs.remove('username');
    await App.application.data.prefs.remove('password');
    await App.application.data.prefs.remove('email');
    await App.application.data.prefs.remove('personName');
    await App.application.data.prefs.remove('personId');
    await App.application.data.prefs.remove('beginning');
  }

  static Future<void> import(Map<String, dynamic> userData) async {
    User user = User.currentUser();

    user.personId = userData['person_id'];
    user.personName = userData['person_name'];
    user.email = userData['email'];
    user.beginning = userData['beginning'];
    await user.save();
  }
}
