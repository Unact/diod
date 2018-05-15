import 'package:diod/main.dart';
import 'package:diod/app/models/user.dart';
import 'package:flutter/material.dart';


class InfoPage extends StatefulWidget {
  InfoPage({
    Key key
  }) : super(key: key);

  @override
  _InfoPageState createState() => new _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  String _personName;
  String _email;

  void _logout() async {
    await App.application.api.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    User user = User.currentUser();

    super.initState();
    this.setState(() {
      _email = user.email;
      _personName = user.personName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Пользователь'),
      ),
      body: _buildBody(context),
      floatingActionButton: new Builder(builder: _buildActionButton)
    );
  }

  Widget _buildBody(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.only(top: 60.0, left: 16.0, right: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          new ListTile(
            title: new Text(_personName,
              style: new TextStyle(fontWeight: FontWeight.w500)
            ),
            leading: new Icon(
              Icons.contacts,
              color: Colors.blue[500],
            ),
          ),
          new ListTile(
            title: new Text(_email,
              style: new TextStyle(fontWeight: FontWeight.w500)
            ),
            leading: new Icon(
              Icons.contact_mail,
              color: Colors.blue[500],
            ),
          ),
        ]
      )
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return new FloatingActionButton(
      child: const Icon(
        Icons.exit_to_app,
        semanticLabel: 'Выйти',
      ),
      backgroundColor: Colors.red,
      onPressed: _logout,
    );
  }
}
