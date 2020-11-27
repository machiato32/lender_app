import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../app_theme.dart';
import '../http_handler.dart';
import '../future_success_dialog.dart';

class ReportABugPage extends StatefulWidget {
  @override
  _ReportABugPageState createState() => _ReportABugPageState();
}

class _ReportABugPageState extends State<ReportABugPage> {
  TextEditingController _bugController = new TextEditingController();
  var _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: AppTheme.gradientFromTheme(Theme.of(context))
            ),
          ),
          title: Text('report_a_bug'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, ),),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(15),
            children: [
              Text('what_is_wrong'.tr(), style: Theme.of(context).textTheme.bodyText2,),
              TextFormField(
                validator: (text){
                  if(text.trim().length==0){
                    return 'field_empty'.tr();
                  }
                  return null;
                },
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 10,
                controller: _bugController,
                decoration: InputDecoration(
                  labelText: 'bug'.tr(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2),
                  ),
                ),
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).textTheme.bodyText1.color),
                cursorColor: Theme.of(context).colorScheme.secondary,
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_formKey.currentState.validate()){
              showDialog(
                barrierDismissible: false,
                context: context,
                child: FutureSuccessDialog(
                  future: _postBug(_bugController.text),
                  dataTrueText: 'bug_scf',
                  onDataTrue: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              );


            }
          },
          child: Icon(Icons.send),

        ),
      ),
    );
  }

  Future<bool> _postBug(String bugText) async {
    try {
      Map<String, dynamic> body = {
        "description":bugText
      };

      await httpPost(uri: '/bug', body: body, context: context);
      return true;
    } catch (_) {
      throw _;
    }
  }
}
