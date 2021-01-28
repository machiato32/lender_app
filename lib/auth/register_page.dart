import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:expandable/expandable.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';

import '../essentials/app_theme.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';

import '../essentials/http_handler.dart';

class RegisterPage extends StatefulWidget {
  final String inviteURL;
  RegisterPage({this.inviteURL});
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();
  TextEditingController _passwordReminderController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _defaultValue = "EUR";

  ExpandableController _reminderExplanationController = ExpandableController();
  ExpandableController _usernameExplanationController = ExpandableController();

  bool _privacyPolicy = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: AppTheme.gradientFromTheme(Theme.of(context))
            ),
          ),
          title: Text('register'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, letterSpacing: 0.25, fontSize: 24))
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Center(
            child: ListView(
              padding: EdgeInsets.only(left:20, right: 20),
              shrinkWrap: true,
              children: <Widget>[
                Stack(
                  children: [
                    TextFormField(
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
                        hintText: 'example_name'.tr(),
                        labelText: 'username'.tr(),
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
                    Container(
                      margin: EdgeInsets.only(top:20),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          onPressed: (){
                            setState(() {
                              _usernameExplanationController.expanded=!_usernameExplanationController.expanded;
                            });
                          },
                          icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary,)
                        )
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expandable(
                  controller: _usernameExplanationController,
                  collapsed: Container(),
                  expanded: Container(
                    constraints: BoxConstraints(maxHeight: 80),
                    child: Row(
                      children: [
                        Flexible(child: Text('username_explanation'.tr(), style: Theme.of(context).textTheme.subtitle2,)),
                      ],
                    )
                  ),
                ),
                SizedBox(
                  height: 10,
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
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'password'.tr(),
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
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  ],
                  obscureText: true,
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyText1.color),
                  cursorColor: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
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
                SizedBox(
                  height: 20,
                ),
                Stack(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'field_empty'.tr();
                        }
                        if (value.length < 3) {
                          return 'minimal_length'.tr(args: ['3']);
                        }
                        return null;
                      },
                      controller: _passwordReminderController,
                      decoration: InputDecoration(
                        labelText: 'password_reminder'.tr(),
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
                        // FilteringTextInputFormatter.allow(RegExp('[a-z0-9]')),
                        LengthLimitingTextInputFormatter(50),
                      ],
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyText1.color),
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                    Container(
                      margin: EdgeInsets.only(top:20),
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                              onPressed: (){
                                setState(() {
                                  _reminderExplanationController.expanded=!_reminderExplanationController.expanded;
                                });
                              },
                              icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary,)
                          )
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expandable(
                  controller: _reminderExplanationController,
                  collapsed: Container(),
                  expanded: Container(
                      constraints: BoxConstraints(maxHeight: 80),
                      child: Row(
                        children: [
                          Flexible(child: Text('reminder_explanation'.tr(), style: Theme.of(context).textTheme.subtitle2,)),
                        ],
                      )
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'your_currency'.tr(),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton(
                          isExpanded: true,
                          onChanged: (value){
                            setState(() {
                              _defaultValue=value;
                            });
                          },
                          value: _defaultValue,
                          style: Theme.of(context).textTheme.bodyText1,
                          items: enumerateCurrencies().map((currency) => DropdownMenuItem(
                            child: Text(currency.split(';')[0].trim()+" ("+currency.split(';')[1].trim()+")",),
                            value: currency.split(';')[0].trim(),
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: InkWell(
                          onTap: (){
                            launch('https://lenderapp.net/privacy-policy');
                          },
                          child: Text('accept_privacy_policy'.tr(),
                            style: Theme.of(context).textTheme.subtitle2.copyWith(decoration: TextDecoration.underline), )
                      ),
                    ),
                    Checkbox(
                      value: _privacyPolicy,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (value){
                        setState(() {
                          _privacyPolicy=value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
              String username = _usernameController.text;
              String passwordReminder = _passwordReminderController.text;
              if (_passwordController.text == _passwordConfirmController.text) {
                if(_privacyPolicy){
                  String password = _passwordConfirmController.text;
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    child: FutureSuccessDialog(
                      future: _register(username, password, passwordReminder, _defaultValue),
                      dataTrueText: 'registration_scf',
                      onDataTrue: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JoinGroup(
                                  fromAuth: true,
                                  inviteURL: widget.inviteURL,
                                )),
                                (r) => false);
                      },
                    )
                  );
                }else{
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
                            child: Text("must_accept_privacy_policy".tr(),
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
                      gravity: ToastGravity.BOTTOM
                  );
                }

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
      String username, String password, String reminder, String currency) async {
    try {
      FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
      Map<String, String> body = {
        "username": username,
        "default_currency": currency,
        "password": password,
        "password_confirmation": password,
        "password_reminder": reminder,
        "fcm_token": await _firebaseMessaging.getToken(),
        "language":context.locale.languageCode,
      };
      Map<String, String> header = {
        "Content-Type": "application/json",
      };

      String bodyEncoded = jsonEncode(body);
      http.Response response = await http.post((useTest?TEST_URL:APP_URL) + '/register',
          headers: header, body: bodyEncoded);
      if (response.statusCode == 201) {
        Map<String, dynamic> decodedResponse = jsonDecode(response.body);
        apiToken = decodedResponse['api_token'];
        currentUsername = decodedResponse['username'];
        currentUserId = decodedResponse['id'];

        SharedPreferences.getInstance().then((_prefs) {
          _prefs.setString('current_username', currentUsername);
          _prefs.setInt('current_user_id', currentUserId);
          _prefs.setString('api_token', apiToken);
        });
        return true;
      } else {
        Map<String, dynamic> error = jsonDecode(response.body);
        throw error['error'];
      }
    } on FormatException {
      throw 'format_exception'.tr()+' F01';
    } on SocketException {
      throw 'cannot_connect'.tr()+ ' F02';
    } catch (_) {
      throw errorHandler(_);
    }
  }
}
