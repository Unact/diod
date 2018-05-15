import 'package:diod/main.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:diod/app/modules/api.dart';
import 'package:diod/app/utils/dialogs.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key
  }) : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _lastSyncTime;

  SnackBar _snackBar;

  Future<void> _sync() async {
    try {
      Dialogs.showLoading(context);
      await App.application.data.dataSync.importData();

      this.setState(_setSnackBar);
      Navigator.pop(context);
    } on ApiException catch(e) {
      Navigator.pop(context);
      Dialogs.showMsg(context, 'Ошибка', e.errorMsg);
    }
  }

  void _setSnackBar() {
    _lastSyncTime = new DateFormat.yMMMd('ru').add_jm().format(App.application.data.dataSync.lastSyncTime);
    _snackBar = new SnackBar(content: new Text('Синхронизация: $_lastSyncTime'));
  }

  @override
  void initState() {

    super.initState();
    this.setState(_setSnackBar);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Заявки'),
        actions: <Widget>[
          new IconButton(
            color: Colors.white,
            icon: new Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/info');
            }
          ),
          new Builder(builder: _buildInfoButton)
        ],
      ),
      body: new Builder(builder: _buildBody),
      floatingActionButton: new Builder(builder: _buildActionButton)
    );
  }

  Widget _buildBody(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
      child: buildTest(context)
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return new FloatingActionButton(
      child: const Icon(Icons.create,
        semanticLabel: 'Создать заявку'
      ),
      backgroundColor: Colors.green,
      onPressed: () => Navigator.pushNamed(context, '/schedule_request')
    );
  }

  Widget _buildInfoButton(BuildContext context) {
    return new IconButton(
      color: Colors.white,
      icon: new Icon(Icons.info),
      onPressed: () {
        Scaffold.of(context).showSnackBar(_snackBar);
      }
    );
  }

  Widget buildTest(BuildContext context) {

    return new SafeArea(
      top: false,
      bottom: false,
      child: new Container(
        padding: const EdgeInsets.all(8.0),

        child: new Column(
          children: <Widget>[
            buildCard(context),
            buildCard(context),
            buildCard(context)
          ],
        )
      ),
    );
  }

  Widget buildCard(BuildContext context) {
    return new Card(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Align(
            alignment: Alignment.topLeft,
            child: new Padding(
              padding: const EdgeInsets.all(6.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: new Text(
                      'Барковский Я. Д.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.start,
                    )
                  ),
                  new Padding(
                    padding: EdgeInsets.all(0.0),
                    child: new Text(
                      'С 10:00 по 19:00',
                      textAlign: TextAlign.start,
                    )
                  ),
                  new Padding(
                    padding: EdgeInsets.all(0.0),
                    child: new Text(
                      'Работаю дома',
                      textAlign: TextAlign.start,
                    )
                  ),
                ]
              )
            )
          )
        ],
      ),
    );
  }
}
