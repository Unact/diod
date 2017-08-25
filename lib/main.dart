import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Заголовок приложения',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new MyHomePage(title: 'Это начальная страница приложения'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _blabla = "";
  
  final TextEditingController _controller = new TextEditingController();
  Database _database;
  
  @override
  void initState() {
    super.initState();
    _readStr().then((String value) {
      setState(() {
        _blabla = value;
        _controller.text = value;
      });
    });
    _initDB().then((Database db) {
      setState(() {
        _database = db;
      });
    });
  }
  
  Future<Database> _initDB() async {
    // Get a location using path_provider
    String dir = (await getApplicationDocumentsDirectory()).path;
    String path = "$dir/demo.db";

    // open the database
    Database database = await openDatabase(path, version: 3,
      onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
        "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL, her INTEGER)");
    });;
    
    return database;
  }
  
  Future<File> _getLocalFile() async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/blabla.txt');
  }

  Future<String> _readStr() async {
    try {
      File file = await _getLocalFile();
      // read the variable as a string from the file.
      String contents = await file.readAsString();
      return contents;
    } on FileSystemException {
      return "Error";
    }
  }
  
  Future<Null> _setStr() async {
    setState(() {
      _blabla = _controller.text;
    });
    // write the variable as a string to the file
    await (await _getLocalFile()).writeAsString('$_blabla');
    
    // Insert some records in a transaction
    await _database.inTransaction(() async {
      int id1 = await _database.rawInsert('INSERT INTO Test(name, value, num) VALUES("$_blabla", 1234, 456.789)');
      print("inserted1: $id1"); 
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'Текст в базе',
            ),
            new Text(
              '${_blabla}',
              style: Theme.of(context).textTheme.display1,
            ),
            new TextField(
              controller: _controller,
              decoration: new InputDecoration(
                hintText: 'Type something',
              ),
            ),
            new RaisedButton(
              onPressed: () {
                _setStr();
                showDialog(
                  context: context,
                  child: new AlertDialog(
                    title: new Text('Сохранен текст:'),
                    content: new Text(_controller.text),
                  ),
                );
              },
              child: new Text('Сохранить'),
            ),
          ],
        ),
      ),
     
    );
  }
}
