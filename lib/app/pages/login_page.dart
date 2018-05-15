import 'package:flutter/material.dart';
import 'package:diod/main.dart';
import 'package:diod/app/modules/api.dart';
import 'package:diod/app/utils/dialogs.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _username;
  String _password;
  final _formKey = new GlobalKey<FormState>();

  void _submit() async {
    _formKey.currentState.save();
    Dialogs.showLoading(context);

    try {
      await App.application.api.login(_username, _password);
      await App.application.data.dataSync.importData();

      Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
    } on ApiException catch(e) {
      Navigator.pop(context);
      Dialogs.showMsg(context, 'Ошибка', e.errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Войти в приложение'),
        automaticallyImplyLeading: false,
      ),
      body: new Container(
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
    );
  }
}
