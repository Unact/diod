import 'package:flutter/material.dart';
import 'package:diod/app/widgets/date_time_picker.dart';
import 'package:diod/app/models/user.dart';
import 'package:diod/app/models/reason.dart';
import 'package:diod/app/models/schedule_request.dart';
import 'package:diod/app/modules/api.dart';
import 'package:diod/app/utils/dialogs.dart';
import 'package:diod/main.dart';

class ScheduleRequestPage extends StatefulWidget {

  @override
  _ScheduleRequestPageState createState() => new _ScheduleRequestPageState();
}


class _ScheduleRequestPageState extends State<ScheduleRequestPage> {
  DateTime _fromDate;
  TimeOfDay _fromTime;
  DateTime _toDate;
  TimeOfDay _toTime;
  DateTime _fromDateFuture;
  TimeOfDay _fromTimeFuture;
  DateTime _toDateFuture;
  TimeOfDay _toTimeFuture;
  String _reasonDropdownHint;
  List<Reason> _reasons;
  bool _needFutureDates = false;

  Reason _reason;
  String _comments;
  User _user;

  void _submit() async {
    Dialogs.showLoading(context);

    try {
      Map<String, dynamic> newReq = {
        'person': _user.personId,
        'ddateb': new DateTime(_fromDate.year, _fromDate.month, _fromDate.day, _fromTime.hour, _fromTime.minute).toString(),
        'ddatee': new DateTime(_toDate.year, _toDate.month, _toDate.day, _toTime.hour, _toTime.minute).toString(),
        'reason': _reason.id,
        'comments': _comments
      };
      if (_needFutureDates) {
        newReq['ddateb_future'] = new DateTime(
          _fromDateFuture.year,
          _fromDateFuture.month,
          _fromDateFuture.day,
          _fromTimeFuture.hour,
          _fromTimeFuture.minute
        ).toString();
        newReq['ddatee_future'] = new DateTime(
          _toDateFuture.year,
          _toDateFuture.month,
          _toDateFuture.day,
          _toTimeFuture.hour,
          _toTimeFuture.minute
        ).toString();
      }
      await ScheduleRequest.create(newReq);
      await App.application.data.dataSync.exportData();
      await App.application.data.dataSync.importData();
      Navigator.pop(context);
      Navigator.pop(context);
    } on ApiException catch(e) {
      Navigator.pop(context);
      Dialogs.showMsg(context, 'Ошибка', e.errorMsg);
    }
  }

  @override
  void initState() {
    User user = User.currentUser();

    super.initState();
    _initStateAsync();
    this.setState(() {
      _user = user;
      _reasonDropdownHint = 'Причина';
      _comments = '';
      _fromDate = DateTime.now().add(Duration(days: 1));
      _fromTime = TimeOfDay.fromDateTime(DateTime.parse(user.beginning).toLocal());
      _toDate = DateTime.now().add(Duration(days: 1));
      _toTime = TimeOfDay(hour: 9 + _fromTime.hour, minute: _fromTime.minute);
      _fromDateFuture = DateTime.now().add(Duration(days: 1));
      _fromTimeFuture = TimeOfDay.fromDateTime(DateTime.parse(user.beginning).toLocal());
      _toDateFuture = DateTime.now().add(Duration(days: 1));
      _toTimeFuture = TimeOfDay(hour: 9 + _fromTime.hour, minute: _fromTime.minute);
    });
  }

  void _initStateAsync() async {
    _reasons = await Reason.all();
    _setReasonDropdownData(_reasons.singleWhere((reason) => reason.name == 'Работаю дома'));
  }

  void _setReasonDropdownData(reason) {
    setState(() {
      _reasonDropdownHint = reason.name;
      _reason = reason;
      if (reason.name != 'Работаю дома' && reason.name != 'Отпуск') {
        _needFutureDates = true;
        _comments = '';
      } else {
        _needFutureDates = false;
        _comments = reason.name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: const Text('Заявка на изменение графика')),
      floatingActionButton: new Builder(builder: _buildActionButton),
      body: new DropdownButtonHideUnderline(
        child: new SafeArea(
          child: new ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              new Row(
                children: <Widget>[
                  Text('Я, ${_user.personName} буду отсутствовать в офисе',
                    style: new TextStyle(fontWeight: FontWeight.w500),
                  )
                ]
              ),
              DateTimePicker(
                labelText: 'С',
                selectedDate: _fromDate,
                selectedTime: _fromTime,
                selectDate: (DateTime date) {
                  setState(() {
                    _fromDate = date;
                  });
                },
                selectTime: (TimeOfDay time) {
                  setState(() {
                    _fromTime = time;
                  });
                },
              ),
              DateTimePicker(
                labelText: 'По',
                selectedDate: _toDate,
                selectedTime: _toTime,
                selectDate: (DateTime date) {
                  setState(() {
                    _toDate = date;
                  });
                },
                selectTime: (TimeOfDay time) {
                  setState(() {
                    _toTime = time;
                  });
                },
              ),
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: new DropdownButton<Reason>(
                        hint: Text(_reasonDropdownHint),
                        items: (_reasons ?? []).map((Reason reason) {
                          return new DropdownMenuItem<Reason>(
                            value: reason,
                            child: new Text(reason.name)
                          );
                        }).toList(),
                        onChanged: (reason) {
                          _setReasonDropdownData(reason);
                        },
                      ),
                  ),
                ]
              ),
              _needFutureDates ? new Container(
                child: new Column(
                  children: <Widget>[
                    new TextField(
                      enabled: true,
                      keyboardType: TextInputType.url,
                      decoration: new InputDecoration(
                        labelText: 'Комментарий'
                      ),
                      onChanged: (comments) {
                        setState(() {
                          _comments = comments;
                        });
                      },
                    ),
                    new SizedBox(height: 20.0),
                    new Row(
                      children: <Widget>[
                        Text('Обязуюсь отработать',
                          style: new TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    DateTimePicker(
                      labelText: 'С',
                      selectedDate: _fromDateFuture,
                      selectedTime: _fromTimeFuture,
                      selectDate: (DateTime date) {
                        setState(() {
                          _fromDateFuture = date;
                        });
                      },
                      selectTime: (TimeOfDay time) {
                        setState(() {
                          _fromTimeFuture = time;
                        });
                      },
                    ),
                    DateTimePicker(
                      labelText: 'По',
                      selectedDate: _toDateFuture,
                      selectedTime: _toTimeFuture,
                      selectDate: (DateTime date) {
                        setState(() {
                          _toDateFuture = date;
                        });
                      },
                      selectTime: (TimeOfDay time) {
                        setState(() {
                          _toTimeFuture = time;
                        });
                      },
                    ),
                  ],
                ),
              ) : new Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return new FloatingActionButton(
      child: const Icon(
        Icons.save,
        semanticLabel: 'Создать',
      ),
      backgroundColor: Colors.blue,
      onPressed: _submit,
    );
  }
}
