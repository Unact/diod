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
          """
        );       
        await db.execute("""CREATE TABLE person (
        id INTEGER PRIMARY KEY,
        name TEXT,
        ts DATETIME DEFAULT CURRENT_TIMESTAMP)""");
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        
      }
    );
    return database;
  }
}

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MyConfig cfg = new MyConfig();
  

  void _handleCfgChanged() {
    cfg.store();
  }
  
  var routes;
  @override
  void initState() {
    super.initState();    
    routes = <String, WidgetBuilder>{
        configRoute: (BuildContext context) => new ConfigScreen(cfg: cfg, onCfgChanged: _handleCfgChanged),
    };
  }
  
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Приложение графика',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new MyHomePage(title: 'График разработчиков', cfg: cfg),
        routes: routes,
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
  String _db_text = "";
  final  host_name = "renew.unact.ru";
  
  @override
  void initState() {
    super.initState();
    widget.cfg.readStr().then((String val){
      widget.cfg.apiCode = val;
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
    List<Map> list = await widget.cfg.database.rawQuery(sql);
    String s = "";
    for (var row in list) {
      s += "${row['name']}\t${row['ddateb'].substring(5,10)}\t${row['comments']}\n";
    }
    
    list = await widget.cfg.database.rawQuery("SELECT MAX(ts) mts FROM schedule_requests");
    DateTime ts = DateTime.parse(list[0]['mts']);
    
    setState(() {
      _db_text = s;
      _last_synch = ts;
    });
  }
  
  Future<Null> setRenew() async {
    setState(() {
      _renew = 'Обновляется...';
    });
    DateTime d1 = (new DateTime.now()).add(new Duration(days: -1));
    DateTime d2 = d1.add(new Duration(days: 3));;
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
      _error_text = '\nСайт недоступен!!!!\n${exception}';
      print(_error_text);
    }
    setFromDB();
    setState(() {
      _renew = ' ';
    });
    
    new Timer(const Duration(minutes: 30), setRenew);
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
        padding: const EdgeInsets.all(32.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.only(bottom: 4.0),
              child: new Text(
                '$_db_text',
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
            new Padding(
              padding: new EdgeInsets.only(bottom: 4.0),
              child: new RaisedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(configRoute);
                },
                child: new Text('Настройки'),
              ),
            ),
          ],
        ),
      ),
     
    );
  }
}

typedef void CfgChangedCallback();
  
class ConfigScreen extends StatefulWidget {
  MyConfig cfg;
  final CfgChangedCallback onCfgChanged;
  ConfigScreen({Key key, this.cfg, this.onCfgChanged}) : super(key: key);

  @override                                                         
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
}
