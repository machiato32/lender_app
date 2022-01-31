import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TutorialDialog extends StatefulWidget {
  @override
  _TutorialDialogState createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  List<String> title = ['hi', '', '', ''];
  List<String> content = ['welcome', 'tutorial_2', 'tutorial_3', 'tutorial_4'];
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    title[index].tr() + ((index == 0) ? '! 😎' : ''),
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  children: [
                    Visibility(
                      visible: index != 0,
                      child: Container(
                        constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height / 2),
                        child: Image.asset('assets/tutorial/lendertut' +
                            index.toString() +
                            '.gif'),
                        // child: Text('asd'),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(content[index].tr(),
                        style: Theme.of(context).textTheme.bodyText1,
                        textAlign: TextAlign.center),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: index != 0,
                      child: GradientButton(
                        onPressed: () {
                          setState(() {
                            index--;
                          });
                        },
                        child: Icon(Icons.navigate_before,
                            color: Theme.of(context).textTheme.button.color),
                      ),
                    ),
                    GradientButton(
                      onPressed: () {
                        if (index != 3) {
                          setState(() {
                            index++;
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Icon(
                          index == 3 ? Icons.check : Icons.navigate_next,
                          color: Theme.of(context).textTheme.button.color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
