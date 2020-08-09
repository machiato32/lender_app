import 'package:flutter/material.dart';
import 'package:csocsort_szamla/user_settings/change_password.dart';
import 'package:csocsort_szamla/user_settings/color_picker.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beállítások'),),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: <Widget>[
            ChangePin(),
            ColorPicker(),
          ],
        ),
      ),

    );
  }
}
