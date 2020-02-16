import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwitchUser extends StatefulWidget {
  @override
  _SwitchUserState createState() => _SwitchUserState();
}

class _SwitchUserState extends State<SwitchUser> {
  Future<List<String>> names;
  Future<bool> success;
  bool waiting=false;

  String dropdownValue='';
  TextEditingController pinController = TextEditingController();

  Future<List<String>> getNames() async {
    http.Response response = await http.get('http://katkodominik.web.elte.hu/JSON/names');
    Map<String, dynamic> response2 = jsonDecode(response.body);

    List<String> list = response2['names'].cast<String>();
    list.remove(name);
    dropdownValue=list[0];
    return list;

  }

  Future<bool> postValidate(int pin, String name) async{
    waiting=true;
    Map<String,dynamic> map = {
      'type':'validate',
      'name':name,
      'pin':pin
    };
    String encoded = json.encode(map);

    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/validate/', body: encoded);

    Map<String,dynamic> decoded = jsonDecode(response.body);

    return (response.statusCode==200 && decoded['valid']);
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
    return Padding(
        padding: EdgeInsets.fromLTRB(8,4,8,4),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onBackground,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onSurface,
                  blurRadius: 10,
                  spreadRadius: 5,
                )
              ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(child: Text('Felhasználóváltás', style: Theme.of(context).textTheme.title,)),
              SizedBox(height: 10,),
              Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                  child: Text('Mostantól ki szeretnél lenni?', style: Theme.of(context).textTheme.button,)
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: FutureBuilder(
                  future: names,
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      return DropdownButton(
                        value: dropdownValue,
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownValue=newValue;
                          });
                        },
                        items: snapshot.data.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: Theme.of(context).textTheme.body2),
                          );
                        }).toList(),

                      );
                    }

                    return CircularProgressIndicator();

                  },
                ),
              ),
              SizedBox(height: 20,),
              Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                  child: Text('Mi a PIN kódod?', style: Theme.of(context).textTheme.button,)
              ),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                cursorColor: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 30,),
               Center(
                 child: RaisedButton.icon(
                  color: Theme.of(context).colorScheme.secondary,
                  label: Text('Küldés', style: Theme.of(context).textTheme.button),
                  icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSecondary),
                  onPressed: (){
                    FocusScope.of(context).unfocus();
                    success=null;
                    int pin = int.parse(pinController.text);
                    success=postValidate(pin, dropdownValue);
                    setState(() {

                    });
                  },
              ),
               ),
              Center(
                child: FutureBuilder(
                    future: success,
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        waiting=false;
                        if(snapshot.data){
                          getPrefs().then((_prefs){
                            name=dropdownValue;
                            _prefs.setString('name', dropdownValue);
                          });
                          return Icon(Icons.check, color: Colors.green, size: 30,);
                        }else{
                          return Icon(Icons.clear, color: Colors.red, size: 30,);
                        }
                      }
                      if(waiting){
                        return CircularProgressIndicator();
                      }
                      return SizedBox();
                    }
                ),
              )
            ],
          ),
        ),
      );
  }
}
