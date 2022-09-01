import 'package:flutter/material.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../essentials/widgets/gradient_button.dart';

class ResetTutorial extends StatefulWidget {
  @override
  _ResetTutorialState createState() => _ResetTutorialState();
}

class _ResetTutorialState extends State<ResetTutorial> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Text(
              'reset_tutorial'.tr(),
              style: Theme.of(context).textTheme.titleLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            )),
            SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                'reset_tutorial_explanation'.tr(),
                style: Theme.of(context).textTheme.titleSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  child: Icon(Icons.check,
                      color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () {
                    FeatureDiscovery.clearPreferences(context, [
                      'drawer',
                      'shopping_list',
                      'group_settings',
                      'add_payment_expense',
                      'settings'
                    ]);
                    SharedPreferences.getInstance()
                        .then((value) => value.setBool('show_tutorial', true));
                    Navigator.pop(context);
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
