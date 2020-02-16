import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'balances.dart';
class Payment extends StatefulWidget {
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  Future<List<String>> names;
  Future<bool> success;
  bool waiting=false;
  String dropdownValue;
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  Future<List<String>> getNames() async {
    http.Response response = await http.get('http://katkodominik.web.elte.hu/JSON/names');
    Map<String, dynamic> response2 = jsonDecode(response.body);

    List<String> list = response2['names'].cast<String>();
    list.remove(name);
    dropdownValue=list[0];
    return list;

  }

  Future<bool> postPayment(int amount, String note, String toName) async {
    waiting=true;
    Map<String,dynamic> map = {
      'type':'payment',
      'from_name':name,
      'to_name':toName,
      'amount':amount,
      'note':note
    };
    String encoded = json.encode(map);

    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/', body: encoded);

    return response.statusCode==200;

  }

  @override
  void initState() {
    super.initState();

    names = getNames();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('De hát én fizettem na'),),
      body:
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                      Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                          child: Text('Kinek?', style: Theme.of(context).textTheme.button)
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

                            return Center(child: CircularProgressIndicator());

                          },
                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                        child: Text('Mennyit?', style: Theme.of(context).textTheme.button,)
                      ),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                        cursorColor: Theme.of(context).colorScheme.secondary,
                      ),
                      SizedBox(height: 20,),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                        child: Text('Megjegyzés:', style: Theme.of(context).textTheme.button)
                      ),
                      TextField(
                        controller: noteController,
                        style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                        cursorColor: Theme.of(context).colorScheme.secondary,
                      ),
                      SizedBox(height: 30,),
                      Center(
                        child: RaisedButton.icon(
                          color: Theme.of(context).colorScheme.secondary,
                          label: Text('Fizetés', style: Theme.of(context).textTheme.button),
                          icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSecondary),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            success=null;
                            int amount = int.parse(amountController.text);
                            String note = noteController.text;
                            success=postPayment(amount, note, dropdownValue);
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
                      ),
                    ],
                  ),
                ),
              ),
              Balances()
            ],
          ),
        )

    );
  }
}
