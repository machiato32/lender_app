import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'balances.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    list.remove(currentUser);
    dropdownValue=list[0];
    return list;

  }

  Future<bool> postPayment(int amount, String note, String toName) async {
    waiting=true;
    Map<String,dynamic> map = {
      'type':'payment',
      'from_name':currentUser,
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
      appBar: AppBar(title: Text('Fizetés'),),
      body:
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                          child: Text('Akinek fizettél', style: Theme.of(context).textTheme.button)
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
                        child: Text('Összeg', style: Theme.of(context).textTheme.button,)
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
                        child: Text('Megjegyzés', style: Theme.of(context).textTheme.button)
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
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            success=null;
                            int amount = int.parse(amountController.text);
                            String note = noteController.text;
                            if(await postPayment(amount, note, dropdownValue)){
                              Widget toast = Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0),
                                  color: Colors.green,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check, color: Colors.white,),
                                    SizedBox(
                                      width: 12.0,
                                    ),
                                    Text("A tranzakciót sikeresen könyveltük!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white)),
                                  ],
                                ),
                              );
                              FlutterToast ft = FlutterToast(context);
                              ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
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
                                    Icon(Icons.clear),
                                    SizedBox(
                                      width: 12.0,
                                    ),
                                    Text("A tranzakció könyvelése sikertelen volt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white)),
                                  ],
                                ),
                              );
                              FlutterToast ft = FlutterToast(context);
                              ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
                            }

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
