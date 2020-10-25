import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';
import 'package:csocsort_szamla/group_objects.dart';
import 'package:csocsort_szamla/http_handler.dart';

class MemberAllInfo extends StatefulWidget {
  final Member member;
  final bool isCurrentUserAdmin;

  MemberAllInfo({@required this.member, @required this.isCurrentUserAdmin});

  @override
  _MemberAllInfoState createState() => _MemberAllInfoState();
}

class _MemberAllInfoState extends State<MemberAllInfo> {
  TextEditingController _nicknameController = TextEditingController();
  var _nicknameFormKey = GlobalKey<FormState>();
  FocusNode _nicknameFocus = FocusNode();

  Future<bool> _changeAdmin(int memberId, bool isAdmin) async {
    try {
      Map<String, dynamic> body = {"member_id": memberId, "admin": isAdmin};

      await httpPut(
          uri: '/groups/' + currentGroupId.toString() + '/admins',
          context: context,
          body: body);
      return true;

    } catch (_) {
      throw _;
    }
  }

  Future<bool> _updateNickname(String nickname, int memberId) async {
    try {
      Map<String, dynamic> body = {
        "member_id": memberId,
        "nickname": nickname
      };
      await httpPut(
          uri: '/groups/' + currentGroupId.toString() + '/members',
          context: context,
          body: body);
      return true;

    } catch (_) {
      throw _;
    }
  }

  @override
  void initState() {
    _nicknameFocus.addListener(() {
      if (_nicknameFocus.hasFocus) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
          Center(
            child: Visibility(
                visible: widget.member.isAdmin && !widget.isCurrentUserAdmin,
                child: Text(
                  'Admin',
                  style: Theme.of(context).textTheme.bodyText1,
                )),
          ),

          SizedBox(
            height: 10,
          ),
          Visibility(
              visible: widget.isCurrentUserAdmin,
              child: SwitchListTile(
                value: widget.member.isAdmin,
                title: Text(
                  'Admin',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                activeColor: Theme.of(context).colorScheme.secondary,
                onChanged: (value) {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      child: FutureSuccessDialog(
                        future: _changeAdmin(widget.member.memberId, value),
                        dataTrueText: 'admin_scf',
                        onDataTrue: () {
                          Navigator.pop(context);
                          Navigator.pop(context, 'madeAdmin');
                        },
                      ));
                },
              )),
          Center(
            child: Visibility(
              visible: widget.isCurrentUserAdmin ||
                  widget.member.memberId == currentUserId,
              child: RaisedButton.icon(
                onPressed: () {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        title: Text(
                          'edit_nickname'.tr(),
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        content: Form(
                          key: _nicknameFormKey,
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
                            focusNode: _nicknameFocus,
                            controller: _nicknameController,
                            decoration: InputDecoration(
                              hintText: widget.member.username
                                      .split('#')[0][0]
                                      .toUpperCase() +
                                  widget.member.username
                                      .split('#')[0]
                                      .substring(1),
                              labelText: 'nickname'.tr(),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 2),
                                //  when the TextFormField in unfocused
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2),
                              ),
                            ),
                            inputFormatters: [
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
                        ),
                        actions: [
                          RaisedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'back'.tr(),
                              style: Theme.of(context).textTheme.button.copyWith(color:Colors.white),
                            ),
                            color: Colors.grey[700],
                          ),
                          RaisedButton(
                            onPressed: () {
                              if (_nicknameFormKey.currentState.validate()) {
                                Navigator.pop(context);
                                FocusScope.of(context).unfocus();
                                String nickname =
                                    _nicknameController.text[0].toUpperCase() +
                                        _nicknameController.text.substring(1);
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    child: FutureSuccessDialog(
                                      future: _updateNickname(
                                          nickname, widget.member.memberId),
                                      onDataTrue: () {
                                        _nicknameController.text = '';
                                        Navigator.pop(context);
                                        Navigator.pop(context, 'madeAdmin');
                                      },
                                      dataTrueText: 'nickname_scf',
                                    ));
                              }
                            },
                            child: Text(
                              'modify'.tr(),
                              style: Theme.of(context).textTheme.button,
                            ),
                            color: Theme.of(context).colorScheme.secondary,
                          ),

                        ],
                      ));
                },
                color: Theme.of(context).colorScheme.secondary,
                label: Text(
                  'edit_nickname'.tr(),
                  style: Theme.of(context).textTheme.button,
                ),
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).textTheme.button.color,
                ),
              ),
            ),
          ),
//              Visibility(
//                visible: _nicknameFocus.hasFocus,
//                child: SizedBox(
//                  height: MediaQuery.of(context).viewInsets.bottom,
//                ),
//              )
        ],
      ),
    ));
  }
}
