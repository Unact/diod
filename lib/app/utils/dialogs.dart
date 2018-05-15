import 'package:flutter/material.dart';

class Dialogs {
  static void showLoading(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: Text('Загрузка'),
          children: <Widget>[
            new Padding(padding: EdgeInsets.all(5.0), child: Center(child: CircularProgressIndicator()))
          ],
        );
      }
    );
  }

  static void showMsg(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Text(title),
          content: Text(msg)
        );
      }
    );
  }
}
