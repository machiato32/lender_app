import 'package:flutter/material.dart';
import 'switch_user.dart';
import 'change_pin.dart';
import 'main.dart';
import 'color_picker.dart';

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
            SwitchUser(),
            Visibility(
              visible: (currentUser!=''),
              child: ChangePin()
            ),
            ColorPicker(),
          ],
        ),
      ),

    );
  }
}
