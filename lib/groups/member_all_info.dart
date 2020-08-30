import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';
import 'package:csocsort_szamla/person.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';

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


  Future<bool> _changeAdmin(String memberId, bool isAdmin) async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };
      Map<String, dynamic> body = {
        "member_id": memberId,
        "admin": isAdmin
      };

      String bodyEncoded = jsonEncode(body);

      http.Response response = await http.put(APPURL+'/groups/'+currentGroupId.toString()+'/admins', headers: header, body: bodyEncoded);
      if(response.statusCode==204){
        return true;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterPage()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }

  Future<bool> _updateNickname(String nickname, String userToChange) async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };
      Map<String, dynamic> body = {
        "member_id":userToChange,
        "nickname": nickname
      };

      String bodyEncoded = jsonEncode(body);
      http.Response response = await http.put(APPURL+'/groups/'+currentGroupId.toString()+'/members', headers: header, body: bodyEncoded);
      if(response.statusCode==204){
        return true;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterPage()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }
  @override
  void initState() {
    _nicknameFocus.addListener(() {
      if(_nicknameFocus.hasFocus){
        setState(() {

        });
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
                  Icon(Icons.account_circle, color: Theme.of(context).colorScheme.primary),
                  Text(' - '),
                  Flexible(child: Text(widget.member.userName, style: Theme.of(context).textTheme.bodyText1,)),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                children: <Widget>[
                  Icon(Icons.account_box, color: Theme.of(context).colorScheme.primary),
                  Text(' - '),
                  Flexible(child: Text(widget.member.nickname, style: Theme.of(context).textTheme.bodyText1,)),
                ],
              ),
              SizedBox(height: 5,),
              Center(
                child: Visibility(
                    visible: widget.member.isAdmin && !widget.isCurrentUserAdmin,
                    child: Text('Admin', style: Theme.of(context).textTheme.bodyText1, )
                ),
              ),

              SizedBox(height: 10,),
              Visibility(
                visible: widget.isCurrentUserAdmin ,
                child: SwitchListTile(
                  value: widget.member.isAdmin,
                  title: Text('Admin', style: Theme.of(context).textTheme.bodyText1,),
                  activeColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (value){
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        child:
                        FutureSuccessDialog(
                          future: _changeAdmin(widget.member.userName, value),
                          dataTrueText: 'admin_scf',
                          onDataTrue: (){
                            Navigator.pop(context);
                            Navigator.pop(context, 'madeAdmin');
                          },
                        )
                    );
                  },
                )
              ),
              Center(
                child: Visibility(
                  visible: widget.isCurrentUserAdmin || widget.member.userId==currentUser,
                  child: RaisedButton.icon(
                    onPressed: (){
                      showDialog(
                        context: context,
                        child: AlertDialog(
                          title: Text('edit_nickname'.tr(), style: Theme.of(context).textTheme.headline6,),
                          content: Form(
                            key: _nicknameFormKey,
                            child: TextFormField(
                              validator: (value){
                                if(value.isEmpty){
                                  return 'field_empty'.tr();
                                }
                                if(value.length<1){
                                  return 'minimal_length'.tr(args: ['1']);
                                }
                                return null;
                              },
                              focusNode: _nicknameFocus,
                              controller: _nicknameController,
                              decoration: InputDecoration(
                                hintText: widget.member.userName,
                                labelText: 'nickname'.tr(),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
                                  //  when the TextFormField in unfocused
                                ) ,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                ),

                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                              ],
                              style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                              cursorColor: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          actions: [
                            RaisedButton(
                              onPressed: (){
                                if(_nicknameFormKey.currentState.validate()){
                                  Navigator.pop(context);
                                  FocusScope.of(context).unfocus();
                                  String nickname = _nicknameController.text[0].toUpperCase()+_nicknameController.text.substring(1);
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      child:
                                      FutureSuccessDialog(
                                        future: _updateNickname(nickname, widget.member.userName),
                                        onDataTrue: (){
                                          _nicknameController.text='';
                                          Navigator.pop(context);
                                          Navigator.pop(context, 'madeAdmin');
                                        },
                                        dataTrueText: 'nickname_scf',
                                      )
                                  );
                                }

                              },
                              child: Text('yes'.tr(), style: Theme.of(context).textTheme.button,),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            RaisedButton(
                              onPressed: (){
                                FocusScope.of(context).unfocus();
                                Navigator.pop(context);
                              },
                              child: Text('no'.tr(), style: Theme.of(context).textTheme.button,),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        )
                      );
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    label: Text('edit_nickname'.tr(), style: Theme.of(context).textTheme.button,),
                    icon: Icon(Icons.edit, color: Theme.of(context).textTheme.button.color,),
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
        )
    );
  }
}
