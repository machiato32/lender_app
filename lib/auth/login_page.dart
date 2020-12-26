import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/main.dart';
import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import '../essentials/app_theme.dart';
import 'forgot_password_page.dart';

class LoginRoute extends StatefulWidget {
  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  TextEditingController _usernameController = TextEditingController(
      text: currentUsername ?? '');
  TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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
          title: Text('login'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, letterSpacing: 0.25, fontSize: 24))
        ),
        body: Center(
          child: ListView(
            padding: EdgeInsets.only(left:20, right: 20),
            shrinkWrap: true,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  value=value.trim();
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
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
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
              SizedBox(
                height: 30,
              ),
              TextFormField(
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'field_empty'.tr();
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
                obscureText: true,
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).textTheme.bodyText1.color),
                cursorColor: Theme.of(context).colorScheme.secondary,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Center(
                child: FlatButton(
                  child: Text('forgot_password'.tr(), style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 15)),
                  onPressed: () async {
                    GlobalKey<FormState> formState = GlobalKey<FormState>();
                    TextEditingController controller = TextEditingController();
                    await showDialog(
                      context: context,
                      child: Form(
                        key: formState,
                        child: AlertDialog(
                          title: Text('forgot_password'.tr(), style: Theme.of(context).textTheme.headline6,),
                          content: TextFormField(
                            controller: controller,
                            validator: (value){
                              if (value.isEmpty) {
                                return 'field_empty'.tr();
                              }
                              if (value.length < 3) {
                                return 'minimal_length'.tr(args: ['3']);
                              }
                              return null;
                            },
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
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2),
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
                          actions: [
                            RaisedButton(
                              onPressed: (){
                                if(formState.currentState.validate()){
                                  String username = controller.text;
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ForgotPasswordPage(username: username,))
                                  );
                                }
                              },
                              child: Icon(Icons.send, color: Theme.of(context).textTheme.button.color),
                              color: Theme.of(context).colorScheme.secondary,
                            )
                          ],
                        ),
                      )
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
              String username = _usernameController.text.toLowerCase();
              String password = _passwordController.text;
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  child: FutureSuccessDialog(
                    future: _login(username, password),
                    dataTrueText: 'login_scf',
                    dataFalse: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Text(
                              'login_scf'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                          height: 15,
                        ),
                        FlatButton.icon(
                          icon: Icon(Icons.check,
                              color: Theme.of(context).colorScheme.onSecondary),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => JoinGroup(
                                      fromAuth: true,
                                    )),
                                    (r) => false
                            );
                          },
                          label: Text(
                            'okay'.tr(),
                            style: Theme.of(context).textTheme.button,
                          ),
                          color: Theme.of(context).colorScheme.secondary,
                        )
                      ],
                    ),
                    onDataTrue: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MainPage()),
                              (r) => false);
                    },
                  ));
            }
          },
          child: Icon(Icons.send),
        ),
      ),
    );
  }

  Future<bool> _selectGroup(int lastActiveGroup) async {
    try {
      http.Response response =
      await httpGet(uri: '/groups', context: context);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      List<Group> groups = [];
      for (var group in decoded['data']) {
        groups.add(Group(
            groupName: group['group_name'], groupId: group['group_id'], groupCurrency: group['currency']));
      }
      if (groups.length > 0) {
        usersGroups=groups.map<String>((group) => group.groupName).toList();
        usersGroupIds=groups.map<int>((group) => group.groupId).toList();
        if (groups
            .where((group) => group.groupId == lastActiveGroup)
            .toList()
            .length !=0) {
          currentGroupName = groups
              .firstWhere((group) => group.groupId == lastActiveGroup)
              .groupName;
          currentGroupId = lastActiveGroup;
          currentGroupCurrency = groups
              .firstWhere((group) => group.groupId == lastActiveGroup)
              .groupCurrency;
          SharedPreferences.getInstance().then((_prefs) {
            _prefs.setString('current_group_name', currentGroupName);
            _prefs.setInt('current_group_id', currentGroupId);
            _prefs.setStringList('users_groups', usersGroups);
            _prefs.setStringList('users_group_ids', usersGroupIds.map<String>((e) => e.toString()).toList());
            _prefs.setString('current_group_currency', currentGroupCurrency);
          });
          return true;
        }
        currentGroupName = groups[0].groupName;
        currentGroupId = groups[0].groupId;
        currentGroupCurrency = groups[0].groupCurrency;
        SharedPreferences.getInstance().then((_prefs) {
          _prefs.setString('current_group_name', currentGroupName);
          _prefs.setInt('current_group_id', currentGroupId);
          _prefs.setStringList('users_groups', usersGroups);
          _prefs.setStringList('users_group_ids', usersGroupIds.map<String>((e) => e.toString()).toList());
          _prefs.setString('current_group_currency', currentGroupCurrency);
        });
        return true;
      }
      return false;

    } catch (_) {
      throw _;
    }
  }

  Future<bool> _login(String username, String password) async {
    try {
      Map<String, String> body = {"username": username, "password": password, "fcm_token": await _firebaseMessaging.getToken()};
      Map<String, String> header = {
        "Content-Type": "application/json"
      };
      String bodyEncoded = jsonEncode(body);
      http.Response response = await http.post((useTest?TEST_URL:APP_URL) + '/login',
          headers: header, body: bodyEncoded);
      if (response.statusCode == 200) {
        Map<String, dynamic> decoded = jsonDecode(response.body);
        apiToken = decoded['data']['api_token'];
        currentUserId = decoded['data']['id'];
        currentUsername = decoded['data']['username'];


        SharedPreferences.getInstance().then((_prefs) {
          _prefs.setString('current_username', currentUsername);
          _prefs.setInt('current_user_id', currentUserId);
          _prefs.setString('api_token', apiToken);
        });

        return await _selectGroup(decoded['data']['last_active_group']);
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
