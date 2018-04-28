
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key
  }) : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    //var config = App.of(context).config;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Заявка'),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: () {Navigator.pushNamed(context, '/schedule_request_list');},),
          new IconButton(icon: new Icon(Icons.security), onPressed: () {Navigator.pushNamed(context, '/login');},),
          new IconButton(icon: new Icon(Icons.search), onPressed: () {Navigator.pushNamed(context, '/test');},),
        ],
      ),
      body: new Container(
        child: new Form(
          child: new Column(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Text('Буду отсутствовать'),
                ]
              )
            ],
          )
        ),
      )
    );
  }
}
