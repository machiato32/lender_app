import 'dart:convert';

import 'package:csocsort_szamla/essentials/app_theme.dart';
import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/essentials/widgets/error_message.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import 'dialogs/share_group_dialog.dart';

class Invitation extends StatefulWidget {
  final bool isAdmin;
  Invitation({this.isAdmin});
  @override
  _InvitationState createState() => _InvitationState();
}

class _InvitationState extends State<Invitation> {
  Future<String> _invitation;
  Future<List<Member>> _unapproved;
  bool _needsApproval;

  Future<String> _getInvitation() async {
    try {
      http.Response response = await httpGet(
          uri: generateUri(GetUriKeys.groupCurrent),
          context: context,
          useCache: false);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      _needsApproval = decoded['data']['admin_approval'] == 1;
      return decoded['data']['invitation'];
    } catch (_) {
      throw _;
    }
  }

  Future<List<Member>> _getUnapprovedMembers() async {
    try {
      http.Response response = await httpGet(
          uri: generateUri(GetUriKeys.groupUnapprovedMembers),
          context: context,
          useCache: false);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      List<Member> members = List<Member>();
      for (Map<String, dynamic> member in decoded['data']) {
        members.add(Member.fromJson(member));
      }
      return members;
    } catch (_) {
      throw _;
    }
  }

  Future<bool> _updateNeedsApproval() async {
    try {
      Map<String, dynamic> body = {'admin_approval': _needsApproval ? 1 : 0};
      await httpPut(
          context: context,
          uri: '/groups/' + currentGroupId.toString(),
          body: body);
      Future.delayed(delayTime()).then((value) => _onUpdateNeedsApproval());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onUpdateNeedsApproval() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    _unapproved = null;
    _unapproved = _getUnapprovedMembers();
    _invitation = null;
    _invitation = _getInvitation();
    super.initState();
  }

  void callback() {
    setState(() {
      _unapproved = null;
      _unapproved = _getUnapprovedMembers();
      _invitation = null;
      _invitation = _getInvitation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GradientButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ShareGroupDialog(
                                          inviteCode: snapshot.data,
                                        );
                                      });
                                },
                                child: Icon(
                                  Icons.share,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: widget.isAdmin,
                          child: FutureBuilder(
                            future: _unapproved,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 7,
                                      ),
                                      _needsApproval
                                          ? Column(
                                              children: [
                                                Text(
                                                  'approve_members'.tr(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6,
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  'approve_members_explanation'
                                                      .tr(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                Text(
                                                  'group_needs_approval'.tr(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6,
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  'group_needs_approval_explanation'
                                                      .tr(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Visibility(
                                        visible: snapshot.data.length != 0,
                                        child: Column(
                                            children: _generateMembers(
                                                snapshot.data)),
                                      ),
                                      SwitchListTile(
                                        value: _needsApproval,
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        onChanged: (value) {
                                          setState(() {
                                            _needsApproval = value;
                                          });
                                          showDialog(
                                              builder: (context) =>
                                                  FutureSuccessDialog(
                                                    future:
                                                        _updateNeedsApproval(),
                                                    onDataTrue: () {
                                                      _onUpdateNeedsApproval();
                                                    },
                                                    onDataFalse: () {
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        _needsApproval =
                                                            !_needsApproval;
                                                      });
                                                    },
                                                    onNoData: () {
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        _needsApproval =
                                                            !_needsApproval;
                                                      });
                                                    },
                                                  ),
                                              context: context,
                                              barrierDismissible: false);
                                        },
                                        title: Text(
                                          'needs_approval'.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2,
                                        ),
                                        dense: true,
                                      ),
                                    ],
                                  );
                                } else {
                                  return ErrorMessage(
                                    error: snapshot.error.toString(),
                                    locationOfError: 'approve_members',
                                    callback: () {
                                      setState(() {
                                        _unapproved = null;
                                        _unapproved = _getUnapprovedMembers();
                                      });
                                    },
                                  );
                                }
                              }
                              return Container();
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return ErrorMessage(
                      error: snapshot.error.toString(),
                      locationOfError: 'invitation',
                      callback: () {
                        setState(() {
                          _invitation = null;
                          _invitation = _getInvitation();
                        });
                      },
                    );
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _generateMembers(List<Member> members) {
    return members.map((member) {
      return Container(
        height: 65,
        margin: EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          gradient:
              AppTheme.gradientFromTheme(Theme.of(context), useSecondary: true),
          borderRadius: BorderRadius.circular(15),
          boxShadow: (Theme.of(context).brightness == Brightness.light)
              ? [
                  BoxShadow(
                    color: Colors.grey[500],
                    offset: Offset(0.0, 1.5),
                    blurRadius: 1.5,
                  )
                ]
              : [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              showModalBottomSheetCustom(
                  context: context,
                  backgroundColor: Theme.of(context).cardTheme.color,
                  builder: (context) => SingleChildScrollView(
                        child: ApproveMember(
                          member: member,
                        ),
                      )).then((value) {
                if (value ?? false) callback();
              });
            },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Flexible(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.account_box_rounded,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                  child: Text(
                                member.username,
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              )),
                              Flexible(
                                  child: Text(
                                member.nickname,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .button
                                        .color,
                                    fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class ApproveMember extends StatefulWidget {
  final Member member;
  ApproveMember({this.member});
  @override
  _ApproveMemberState createState() => _ApproveMemberState();
}

class _ApproveMemberState extends State<ApproveMember> {
  Future<bool> _postApproveMember(int memberId, bool approve) async {
    try {
      Map<String, dynamic> body = {'member_id': memberId, 'approve': approve};
      await httpPost(
          context: context,
          uri: '/groups/' +
              currentGroupId.toString() +
              '/members/approve_or_deny',
          body: body);
      Future.delayed(delayTime()).then((value) => _onPostApproveMember());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onPostApproveMember() {
    clearGroupCache();
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Icon(Icons.account_circle,
                  color: Theme.of(context).colorScheme.primary),
              Text(' - '),
              Flexible(
                  child: Text(
                widget.member.username,
                style: Theme.of(context).textTheme.bodyText1,
              )),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: <Widget>[
              Icon(Icons.account_box,
                  color: Theme.of(context).colorScheme.primary),
              Text(' - '),
              Flexible(
                  child: Text(
                widget.member.nickname,
                style: Theme.of(context).textTheme.bodyText1,
              )),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientButton(
                onPressed: () {
                  showDialog(
                      builder: (context) => FutureSuccessDialog(
                            future: _postApproveMember(
                                widget.member.memberId, true),
                          ),
                      context: context);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      'approve'.tr(),
                      style: Theme.of(context).textTheme.button,
                    ),
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientButton(
                onPressed: () {
                  showDialog(
                      builder: (context) => FutureSuccessDialog(
                            future: _postApproveMember(
                                widget.member.memberId, false),
                          ),
                      context: context);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.clear,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      'disapprove'.tr(),
                      style: Theme.of(context).textTheme.button,
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
