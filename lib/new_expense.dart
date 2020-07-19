import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'balances.dart';
import 'shopping.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

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
    try{
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
    }catch(Exception){
      return false;
    }


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
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text('Végösszeg', style: Theme.of(context).textTheme.body2,),
                              SizedBox(width: 20,),
                              Flexible(
                                child: TextField(
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
                                  controller: amountController,
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                                  cursorColor: Theme.of(context).colorScheme.secondary,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ -\\,]'))],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
//                    Container(
//                      padding: EdgeInsets.all(5),
//                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
//                      child: Text('Megjegyzés', style: Theme.of(context).textTheme.button,)
//                    ),
                          Row(
                            children: <Widget>[
                              Text('Megjegyzés', style: Theme.of(context).textTheme.body2,),
                              SizedBox(width: 15,),
                              Flexible(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Dolgok',
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
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Divider(),
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
                              constraints: BoxConstraints(maxHeight: 310),
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
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
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
                        Flexible(
                          child: Text(
                            amountController.text!='' && checkboxBool.values.where((element)=>element==true).toList().length>0?
                            (double.parse(amountController.text)/checkboxBool.values.where((element)=>element==true).toList().length).toStringAsFixed(2)+' Ft/fő':
                            '',
                            style: Theme.of(context).textTheme.body1,

                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Center(
                      child: RaisedButton.icon(
                        color: Theme.of(context).colorScheme.secondary,
                        label: Text('Mehet', style: Theme.of(context).textTheme.button),
                        icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSecondary),
                        onPressed: () async {
                          //TODO: catch exceptions with
                          FocusScope.of(context).unfocus();
                          //TODO: round will not be needed
                          int amount = double.parse(amountController.text).round();
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
                          f(param);
                          Future<bool> success = postNewExpense(names, amount, note);
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
            ),
            Balances()
          ],

        ),
      ),
    );
  }
}
