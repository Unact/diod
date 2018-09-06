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
  String _baseApiUrl;
  bool _showBaseApiUrl = false;

  Future<void> _submit() async {
    _updateFormAttributes();
    if (_username == _password && _username == App.application.config.secretKeyWord) {
      setState(() {
        _formKey.currentState.reset();
        _showBaseApiUrl = true;
      });
      return null;
    }
    try {
      Dialogs.showLoading(context);
      await App.application.api.login(_username, _password);
      Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
    } on ApiException catch(e) {
      Navigator.pop(context);
      _showSnackBar(e.errorMsg);
    } catch(e) {
      Navigator.pop(context);
      _showSnackBar('Произошла ошибка');
    }
  }

  Future<void> _getNewPassword() async {
    _updateFormAttributes();
    if (_username == null || _username == '') {
      _showSnackBar('Не заполнено поле с логином');
    } else {
      try {
        await App.application.api.resetPassword(_username);
        _showSnackBar('Пароль отправлен на почту');
      } on ApiException catch(e) {
        _showSnackBar(e.errorMsg);
      } catch(e) {
        _showSnackBar('Произошла ошибка');
      }
    }
  }

  void _updateFormAttributes() {
    _formKey.currentState.save();
    if (_showBaseApiUrl) {
        App.application.config.apiBaseUrl = _baseApiUrl;
        App.application.config.save();
      }
  }

  void _showSnackBar(String content) {
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
              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
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
                        _showBaseApiUrl ? new TextFormField(
                          initialValue: App.application.config.apiBaseUrl,
                          onSaved: (val) => _baseApiUrl = val,
                          keyboardType: TextInputType.url,
                          decoration: new InputDecoration(
                            labelText: 'Api Url'
                          ),
                        ) : new Container(),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                          new Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
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
                          new Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                              child: new Container(
                                width: 150.0,
                                child: new RaisedButton(
                                  onPressed: _getNewPassword,
                                  color: Colors.blueAccent,
                                  textColor: Colors.white,
                                  child: new Text('Получить пароль'),
                                ),
                              )
                          ),
                        ],)
                      ]
                  )
              )
          ),
        ],
      )
    );
  }
}
