import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:csocsort_szamla/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'dart:math';

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

      appBar: AppBar(title: Text('Regisztráció')),
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
                      helperText: 'Nem megváltoztatható',
                      hintText: 'sanyika',
                      labelText: 'Név',
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
                Text('#'),
                SizedBox(width: 5,),
                Flexible(
                  child: TextField(
                    controller: _userNumController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Azonosító',
                      helperText: 'Nem megváltoztatható',
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
                  labelText: 'Jelszó',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
                    //  when the TextFormField in unfocused
                  ) ,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ) ,

                ),
                inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[\\. \\,-]'))],
                keyboardType: TextInputType.number,
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
                  labelText: 'Jelszó újra',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
                    //  when the TextFormField in unfocused
                  ) ,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ) ,

                ),
                inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[\\. \\,-]'))],
                keyboardType: TextInputType.number,
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
            RaisedButton(
              onPressed: (){
                //TODO: validate
                String username = _usernameController.text;
                String userNum = _userNumController.text;
                if(_passwordController.text==_passwordConfirmController.text){
                  String password = _passwordConfirmController.text;
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      child: Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: FutureBuilder(
                          future: _register(username, userNum, password, ''),
                          builder: (context, snapshot){
                            if(snapshot.connectionState==ConnectionState.done){
                              if(snapshot.hasData){
                                if(snapshot.data){

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(child: Text("A regisztráció sikeres volt!", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
                                      SizedBox(height: 15,),
                                      FlatButton.icon(
                                        icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                                        onPressed: (){
                                          Navigator.pop(context);
                                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => JoinGroup()), (r)=>false);
                                        },
                                        label: Text('Rendben', style: Theme.of(context).textTheme.button,),
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
                                        Flexible(child: Text("Hiba a regisztrációkor!", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
                                        SizedBox(height: 15,),
                                        FlatButton.icon(
                                          icon: Icon(Icons.clear, color: Colors.white,),
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                          label: Text('Vissza', style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),),
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
                                        label: Text('Vissza', style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),),
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
                }
              },
              child: Text('Regisztráció', style: Theme.of(context).textTheme.button),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
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
      }
      return response.statusCode==201;
    }catch(_){
      throw _;
    }
  }

}
