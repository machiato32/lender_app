import 'package:flutter/material.dart';
import 'history.dart';
import 'balances.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'new_expense.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HistoryRoute extends StatefulWidget {
  final HistoryData data;
  HistoryRoute({@required this.data});
  @override
  _HistoryRouteState createState() => _HistoryRouteState();
}

class _HistoryRouteState extends State<HistoryRoute> {
  Future<bool> _deleteElement(int id) async {
    Map<String, dynamic> map = {
      "type":'delete',
      "Transaction_Id":id
    };

    String encoded = json.encode(map);
    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/', body: encoded);
    int a=8;

    return response.statusCode==200;
  }
  @override
  Widget build(BuildContext context) {
    String title='';
    if(widget.data.note==''){
      title='Nincs megjegyzés';
    }else{
      title=widget.data.note[0].toUpperCase()+widget.data.note.substring(1);
    }
    return Scaffold(
      appBar: AppBar(title: Text(title),),
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

                    Row(
                      children: <Widget>[
                        Icon(Icons.account_circle, color: Theme.of(context).colorScheme.primary),
                        Text(' - '),
                        Flexible(child: Text(widget.data.fromUser, style: Theme.of(context).textTheme.body2,)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
                        Text(' - '),
                        Flexible(child: Text(widget.data.toUser.join(', '), style: Theme.of(context).textTheme.body2, )),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: <Widget>[
                        Icon(Icons.attach_money, color: Theme.of(context).colorScheme.primary),
                        Text(' - '),
                        Flexible(child: Text(widget.data.amount.toString(), style: Theme.of(context).textTheme.body2)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: <Widget>[
                        Icon(Icons.date_range, color: Theme.of(context).colorScheme.primary,),
                        Text(' - '),
                        Flexible(child: Text(DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.date), style: Theme.of(context).textTheme.body2)),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Visibility(
                      visible: widget.data.type=="payment" || widget.data.type=="add_expense",
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
//                          FlatButton.icon(
//
//                            onPressed: (){
//                              showDialog(
//                                  context: context,
//                                  child: Dialog(
//                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//                                    backgroundColor: Theme.of(context).colorScheme.onBackground,
//                                    child: Container(
//                                      padding: EdgeInsets.all(8),
//                                      child: Column(
//                                        crossAxisAlignment: CrossAxisAlignment.center,
//                                        mainAxisSize: MainAxisSize.min,
//                                        children: <Widget>[
//                                          Text('Szerkeszteni szeretnéd a tételt?', style: Theme.of(context).textTheme.title, textAlign: TextAlign.center,),
//                                          SizedBox(height: 15,),
//                                          Row(
//                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                            children: <Widget>[
//                                              RaisedButton(
//                                                  color: Theme.of(context).colorScheme.secondary,
//                                                  onPressed: (){
//                                                        Navigator.pop(context);
//                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewExpense(type: ExpenseType.fromSavedExpense,
//                                                          expense: new SavedExpense(name: widget.data.fromUser,
//                                                              names: widget.data.toUser,
//                                                              amount: widget.data.amount,
//                                                              note: widget.data.note,
//                                                              iD: widget.data.transactionID
//                                                          ),
//                                                        )));
//                                                  },
//                                                  child: Text('Igen', style: Theme.of(context).textTheme.button)
//                                              ),
//                                              RaisedButton(
//                                                  color: Theme.of(context).colorScheme.secondary,
//                                                  onPressed: (){ Navigator.pop(context);},
//                                                  child: Text('Nem', style: Theme.of(context).textTheme.button)
//                                              )
//                                            ],
//                                          )
//                                        ],
//                                      ),
//                                    ),
//                                  )
//                              );
//                            },
//                            color: Theme.of(context).colorScheme.secondary,
//                            label: Text('Szerkesztés', style: Theme.of(context).textTheme.button,),
//                            icon: Icon(Icons.edit, color: Theme.of(context).textTheme.button.color),
//                          ),
                          FlatButton.icon(
                              onPressed: (){
                                showDialog(
                                    context: context,
                                    child: Dialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      backgroundColor: Theme.of(context).colorScheme.onBackground,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text('Törölni szeretnéd a tételt?', style: Theme.of(context).textTheme.title,),
                                            SizedBox(height: 15,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                RaisedButton(
                                                    color: Theme.of(context).colorScheme.secondary,
                                                    onPressed: () async {

                                                      if(await _deleteElement(widget.data.transactionID)){
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
                                                              Flexible(child: Text("A tranzakciót sikeresen töröltük!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
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
                                                              Icon(Icons.clear, color: Colors.white,),
                                                              SizedBox(
                                                                width: 12.0,
                                                              ),
                                                              Flexible(child: Text("A tranzakció törlése sikertelen volt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                                                            ],
                                                          ),
                                                        );
                                                        FlutterToast ft = FlutterToast(context);
                                                        ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
                                                      }
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Igen', style: Theme.of(context).textTheme.button)
                                                ),
                                                RaisedButton(
                                                    color: Theme.of(context).colorScheme.secondary,
                                                    onPressed: (){ Navigator.pop(context);},
                                                    child: Text('Nem', style: Theme.of(context).textTheme.button)
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                );
                              },
                              color: Theme.of(context).colorScheme.secondary,
                              label: Text('Törlés', style: Theme.of(context).textTheme.button,),
                              icon: Icon(Icons.cancel, color: Theme.of(context).textTheme.button.color)
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ),
            Balances()
          ],
        ),
      ),
    );
  }
}
