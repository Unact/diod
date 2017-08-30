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
    database = await openDatabase(path, version: 2,
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
  int    _cnt = 0;
    
  @override
  void initState() {
    super.initState();
    widget.cfg.readStr().then((String val){
      widget.cfg.apiCode = val;
      widget.cfg.initDB().then((Database db){
        setRenew();
      });
    });
  }
  
        
  Future<Null> setRenew() async {
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
    
    int cnt = await (Sqflite.firstIntValue(await widget.cfg.database.rawQuery("SELECT COUNT(*) FROM Test")));
    
    setState(() {
      _renew = cc;
      _cnt = cnt;
    });
    
    // new Timer(const Duration(seconds: 10), setRenew);
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
                'Текст в базе',
              ),
            ),
            new Padding(
              padding: new EdgeInsets.only(bottom: 4.0),
              child: new Text(
                '${_cnt} - ${_renew}',
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
