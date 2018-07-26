import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:diod/app/app.dart';
import 'package:diod/app/models/schedule_request.dart';
import 'package:diod/app/modules/api.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key
  }) : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  List<ScheduleRequest> _scheduleRequests;

  Future<void> _sync() async {
    _scheduleRequests = await ScheduleRequest.all();
    setState(() {});
    if (App.application.api.isLogged()) {
      try {
        await App.application.data.dataSync.importData();
        _scheduleRequests = await ScheduleRequest.all();
        setState(() {});
      } on ApiException catch(e) {
        _showErrorSnackBar(e.errorMsg);
      } catch(e) {
        _showErrorSnackBar('Произошла ошибка');
      }
    }
  }

  Future<Null> _refresh() async {
    _refreshIndicatorKey.currentState.show();
    return new Future(() async {
      await _sync();
    });
  }

  void _showErrorSnackBar(String content) {
    _scaffoldKey.currentState?.showSnackBar(new SnackBar(
      content: new Text(content),
      action: new SnackBarAction(
        label: 'Повторить',
        onPressed: _refresh
      )
    ));
  }

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  Widget build(BuildContext context) {
    List<ScheduleRequest> scheduleRequests = _scheduleRequests ?? [];
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('Заявки'),
          actions: <Widget>[
            new IconButton(
              color: Colors.white,
              icon: new Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/person');
              }
            ),
            new Builder(builder: _buildInfoButton)
          ],
        ),
        body: new RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: new ListView.builder(
              padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
              itemCount: scheduleRequests.length,
              itemBuilder: (BuildContext context, int index) {
                return buildCard(context, scheduleRequests[index]);
              }
            )
        ),
        floatingActionButton: new Builder(builder: _buildActionButton)
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
        DateTime lastsyncTime = App.application.data.dataSync.lastSyncTime;
        String content = lastsyncTime != null ? new DateFormat.yMMMd('ru').add_jm().format(lastsyncTime) : 'Не проводилась';
        _scaffoldKey.currentState?.showSnackBar(new SnackBar(content: new Text('Синхронизация: $content')));
      }
    );
  }

  Widget buildCard(BuildContext context, ScheduleRequest req) {
    String dateTimeFrom = new DateFormat.yMd('ru').add_jm().format(req.ddateb.toLocal());
    String dateTimeTo = new DateFormat.yMd('ru').add_jm().format(req.ddatee.toLocal());
    String dateTimeFromFuture;
    String dateTimeToFuture;
    String comments = req.comments;
    bool hasFutureDates = false;

    if (req.ddatebFuture != null) {
      hasFutureDates = true;
      dateTimeFromFuture = new DateFormat.yMd('ru').add_jm().format(req.ddatebFuture.toLocal());
      dateTimeToFuture = new DateFormat.yMd('ru').add_jm().format(req.ddateeFuture.toLocal());
    }
    return new Card(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            isThreeLine: true,
            leading: new CircleAvatar(child: Icon(Icons.person_outline)),
            title: new Text(req.personName),
            subtitle: new Text(comments),
          ),
          new Container(
            padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text('Отсутствует:'),
                new Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: new Text('$dateTimeFrom - $dateTimeTo'),
                )
              ],
            )
          ),
          hasFutureDates ? new Container(
            padding: EdgeInsets.only(left: 20.0, bottom: 5.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text('Обязуется отработать:'),
                new Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: new Text('$dateTimeFromFuture - $dateTimeToFuture')
                ),
              ],
            ),
          ) : new Container(),
        ],
      ),
    );
  }
}
