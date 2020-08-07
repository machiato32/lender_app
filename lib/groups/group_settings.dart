import 'package:flutter/material.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:csocsort_szamla/auth/login_route.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GroupSettings extends StatefulWidget {
  @override
  _GroupSettingState createState() => _GroupSettingState();
}

class _GroupSettingState extends State<GroupSettings> {

  Future<String> _getInvitation() async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.get(APPURL+'/groups/'+currentGroupId.toString(), headers: header);
      if(response.statusCode==200){
        Map<String, dynamic> response2 = jsonDecode(response.body);
        return response2['data']['invitations'][0]['token'];
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginRoute()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw 'Hiba';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
//      padding: EdgeInsets.all(15),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Text('Meghívó', style: Theme.of(context).textTheme.title,),
                SizedBox(height: 40,),
                FutureBuilder(
                  future: _getInvitation(),
                  builder: (context, snapshot){
                    if(snapshot.connectionState==ConnectionState.done){
                      if(snapshot.hasData){
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(child: Text(snapshot.data, style: Theme.of(context).textTheme.body2,)),
                            RaisedButton(
                              onPressed: (){
                                Clipboard.setData(ClipboardData(text: snapshot.data));
                                FlutterToast ft = FlutterToast(context);
                                ft.showToast(child: Text('Másolva', style: Theme.of(context).textTheme.body2,));
                              },
                              child: Icon(Icons.content_copy, color: Theme.of(context).colorScheme.onSecondary,),
                              color: Theme.of(context).colorScheme.secondary,
                            )
                          ],
                        );
                      }else{
                        return InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(snapshot.error.toString()),
                            ),
                            onTap: (){
                              setState(() {
                            });
                            }
                        );
                      }
                    }
                    return CircularProgressIndicator();
                  },
                ),

              ],
            ),
          ),
        )

      ],
    );
  }
}
