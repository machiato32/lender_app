import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SwitchUser extends StatefulWidget {
  @override
  _SwitchUserState createState() => _SwitchUserState();
}

class _SwitchUserState extends State<SwitchUser> {
  Future<List<String>> names;

  String dropdownValue;
  TextEditingController pinController = TextEditingController();

  Future<List<String>> getNames() async {
    try{

      http.Response response = await http.get('http://katkodominik.web.elte.hu/JSON/names');
      Map<String, dynamic> response2 = jsonDecode(response.body);

      List<String> list = response2['names'].cast<String>();
      list.remove(currentUser);
      return list;
    }catch(_){
      throw 'Hiba';
    }

  }

  Future<bool> postValidate(int pin, String name) async{
    Map<String,dynamic> map = {
      'type':'validate',
      'name':name,
      'pin':pin
    };
    String encoded = json.encode(map);

    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/validate/', body: encoded);

    Map<String,dynamic> decoded = jsonDecode(response.body);

    return (response.statusCode==200 && decoded['valid']);
    //TODO: catch
  }

  Future<SharedPreferences> getPrefs() async{
    return await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    names=getNames();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(child: Text('Felhasználóváltás', style: Theme.of(context).textTheme.title,)),
            SizedBox(height: 10,),
            Center(
              child: FutureBuilder(
                future: names,
                builder: (context, snapshot) {
                  if(snapshot.connectionState==ConnectionState.done){
                    if(snapshot.hasData){
                      return DropdownButton(
                        hint: Text('Felhasználó', style: Theme.of(context).textTheme.body2.copyWith(fontSize: 25)),
                        value: dropdownValue,
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownValue=newValue;
                          });
                        },
                        items: snapshot.data.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: Theme.of(context).textTheme.body2.copyWith(fontSize: 25)),
                          );
                        }).toList(),

                      );
                    }else{
                      return InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(snapshot.error.toString()),
                          ),
                          onTap: (){
                            setState(() {
                              names=null;
                              names=getNames();
                            });
                          }
                      );
                    }
                  }

                  return CircularProgressIndicator();

                },
              ),
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Text('PIN kód', style: Theme.of(context).textTheme.body2,),
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
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
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
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if(pinController.text=='' || dropdownValue==null){
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
                          Flexible(child: Text("Nem töltötted ki a szükséges mezőket!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                        ],
                      ),
                    );
                    FlutterToast ft = FlutterToast(context);
                    ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
                    return;
                  }
                  int pin = int.parse(pinController.text);
                  Future<bool> success = postValidate(pin, dropdownValue);
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
                            if(snapshot.hasData){
                              if(snapshot.data){
                                getPrefs().then((_prefs){
                                  currentUser=dropdownValue;
                                  _prefs.setString('name', dropdownValue);
                                });
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(child: Text("A bejelentkezés sikeres volt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                                    SizedBox(height: 15,),
                                    FlatButton.icon(
                                      icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                                      onPressed: (){
                                        Navigator.pop(context);
                                        Navigator.pop(context);
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
                                      Flexible(child: Text("Hiba történt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
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
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      )
                  );

                },
              ),
             ),
          ],
        ),
      ),
    );
  }
}
