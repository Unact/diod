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
  
  Future<File> _getLocalFile() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/api_code.txt');
  }
    
  Future<String> _readStr() async {
    try {
      File file = await _getLocalFile();
      String contents = await file.readAsString();
      return contents;
    } on FileSystemException {
      return "Error";
    }
  }
  
  Future<Null> _setStr(String str) async {
       await (await _getLocalFile()).writeAsString('$str');
  }

  Future<Database> _initDB() async {
    // Get a location using path_provider
    String dir = (await getApplicationDocumentsDirectory()).path;
    String path = "$dir/mydb.db";

    // open the database
    Database database = await openDatabase(path, version: 2,
      onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute("""CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER,
                                             num REAL,
                                             her TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP)""");
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        assert(oldVersion == 1);
        assert(newVersion == 2);
        await db.execute("ALTER TABLE Test ADD her TEXT");
      }
    );
    return database;
  }

  void _handleCfgChanged() {
    _setStr(cfg.apiCode);
  }
  
  var routes;
  @override
  void initState() {
    super.initState();
    _readStr().then((String val){
      cfg.apiCode = val;
    });
    _initDB().then((Database db) {
      cfg.database = db;  
    });
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
        routes: routes);
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
  String _renew = "";
  int    _cnt = 0;
    
  @override
  void initState() {
    super.initState();
    if (widget.cfg.database != null) {
      _getCnt(widget.cfg.database).then((int cc) {
        setState(() {
          _cnt = cc;
        });
      });
    }
    new Timer(const Duration(seconds: 1), _setRenew);
  }
  
  Future<int> _getCnt(Database db) async {
    int cc = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM Test"));
    return cc;
  }
        
  Future<Null> _setRenew() async {
    Uri uri = new Uri.https("renew.unact.ru", "/schedule_requests.json",
      { "q[ddatee_gteq]": "2017-08-28", "q[ddateb_lteq]": "2017-08-30" }
    );
    var httpClient = createHttpClient();
    var response = await httpClient.get(uri,
      headers: {"api-code": widget.cfg.apiCode}
    );
    List<Map> data = JSON.decode(response.body);
    String cc = data[0]["comments"];
    
    await widget.cfg.database.inTransaction(() async {
      int id1 = await widget.cfg.database.rawInsert("INSERT INTO Test(her) VALUES('${response.body}')");
      print("inserted2: $id1"); 
    });
    
    int cnt = await _getCnt(widget.cfg.database);
    
    setState(() {
      _renew = cc;
      _cnt = cnt;
    });
    
    // new Timer(const Duration(seconds: 10), _setRenew);
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'Текст в базе',
            ),
            new Text(
              '${_cnt} - ${_renew}',
              style: Theme.of(context).textTheme.display1,
            ),
            new RaisedButton(
              onPressed: () {
                _setRenew();
              },
              child: new Text('Обновить'),
            ),
            new RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(configRoute);
              },
              child: new Text('Настройки'),
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
          // mainAxisAlignment: MainAxisAlignment.center,
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
