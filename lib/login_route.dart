import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'person.dart';

class LoginRoute extends StatefulWidget {
  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('Bejelentkezés')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20, left: 20),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'sanyika#1234',
                  labelText: 'Felhasználónév',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                    //  when the TextFormField in unfocused
                  ) ,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ) ,

                ),
                style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                cursorColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 30,),
            Padding(
              padding: EdgeInsets.only(right: 20, left: 20),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Jelszó',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                    //  when the TextFormField in unfocused
                  ) ,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ) ,

                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                cursorColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 40,)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          String username = _usernameController.text.toLowerCase();
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
                              Flexible(child: Text("A bejelentkezés sikeres volt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                              SizedBox(height: 15,),
                              FlatButton.icon(
                                icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                                onPressed: (){
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));
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
                                Flexible(child: Text("Hiba a bejelentkezéskor!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                                SizedBox(height: 15,),
                                FlatButton.icon(
                                  icon: Icon(Icons.clear, color: Colors.white,),
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  label: Text('Vissza', style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white),),
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
                              Flexible(child: Text(snapshot.error.toString(), style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                              SizedBox(height: 15,),
                              FlatButton.icon(
                                icon: Icon(Icons.clear, color: Colors.white,),
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                label: Text('Vissza', style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white),),
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

  Future<bool> _selectGroup() async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.get(APPURL+'/groups', headers: header);
      Map<String, dynamic> response2 = jsonDecode(response.body);
      if(response.statusCode==200){
        List<Group> groups=[];
        for(var group in response2['data']){
          groups.add(Group(groupName: group['group_name'], groupId: group['group_id']));
        }
        if(groups.length>0){
          currentGroupName=groups[0].groupName;
          currentGroupId=groups[0].groupId;
          return true;
        }
        return false;
      }else{
        throw 'Hiba';
      }
    }catch(_){
      throw 'Hiba';
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
      Map<String, dynamic> response2 = jsonDecode(response.body);
      if(response.statusCode==200){
        apiToken=response2['data']['api_token'];

        currentUser=response2['data']['id'];

        SharedPreferences.getInstance().then((_prefs){
          _prefs.setString('current_user', currentUser);
          _prefs.setString('api_token', apiToken);
        });
      }
      return await _selectGroup();
    }catch(_){
      throw _;
    }
  }
}
