import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csocsort_szamla/main.dart';
import 'package:csocsort_szamla/user_settings/user_settings_page.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  TextEditingController _groupName = TextEditingController();
  TextEditingController _nicknameController = TextEditingController(text: currentUser.split('#')[0]);

  Future _logout() async{
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      await http.get(APPURL+'/logout', headers: header);

    }catch(_){
      throw _;
    }
  }

  Future<bool> _joinGroup(String groupName, String nickname) async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      Map<String, dynamic> body = {
        'group_name':groupName,
        'currency':'HUF',
        'member_nickname':nickname
      };

      String encoded = json.encode(body);
      http.Response response = await http.post(APPURL+'/groups', headers: header, body: encoded);

      if(response.statusCode==201){
        Map<String, dynamic> decoded = jsonDecode(response.body);
        currentGroupName=decoded['group_name'];
        currentGroupId=decoded['group_id'];
        SharedPreferences.getInstance().then((_prefs) {
          _prefs.setString('current_group_name', currentGroupName);
          _prefs.setInt('current_group_id', currentGroupId);
        });
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterRoute()), (r)=>false);
        }
        throw error['error'];
      }
      return response.statusCode==201;
    }catch(_){
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'create'.tr(),
          style: TextStyle(letterSpacing: 0.25, fontSize: 24),
        ),
      ),
//      drawer: Drawer(
//        elevation: 16,
//        child: ListView(
////          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//          children: <Widget>[
//            DrawerHeader(
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Text(
//                    'LENDER',
//                    style: Theme.of(context).textTheme.headline6.copyWith(letterSpacing: 2.5),
//                  ),
//                  SizedBox(height: 5,),
//                  Text(
//                    currentUser,
//                    style: Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).colorScheme.secondary),
//                  ),
////                  SizedBox(height: 20,)
//                ],
//              ),
//            ),
//            ListTile(
//              leading: Icon(
//                Icons.settings,
//                color: Theme.of(context).textTheme.bodyText1.color,
//              ),
//              title: Text(
//                'settings'.tr(),
//                style: Theme.of(context).textTheme.bodyText1,
//              ),
//              onTap: () {
//                Navigator.push(context,
//                    MaterialPageRoute(builder: (context) => Settings()));
//              },
//            ),
//            Divider(),
//
//            ListTile(
//              leading: Icon(
//                Icons.account_circle,
//                color: Theme.of(context).textTheme.bodyText1.color,
//              ),
//              title: Text(
//                'logout'.tr(),
//                style: Theme.of(context).textTheme.bodyText1,
//              ),
//              onTap: () {
//                _logout();
//                currentUser=null;
//                currentGroupId=null;
//                currentGroupName=null;
//                apiToken=null;
//                SharedPreferences.getInstance().then((_prefs) {
//                  _prefs.remove('current_group_name');
//                  _prefs.remove('current_group_id');
//                  _prefs.remove('current_user');
//                  _prefs.remove('api_token');
//                });
//
//                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterRoute()), (r)=>false);
//              },
//            ),
//          ],
//        ),
//      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('group_name'.tr(), style: Theme.of(context).textTheme.bodyText1,),
                SizedBox(width: 20,),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,

                    ),
                    controller: _groupName,
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Text('nickname_in_group'.tr(), style: Theme.of(context).textTheme.bodyText1,),
                SizedBox(width: 20,),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'example_nickname'.tr(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,
                    ),
                    controller: _nicknameController,
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                RaisedButton(
                  child: Text('create_group'.tr(), style: Theme.of(context).textTheme.button),
                  onPressed: (){
                    String token = _groupName.text;
                    String nickname = _nicknameController.text;
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        child: Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: FutureBuilder(
                            future: _joinGroup(token, nickname),
                            builder: (context, snapshot){
                              if(snapshot.connectionState==ConnectionState.done){
                                if(snapshot.hasData){
                                  if(snapshot.data){
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(child: Text("creation_scf".tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
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
                                          Flexible(child: Text("error".tr(), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
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
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
