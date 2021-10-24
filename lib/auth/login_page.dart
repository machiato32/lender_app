import 'dart:convert';
import 'dart:io';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:csocsort_szamla/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../essentials/app_theme.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  final String inviteURL;
  LoginPage({this.inviteURL});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController =
      TextEditingController(text: currentUsername ?? '');
  TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Form(
        key: _formKey,
        child: Scaffold(
          appBar: AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                    gradient: AppTheme.gradientFromTheme(Theme.of(context))),
              ),
              title: Text('login'.tr(),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      letterSpacing: 0.25,
                      fontSize: 24))),
          body: Center(
            child: ListView(
              padding: EdgeInsets.only(left: 20, right: 20),
              shrinkWrap: true,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: TextFormField(
                    validator: (value) {
                      value = value.trim();
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
                      fillColor: Theme.of(context).cardTheme.color,
                      filled: true,
                      prefixIcon: Icon(
                        Icons.account_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'username'.tr(),
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
                    hintText: 'password'.tr(),
                    fillColor: Theme.of(context).cardTheme.color,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.password,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
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
                    child: Text('forgot_password'.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(fontSize: 15)),
                    onPressed: () async {
                      GlobalKey<FormState> formState = GlobalKey<FormState>();
                      TextEditingController controller =
                          TextEditingController();
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return Form(
                            key: formState,
                            child: AlertDialog(
                              title: Text(
                                'forgot_password'.tr(),
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              content: TextFormField(
                                controller: controller,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'field_empty'.tr();
                                  }
                                  if (value.length < 3) {
                                    return 'minimal_length'.tr(args: ['3']);
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'username'.tr(),
                                  fillColor: Theme.of(context).cardTheme.color,
                                  filled: true,
                                  prefixIcon: Icon(
                                    Icons.account_circle,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp('[a-z0-9]')),
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color),
                                cursorColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              actions: [
                                RaisedButton(
                                  onPressed: () {
                                    if (formState.currentState.validate()) {
                                      String username = controller.text;
                                      Navigator.pop(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ForgotPasswordPage(
                                                    username: username,
                                                  )));
                                    }
                                  },
                                  child: Icon(Icons.send,
                                      color: Theme.of(context)
                                          .textTheme
                                          .button
                                          .color),
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                )
                              ],
                            ),
                          );
                        },
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
                  builder: (context) {
                    return FutureSuccessDialog(
                      future: _login(username, password),
                      dataTrueText: 'login_scf',
                      onDataTrue: () {
                        _onSelectGroupTrue();
                      },
                    );
                  },
                );
              }
            },
            child: Icon(Icons.send),
          ),
        ),
      ),
    );
  }

  Future<bool> _selectGroup(int lastActiveGroup) async {
    try {
      http.Response response =
          await httpGet(uri: generateUri(GetUriKeys.groups), context: context);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      List<Group> groups = [];
      for (var group in decoded['data']) {
        groups.add(Group(
            groupName: group['group_name'],
            groupId: group['group_id'],
            groupCurrency: group['currency']));
      }
      if (groups.length > 0) {
        usersGroups = groups.map<String>((group) => group.groupName).toList();
        usersGroupIds = groups.map<int>((group) => group.groupId).toList();
        saveUsersGroups();
        saveUsersGroupIds();
        if (groups
                .where((group) => group.groupId == lastActiveGroup)
                .toList()
                .length !=
            0) {
          Group currentGroup =
              groups.firstWhere((group) => group.groupId == lastActiveGroup);
          saveGroupName(currentGroup.groupName);
          saveGroupId(lastActiveGroup);
          saveGroupCurrency(currentGroup.groupCurrency);
          Future.delayed(delayTime()).then((value) => _onSelectGroupTrue());
          return true;
        }
        saveGroupName(groups[0].groupName);
        saveGroupId(groups[0].groupId);
        saveGroupCurrency(groups[0].groupCurrency);
        Future.delayed(delayTime()).then((value) => _onSelectGroupTrue());
        return true;
      }
      Future.delayed(delayTime()).then((value) => _onSelectGroupFalse());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onSelectGroupTrue() {
    if (widget.inviteURL == null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => MainPage()), (r) => false);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => JoinGroup(
                    inviteURL: widget.inviteURL,
                  )),
          (r) => false);
    }
  }

  void _onSelectGroupFalse() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => JoinGroup(
                  fromAuth: true,
                  inviteURL: widget.inviteURL,
                )),
        (r) => false);
  }

  Future<bool> _login(String username, String password) async {
    try {
      FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
      Map<String, String> body = {
        "username": username,
        "password": password,
        "fcm_token": kIsWeb ? null : await _firebaseMessaging.getToken()
      };
      Map<String, String> header = {"Content-Type": "application/json"};
      String bodyEncoded = jsonEncode(body);
      http.Response response = await http.post(
          Uri.parse((useTest ? TEST_URL : APP_URL) + '/login'),
          headers: header,
          body: bodyEncoded);
      if (response.statusCode == 200) {
        Map<String, dynamic> decoded = jsonDecode(response.body);
        showAds = decoded['data']['ad_free'] == 0;
        useGradients = decoded['data']['gradients_enabled'] == 1;
        trialVersion = decoded['data']['trial'] == 1;
        saveUsername(decoded['data']['username']);
        saveUserId(decoded['data']['id']);
        saveApiToken(decoded['data']['api_token']);
        await clearAllCache();
        return await _selectGroup(decoded['data']['last_active_group']);
      } else {
        Map<String, dynamic> error = jsonDecode(response.body);
        throw error['error'];
      }
    } on FormatException {
      throw 'format_exception'.tr() + ' F01';
    } on SocketException {
      throw 'cannot_connect'.tr() + ' F02';
    } catch (_) {
      throw _;
    }
  }
}
