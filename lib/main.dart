import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';

const String configRoute = "/config";

class MyConfig {
  String apiCode = "";
  int personid;
  Database database;

  Future<File> _getLocalFile() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/api_code.txt');
  }

  Future<String> readStr() async {
    try {
      File file = await _getLocalFile();
      String contents = await file.readAsString();
      return contents;
    } on FileSystemException {
      return "Error";
    }
  }

  Future<Null> store() async {
       await (await _getLocalFile()).writeAsString('$apiCode');
  }

  Future<Database> initDB() async {
    // Get a location using path_provider
    String dir = (await getApplicationDocumentsDirectory()).path;
    String path = "$dir/mydb.db";

    // open the database
    database = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        await db.execute("""
          CREATE TABLE schedule_requests(
            id INTEGER PRIMARY KEY,
            ddateb DATETIME,
            ddatee DATETIME,
            ddateb_future DATETIME,
            ddatee_future DATETIME,
            person INTEGER,
            comments TEXT,
            ts DATETIME DEFAULT CURRENT_TIMESTAMP
          )
          """);

      await db.execute("""
        CREATE TABLE person (
        id INTEGER PRIMARY KEY,
        name TEXT,
        ts DATETIME DEFAULT CURRENT_TIMESTAMP)""");

/* Таблицы почему-то не работают
      await db.execute("""
        CREATE TABLE shedule_requests_reasons (
          id INTEGER PRIMARY KEY,
          name TEXT
        )""");
*/


        await db.execute("""
          CREATE TABLE new_request (
            ddateb DATETIME,
            ddatee DATETIME,
            ddateb_future DATETIME,
            ddatee_future DATETIME,
            reason INTEGER,
            person INTEGER,
            comments TEXT
          )""");



      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {

      }
    );
    return database;
  }

  Future<Null> findpersonid() async {

       personid = null;

       Uri uri = new Uri.https('renew.unact.ru', "/renew_users.json",
         { "q[api_code]": '${apiCode}'});
       var httpClient = createHttpClient();
       var response = await httpClient.get(uri,
         headers: {"api-code": apiCode}
       );
       List<Map> data = JSON.decode(response.body);

       for (var row in data) {
         if (row["api_code"].toString() == apiCode) {
           personid = row["person_id"];
         }
       }

  }




} //myConfig




class Choice {
  const Choice({ this.title, this.icon });
  final String title;
  final IconData icon;
}


const List<Choice> choices = const <Choice>[
  const Choice(title: 'Список', icon: Icons.directions_car),
  const Choice(title: 'Заявка', icon: Icons.directions_walk),
  const Choice(title: 'Настройки', icon: Icons.flight),
];


class ChoiceCard extends StatefulWidget {
   final MyConfig cfg;
   final Choice choice;
   const ChoiceCard({ Key key, this.cfg, this.choice }) : super(key: key);

  _ChoiceCardState createState() => new _ChoiceCardState();
}



class _ChoiceCardState extends State<ChoiceCard> {


    void _handleCfgChanged() {
      widget.cfg.store();
    }



  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;

    switch (widget.choice.title) {
    case 'Список': return new MyHomePage(title: 'График разработчиков', cfg: widget.cfg);
    case 'Заявка': return new MyEntry(cfg: widget.cfg);
    case 'Настройки': return new ConfigScreen(cfg: widget.cfg, onCfgChanged: _handleCfgChanged);


  }
  }
} ////class ChoiceCard




void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => new _MyAppState();
}


class _MyAppState extends State<MyApp> {

  final MyConfig cfg = new MyConfig();



  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new DefaultTabController(
        length: choices.length,
        child: new Scaffold(
          appBar: new AppBar(
            bottom: new TabBar(
              isScrollable: true,
              tabs: choices.map((Choice choice) {
                return new Tab(
                  text: choice.title,
                  icon: new Icon(choice.icon),
                );
              }).toList(),
            ),
          ),
          body: new TabBarView(
            children: choices.map((Choice choice) {
              return new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new ChoiceCard(cfg: cfg, choice: choice),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }


}



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.cfg}) : super(key: key);

  final String title;
  final MyConfig cfg;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  String _renew = "Обновляю....";
  DateTime _last_synch = new DateTime(1999,01,01);
  String _error_text = "";
  List _list = [];
  final  host_name = "renew.unact.ru";

  @override
  void initState() {
    super.initState();
    widget.cfg.readStr().then((String val){
      widget.cfg.apiCode = val;
      widget.cfg.findpersonid();
      widget.cfg.initDB().then((Database db){
        setFromDB();
        setRenew();
      });
    });
  }

  Future<Null> setFromDB() async {
    String sql = """
      select p.name, r.ddateb, r.ddatee, r.comments, r.ddateb_future, r.ddatee_future
      from person p
           join schedule_requests r on r.person = p.id
      order by r.ddateb, p.name
    """;
    List<Map> dlist = await widget.cfg.database.rawQuery(sql);
    List slist = [];
    for (var row in dlist) {
      slist.add(row['name']);
      slist.add(row['ddateb'].substring(8,16).replaceAll('T', ' '));
      slist.add(row['ddatee'].substring(8,16).replaceAll('T', ' '));
      slist.add(row['comments']);
    }

    List<Map> list = await widget.cfg.database.rawQuery("SELECT MAX(ts) mts FROM schedule_requests");
    DateTime ts = DateTime.parse(list[0]['mts']).add(new Duration(hours: 3));

    setState(() {
      _list = slist;
      _last_synch = ts;
    });
  }

  Future<Null> setRenew() async {
    setState(() {
      _renew = 'Обновляется...';
    });
    DateTime d1 = (new DateTime.now()).add(new Duration(days: -1));
    DateTime d2 = d1.add(new Duration(days: 4));;
    try {
    Uri uri = new Uri.https(host_name, "/schedule_requests.json",
      { "q[ddatee_gteq]": '${d1.year}-${d1.month}-${d1.day}',
        "q[ddateb_lteq]": '${d2.year}-${d2.month}-${d2.day}' }
    );
    var httpClient = createHttpClient();
    var response = await httpClient.get(uri,
      headers: {"api-code": widget.cfg.apiCode}
    );
    List<Map> data = JSON.decode(response.body);

    await widget.cfg.database.inTransaction(() async {
      await widget.cfg.database.rawDelete("DELETE FROM schedule_requests");
      for (var row in data) {
        int id1 = await widget.cfg.database.rawInsert("""
          INSERT INTO schedule_requests(id, ddateb, ddatee, ddateb_future, ddatee_future, person, comments)
          VALUES(${row["id"]},'${row["ddateb"]}','${row["ddatee"]}',
                              '${row["ddateb_future"]}','${row["ddateb_future"]}',
                              ${row["person"]}, '${row["comments"]}')
        """);
        print("inserted schedule: $id1");
        int person_id = await (Sqflite.firstIntValue(await widget.cfg.database.rawQuery("SELECT id FROM person where id = ${row['person']}")));
        print("find person: $person_id");
        if (person_id == null) {
          Uri uri2 = new Uri.https(host_name, "/universal_api/Person.json",
            { "q[person_id_eq]": "${row['person']}",
              "q[fio_combo]": "true" }
          );
          var response = await httpClient.get(uri2,
            headers: {"api-code": widget.cfg.apiCode}
          );
          List<Map> pdata = JSON.decode(response.body);
          print("${pdata[0]['name']}");
          int id2 = await widget.cfg.database.rawInsert("""
            INSERT INTO person(id, name)
            VALUES(${pdata[0]['id']}, '${pdata[0]['name']}')""");
          print("inserted person: $id2");
        }
      }
    });
    _error_text = "";
    } catch(exception, stackTrace) {
      _error_text = '\nСайт недоступен!\n${exception}';
      print(_error_text);
    }
    setFromDB();
    setState(() {
      _renew = ' ';
    });

    new Timer(const Duration(minutes: 30), setRenew);
  } //end of Future SetRenew()

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              child: new GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                  padding: const EdgeInsets.all(4.0),
                  childAspectRatio: 2.0,
                  children: _list.map((var a) {
                    return new Text('$a');
                  }).toList(),
              ),
            ),
            new Padding(
              padding: new EdgeInsets.only(bottom: 4.0),
              child: new Text(
                'Последняя синхронизация: ${_last_synch.hour}:${_last_synch.minute}\n${_renew}${_error_text}',
              ),
            ),
            new Padding(
              padding: new EdgeInsets.only(bottom: 4.0),
              child:
                new RaisedButton(
                  onPressed: () {
                    setRenew();
                  },
                  child: new Text('Обновить'),
                ),
            ),
          ],
        ),
      ),

    );
  }
} // end of _MyHomePageState


typedef void CfgChangedCallback();


class ConfigScreen extends StatefulWidget {
  final MyConfig cfg;
  final CfgChangedCallback onCfgChanged;
  ConfigScreen({Key key, this.cfg, this.onCfgChanged}) : super(key: key);

  //@override
  State createState() => new ConfigScreenState();

}

class ConfigScreenState extends State<ConfigScreen> {

final TextEditingController _controller = new TextEditingController();


  @override
  void initState() {
    super.initState();
    _controller.text = widget.cfg.apiCode;
    _controller.addListener(() {
      widget.cfg.apiCode = _controller.text;
      widget.onCfgChanged();
      setState(() {});
    });
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Настройки подключения")
      ),
      body: new Container(
        padding: const EdgeInsets.all(32.0),
        child: new Column(
          children: <Widget>[
            new Text('API code'),
            new TextField(
              controller: _controller,
              decoration: new InputDecoration(
                hintText: 'Введи код',
              ),
            ),
          ],
        ),
      ),
    );
  }
} //конец ConfigScreen




class MyEntry extends StatefulWidget {
  final MyConfig cfg;
  MyEntry({Key key, this.cfg}) : super(key: key);


  @override
  State createState() => new MyEntryState();
}

class MyEntryState extends State<MyEntry> {


DateTime _timemiss_from;
DateTime _timemiss_to;
DateTime _timecompense_from;
DateTime _timecompense_to;
int      _reason;
String   _datemiss_from;
String   _datemiss_to;
String   _datecompense_from;
String   _datecompense_to;
String   _comment;

DateTime _testdate;


final TextEditingController _controller_datemiss_from = new TextEditingController();
final TextEditingController _controller_datemiss_to = new TextEditingController();
final TextEditingController _controller_datecompense_from = new TextEditingController();
final TextEditingController _controller_datecompense_to = new TextEditingController();
final TextEditingController _controller_comment = new TextEditingController();




@override
void initState() {
  super.initState();
  _datemiss_from = '2017.12.01';
  _datemiss_to = '2017.12.02';
  _controller_datemiss_from.text = _datemiss_from;
  _controller_datemiss_to.text = _datemiss_to;
}



//Вставляем заявку в локальную таблицу
Future<Null> insertEntry() async {

    print('===================== GO AHEAD insertEntry()');
    print(widget.cfg.apiCode);
    _timemiss_to = new DateTime.now();

  await widget.cfg.database.inTransaction(() async {

    await widget.cfg.database.rawDelete("DELETE FROM new_request");

    print('===========************ step 1');

    int id1 = await widget.cfg.database.rawInsert("""
      INSERT INTO new_request(ddateb, ddatee, ddateb_future, ddatee_future, reason, person, comments)
      VALUES('${_timemiss_from}','${_timemiss_to}',
                          '${_timecompense_from}','${_timecompense_to}',
                          '${_reason}',2647, '${_comment}')
    """);

    print("ins sched: $id1");

    //Отладка. Попробуем селектнуть count(*) из новой таблицы и распечатать
    List<Map> list = await widget.cfg.database.rawQuery("SELECT ddateb, ddatee from new_request");
    print('даты = ');
    print(list[0]['ddateb']);
    print(list[0]['ddatee']);



/* Пример как делать селект
    List<Map> list = await widget.cfg.database.rawQuery("SELECT MAX(ts) mts FROM schedule_requests");
    DateTime ts = DateTime.parse(list[0]['mts']).add(new Duration(hours: 3));
*/


  });


}

//Посылаем пост в реальную базу.

//Нужно обрабатывать респонс и при успехе удалять из new_request
//НЕ ДЕЛАТЬ если записей в локальной таблице нет
Future<Null> syncEntry() async {

//Здесь нужно заселектить new_reuqest и заполнить из нее jsonData
List<Map> list = await widget.cfg.database.rawQuery("SELECT ddateb, ddatee, ddateb_future, ddatee_future, reason, person, comments from new_request");

    //нехватает полей compense, пока потестю без них
  Map jsonData = {  //перезаполнить под наши нужды
    'ddateb':       list[0]['ddateb'],
    'ddatee':       list[0]['ddatee'],
    'comments':     list[0]['comments'],
    'reason':       list[0]['reason'],
    'person':       list[0]['person'],
  };

/*   Вставка данных работоспособная, оттестированная, но пока деактивирована
Uri uri = new Uri.https('renew.unact.ru', '/schedule_requests');
var httpClient = createHttpClient();
var response = httpClient.post(uri, headers: {"api-code": widget.cfg.apiCode, 'Accept': 'application/json', 'Content-Type': 'application/json'}, body: JSON.encode(jsonData));

*/

}



Widget build(BuildContext context) {



String _twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}

List<DateTime> intervals = new List();
DateTime d1 = new DateTime(2017,01,01);
for (var i = 0; i < 24*4; i++) {
  intervals.add(d1);
  d1 = d1.add(new Duration(minutes:15));
}


//Генерим дропдаун с ризонами. Пока что хардкодом
Widget dddw_reasons = new DropdownButton<int>(
  items:
  [
    new DropdownMenuItem<int>(value: 0, child: new Text('Иное')),
    new DropdownMenuItem<int>(value: 1, child: new Text('Работаю дома')),
    new DropdownMenuItem<int>(value: 2, child: new Text('Отпуск')),
    new DropdownMenuItem<int>(value: 4, child: new Text('Пришел пораньше')),
    new DropdownMenuItem<int>(value: 5, child: new Text('Задержусь')),
    new DropdownMenuItem<int>(value: 6, child: new Text('Отработано'))
  ],
  value: _reason,
  onChanged: (int newValue) {
    setState(() {
      _reason = newValue;
    });
  }
);


Widget dddw_timemiss_from = new DropdownButton<DateTime>(
  items: intervals.map((DateTime value) {
    return new DropdownMenuItem<DateTime>(
      value: value,
      child: new Text('${_twoDigits(value.hour)}'+':'+'${_twoDigits(value.minute)}'),
    );
  }).toList(),
  value: _timemiss_from,
  onChanged: (DateTime newValue) {
    setState(() {
      _timemiss_from = newValue;
    });
  }
);

Widget dddw_timemiss_to = new DropdownButton<DateTime>(
  items: intervals.map((DateTime value) {
    return new DropdownMenuItem<DateTime>(
      value: value,
      child: new Text('${_twoDigits(value.hour)}'+':'+'${_twoDigits(value.minute)}'),
    );
  }).toList(),
  value: _timemiss_to,
  onChanged: (DateTime newValue) {
    setState(() {
      _timemiss_to = newValue;
    });
  }
);

Widget dddw_timecompense_from = new DropdownButton<DateTime>(
  items: intervals.map((DateTime value) {
    return new DropdownMenuItem<DateTime>(
      value: value,
      child: new Text('${_twoDigits(value.hour)}'+':'+'${_twoDigits(value.minute)}'),
    );
  }).toList(),
  value: _timecompense_from,
  onChanged: (DateTime newValue) {
    setState(() {
      _timecompense_from = newValue;
    });
  }
);





Widget dddw_timecompense_to = new DropdownButton<DateTime>(
  items: intervals.map((DateTime value) {
    return new DropdownMenuItem<DateTime>(
      value: value,
      child: new Text('${_twoDigits(value.hour)}'+':'+'${_twoDigits(value.minute)}'),
    );
  }).toList(),
  value: _timecompense_to,
  onChanged: (DateTime newValue) {
    setState(() {
      _timecompense_to = newValue;
    });
  }
);



return new Column(
  children: <Widget>[
    new Row(
      children: <Widget>[
       new Expanded(child: new Text('Буду отсутствовать: ')),
     ]
    ),
    new Row(
      children: <Widget>[
        new Expanded (child: new Text('С ')),
        new Expanded (child: new TextField(controller: _controller_datemiss_from )),
        dddw_timemiss_from
      ]
    ),
    new Row(
      children: <Widget>[
        new Expanded (child: new Text('По ')),
        new Expanded (child: new TextField(controller: _controller_datemiss_to )),
        dddw_timemiss_to
      ]
    ),
    new Row(
      children: <Widget>[
        new Expanded (child: new Text('Причина ')),
        dddw_reasons
      ]
    ),
    new Row(
      children: <Widget>[
        new Expanded (child: new Text('Комментарий ')),
        new Expanded (child: new TextField(controller: _controller_comment ))
      ]
    ),
    new Row(
      children: <Widget>[
       new Expanded(child: new Text('Обязуюсь отработать: '))
     ]
    ),
    new Row(
      children: <Widget>[
        new Expanded (child: new Text('С ')),
        new Expanded (child: new TextField(controller: _controller_datecompense_from )),
        dddw_timecompense_from
      ]
    ),
    new Row(
      children: <Widget>[
        new Expanded (child: new Text('По ')),
        new Expanded (child: new TextField(controller: _controller_datecompense_to  )),
        dddw_timecompense_to
      ]
    ),
    new Row(
      children: <Widget>[
        new Expanded (child: new RaisedButton
        ( child: new Text('ОК') ,
          color: Colors.blue,

          //Заносим заявку в локальную таблицу
          onPressed: () {

          }


        )),

        new Expanded (child: new RaisedButton
        ( child: new Text('тестовая кнопка') ,
          color: Colors.pink,

          onPressed: () {

                    insertEntry();
            //Такой парсинг отлично работает
            //_testdate = DateTime.parse('2017-09-18');
            //print(_testdate);
          }


        )),

        new Expanded (child: new RaisedButton
        ( child: new Text('заслать в кота') ,
          color: Colors.yellow,

          onPressed: () {

                    syncEntry();
          }


        )),

        new Expanded (child: new RaisedButton
        ( child: new Text('определить person_id') ,
          color: Colors.indigo,

          onPressed: () {
             print(widget.cfg.personid);
        }


        )),


      ]

    )
  ]

);




  } //widget_build
} //MyEntry
