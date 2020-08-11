import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:csocsort_szamla/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:csocsort_szamla/main.dart';

class ChangePin extends StatefulWidget {
  @override
  _ChangePinState createState() => _ChangePinState();
}

class _ChangePinState extends State<ChangePin> {
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();


  Future<bool> _updatePassword(String oldPassword, String newPassword) async{
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };
      Map<String,dynamic> map ={
        'old_password':oldPassword,
        'new_password':newPassword,
        'new_password_confirmation':newPassword
      };

      String encoded = jsonEncode(map);

      http.Response response = await http.post(APPURL+'/change_password', headers: header, body: encoded);
      if(response.statusCode==204){
        return true;
      }else{
        Map<String,dynamic> error = jsonDecode(response.body);

        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(child: Text('Jelszó megváltoztatása', style: Theme.of(context).textTheme.headline6,)),
            SizedBox(height: 10,),
            Row(
              children: <Widget>[
                Text('Jelenlegi jelszó', style: Theme.of(context).textTheme.bodyText1,),
                SizedBox(width: 15,),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '1234',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                        //  when the TextFormField in unfocused
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,

                    ),
                    inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ \\,\\.-]'))],
                    controller: _oldPasswordController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Text('Új jelszó', style: Theme.of(context).textTheme.bodyText1,),
                SizedBox(width: 15,),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '5678',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                        //  when the TextFormField in unfocused
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,

                    ),
                    inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ \\,\\.-]'))],
                    controller: _newPasswordController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Text('Új jelszó megerősítése', style: Theme.of(context).textTheme.bodyText1,),
                SizedBox(width: 15,),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '5678',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                        //  when the TextFormField in unfocused
                      ) ,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ) ,

                    ),
                    inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ \\,\\.-]'))],
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30,),
            Center(
              child: RaisedButton.icon(
                color: Theme.of(context).colorScheme.secondary,
                label: Text('Küldés', style: Theme.of(context).textTheme.button),
                icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSecondary),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  if(_confirmPasswordController.text==_newPasswordController.text){
                    Future<bool> success = _updatePassword(_oldPasswordController.text, _newPasswordController.text);
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        child: Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: FutureBuilder(
                            future: success,
                            builder: (context, snapshot){
                              if(snapshot.connectionState==ConnectionState.done){
                                if(snapshot.hasData){
                                  if(snapshot.data){
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(child: Text("A jelszó megváltoztatása sikeres volt!", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
                                        SizedBox(height: 15,),
                                        FlatButton.icon(
                                          icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                                          onPressed: (){
                                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainPage()), (route) => false);
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
                                          Flexible(child: Text("Hiba történt!", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
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
                  }else{
                    Widget toast = Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        color: Colors.red,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear, color: Colors.white,),
                          SizedBox(
                            width: 12.0,
                          ),
                          Flexible(child: Text("A megadott két jelszó nem egyezik!", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white))),
                        ],
                      ),
                    );
                    FlutterToast ft = FlutterToast(context);
                    ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
