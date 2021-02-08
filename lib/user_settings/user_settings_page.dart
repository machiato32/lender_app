import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/ad_management.dart';
import 'package:csocsort_szamla/user_settings/delete_all_data.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../essentials/app_theme.dart';
import 'about_us.dart';
import 'change_password.dart';
import 'color_picker.dart';
import 'change_language.dart';
import 'change_username.dart';
import 'reset_tutorial.dart';
import 'personalised_ads.dart';

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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[ColorPicker(), LanguagePicker(), ChangePassword(), ChangeUsername(), ResetTutorial(),
                  Visibility(visible: showAds, child: PersonalisedAds()),
                  AboutUs(), DeleteAllData()],
              ),
            ),
            adUnitForSite('settings'),
          ],
        ),
      ),
    );
  }
}
