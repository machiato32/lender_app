import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'change_password.dart';
import 'color_picker.dart';
import 'change_language.dart';
import 'change_username.dart';
import 'reset_tutorial.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr()),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          children: <Widget>[ChangePassword(), ChangeUsername(), ColorPicker(), LanguagePicker(), ResetTutorial()],
        ),
      ),
    );
  }
}
