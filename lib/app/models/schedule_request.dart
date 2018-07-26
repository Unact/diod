import 'dart:async';

import 'package:diod/app/app.dart';

class ScheduleRequest {
  static String _tableName = 'schedule_requests';
  int localId;
  int id;
  String ndoc;
  DateTime ddate;
  int person;
  String personName;
  DateTime ddateb;
  DateTime ddatee;
  String comments;
  int status;
  DateTime ddatebFuture;
  DateTime ddateeFuture;
  int reason;

  ScheduleRequest(Map<String, dynamic> values) :
    id = values['id'],
    person = values['person'],
    personName = values['person_name'],
    ddateb = values['ddateb'] != null ? DateTime.parse(values['ddateb']) : null,
    ddatee = values['ddatee'] != null ? DateTime.parse(values['ddatee']) : null,
    comments = values['comments'],
    reason = values['reason'],
    ddatebFuture = values['ddateb_future'] != null ? DateTime.parse(values['ddateb_future']) : null,
    ddateeFuture = values['ddatee_future'] != null ? DateTime.parse(values['ddatee_future']) : null;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = id;
    map['person'] = person;
    map['person_name'] = personName;
    map['ddateb'] = ddateb != null ? ddateb.toIso8601String() : null;
    map['ddatee'] = ddatee != null ? ddatee.toIso8601String() : null;
    map['comments'] = comments;
    map['reason'] = reason;
    map['ddateb_future'] = ddatebFuture != null ? ddatebFuture.toIso8601String() : null;
    map['ddatee_future'] = ddateeFuture != null ? ddateeFuture.toIso8601String() : null;

    return map;
  }

  Future<void> save() async {
    localId = await App.application.data.db.insert(_tableName, toMap());
  }

  Future<void> delete() async {
    await App.application.data.db.delete(_tableName, where: 'local_id = $localId');
  }

  static Future<ScheduleRequest> create(Map<String, dynamic> values) async {
    ScheduleRequest req = ScheduleRequest(values);
    await req.save();
    return req;
  }

  static Future<void> deleteAll() async {
    await App.application.data.db.delete(_tableName);
  }

  static Future<List<ScheduleRequest>> all() async {
    return (await App.application.data.db.query(_tableName)).map((rec) {
      return ScheduleRequest(rec);
    }).toList();
  }

  static Future<void> import(List<dynamic> scheduleRequests) async {
    await ScheduleRequest.deleteAll();
    await Future.wait(scheduleRequests.map((req) async {
      return await ScheduleRequest.create(req);
    }));
  }

  static Future<List<Map<String, dynamic>>> export() async {
    List<ScheduleRequest> allReqs = await ScheduleRequest.all();
    allReqs.removeWhere((ScheduleRequest req) => req.id != null);

    return allReqs.map((req) => req.toMap()).toList();
  }
}
