import 'package:csocsort_szamla/groups/add_guest_dialog.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../essentials/widgets/gradient_button.dart';

class ManageGuests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                'manage_guests'.tr(),
                style:
                Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
                  'manage_guests_explanation'.tr(),
                  style:
                  Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                )
            ),
            SizedBox(
              height: 10,
            ),
            Divider(),
            Center(
                child: Text(
                  'add_guest'.tr(),
                  style:
                  Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                )
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
                  'add_guest_explanation'.tr(),
                  style:
                  Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                )
            ),SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  child: Icon(Icons.person_add, color: Theme.of(context).colorScheme.onSecondary,),
                  onPressed: (){
                    showDialog(context: context, child: AddGuestDialog());
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
                  'remove_guest'.tr(),
                  style:
                  Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                )
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
                  'remove_guest_explanation'.tr(),
                  style:
                  Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                )
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  child: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.onSecondary,),
                  onPressed: (){
                    // showDialog(context: context, child: ChangeGroupCurrencyDialog());
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
                  'merge_guest'.tr(),
                  style:
                  Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                )
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
                  'merge_guest_explanation'.tr(),
                  style:
                  Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                )
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  child: Icon(Icons.call_merge, color: Theme.of(context).colorScheme.onSecondary,),
                  onPressed: (){
                    // showDialog(context: context, child: ChangeGroupCurrencyDialog());
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
