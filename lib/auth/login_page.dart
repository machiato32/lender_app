import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:csocsort_szamla/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csocsort_szamla/main.dart';
import 'package:csocsort_szamla/person.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginRoute extends StatefulWidget {
  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _userNumController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('login'.tr())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 20,),
                Flexible(
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'example_name'.tr(),
                      labelText: 'name'.tr(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,
                    ),
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp('[a-z0-9]')),
                      LengthLimitingTextInputFormatter(15),
                    ],
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(width: 5,),
                Column(
                  children: <Widget>[
                    SizedBox(height: 15,),
                    Text('#', style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 30),),
                  ],
                ),
                SizedBox(width: 5,),
                Flexible(
                  child: TextField(
                    controller: _userNumController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'id'.tr(),
                      hintText: '1234',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
                        //  when the TextFormField in unfocused
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,

                    ),
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp('[0-9]')),
                      LengthLimitingTextInputFormatter(4),
                    ],
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(width: 20,),
              ],
            ),
            SizedBox(height: 30,),
            Padding(
              padding: EdgeInsets.only(right: 20, left: 20),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'password'.tr(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
                  ) ,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ) ,

                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                cursorColor: Theme.of(context).colorScheme.secondary,
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp('[0-9]')),
                ],
              ),
            ),
            SizedBox(height: 40,)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          String username = _usernameController.text.toLowerCase()+'#'+_userNumController.text.toLowerCase();
          String password = _passwordController.text.toLowerCase();
          showDialog(
              barrierDismissible: false,
              context: context,
              child: Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: FutureBuilder(
                  future: _login(username, password),
                  builder: (context, snapshot){
                    if(snapshot.connectionState==ConnectionState.done){
                      if(snapshot.hasData){
                        if(snapshot.data){
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(child: Text("login_scf".tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
                              SizedBox(height: 15,),
                              FlatButton.icon(
                                icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                                onPressed: (){
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainPage()), (r)=>false);
                                },
                                label: Text('okay'.tr(), style: Theme.of(context).textTheme.button,),
                                color: Theme.of(context).colorScheme.secondary,
                              )
                            ],
                          );
                        }else{
                          return Container(
                            color: Colors.transparent ,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(child: Text("login_scf".tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
                                SizedBox(height: 15,),
                                FlatButton.icon(
                                  icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                                  onPressed: (){
                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => JoinGroup(fromAuth: true,)), (r)=>false);
                                  },
                                  label: Text('okay'.tr(), style: Theme.of(context).textTheme.button,),
                                  color: Theme.of(context).colorScheme.secondary,
                                )
                              ],
                            ),
                          );
                        }
                      }else{
                        return Container(
                          color: Colors.transparent ,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(child: Text(snapshot.error.toString(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
                              SizedBox(height: 15,),
                              FlatButton.icon(
                                icon: Icon(Icons.clear, color: Colors.white,),
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                label: Text('back'.tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),),
                                color: Colors.red,
                              )
                            ],
                          ),
                        );
                      }
                    }
                    return Center(child: CircularProgressIndicator());

                  },
                ),
              )
          );
        },
        child: Icon(Icons.send),
      ),
    );
  }

  Future<bool> _selectGroup(int lastActiveGroup) async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.get(APPURL+'/groups', headers: header);
      if(response.statusCode==200){
        Map<String, dynamic> decoded = jsonDecode(response.body);
        List<Group> groups=[];
        for(var group in decoded['data']){
          groups.add(Group(groupName: group['group_name'], groupId: group['group_id']));
        }
        if(groups.length>0){
          if(groups.where((group) => group.groupId==lastActiveGroup).toList().length!=0){
            currentGroupName=groups.firstWhere((group) => group.groupId==lastActiveGroup).groupName;
            currentGroupId=lastActiveGroup;
            SharedPreferences.getInstance().then((_prefs){
              _prefs.setString('current_group_name', currentGroupName);
              _prefs.setInt('current_group_id', currentGroupId);
            });
            return true;
          }
          currentGroupName=groups[0].groupName;
          currentGroupId=groups[0].groupId;
          SharedPreferences.getInstance().then((_prefs){
            _prefs.setString('current_group_name', currentGroupName);
            _prefs.setInt('current_group_id', currentGroupId);
          });
          return true;
        }
        return false;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }

  Future<bool> _login(String username, String password) async{
    try{
      Map<String, String> body = {
        "id":username,
        "password":password
      };
      Map<String, String> header = {
        "Content-Type": "application/json",
        //"Authorization": "Bearer api_token"
      };

      String bodyEncoded = jsonEncode(body);
      http.Response response = await http.post(APPURL+'/login', headers: header, body: bodyEncoded);
      if(response.statusCode==200){
        Map<String, dynamic> decoded = jsonDecode(response.body);
        apiToken=decoded['data']['api_token'];
        currentUser=decoded['data']['id'];

        SharedPreferences.getInstance().then((_prefs){
          _prefs.setString('current_user', currentUser);
          _prefs.setString('api_token', apiToken);
        });

        return await _selectGroup(decoded['data']['last_active_group']);
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }
}
