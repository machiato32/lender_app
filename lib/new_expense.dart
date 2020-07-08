import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'balances.dart';
import 'shopping.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      "fulfilled_by":currentUser,
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
      "from_name":currentUser,
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
      appBar: AppBar(title: Text('Bevásárlás')),
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
                      child: Text('Amennyit fizettél', style: Theme.of(context).textTheme.button,)
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
                      child: Text('Megjegyzés', style: Theme.of(context).textTheme.button,)
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: 'Tárgyrag nélkül'),
                      controller: noteController,
                      style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                    SizedBox(height: 20,),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                      child: Text('Akinek vetted', style: Theme.of(context).textTheme.button,)
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
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          int amount = int.parse(amountController.text);
                          if(amount<0) return;
                          String note = noteController.text;
                          List<String> names = new List<String>();
                          checkboxBool.forEach((String key, bool value) {
                            if(value) names.add(key);
                          });
                          Function f;
                          var param;
                          if(widget.type==ExpenseType.fromSavedExpense){
                            f=_deleteExpense;
                            param=widget.expense.iD;
                          }else if(widget.type==ExpenseType.fromShopping){
                            f=_fulfillShopping;
                            param=widget.shoppingData.shoppingId;
                          }else{
                            f=(par){return true;};
                            param=5;
                          }
                          if(await f(param) && await postNewExpense(names, amount, note)){
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
//                          Navigator.pop(context);
//                          Navigator.of(context).popUntil((route)=> route.settings.name=='/');

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
      ),
    );
  }
}
