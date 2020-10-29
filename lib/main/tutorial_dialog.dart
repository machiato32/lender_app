import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TutorialDialog extends StatefulWidget {
  @override
  _TutorialDialogState createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  List<String> title = ['hi', '', '', '', ''];
  List<String> content = ['welcome', 'tutorial_1', 'tutorial_2', 'tutorial_3', 'tutorial_4'];
  int index=0;
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState){
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Center(child: Text(title[index].tr()+((index==0)?'!':''))),
          content: Container(
            width: double.minPositive,
            child: ListView(
              shrinkWrap: true,
              children: [
                Visibility(visible: index!=0,child: Image.asset('assets/tutorial/lendertut'+index.toString()+'.gif')),
                Text(content[index].tr(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1,
                ),
              ],

            ),
          ),
          actions: <Widget>[
            Visibility(
              visible: index!=0,
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    index--;
                  });
                },
                child: Icon(Icons.navigate_before, color: Theme.of(context).textTheme.button.color),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Visibility(
              visible: index!=4,
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    index++;
                  });
                },
                child: Icon(Icons.navigate_next, color: Theme.of(context).textTheme.button.color),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Visibility(
              visible: index==4,
              child: FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.check, color: Theme.of(context).textTheme.button.color),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        );
      },
    );
  }
}
