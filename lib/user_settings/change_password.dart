import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/main.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  var _formKey = GlobalKey<FormState>();

  Future<bool> _updatePassword(String oldPassword, String newPassword) async {
    try {
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + apiToken
      };
      Map<String, dynamic> map = {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword
      };

      String encoded = jsonEncode(map);

      http.Response response = await http.post(APPURL + '/change_password',
          headers: header, body: encoded);
      if (response.statusCode == 204) {
        return true;
      } else {
        Map<String, dynamic> error = jsonDecode(response.body);

        throw error['error'];
      }
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
                'change_password'.tr(),
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
                  labelText: 'old_password'.tr(),
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
                controller: _oldPasswordController,
                obscureText: true,
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).textTheme.bodyText1.color),
                cursorColor: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'field_empty'.tr();
                  }
                  if (value.length < 4) {
                    return 'minimal_length'.tr(args: ['4']);
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'new_password'.tr(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                ],
                controller: _newPasswordController,
                obscureText: true,
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).textTheme.bodyText1.color),
                cursorColor: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'passwords_not_match'.tr();
                  }
                  if (value.isEmpty) {
                    return 'field_empty'.tr();
                  }
                  if (value.length < 4) {
                    return 'minimal_length'.tr(args: ['4']);
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'new_password_confirm'.tr(),
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
                controller: _confirmPasswordController,
                obscureText: true,
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).textTheme.bodyText1.color),
                cursorColor: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(
                height: 30,
              ),
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
                            future: _updatePassword(_oldPasswordController.text,
                                _newPasswordController.text),
                            dataTrueText: 'change_password_scf',
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
