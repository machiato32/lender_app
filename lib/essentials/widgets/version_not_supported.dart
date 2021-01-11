import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';

class VersionNotSupportedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: AppTheme.gradientFromTheme(Theme.of(context))
          ),
        ),
        title: Text(
          'version_not_supported'.tr(),
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, letterSpacing: 0.25, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('version_not_supported_explanation'.tr(), style: Theme.of(context).textTheme.bodyText1,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  child: Text('download_new_version'.tr(), style: Theme.of(context).textTheme.button,),
                  onPressed: (){
                    launch('https://play.google.com/store/apps/details?id=csocsort.hu.machiato32.csocsort_szamla');
                  },
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
