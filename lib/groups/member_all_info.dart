import 'dart:convert';

import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/groups/change_nickname_dialog.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'confirm_leave_dialog.dart';
import 'join_group.dart';

class MemberAllInfo extends StatefulWidget {
  final Member member;
  final bool isCurrentUserAdmin;

  MemberAllInfo({@required this.member, @required this.isCurrentUserAdmin});

  @override
  _MemberAllInfoState createState() => _MemberAllInfoState();
}

class _MemberAllInfoState extends State<MemberAllInfo> {
  FocusNode _nicknameFocus = FocusNode();

  Future<bool> _changeAdmin(int memberId, bool isAdmin) async {
    try {
      Map<String, dynamic> body = {"member_id": memberId, "admin": isAdmin};

      await httpPut(
          uri: '/groups/' + currentGroupId.toString() + '/admins',
          context: context,
          body: body
      );
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
              Visibility(
                visible: widget.isCurrentUserAdmin ||
                    widget.member.memberId == currentUserId,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GradientButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            child: ChangeNicknameDialog(username: widget.member.username, memberId: widget.member.memberId,)
                        ).then((value) {if(value!=null && value=='madeAdmin') Navigator.pop(context, 'madeAdmin');});
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Theme.of(context).textTheme.button.color,
                          ),
                          SizedBox(width: 3,),
                          Text(
                            'edit_nickname'.tr(),
                            style: Theme.of(context).textTheme.button,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: widget.isCurrentUserAdmin && widget.member.memberId!=currentUserId,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GradientButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          child: ConfirmLeaveDialog(
                            title: 'kick_member',
                            choice: 'really_kick',
                          )
                        ).then((value){
                          if(value!=null && value){
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                child: FutureSuccessDialog(
                                  future: _removeMember(widget.member.memberId),
                                  dataTrueText: 'kick_member_scf',
                                  onDataTrue: (){
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MainPage()),
                                            (r) => false);
                                  },
                                )
                            );
                          }
                        });

                      },
                      child:Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Theme.of(context).textTheme.button.color,
                          ),
                          SizedBox(width: 3,),
                          Text(
                            'kick_member'.tr(),
                            style: Theme.of(context).textTheme.button,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: widget.member.memberId==currentUserId,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GradientButton(
                      onPressed: () {
                        if(widget.member.balance<0){
                          FlutterToast ft = FlutterToast(context);
                          ft.showToast(
                              child: errorToast('balance_at_least_0', context),
                              toastDuration: Duration(seconds: 2),
                              gravity: ToastGravity.BOTTOM);
                          return;
                        }else{
                          showDialog(
                            context: context,
                            child: ConfirmLeaveDialog(
                              title: 'leave_group',
                              choice: 'really_leave',
                            )
                          ).then((value){
                            if(value!=null && value){
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  child: FutureSuccessDialog(
                                    future: _removeMember(null),
                                    dataTrueText: 'leave_scf',
                                    onDataTrue: () async {
                                      await clearAllCache();
                                      if(currentGroupId!=null){
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MainPage()
                                            ),
                                            (r) => false
                                        );
                                      }else{
                                        usersGroupIds.remove(currentGroupId);
                                        usersGroups.remove(currentGroupName);
                                        SharedPreferences.getInstance().then((prefs) {
                                          prefs.setStringList('users_groups', usersGroups);
                                          prefs.setStringList('users_group_ids', usersGroupIds.map<String>((e) => e.toString()).toList());
                                        });
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => JoinGroup(fromAuth: true,)
                                            ),
                                            (r) => false
                                        );
                                      }
                                    },
                                  )
                              );
                            }
                          });

                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Theme.of(context).textTheme.button.color,
                          ),
                          SizedBox(width: 3,),
                          Text(
                            'leave_group'.tr(),
                            style: Theme.of(context).textTheme.button,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Future<bool> _removeMember(int memberId) async {
    Map<String, dynamic> body ={
      "member_id":memberId??currentUserId
    };
    clearAllCache();
    http.Response response = await httpPost(context: context, uri: '/groups/'+currentGroupId.toString()+'/members/delete', body: body);
    if(memberId==null){
      Map<String, dynamic> decoded = jsonDecode(response.body);
      if(decoded!=null){
        saveGroupName(decoded['data']['group_name']);
        saveGroupId(decoded['data']['group_id']);
        saveGroupCurrency(decoded['data']['currency']);
      }else{
        deleteGroupCurrency();
        deleteGroupId();
        deleteGroupName();
      }
    }

    return true;
  }
}
