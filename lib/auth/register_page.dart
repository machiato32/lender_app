import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';

class RegisterRoute extends StatefulWidget {
  @override
  _RegisterRouteState createState() => _RegisterRouteState();
}

class _RegisterRouteState extends State<RegisterRoute> {
  Random _random = Random();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _userNumController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();
  TextEditingController _passwordReminderController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _randomNum;

  @override
  void initState() {
    _randomNum = _random.nextInt(10000).toString().padLeft(4, '0');
    _userNumController.text = _randomNum;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(title: Text('register'.tr())),
        body: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'field_empty'.tr();
                        }
                        if (value.length < 3) {
                          return 'minimal_length'.tr(args: ['3']);
                        }
                        return null;
                      },
                      controller: _usernameController,
                      decoration: InputDecoration(
                        helperText: 'not_alterable'.tr(),
                        hintText: 'example_name'.tr(),
                        labelText: 'name'.tr(),
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
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[a-z0-9]')),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyText1.color),
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '#',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 30),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'field_empty'.tr();
                        }
                        if (value.length != 4) {
                          return 'num_length'.tr();
                        }
                        return null;
                      },
                      controller: _userNumController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'id'.tr(),
                        helperText: 'not_alterable'.tr(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 2),
                          //  when the TextFormField in unfocused
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(new RegExp('[0-9]')),
                        LengthLimitingTextInputFormatter(4),
                      ],
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyText1.color),
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),

              SizedBox(
                height: 30,
              ),
              Padding(
                padding: EdgeInsets.only(right: 20, left: 20),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'field_empty'.tr();
                    }
                    if (value.length < 4) {
                      return 'minimal_length'.tr(args: ['4']);
                    }
                    return null;
                  },
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'password'.tr(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 2),
                      //  when the TextFormField in unfocused
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  ],
                  obscureText: true,
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyText1.color),
                  cursorColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: EdgeInsets.only(right: 20, left: 20),
                child: TextFormField(
                  validator: (value) {
                    if (value != _passwordController.text) {
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
                  controller: _passwordConfirmController,
                  decoration: InputDecoration(
                    labelText: 'confirm_password'.tr(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 2),
                      //  when the TextFormField in unfocused
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  ],
                  obscureText: true,
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyText1.color),
                  cursorColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(
                height: 30,
              ),
//            Padding(
//              padding: EdgeInsets.only(right: 20, left: 20),
//              child: TextField(
//                controller: _passwordReminderController,
//                decoration: InputDecoration(
//                  labelText: 'Jelszóemlékeztető',
//                  enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
//                    //  when the TextFormField in unfocused
//                  ) ,
//                  focusedBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
//                  ) ,
//
//                ),
//                style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
//                cursorColor: Theme.of(context).colorScheme.secondary,
//              ),
//            ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
              String username = _usernameController.text;
              String userNum = _userNumController.text;
              if (_passwordController.text == _passwordConfirmController.text) {
                String password = _passwordConfirmController.text;
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    child: FutureSuccessDialog(
                      future: _register(username, userNum, password, ''),
                      dataTrueText: 'registration_scf',
                      onDataTrue: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JoinGroup(
                                      fromAuth: true,
                                    )),
                            (r) => false);
                      },
                    ));
              } else {
                Widget toast = Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.red,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      Flexible(
                          child: Text("passwords_not_match".tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(color: Colors.white))),
                    ],
                  ),
                );
                FlutterToast ft = FlutterToast(context);
                ft.showToast(
                    child: toast,
                    toastDuration: Duration(seconds: 2),
                    gravity: ToastGravity.BOTTOM);
              }
            }
          },
          child: Icon(Icons.send),
        ),
      ),
    );
  }

  Future<bool> _register(
      String username, String userNum, String password, String reminder) async {
    try {
      Map<String, String> body = {
        "id": username + "#" + userNum,
        "default_currency": "HUF",
        "password": password,
        "password_confirmation": password,
        "password_reminder": reminder
      };
      Map<String, String> header = {
        "Content-Type": "application/json",
      };

      String bodyEncoded = jsonEncode(body);
      http.Response response = await http.post(APPURL + '/register',
          headers: header, body: bodyEncoded);
      if (response.statusCode == 201) {
        Map<String, dynamic> decodedResponse = jsonDecode(response.body);
        apiToken = decodedResponse['api_token'];
        currentUser = decodedResponse['id'];

        SharedPreferences.getInstance().then((_prefs) {
          _prefs.setString('current_user', currentUser);
          _prefs.setString('api_token', apiToken);
        });
        return true;
      } else {
        Map<String, dynamic> error = jsonDecode(response.body);
        throw error['error'];
      }
    } catch (_) {
      throw _;
    }
  }
}
