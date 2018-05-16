import 'dart:async';

import 'package:diod/app/app.dart';

class Reason {
  static String _tableName = 'reasons';
  int localId;
  int id;
  String name;

  Reason(Map<String, dynamic> values) :
    id = values['id'],
    name = values['name'];

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = id;
    map['name'] = name;

    return map;
  }

  Future<void> save() async {
    localId = await App.application.data.db.insert(_tableName, toMap());
  }

  Future<void> delete() async {
    await App.application.data.db.delete(_tableName, where: 'local_id = $localId');
  }

  static Future<Reason> create(Map<String, dynamic> values) async {
    Reason req = Reason(values);
    await req.save();
    return req;
  }

  static Future<void> deleteAll() async {
    await App.application.data.db.delete(_tableName);
  }

  static Future<List<Reason>> all() async {
    return (await App.application.data.db.query(_tableName)).map((rec) {
      return Reason(rec);
    }).toList();
  }

  static Future<void> import(List<dynamic> reasons) async {
    await Reason.deleteAll();
    await Future.wait(reasons.map((res) async {
      return await Reason.create(res);
    }));
  }
}
