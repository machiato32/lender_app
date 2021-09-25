import 'dart:convert';

import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/ad_management.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/main.dart';
import 'package:csocsort_szamla/user_settings/user_settings_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import '../essentials/app_theme.dart';
import 'create_group.dart';

class JoinGroup extends StatefulWidget {
  final bool fromAuth;
  final String inviteURL;

  JoinGroup({this.fromAuth = false, this.inviteURL});

  @override
  _JoinGroupState createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
  TextEditingController _tokenController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController(
      text: currentUsername[0].toUpperCase() + currentUsername.substring(1));

  var _formKey = GlobalKey<FormState>();

  Future _logout() async {
    try {
      await clearAllCache();
      await httpPost(context: context, uri: '/logout', body: {});
      deleteApiToken();
      deleteUserId();
      deleteGroupId();
      deleteGroupName();
    } catch (_) {
      throw _;
    }
  }

  Future<bool> _joinGroup(String token, String nickname) async {
    try {
      Map<String, dynamic> body = {
        'invitation_token': token,
        'nickname': nickname
      };
      http.Response response =
          await httpPost(uri: '/join', context: context, body: body);

      if (response.body != "") {
        Map<String, dynamic> decoded = jsonDecode(response.body);
        saveGroupName(decoded['data']['group_name']);
        saveGroupId(decoded['data']['group_id']);
        saveGroupCurrency(decoded['data']['currency']);
        if (usersGroups == null) {
          usersGroupIds = List<int>();
          usersGroups = List<String>();
        }
        usersGroupIds.add(decoded['data']['group_id']);
        usersGroups.add(decoded['data']['group_name']);
        saveUsersGroupIds();
        saveUsersGroups();
        Future.delayed(delayTime()).then((value) => _onJoinGroup());
      } else {
        return false;
      }

      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onJoinGroup() async {
    await clearAllCache();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => MainPage()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_tokenController.text == '') {
      _tokenController.text = widget.inviteURL != null
          ? widget.inviteURL.split('/').removeLast()
          : '';
    }
    return WillPopScope(
      onWillPop: () {
        if (currentGroupName != null && currentGroupId != null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
              (r) => false);
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Form(
        key: _formKey,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: AppTheme.gradientFromTheme(Theme.of(context))),
            ),
            title: Text(
              'join'.tr(),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  letterSpacing: 0.25,
                  fontSize: 24),
            ),
            leading: (currentGroupName != null)
                ? IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onSecondary),
                    onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage()),
                        (r) => false),
                  )
                : null,
          ),
          drawer: !(widget.fromAuth || currentGroupName != null)
              ? null
              : Drawer(
                  elevation: 16,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            DrawerHeader(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'LENDER',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(letterSpacing: 2.5),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    currentUsername,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: Theme.of(context).textTheme.bodyText1.color,
                        ),
                        title: Text(
                          'settings'.tr(),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Settings()));
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.exit_to_app,
                          color: Theme.of(context).textTheme.bodyText1.color,
                        ),
                        title: Text(
                          'logout'.tr(),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        onTap: () {
                          _logout();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginOrRegisterPage()),
                              (r) => false);
                        },
                      ),
                    ],
                  ),
                ),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(15),
                    children: <Widget>[
                      Visibility(
                        visible: widget.inviteURL == null,
                        child: Column(
                          children: [
                            Text(
                              'scan_code'.tr(),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GradientButton(
                                  child: Icon(Icons.qr_code_scanner,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                  onPressed: () async {
                                    if (await Permission.camera
                                            .request()
                                            .isGranted &&
                                        await Permission.storage
                                            .request()
                                            .isGranted) {
                                      String cameraScanResult =
                                          await scanner.scan();
                                      setState(() {
                                        _tokenController.text =
                                            cameraScanResult;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'paste_code'.tr(),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Visibility(
                            visible: widget.inviteURL != null,
                            child: Row(
                              children: [
                                Text(
                                  'invitation'.tr(),
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'field_empty'.tr();
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                  //  when the TextFormField in unfocused
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2),
                                ),
                              ),
                              controller: _tokenController,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color),
                              cursorColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'nickname_in_group'.tr(),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Flexible(
                            child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'field_empty'.tr();
                                }
                                if (value.length < 1) {
                                  return 'minimal_length'.tr(args: ['1']);
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'example_name'.tr(),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                  //  when the TextFormField in unfocused
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2),
                                ),
                              ),
                              controller: _nicknameController,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color),
                              cursorColor:
                                  Theme.of(context).colorScheme.secondary,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GradientButton(
                            child: Text('join_group'.tr(),
                                style: Theme.of(context).textTheme.button),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                String token = _tokenController.text;
                                String nickname =
                                    _nicknameController.text[0].toUpperCase() +
                                        _nicknameController.text.substring(1);
                                showDialog(
                                    builder: (context) => FutureSuccessDialog(
                                          future: _joinGroup(token, nickname),
                                          dataTrueText: 'join_scf',
                                          onDataTrue: () {
                                            _onJoinGroup();
                                          },
                                          dataFalse: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                  child: Text(
                                                'approve_still_needed'.tr(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .copyWith(
                                                        color: Colors.white),
                                                textAlign: TextAlign.center,
                                              )),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  GradientButton(
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.check,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSecondary),
                                                        SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text(
                                                          'okay'.tr(),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .button,
                                                        ),
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    useShadow: false,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                    barrierDismissible: false,
                                    context: context);
                              }
                            },
                            // color: Theme.of(context).colorScheme.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

//              SizedBox(height: 40,),
//              Divider(),
//              SizedBox(height: 40,),
                Visibility(
                  visible: MediaQuery.of(context).viewInsets.bottom == 0,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Center(
                                child: Text(
                              'no_group_yet'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 15),
                            )),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GradientButton(
                                  child: Text('create_group'.tr(),
                                      style:
                                          Theme.of(context).textTheme.button),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CreateGroup()));
                                  },
                                  // color: Theme.of(context).colorScheme.secondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      adUnitForSite('join_group'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
