import 'package:csocsort_szamla/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/http_handler.dart';
import 'group_members.dart';
import 'package:csocsort_szamla/main.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';

class GroupSettings extends StatefulWidget {
  @override
  _GroupSettingState createState() => _GroupSettingState();
}

class _GroupSettingState extends State<GroupSettings> {
  Future<String> _invitation;
  Future<bool> _isUserAdmin;

  TextEditingController _groupNameController = TextEditingController();

  var _groupNameFormKey = GlobalKey<FormState>();

  Future<String> _getInvitation() async {
    try {
      http.Response response = await httpGet(
          uri: '/groups/' + currentGroupId.toString(),
          context: context);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded['data']['invitation'];

    } catch (_) {
      throw _;
    }
  }

  Future<bool> _updateGroupName(String groupName) async {
    try {
      Map<String, dynamic> body = {"name": groupName};

      http.Response response = await httpPut(
          uri: '/groups/' + currentGroupId.toString(),
          context: context,
          body: body);

      Map<String, dynamic> decoded = jsonDecode(response.body);
      currentGroupName = decoded['group_name'];
      currentGroupId = decoded['group_id'];
      return true;

    } catch (_) {
      throw _;
    }
  }

  Future<bool> _getIsUserAdmin() async {
    try {
      http.Response response = await httpGet(
          uri: '/groups/' + currentGroupId.toString() + '/member',
          context: context, useCache: false);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded['data']['is_admin'] == 1;
    } catch (_) {
      throw _;
    }
  }

  @override
  void initState() {
    _invitation = null;
    _invitation = _getInvitation();
    _isUserAdmin = null;
    _isUserAdmin = _getIsUserAdmin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await deleteCache(uri: '/groups');
        setState(() {
          _invitation = null;
          _invitation = _getInvitation();
          _isUserAdmin = null;
          _isUserAdmin = _getIsUserAdmin();
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          children: <Widget>[
            FutureBuilder(
                future: _isUserAdmin,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Visibility(
                            visible: snapshot.data,
                            child: Form(
                              key: _groupNameFormKey,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'rename_group'.tr(),
                                        style:
                                            Theme.of(context).textTheme.headline6,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Center(
                                          child: Text(
                                        'rename_group_explanation'.tr(),
                                        style:
                                            Theme.of(context).textTheme.subtitle2,
                                        textAlign: TextAlign.center,
                                      )),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'field_empty'.tr();
                                            }
                                            if (value.length < 1) {
                                              return 'minimal_length'
                                                  .tr(args: ['1']);
                                            }
                                            return null;
                                          },
                                          controller: _groupNameController,
                                          decoration: InputDecoration(
                                            labelText: 'new_name'.tr(),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  width: 2),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  width: 2),
                                            ),
                                          ),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(20),
                                          ],
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .color),
                                          cursorColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          GradientButton(
                                            onPressed: () {
                                              if (_groupNameFormKey.currentState
                                                  .validate()) {
                                                FocusScope.of(context).unfocus();
                                                String _groupName =
                                                    _groupNameController.text;
                                                showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    child: FutureSuccessDialog(
                                                      future: _updateGroupName(
                                                          _groupName),
                                                      dataTrueText: 'nickname_scf',
                                                      onDataTrue: () {
                                                        Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    MainPage()),
                                                            (r) => false);
                                                        _groupNameController.text =
                                                            '';
                                                      },
                                                    ));
                                              }
                                            },
                                            child: Icon(
                                              Icons.send,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    'invitation'.tr(),
                                    style: Theme.of(context).textTheme.headline6,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                      child: Text(
                                    'invitation_explanation'.tr(),
                                    style: Theme.of(context).textTheme.subtitle2,
                                    textAlign: TextAlign.center,
                                  )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  FutureBuilder(
                                    future: _invitation,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasData) {
                                          return Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                GradientButton(
                                                  onPressed: () {
                                                    Share.share(
                                                        'http://www.lenderapp.net/join/' +
                                                            snapshot.data,
                                                        subject:
                                                            'invitation_to_lender'
                                                                .tr());
                                                  },
                                                  child: Icon(
                                                    Icons.share,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return InkWell(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(32.0),
                                                child: Text(
                                                    snapshot.error.toString()),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _invitation = null;
                                                  _invitation = _getInvitation();
                                                });
                                              });
                                        }
                                      }
                                      return Center(
                                          child: CircularProgressIndicator());
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GroupMembers(),
                        ],
                      );
                    } else {
                      return InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(snapshot.error.toString()),
                          ),
                          onTap: () {
                            setState(() {
                              _isUserAdmin = null;
                              _isUserAdmin = _getIsUserAdmin();
                            });
                          });
                    }
                  }
                  return LinearProgressIndicator();
                }),
          ],
        ),
      ),
    );
  }
}
