import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'balances.dart';

class NewExpense extends StatefulWidget {
  @override
  _NewExpenseState createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  Future<List<String>> names;
  Future<bool> success;
  bool waiting=false;
  Map<String,bool> checkboxBool = Map<String,bool>();

  Future<List<String>> getNames() async {
    http.Response response = await http.get('http://katkodominik.web.elte.hu/JSON/names');
    Map<String, dynamic> response2 = jsonDecode(response.body);

    List<String> list = response2['names'].cast<String>();
    return list;

  }

  Future<bool> postNewExpense(List<String> names, int amount, String note) async{
    waiting=true;
    Map<String, dynamic> map = {
      "type":"new_expense",
      "from_name":name,
      "to_names":names,
      "amount":amount,
      "note":note
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
      appBar: AppBar(title: Text('Vettem dolgokat')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8),
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
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                      child: Text('Mennyiért vettél?', style: Theme.of(context).textTheme.button,)
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
                      child: Text('Mit vettél?', style: Theme.of(context).textTheme.button,)
                    ),
                    TextField(
                      controller: noteController,
                      style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                    SizedBox(height: 20,),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                      child: Text('Kinek/kiknek vetted?', style: Theme.of(context).textTheme.button,)
                    ),
                    Center(
                      child: FutureBuilder(
                        future: names,
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            for(String name in snapshot.data){
                              checkboxBool.putIfAbsent(name, () => false);
                            }
                            return ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 300),
                              child: ListView(
                                shrinkWrap: true,
                                children: snapshot.data.map<CheckboxListTile>((String name)=>
                                    CheckboxListTile(
                                      title: Text(name, style: Theme.of(context).textTheme.body2,),
                                      value: checkboxBool[name],
                                      onChanged: (bool newValue){
                                        FocusScope.of(context).unfocus();
                                        setState(() {
                                          checkboxBool[name]=newValue;
                                        });
                                      },
                                    ),
                                ).toList(),
                              ),
                            );
                          }
                          return CircularProgressIndicator();
                        },
                      ),
                    ),
                    SizedBox(height: 20,),
                    Center(
                      child: RaisedButton.icon(
                        color: Theme.of(context).colorScheme.secondary,
                        label: Text('Fizetés', style: Theme.of(context).textTheme.button),
                        icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSecondary),
                        onPressed: (){
                          FocusScope.of(context).unfocus();
                          success=null;
                          int amount = int.parse(amountController.text);
                          String note = noteController.text;
                          List<String> names = new List<String>();
                          checkboxBool.forEach((String key, bool value) {
                            if(value) names.add(key);
                          });
                          success=postNewExpense(names, amount, note);
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
      ),
    );
  }
}
