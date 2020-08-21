import 'package:flutter/material.dart';
import 'package:csocsort_szamla/person.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:csocsort_szamla/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';

class GroupMembers extends StatefulWidget {
  @override
  _GroupMembersState createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {

  Future<List<Member>> _members;

  Future<List<Member>> _getMembers() async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.get(APPURL+'/groups/'+currentGroupId.toString(), headers: header);
      if(response.statusCode==200){
        Map<String, dynamic> decoded = jsonDecode(response.body);
        List<Member> members =[];
        for(var member in decoded['data']['members']){
          members.add(Member.fromJson(member));
        }
        return members;
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
    _members=null;
    _members=_getMembers();
    super.initState();
  }

  void callback(){
    setState(() {
      _members=null;
      _members=_getMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Text('members'.tr(), style: Theme.of(context).textTheme.headline6,),
            SizedBox(height: 40,),
            FutureBuilder(
              future: _members,
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.done){
                  if(snapshot.hasData){
                    return Column(
                      children: _generateMembers(snapshot.data)
                    );
                  }else{
                    return InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(snapshot.error.toString()),
                        ),
                        onTap: (){
                          setState(() {
                            _members=null;
                            _members=_getMembers();
                          });
                        }
                    );
                  }
                }
                return Center(child: CircularProgressIndicator(),);
              },
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _generateMembers(List<Member> members){
    Member currentMember = members.firstWhere((member) => member.userId==currentUser);
    return members.map((member){
      return MemberEntry(member: member, isCurrentUserAdmin: currentMember.isAdmin, callback: this.callback,);
    }).toList();
  }
}

class MemberEntry extends StatefulWidget {
  final Function callback;
  final Member member;
  final bool isCurrentUserAdmin;
  MemberEntry({this.member, this.isCurrentUserAdmin, this.callback});
  @override
  _MemberEntryState createState() => _MemberEntryState();


}

class _MemberEntryState extends State<MemberEntry> {
  TextStyle style;
  BoxDecoration boxDecoration;
  Color nicknameColor, iconColor;

  Future<bool> _makeAdmin(String memberId) async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };
      Map<String, dynamic> body = {
        "member_id": memberId,
        "admin": true
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

  @override
  Widget build(BuildContext context) {

    if(widget.member.userId==currentUser){
      style=(Theme.of(context).brightness==Brightness.dark)?
      Theme.of(context).textTheme.bodyText1:
      Theme.of(context).textTheme.button;
      nicknameColor=(Theme.of(context).brightness==Brightness.dark)?
      Theme.of(context).colorScheme.surface:
      Theme.of(context).textTheme.button.color;
      iconColor=style.color;
      boxDecoration=BoxDecoration(
        color: (Theme.of(context).brightness==Brightness.dark)?Colors.transparent:Theme.of(context).colorScheme.secondary,
        border: Border.all(color: (Theme.of(context).brightness==Brightness.dark)?Theme.of(context).colorScheme.secondary:Colors.transparent, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      );
    }else{
      iconColor=Theme.of(context).textTheme.bodyText1.color;
      style=Theme.of(context).textTheme.bodyText1;
      nicknameColor=Theme.of(context).colorScheme.surface;
      boxDecoration=BoxDecoration();
    }
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      decoration: boxDecoration,
      margin: EdgeInsets.only(bottom: 4),
      child: Material(
        type: MaterialType.transparency,

        child: InkWell(
          onTap: () {
            showModalBottomSheetCustom(
                context: context,
                backgroundColor: Theme.of(context).cardTheme.color,
                builder: (context)=>SingleChildScrollView(
                    child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Icons.account_circle, color: Theme.of(context).colorScheme.primary),
                                  Text(' - '),
                                  Flexible(child: Text(widget.member.userId, style: Theme.of(context).textTheme.bodyText1,)),
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
                              Visibility(
                                visible: widget.member.isAdmin,
                                child: Text('Admin', style: Theme.of(context).textTheme.bodyText1, )
                              ),

                              SizedBox(height: 10,),
                              Visibility(
                                visible: widget.isCurrentUserAdmin && !widget.member.isAdmin,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    FlatButton(
                                        onPressed: (){
                                          showDialog(
                                              context: context,
                                              child: Dialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                backgroundColor: Colors.transparent,
                                                elevation: 0,
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text('want_make_admin'.tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),),
                                                      SizedBox(height: 15,),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: <Widget>[
                                                          RaisedButton(
                                                              color: Theme.of(context).colorScheme.secondary,
                                                              onPressed: () async {
                                                                Navigator.pop(context);
                                                                showDialog(
                                                                    barrierDismissible: false,
                                                                    context: context,
                                                                    child:
                                                                    FutureSuccessDialog(
                                                                      future: _makeAdmin(widget.member.userId),
                                                                      dataTrueText: 'admin_scf',
                                                                      onDataTrue: (){
                                                                        Navigator.pop(context);
                                                                        Navigator.pop(context, 'madeAdmin');
                                                                      },
                                                                    )
                                                                );
                                                              },
                                                              child: Text('yes'.tr(), style: Theme.of(context).textTheme.button)
                                                          ),
                                                          RaisedButton(
                                                              color: Theme.of(context).colorScheme.secondary,
                                                              onPressed: (){ Navigator.pop(context);},
                                                              child: Text('no'.tr(), style: Theme.of(context).textTheme.button)
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                          );
                                        },
                                        color: Theme.of(context).colorScheme.secondary,
                                        child: Text('make_admin'.tr(), style: Theme.of(context).textTheme.button,)
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                    )
                )
            ).then((val){
              if(val=='madeAdmin')
                widget.callback();
            });
          },
          borderRadius: BorderRadius.circular(4.0),

          child: Padding(

            padding: EdgeInsets.all(15),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Flexible(
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.account_box, color: iconColor,),
                                    SizedBox(width: 20,),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Flexible(child: Text(widget.member.userId, style: style.copyWith(fontSize: 22), overflow: TextOverflow.ellipsis,)),
                                          Flexible(child: Text(widget.member.nickname, style: TextStyle(color: nicknameColor, fontSize: 15), overflow: TextOverflow.ellipsis,))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Visibility(
                                visible: widget.member.isAdmin,
                                child: Text('Admin', style: style,)
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}

