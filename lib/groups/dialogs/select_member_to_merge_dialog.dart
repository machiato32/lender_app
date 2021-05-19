import 'dart:convert';
import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:csocsort_szamla/essentials/widgets/confirm_choice_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/error_message.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:flutter/material.dart';
import 'package:csocsort_szamla/essentials/group_objects.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/main.dart';

class MemberToMergeDialog extends StatefulWidget {
  @override
  _MemberToMergeDialogState createState() => _MemberToMergeDialogState();
}

class _MemberToMergeDialogState extends State<MemberToMergeDialog> {
  Future<List<Member>> _members;
  Member _dropdownValue;

  Future<bool> _mergeGuest(int memberId) async {
    Map<String, dynamic> body = {
      'member_id':memberId,
      'guest_id':guestUserId
    };
    await httpPost(context: context, uri: '/groups/'+currentGroupId.toString()+'/merge_guest', body: body);
    Future.delayed(delayTime()).then((value) => _onMergeGuest());
    return true;
  }
  void _onMergeGuest(){
    clearGroupCache();
    deleteCache(uri: generateUri(GetUriKeys.userBalanceSum));
    deleteGuestApiToken();
    deleteGuestGroupId();
    deleteGuestNickname();
    deleteGuestUserId();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
            (r) => false);
  }
  Future<List<Member>> _getMembers() async {
    try {

      http.Response response = await httpGet(
          uri: generateUri(GetUriKeys.groupCurrent),
          context: context,
          useCache: false
      );
      Map<String, dynamic> decoded = jsonDecode(response.body);
      List<Member> members = [];
      print(decoded['data']['members']);
      for (var member in decoded['data']['members']) {
        if(member['is_guest']!=1){
          members.add(
              Member(
                apiToken: member['api_token'],
                nickname: member['nickname'],
                memberId: member['user_id']
              )
          );
        }
      }
      return members;

    } catch (_) {
      throw _;
    }
  }

  @override
  void initState() {
    super.initState();
    _members=null;
    _members=_getMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(

      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text('merge_guest'.tr(), style: Theme.of(context).textTheme.headline6,),
            ),
            FutureBuilder(
              future: _members,
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.done){
                  if(snapshot.hasData){
                    return DropdownButton(
                      style: Theme.of(context).textTheme.subtitle2,
                      hint: Text('select_member'.tr()),
                      value: _dropdownValue,
                      onChanged: (value){
                        setState(() {
                          _dropdownValue=value;
                        });
                      },
                      items: (snapshot.data as List<Member>).map((member){
                        return DropdownMenuItem(
                          value: member,
                          child: Text(member.nickname),
                        );
                      }).toList(),
                    );
                  }
                  return ErrorMessage(
                    callback: (){
                      _members=null;
                      _members=_getMembers();
                    },
                    error: snapshot.error,
                    locationOfError: 'merge_guest',
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  child: Icon(Icons.done, color: Theme.of(context).colorScheme.onSecondary,),
                  onPressed: (){
                    showDialog(
                      context: context,
                      child: ConfirmChoiceDialog(
                        choice: 'sure_merge_guest',
                      )
                    ).then((value){
                      if(value??false==true){
                        print(_dropdownValue.memberId);
                        showDialog(
                          context: context,
                          child: FutureSuccessDialog(
                            future: _mergeGuest(_dropdownValue.memberId),
                            dataTrueText: 'merge_scf',
                            onDataTrue: (){
                              _onMergeGuest();
                            },
                          )
                        );
                      }
                    });
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
