import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:csocsort_szamla/auth/login_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csocsort_szamla/main.dart';

class JoinGroup extends StatefulWidget {
  @override
  _JoinGroupState createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
  TextEditingController _tokenController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController(text: currentUser.split('#')[0]);

  Future<bool> _joinGroup(String token, String nickname) async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      Map<String, dynamic> body = {
        'invitation_token':token,
        'nickname':nickname
      };

      String encoded = json.encode(body);
      http.Response response = await http.post(APPURL+'/join', headers: header, body: encoded);

      if(response.statusCode==200){
        Map<String, dynamic> response2 = jsonDecode(response.body);
        currentGroupName=response2['data']['group_name'];
        currentGroupId=response2['data']['group_id'];
        SharedPreferences.getInstance().then((_prefs) {
          _prefs.setString('current_group_name', currentGroupName);
          _prefs.setInt('current_group_id', currentGroupId);
        });
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginRoute()));
        }
        throw error['error'];
      }
      return response.statusCode==200;
    }catch(_){
      throw 'Hiba';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Csatlakozás',
          style: TextStyle(letterSpacing: 0.25, fontSize: 24),
        ),
      ),
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
                Text('Meghívó', style: Theme.of(context).textTheme.body2,),
                SizedBox(width: 20,),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                        //  when the TextFormField in unfocused
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,

                    ),
                    controller: _tokenController,
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Text('Becenév a csoportban', style: Theme.of(context).textTheme.body2,),
                SizedBox(width: 20,),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Sanyi',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                        //  when the TextFormField in unfocused
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,
                    ),
                    controller: _nicknameController,
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          String token = _tokenController.text;
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
                              Flexible(child: Text("A csatlakozás sikeres volt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                              SizedBox(height: 15,),
                              FlatButton.icon(
                                icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                                onPressed: (){
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainPage()), (r)=>false);
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
                                Flexible(child: Text("Hiba a csatlakozáskor!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
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
}
