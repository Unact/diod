import 'dart:async';

import 'package:diod/app/app.dart';
import 'package:diod/app/models/reason.dart';
import 'package:diod/app/models/schedule_request.dart';
import 'package:diod/app/models/user.dart';

class DataSync {
  get lastSyncTime {
    String time = App.application.data.prefs.getString('lastSyncTime');
    return time != null ? DateTime.parse(time) : null;
  }
  set lastSyncTime(val) => App.application.data.prefs.setString('lastSyncTime', val.toString());

  Future<void> importData() async {
    var importData = await App.application.api.get('v1/diod');
    lastSyncTime = new DateTime.now();

    await ScheduleRequest.import(importData['schedule_requests']);
    await Reason.import(importData['reasons']);
    await User.import(importData['user']);
  }

  Future<void> exportData() async {
    Map<String, dynamic> exportData = {
      'schedule_requests': await ScheduleRequest.export()
    };
    await App.application.api.post('v1/diod/save', body: exportData);

    lastSyncTime = new DateTime.now();
  }
}
