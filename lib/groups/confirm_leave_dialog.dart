import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ConfirmLeaveDialog extends StatefulWidget {
  final String title;
  final String choice;
  ConfirmLeaveDialog({@required this.choice, @required this.title});
  @override
  _ConfirmLeaveDialogState createState() => _ConfirmLeaveDialogState();
}

class _ConfirmLeaveDialogState extends State<ConfirmLeaveDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(widget.title.tr(), style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
            SizedBox(height: 10,),
            Text(widget.choice.tr(), style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.center,),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GradientButton(
                  onPressed: (){ Navigator.pop(context, true); },
                  child: Text('yes'.tr(), style: Theme.of(context).textTheme.button),
                  useShadow: false,
                ),
                GradientButton(
                  onPressed: (){ Navigator.pop(context, false);},
                  child: Text('no'.tr(), style: Theme.of(context).textTheme.button),
                  useShadow: false,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
