import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:csocsort_szamla/custom_dialog.dart';

class RegisterRoute extends StatefulWidget {
  @override
  _RegisterRouteState createState() => _RegisterRouteState();
}

class _RegisterRouteState extends State<RegisterRoute> {
  Random _random = Random();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _userNumController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();
  TextEditingController _passwordReminderController = TextEditingController();

  String _randomNum;

  @override
  void initState() {
    _randomNum=_random.nextInt(10000).toString().padLeft(4, '0');
    _userNumController.text=_randomNum;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('register'.tr())),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 20,),
                Flexible(
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      helperText: 'not_alterable'.tr(),
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
                Text('#', style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 30),),
                SizedBox(width: 5,),
                Flexible(
                  child: TextField(
                    controller: _userNumController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'id'.tr(),
                      helperText: 'not_alterable'.tr(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
                        //  when the TextFormField in unfocused
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,

                    ),
                    inputFormatters: [
                      BlacklistingTextInputFormatter(new RegExp('[\\. \\,-]')),
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
                    //  when the TextFormField in unfocused
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                ),
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9]')),
                ],
                obscureText: true,
                style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                cursorColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 30,),
            Padding(
              padding: EdgeInsets.only(right: 20, left: 20),
              child: TextField(
                controller: _passwordConfirmController,
                decoration: InputDecoration(
                  labelText: 'confirm_password'.tr(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
                    //  when the TextFormField in unfocused
                  ) ,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ) ,

                ),
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9]')),
                ],
                obscureText: true,
                style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                cursorColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 30,),
//            Padding(
//              padding: EdgeInsets.only(right: 20, left: 20),
//              child: TextField(
//                controller: _passwordReminderController,
//                decoration: InputDecoration(
//                  labelText: 'Jelszóemlékeztető',
//                  enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
//                    //  when the TextFormField in unfocused
//                  ) ,
//                  focusedBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
//                  ) ,
//
//                ),
//                style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
//                cursorColor: Theme.of(context).colorScheme.secondary,
//              ),
//            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          //TODO: validate
          String username = _usernameController.text;
          String userNum = _userNumController.text;
          if(_passwordController.text==_passwordConfirmController.text){
            String password = _passwordConfirmController.text;
            showDialog(
                barrierDismissible: false,
                context: context,
                child:
                FutureSuccessDialog(
                  future: _register(username, userNum, password, ''),
                  dataTrueText: 'registration_scf',
                  onDataTrue: (){
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => JoinGroup(fromAuth: true,)), (r)=>false);
                  },
                )
            );
          }
        },
        child: Icon(Icons.send),
      ),
    );
  }

  Future<bool> _register(String username, String userNum, String password, String reminder) async {
    try{
      Map<String, String> body = {
        "id":username+"#"+userNum,
        "default_currency" : "HUF",
        "password" : password,
        "password_confirmation" : password,
        "password_reminder": reminder

      };
      Map<String, String> header = {
        "Content-Type": "application/json",
      };

      String bodyEncoded = jsonEncode(body);
      http.Response response = await http.post(APPURL+'/register', headers: header, body: bodyEncoded);
      if(response.statusCode==201){
        Map<String, dynamic> decodedResponse = jsonDecode(response.body);
        apiToken=decodedResponse['api_token'];
        currentUser=decodedResponse['id'];

        SharedPreferences.getInstance().then((_prefs){
          _prefs.setString('current_user', currentUser);
          _prefs.setString('api_token', apiToken);
        });
        return true;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }

}
