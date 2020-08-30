import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/main.dart';
import 'package:csocsort_szamla/person.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';

class LoginRoute extends StatefulWidget {
  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {

  TextEditingController _usernameController = TextEditingController(text: currentUser!=null?currentUsername:'');
  TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
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
                    child: TextFormField(
                      validator: (value){
                        if(value.isEmpty){
                          return 'field_empty'.tr();
                        }
                        if(value.length<3){
                          //TODO set new rules
                          return 'minimal_length'.tr(args: ['3']);
                        }
                        return null;
                      },
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'example_name'.tr(),
                        labelText: 'name'.tr(), //TODO change label to username
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
                        ) ,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[a-z0-9#]')),
                        LengthLimitingTextInputFormatter(15), //TODO check this
                      ],
                      style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              Padding(
                padding: EdgeInsets.only(right: 20, left: 20),
                child: TextFormField(
                  validator: (value){
                    if(value.isEmpty){
                      return 'field_empty'.tr();
                    }
                    return null;
                  },
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
                  obscureText: true,
                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  ],
                ),
              ),
              SizedBox(height: 40,)
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_formKey.currentState.validate()){
              String username = _usernameController.text.toLowerCase();
              String password = _passwordController.text;
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  child: FutureSuccessDialog(
                    dataTrueText: 'login_scf'.tr(),
                    dataFalseText: 'login_scf'.tr(),
                    future: _login(username, password),
                    onDataTrue: (){
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainPage()), (r)=>false);
                    },
                    onDataFalse: (){
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => JoinGroup(fromAuth: true,)), (r)=>false);
                    },
                  )
              );
            }

          },
          child: Icon(Icons.send),
        ),
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
        "username":username,
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
        currentUsername=decoded['data']['username'];

        SharedPreferences.getInstance().then((_prefs){
          _prefs.setString('current_username', currentUsername);
          _prefs.setInt('current_user', currentUser);
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
