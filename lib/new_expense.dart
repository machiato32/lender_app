import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'balances.dart';
import 'shopping.dart';

class SavedExpense{
  String name, note;
  List<String> names;
  int amount;
  int iD;
  SavedExpense({this.name, this.names, this.amount, this.note, this.iD});
}

enum ExpenseType{
  fromShopping, fromSavedExpense, newExpense
}

class NewExpense extends StatefulWidget {
  final ExpenseType type;
  final SavedExpense expense;
  final ShoppingData shoppingData;
  NewExpense({@required this.type, this.expense, this.shoppingData});
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

  Future<bool> _deleteExpense(int id) async {
    Map<String, dynamic> map = {
      "type":'delete',
      "Transaction_Id":id
    };

    String encoded = json.encode(map);
    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/', body: encoded);

    return response.statusCode==200;
  }
  Future<bool> _fulfillShopping(int id) async {
    Map<String, dynamic> map = {
      "type":'fulfill',
      "fulfilled_by":name,
      "id":id
    };

    String encoded = json.encode(map);
    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/list/', body: encoded);

    return response.statusCode==200;
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

  void setInitialValues(){
    if(widget.type==ExpenseType.fromSavedExpense){
      noteController.text = widget.expense.note;
      amountController.text=widget.expense.amount.toString();
    }else{
      noteController.text=widget.shoppingData.quantity+' '+widget.shoppingData.item;
    }
  }

  @override
  void initState() {
    super.initState();
    if(widget.type==ExpenseType.fromSavedExpense || widget.type==ExpenseType.fromShopping){
      setInitialValues();
    }
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
            Card(

              child: Padding(
                padding: const EdgeInsets.all(15),
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
                      decoration: InputDecoration(hintText: 'A teljes végösszeg'),
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
                            if(widget.type==ExpenseType.fromSavedExpense && widget.expense.names!=null){
                              for(String name in widget.expense.names){
                                checkboxBool[name]=true;
                              }
                              widget.expense.names=null;
                            }else if(widget.type==ExpenseType.fromShopping){
                              checkboxBool[widget.shoppingData.user]=true;
                            }
                            return ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 300),
                              child: ListView(
                                shrinkWrap: true,
                                children: snapshot.data.map<CheckboxListTile>((String name)=>
                                    CheckboxListTile(
                                      activeColor: Theme.of(context).primaryColor,
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
                    RaisedButton.icon(
                      color: Theme.of(context).colorScheme.secondary,
                      label: Text('Inverz kijelölés', style: Theme.of(context).textTheme.button),
                      icon: Icon(Icons.check_box, color: Theme.of(context).colorScheme.onSecondary),
                      onPressed: (){
                        FocusScope.of(context).unfocus();
                        for(String name in checkboxBool.keys){
                          checkboxBool[name]=!checkboxBool[name];
                        }
                        setState(() {

                        });
                      },
                    ),
                    SizedBox(height: 20,),
                    Center(
                      child: RaisedButton.icon(
                        color: Theme.of(context).colorScheme.secondary,
                        label: Text('Mehet', style: Theme.of(context).textTheme.button),
                        icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSecondary),
                        onPressed: (){
                          FocusScope.of(context).unfocus();
                          success=null;
                          int amount = int.parse(amountController.text);
                          if(amount<0) return;
                          String note = noteController.text;
                          List<String> names = new List<String>();
                          checkboxBool.forEach((String key, bool value) {
                            if(value) names.add(key);
                          });
                          if(widget.type==ExpenseType.fromSavedExpense){
                            _deleteExpense(widget.expense.iD);
                          }else if(widget.type==ExpenseType.fromShopping){
                            _fulfillShopping(widget.shoppingData.shoppingId);
                          }
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
