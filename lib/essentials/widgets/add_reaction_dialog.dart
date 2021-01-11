import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../group_objects.dart';

class AddReactionDialog extends StatefulWidget {
  final String type;
  final List<Reaction> reactions;
  AddReactionDialog({this.type, this.reactions});
  @override
  _AddReactionDialogState createState() => _AddReactionDialogState();
}

class _AddReactionDialogState extends State<AddReactionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'reactions'.tr(),
              style:
              Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'add_reaction'.tr(),
              style:
              Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),

          ],
        ),
      ),
    );
  }
}
