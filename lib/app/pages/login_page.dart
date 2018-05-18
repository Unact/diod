import 'dart:async';

import 'package:flutter/material.dart';

import 'package:diod/app/app.dart';
import 'package:diod/app/modules/api.dart';
import 'package:diod/app/utils/dialogs.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _username;
  String _password;

  Future<void> _submit() async {
    try {
      _formKey.currentState.save();
      Dialogs.showLoading(context);
      await App.application.api.login(_username, _password);
      Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
    } on ApiException catch(e) {
      Navigator.pop(context);
      _showErrorSnackBar(e.errorMsg);
    }
  }

  void _showErrorSnackBar(String content) {
    _scaffoldKey.currentState?.showSnackBar(new SnackBar(
      content: new Text(content)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Войти в приложение'),
        automaticallyImplyLeading: false,
      ),
      body: new ListView(
        children: <Widget>[
          new Container(
              padding: const EdgeInsets.only(top: 180.0, left: 16.0, right: 16.0),
              child: new Form(
                  key: _formKey,
                  child: new Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new TextFormField(
                          onSaved: (val) => _username = val,
                          keyboardType: TextInputType.url,
                          decoration: new InputDecoration(
                            labelText: 'Телефон или e-mail или login',
                          ),
                        ),
                        new TextFormField(
                          onSaved: (val) => _password = val,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          decoration: new InputDecoration(
                              labelText: 'Пароль'
                          ),
                        ),
                        new Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: new Container(
                              width: 100.0,
                              child: new RaisedButton(
                                onPressed: _submit,
                                color: Colors.blueAccent,
                                textColor: Colors.white,
                                child: new Text('Войти'),
                              ),
                            )
                        ),
                      ]
                  )
              )
          ),
        ],
      )
    );
  }
}
