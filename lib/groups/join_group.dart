import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:csocsort_szamla/http_handler.dart';
import 'package:csocsort_szamla/main.dart';
import 'create_group.dart';
import 'package:csocsort_szamla/user_settings/user_settings_page.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';

class JoinGroup extends StatefulWidget {
  final bool fromAuth;
  final String inviteURL;

  JoinGroup({this.fromAuth = false, this.inviteURL = ''});

  @override
  _JoinGroupState createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
  TextEditingController _tokenController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController(
      text: currentUsername[0].toUpperCase()+currentUsername.substring(1));

  var _formKey = GlobalKey<FormState>();

  Future _logout() async {
    try {
      await clearAllCache();
      await httpPost(context: context, uri: '/logout', body: {});
      currentUserId = null;
      currentGroupId = null;
      currentGroupName = null;
      apiToken = null;
      SharedPreferences.getInstance().then((_prefs) {
        _prefs.remove('current_group_name');
        _prefs.remove('current_group_id');
        _prefs.remove('current_user_id');
        _prefs.remove('api_token');
      });
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

      Map<String, dynamic> response2 = jsonDecode(response.body);
      currentGroupName = response2['data']['group_name'];
      currentGroupId = response2['data']['group_id'];
      SharedPreferences.getInstance().then((_prefs) {
        _prefs.setString('current_group_name', currentGroupName);
        _prefs.setInt('current_group_id', currentGroupId);
      });

      return response.statusCode == 200;
    } catch (_) {
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
    _tokenController.text =
        widget.inviteURL != '' ? widget.inviteURL.split('/').removeLast() : '';
    return WillPopScope(
      onWillPop: () {
        if (currentGroupName != null) {
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
            title: Text(
              'join'.tr(),
              style: TextStyle(letterSpacing: 0.25, fontSize: 24),
            ),
            leading: (currentGroupName != null)
                ? IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage()),
                        (r) => false),
                  )
                : null,
          ),
          drawer: !widget.fromAuth
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
                              (r) => false
                          );
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
                      Row(
                        children: <Widget>[
                          Text(
                            'invitation'.tr(),
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
                                hintText: 'example_nickname'.tr(),
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
                      Center(
                        child: RaisedButton(
                          child: Text('join_group'.tr(),
                              style: Theme.of(context).textTheme.button),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              String token = _tokenController.text;
                              String nickname =
                                  _nicknameController.text[0].toUpperCase() +
                                      _nicknameController.text.substring(1);
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  child: FutureSuccessDialog(
                                    future: _joinGroup(token, nickname),
                                    dataTrueText: 'join_scf',
                                    onDataTrue: () async {
                                      await clearCache();
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MainPage()),
                                          (r) => false);
                                    },
                                  ));
                            }
                          },
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

//              SizedBox(height: 40,),
//              Divider(),
//              SizedBox(height: 40,),
                Visibility(
                  visible: MediaQuery.of(context).viewInsets.bottom == 0,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Center(
                            child: Text(
                          'no_group_yet'.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontSize: 12),
                        )),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                          child: Text('create_group'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(fontSize: 12)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateGroup()));
                          },
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future clearCache() async {
    await deleteCache(uri: '/groups/' + currentGroupId.toString());
    await deleteCache(uri: '/groups');
    await deleteCache(uri: '/user');
    await deleteCache(uri: '/payments?group=' + currentGroupId.toString());
    await deleteCache(uri: '/transactions?group=' + currentGroupId.toString());
  }
}
