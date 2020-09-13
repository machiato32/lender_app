import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/main.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';
import 'package:csocsort_szamla/http_handler.dart';

class ChangeUsername extends StatefulWidget {
  @override
  _ChangeUsernameState createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  TextEditingController _usernameController = TextEditingController();

  var _formKey = GlobalKey<FormState>();

  Future<bool> _updateUsername(String newUsername) async {
    try {
      Map<String, dynamic> body = {
        'new_username': newUsername
      };

      await httpPost(uri: '/change_username',
          context: context, body: body);
      SharedPreferences.getInstance().then((prefs){
        prefs.setString('current_username', newUsername);
      });
      currentUsername=newUsername;
      return true;

    } catch (_) {
      throw _;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                  child: Text(
                    'change_username'.tr(),
                    style: Theme.of(context).textTheme.headline6,
                  )),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'field_empty'.tr();
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'username'.tr(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface),
                    //  when the TextFormField in unfocused
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                ],
                controller: _usernameController,
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).textTheme.bodyText1.color),
                cursorColor: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 30,),
              Center(
                child: RaisedButton.icon(
                  color: Theme.of(context).colorScheme.secondary,
                  label: Text('send'.tr(),
                      style: Theme.of(context).textTheme.button),
                  icon: Icon(Icons.send,
                      color: Theme.of(context).colorScheme.onSecondary),
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (_formKey.currentState.validate()) {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          child: FutureSuccessDialog(
                            future: _updateUsername(_usernameController.text),
                            dataTrueText: 'change_username_scf',
                            onDataTrue: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainPage()),
                                      (route) => false);
                            },
                          ));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
