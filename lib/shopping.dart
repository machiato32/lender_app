import 'package:flutter/material.dart';
import 'main.dart';
import 'new_expense.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ShoppingData {
  DateTime date;
  String user, fulfilledUser;
  String item, quantity;
  int shoppingId;
  bool fulfilled;

  ShoppingData({this.date, this.user, this.fulfilledUser, this.item, this.quantity, this.shoppingId, this.fulfilled});

  factory ShoppingData.fromJson(Map<String,dynamic> json){
    return ShoppingData(
        shoppingId: json['Id'],
        user: json['User'],
        item: json['Name'],
        date: DateTime.parse(json['Date']),
        quantity: json['Quantity'],
        fulfilled: json['Fulfilled']==1,
        fulfilledUser: json['Fulfilled_by']
    );
  }

}

class ShoppingList extends StatefulWidget {
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {

  Future<List<ShoppingData>> shoppingList;

  Future<List<ShoppingData>> _getShoppingList() async{

    http.Response response = await http.get('http://katkodominik.web.elte.hu/JSON/list/');

    List<dynamic> decoded = jsonDecode(response.body);

    List<ShoppingData> shopping = new List<ShoppingData>();
    decoded.forEach((element){shopping.add(ShoppingData.fromJson(element));});
    shopping = shopping.reversed.toList();
    return shopping;
  }

  void callback(){
    setState(() {
      shoppingList=_getShoppingList();
    });
  }

  @override
  void initState() {
    super.initState();
    shoppingList = _getShoppingList();
  }
  @override
  void didUpdateWidget(ShoppingList oldWidget) {
    shoppingList = _getShoppingList();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Text('Bevásárlólista', style: Theme.of(context).textTheme.title,),
            SizedBox(height: 40,),
            Center(
              child: FutureBuilder(
                future: shoppingList,
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    return ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 400),
                      child: ListView(
                          shrinkWrap: true,
                          children: _generateShoppingList(snapshot.data)
//                          HistoryElement(data: snapshot.data[index], callback: this.callback,);
                      ),
                    );
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  List<Widget> _generateShoppingList(List<ShoppingData> data){
    data=data.where((element) => element.fulfilled==false).toList();
    Function callback=this.callback;
    return data.map((element){
      return ShoppingListEntry(data: element, callback: callback,);
    }).toList();
  }
}

class ShoppingListEntry extends StatefulWidget {
  final ShoppingData data;
  final Function callback;
  const ShoppingListEntry({this.data, this.callback});
  @override
  _ShoppingListEntryState createState() => _ShoppingListEntryState();
}

class _ShoppingListEntryState extends State<ShoppingListEntry> {
  Color dateColor;
  TextStyle style;
  String date;
  String item;
  String quantity;
  String user;

  Future<bool> _deleteShopping(int id) async {
    Map<String, dynamic> map = {
      "type":'delete',
      "id":id.toString()
    };

    String encoded = json.encode(map);
    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/', body: encoded);

    widget.callback();

    return response.statusCode==200;
  }

  @override
  Widget build(BuildContext context) {
    item = widget.data.item;
    user = widget.data.user;
    quantity = widget.data.quantity;
    date = DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.date);
    if(widget.data.user==name){
      style=Theme.of(context).textTheme.button;
      dateColor=Theme.of(context).textTheme.button.color;
      return Card(
        color: Theme.of(context).colorScheme.secondary,
        margin: EdgeInsets.only(bottom: 4),
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.check_box, color: dateColor,),
                      Text(' - '+user, style: TextStyle(color: dateColor, fontSize: 23)),

                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20,),
                      Text(quantity+' '+item, style: style),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20,),
                      Text(date, style: TextStyle(color: dateColor, fontSize: 15),)
                    ],
                  ),
                  SizedBox(height: 4,)
                ],
              ),
              Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
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
                                      Text('Szerkeszteni szeretnéd a tételt?', style: Theme.of(context).textTheme.title, textAlign: TextAlign.center,),
                                      SizedBox(height: 15,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          RaisedButton(
                                              color: Theme.of(context).colorScheme.secondary,
                                              onPressed: (){
                                                Navigator.pop(context);
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingRoute(data: widget.data,)));
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
                        child: Icon(Icons.edit, color: Theme.of(context).textTheme.button.color),
                      ),
                      FlatButton(
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
                                                onPressed: (){
                                                  _deleteShopping(widget.data.shoppingId);
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
                          child: Icon(Icons.cancel, color: Theme.of(context).textTheme.button.color)
                      ),
                    ],
                  )
              )
            ],
          ),
        ),

      );
    }else{
      style=Theme.of(context).textTheme.body2;
      dateColor=Theme.of(context).colorScheme.surface;
      Color iconColor = Theme.of(context).textTheme.body2.color;
      return Container(
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.check_box, color: iconColor),
                    Text(' - '+user, style: TextStyle(color: iconColor, fontSize: 23)),

                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(width: 20,),
                    Text(quantity+' '+item, style: style),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(width: 20,),
                    Text(date, style: TextStyle(color: dateColor, fontSize: 15),)
                  ],
                ),
                SizedBox(height: 4,)
              ],
            ),
            Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
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
                                    Text('Megvetted a tételt?', style: Theme.of(context).textTheme.title, textAlign: TextAlign.center,),
                                    SizedBox(height: 15,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        RaisedButton(
                                            color: Theme.of(context).colorScheme.secondary,
                                            onPressed: (){
                                              Navigator.pop(context);
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => NewExpense(
                                                  type: ExpenseType.fromShopping, shoppingData: widget.data,
                                                )));
                                            },
                                            child: Text('Igen', style: Theme.of(context).textTheme.button)
                                        ),
                                        RaisedButton(
                                            color: Theme.of(context).colorScheme.secondary,
                                            onPressed: (){ Navigator.pop(context); },
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
                      child: Icon(Icons.check, color: iconColor),
                    ),

                  ],
                )
            )
          ],
        ),
      );
    }
  }
}


class ShoppingRoute extends StatefulWidget {
  final ShoppingData data;
  ShoppingRoute({this.data});

  @override
  _ShoppingRouteState createState() => _ShoppingRouteState();
}

class _ShoppingRouteState extends State<ShoppingRoute> {
  TextEditingController itemController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  Future<bool> success;
  bool waiting=false;

  Future<bool> _postNewShopping(String item, String quantity) async{
    waiting=true;
    Map<String, dynamic> map = {
      "type":"request",
      "user":name,
      "name":item,
      "quantity":quantity
    };

    String encoded = json.encode(map);

    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/list/', body: encoded);

    return response.statusCode==200;

  }

  Future<bool> _deleteShopping(int id) async {
    Map<String, dynamic> map = {
      "type":'delete',
      "id":id.toString()
    };

    String encoded = json.encode(map);
    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/', body: encoded);

    return response.statusCode==200;
  }

  void setInitialValues(){
    itemController.text=widget.data.item;
    quantityController.text=widget.data.quantity;
  }

  @override
  void initState() {
    super.initState();
    if(widget.data!=null){
      setInitialValues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ezt szeretném')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: <Widget>[
            Card(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10,),
                    Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                        child: Text('Mit szeretnél?', style: Theme.of(context).textTheme.button,)
                    ),
                    TextField(
                      controller: itemController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                    SizedBox(height: 20,),
                    Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                        child: Text('Mennyit szeretnél?', style: Theme.of(context).textTheme.button,)
                    ),
                    TextField(
                      controller: quantityController,
                      style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                      cursorColor: Theme.of(context).colorScheme.secondary,
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
                          String quantity = quantityController.text;
                          String item = itemController.text;
                          if(quantity!='' && item!=''){
                            success=_postNewShopping(item, quantity);
                            if(widget.data!=null){
                              _deleteShopping(widget.data.shoppingId);
                            }
                          }

                          setState(() {

                          });
                        },
                      ),
                    ),
                  ],
                ),
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
            ShoppingList(),

          ],

        ),
      ),
    );
  }
}
