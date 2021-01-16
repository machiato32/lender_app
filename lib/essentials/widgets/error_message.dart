import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../main/report_a_bug_page.dart';

class ErrorMessage extends StatelessWidget {
  final String error;
  final Function callback;
  final String locationOfError;
  ErrorMessage({@required this.error, @required this.callback, this.locationOfError});
  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Text(error.tr(), textAlign: TextAlign.center, style: TextStyle(color: Colors.red),),
              Visibility(
                visible: error!='cannot_connect',
                child: Column(
                  children: [
                    Divider(),
                    Text('if_not_working'.tr(), style: Theme.of(context).textTheme.bodyText1),
                    FlatButton.icon(
                      onPressed: (){
                        DateTime now = DateTime.now();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReportABugPage(error: error, date: now, location: locationOfError,))
                        );
                      },
                      icon: Icon(Icons.error, color: Theme.of(context).brightness==Brightness.dark?Colors.black:Colors.white,),
                      label: Text('report_this_error'.tr(), style: TextStyle(color: Theme.of(context).brightness==Brightness.dark?Colors.black:Colors.white),),
                      color: Theme.of(context).textTheme.bodyText1.color,
                    )
                  ],
                ),
              ),

            ],
          ),
        ),
        onTap: () {
          callback();
        }
    );
  }
}
