import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ConfirmChoiceDialog extends StatefulWidget {
  final String choice;
  ConfirmChoiceDialog({@required this.choice});
  @override
  _ConfirmChoiceDialogState createState() => _ConfirmChoiceDialogState();
}

class _ConfirmChoiceDialogState extends State<ConfirmChoiceDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(widget.choice.tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white), textAlign: TextAlign.center,),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: (){ Navigator.pop(context, true); },
                    child: Text('yes'.tr(), style: Theme.of(context).textTheme.button)
                ),
                RaisedButton(
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: (){ Navigator.pop(context, false);},
                    child: Text('no'.tr(), style: Theme.of(context).textTheme.button)
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
