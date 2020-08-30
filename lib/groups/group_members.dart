import 'package:flutter/material.dart';
import 'package:csocsort_szamla/person.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:csocsort_szamla/bottom_sheet_custom.dart';
import 'member_all_info.dart';

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
        borderRadius: BorderRadius.circular(15),
      );
    }else{
      iconColor=Theme.of(context).textTheme.bodyText1.color;
      style=Theme.of(context).textTheme.bodyText1;
      nicknameColor=Theme.of(context).colorScheme.surface;
      boxDecoration=BoxDecoration();
    }
    return Container(
      height: 70,
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
                    child: MemberAllInfo(member: widget.member, isCurrentUserAdmin: widget.isCurrentUserAdmin,),
                )
            ).then((val){
              if(val=='madeAdmin')
                widget.callback();
            });
          },
          borderRadius: BorderRadius.circular(4.0),

          child: Padding(

            padding: EdgeInsets.all(8),
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
                                          Flexible(child: Text(widget.member.userName, style: style.copyWith(fontSize: 22), overflow: TextOverflow.ellipsis,)),
                                          Flexible(child: Text(widget.member.nickname, style: TextStyle(color: nicknameColor, fontSize: 15), overflow: TextOverflow.ellipsis,))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Center(
                                child: Visibility(
                                  visible: widget.member.isAdmin,
                                  child: Text('Admin', style: style,)
                                ),
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

