import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'balances.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

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
//    list.insert(0, 'Válaszd ki a személyt!');
//    dropdownValue=list[0];
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

                      Row(
                        children: <Widget>[
                          Text('Összeg', style: Theme.of(context).textTheme.body2,),
                          SizedBox(width: 20,),
                          Flexible(
                            child: TextField(
                              controller: amountController,
                              decoration: InputDecoration(
                                hintText: 'Ft',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                                  //  when the TextFormField in unfocused
                                ) ,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                ) ,

                              ),
                              style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                              cursorColor: Theme.of(context).colorScheme.secondary,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ -\\,]'))],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: <Widget>[
                          Text('Megjegyzés', style: Theme.of(context).textTheme.body2,),
                          SizedBox(width: 20,),
                          Flexible(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Mamut',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                                  //  when the TextFormField in unfocused
                                ) ,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                ) ,

                              ),
                              controller: noteController,
                              style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                              cursorColor: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Divider(),
                      Center(
                        child: FutureBuilder(
                          future: names,
                          builder: (context, snapshot) {
                            if(snapshot.hasData){
                              return DropdownButton(
                                hint: Text('Válaszd ki a személyt!', style: Theme.of(context).textTheme.body2,),
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
                      SizedBox(height: 30,),
                      Center(
                        child: RaisedButton.icon(
                          color: Theme.of(context).colorScheme.secondary,
                          label: Text('Fizetés', style: Theme.of(context).textTheme.button),
                          icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSecondary),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            //TODO: catch exceptions
                            if(dropdownValue==null){
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
                                    Flexible(child: Text("Nem választottál személyt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                                  ],
                                ),
                              );
                              FlutterToast ft = FlutterToast(context);
                              ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
                              return;
                            }
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
