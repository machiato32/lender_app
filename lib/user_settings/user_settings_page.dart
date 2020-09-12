import 'package:flutter/material.dart';
import 'package:csocsort_szamla/user_settings/change_password.dart';
import 'package:csocsort_szamla/user_settings/color_picker.dart';
import 'change_language.dart';
import 'change_username.dart';
import 'package:easy_localization/easy_localization.dart';

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
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: <Widget>[ChangePassword(), ChangeUsername(), ColorPicker(), LanguagePicker()],
        ),
      ),
    );
  }
}
