import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../essentials/app_theme.dart';
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: AppTheme.gradientFromTheme(Theme.of(context))
          ),
        ),
        title: Text('settings'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, ),),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          children: <Widget>[ColorPicker(), LanguagePicker(), ChangePassword(), ChangeUsername(), ResetTutorial()],
        ),
      ),
    );
  }
}
