import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePin extends StatefulWidget {
  @override
  _ChangePinState createState() => _ChangePinState();
}

class _ChangePinState extends State<ChangePin> {
  TextEditingController oldPin = TextEditingController();
  TextEditingController newPin = TextEditingController();
  TextEditingController confirmPin = TextEditingController();

  Future<bool> success;
  bool waiting=false;

  Future<bool> postNewPin(int oldPin, int newPin) async{
    waiting=true;
    Map<String,dynamic> map ={
      'type':'change',
      'name':name,
      'pin':oldPin,
      'new_pin':newPin
    };

    String encoded = jsonEncode(map);

    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/validate/', body: encoded);

    Map<String,dynamic> decoded = jsonDecode(response.body);

    return (response.statusCode==200 && decoded['valid']);

  }

  @override
  Widget build(BuildContext context) {
    return Card(
      
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(child: Text('Pin megváltoztatása', style: Theme.of(context).textTheme.title,)),
            SizedBox(height: 10,),
            Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                child: Text('Mi a mostani pined?', style: Theme.of(context).textTheme.button,)
            ),
            TextField(
              controller: oldPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 20),
              cursorColor: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: 20,),
            Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                child: Text('Mi legyen az új pined?', style: Theme.of(context).textTheme.button,)
            ),
            TextField(
              controller: newPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 20),
              cursorColor: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: 20,),
            Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                child: Text('Még egyszer', style: Theme.of(context).textTheme.button,)
            ),
            TextField(
              controller: confirmPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 20),
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
                  if(confirmPin.text==newPin.text){
                    success=postNewPin(int.parse(oldPin.text), int.parse(newPin.text));
                  }else{
                    Fluttertoast.showToast(msg: 'Az új pin és az újrázás nem ugyanaz :(');
                  }
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
