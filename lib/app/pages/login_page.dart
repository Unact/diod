import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Войти в приложение')
      ),
      body: new Container(
        padding: const EdgeInsets.only(top: 180.0, left: 16.0, right: 16.0),
        child: new Form(
          child: new Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new TextFormField(
                keyboardType: TextInputType.url,
                decoration: new InputDecoration(
                  labelText: 'Телефон или e-mail или login',
                ),
              ),
              new TextFormField(
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
                    onPressed: () {

                    },
                    color: Colors.blueAccent,
                    child: new Text('Войти'),
                  ),
                )
              ),
            ]
          )
        )
      )
    );
  }
}
