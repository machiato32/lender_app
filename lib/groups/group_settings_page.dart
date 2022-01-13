import 'dart:convert';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/groups/dialogs/change_group_currency_dialog.dart';
import 'package:csocsort_szamla/groups/dialogs/rename_group_dialog.dart';
import 'package:csocsort_szamla/groups/manage_guests.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../essentials/widgets/error_message.dart';
import 'boost_group.dart';
import 'group_members.dart';
import 'invitation.dart';

class GroupSettings extends StatefulWidget {
  final GlobalKey<State> bannerKey;
  final String scrollTo;
  GroupSettings({this.bannerKey, this.scrollTo});
  @override
  _GroupSettingState createState() => _GroupSettingState();
}

class _GroupSettingState extends State<GroupSettings> {
  Future<bool> _isUserAdmin;
  Future<bool> _hasGuests;
  var guestsKey = GlobalKey();

  Future<bool> _getHasGuests() async {
    try {
      http.Response response = await httpGet(
          uri: generateUri(GetUriKeys.groupHasGuests,
              args: [currentGroupId.toString()]),
          context: context);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      print(decoded);
      return decoded['data'] == 1;
    } catch (_) {
      throw _;
    }
  }

  Future<bool> _getIsUserAdmin() async {
    try {
      http.Response response = await httpGet(
          uri: generateUri(GetUriKeys.groupMember),
          context: context,
          useCache: false);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded['data']['is_admin'] == 1;
    } catch (_) {
      throw _;
    }
  }

  @override
  void initState() {
    _isUserAdmin = null;
    _isUserAdmin = _getIsUserAdmin();
    _hasGuests = null;
    _hasGuests = _getHasGuests();
    WidgetsFlutterBinding.ensureInitialized();
    _hasGuests.whenComplete(() {
      print('asd');
      Future.delayed(Duration(milliseconds: 1000)).then((value) {
        if (widget.scrollTo == 'guests') {
          print('lol');
          print(guestsKey.currentContext);
          Scrollable.ensureVisible(guestsKey.currentContext);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await deleteCache(uri: '/groups');
        setState(() {
          _isUserAdmin = null;
          _isUserAdmin = _getIsUserAdmin();
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: <Widget>[
              FutureBuilder(
                  future: _isUserAdmin,
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Visibility(
                              visible: snapshot.data,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                          'rename_group'.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Center(
                                          child: Text(
                                        'rename_group_explanation'.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                        textAlign: TextAlign.center,
                                      )),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          GradientButton(
                                            child: Icon(
                                              Icons.edit,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                  builder: (context) =>
                                                      RenameGroupDialog(),
                                                  context: context);
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Invitation(isAdmin: snapshot.data),
                            BoostGroup(),
                            Visibility(
                              visible: snapshot.data,
                              child: FutureBuilder(
                                future: _hasGuests,
                                builder: (context, hasGuestsSnapshot) {
                                  if (hasGuestsSnapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      return Column(
                                        key: guestsKey,
                                        children: [
                                          ManageGuests(
                                              hasGuests: hasGuestsSnapshot.data,
                                              bannerKey: widget.bannerKey),
                                        ],
                                      );
                                    } else {
                                      return ErrorMessage(
                                        error: hasGuestsSnapshot.error,
                                        locationOfError: 'has_guests',
                                        callback: () {
                                          _hasGuests = null;
                                          _hasGuests = _getHasGuests();
                                        },
                                      );
                                    }
                                  }
                                  return LinearProgressIndicator(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  );
                                },
                              ),
                            ),
                            Visibility(
                              visible: snapshot.data,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                          'change_group_currency'.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Center(
                                          child: Text(
                                        'change_group_currency_explanation'
                                            .tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                        textAlign: TextAlign.center,
                                      )),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          GradientButton(
                                            child: Icon(
                                              Icons.monetization_on,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                  builder: (context) =>
                                                      ChangeGroupCurrencyDialog(),
                                                  context: context);
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GroupMembers(),
                          ],
                        );
                      } else {
                        return ErrorMessage(
                          error: snapshot.error.toString(),
                          locationOfError: 'is_user_admin',
                          callback: () {
                            setState(() {
                              _isUserAdmin = null;
                              _isUserAdmin = _getIsUserAdmin();
                            });
                          },
                        );
                      }
                    }
                    return LinearProgressIndicator(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
