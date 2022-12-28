import 'package:csocsort_szamla/config.dart';
import 'dialogs/add_guest_dialog.dart';
import 'package:csocsort_szamla/groups/dialogs/select_member_to_merge_dialog.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../essentials/widgets/gradient_button.dart';

class ManageGuests extends StatelessWidget {
  final bool hasGuests;
  final GlobalKey<State> bannerKey;
  ManageGuests({this.hasGuests = false, this.bannerKey});

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
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
              'manage_guests_explanation'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            )),
            SizedBox(
              height: 10,
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
              'add_guest'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  .copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
              textAlign: TextAlign.center,
            )),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
              'add_guest_explanation'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            )),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  child: Icon(
                    Icons.person_add,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    showDialog(builder: (context) => AddGuestDialog(), context: context);
                  },
                ),
              ],
            ),
            Visibility(
              visible: hasGuests,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: Text(
                    'merge_guest'.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        .copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                    textAlign: TextAlign.center,
                  )),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: Text(
                    'merge_guest_explanation'.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        .copyWith(color: Theme.of(context).colorScheme.onSurface),
                    textAlign: TextAlign.center,
                  )),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(
                        child: Icon(
                          Icons.call_merge,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          showDialog(builder: (context) => MergeGuestDialog(), context: context);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
