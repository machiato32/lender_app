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
                            int amount = int.parse(amountController.text);
                            String note = noteController.text;
                            Future<bool> success = postPayment(amount, note, dropdownValue);
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
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(child: Text("A tranzakciót sikeresen könyveltük!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
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
//                                          FlutterToast ft = FlutterToast(context);
//                                          ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
//                                          return Center();
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
//                                          FlutterToast ft = FlutterToast(context);
//                                          ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
//                                          Navigator.pop(context);
//                                          return Center();
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
              ),
              Balances()
            ],
          ),
        )

    );
  }
}
