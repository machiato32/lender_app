import 'package:flutter/material.dart';
import 'main.dart';
import 'shopping_route.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'all_shopping_route.dart';

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
    try{
      http.Response response = await http.get('http://katkodominik.web.elte.hu/JSON/list/');

      List<dynamic> decoded = jsonDecode(response.body);

      List<ShoppingData> shopping = new List<ShoppingData>();
      decoded.forEach((element){shopping.add(ShoppingData.fromJson(element));});
      shopping = shopping.reversed.toList();
      return shopping;
    }catch(ex){
      return [ShoppingData(date: DateTime.now(), fulfilled: false, fulfilledUser: 'asd', item: 'asd', quantity: 'asd', shoppingId: 12, user: 'asd')];
    }
    //TODO:lol
  }

  void callback(){
    setState(() {
      shoppingList=null;
      shoppingList=_getShoppingList();
    });
  }

  @override
  void initState() {
    super.initState();
    shoppingList=null;
    shoppingList = _getShoppingList();
  }
  @override
  void didUpdateWidget(ShoppingList oldWidget) {
    shoppingList=null;
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
                    return Column(
                      children: <Widget>[
                        Column(
                            children: _generateShoppingList(snapshot.data)
                        ),
                        Visibility(
                          visible: (snapshot.data as List).where((element) => element.fulfilled==false).toList().length>0,
                          child: FlatButton.icon(
                              onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => AllHistoryRoute()));},
                              icon: Icon(Icons.more_horiz, color: Theme.of(context).textTheme.button.color,),
                              label: Text('Több', style: Theme.of(context).textTheme.button,),
                              color: Theme.of(context).colorScheme.secondary
                          ),
                        )
                      ],
//                        children: generateHistory(snapshot.data)
//                          HistoryElement(data: snapshot.data[index], callback: this.callback,);
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
    if(data.length>3){
      data=data.take(3).toList();
    }
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
  Icon icon;
  TextStyle style;
  BoxDecoration boxDecoration;

  String date;
  String item;
  String quantity;
  String user;



  @override
  Widget build(BuildContext context) {
    item = widget.data.item;
    user = widget.data.user;
    quantity = widget.data.quantity[0].toUpperCase()+widget.data.quantity.substring(1);
    date = DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.date);
    if(widget.data.user==currentUser){
      style=Theme.of(context).textTheme.button;
      dateColor=Theme.of(context).textTheme.button.color;
      icon=Icon(Icons.check_box, color: dateColor);
      boxDecoration=BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(4),
      );
    }else{
      style=Theme.of(context).textTheme.body2;
      dateColor=Theme.of(context).colorScheme.surface;
      icon=Icon(Icons.check, color: style.color,);
      boxDecoration=BoxDecoration();
    }
    return Container(
      decoration: boxDecoration,
      margin: EdgeInsets.only(bottom: 4),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingRoute(data: widget.data,))).then((val){
              widget.callback();
            });
          },
          borderRadius: BorderRadius.circular(4.0),
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          icon,
                          Flexible(child: Text('  '+quantity+' '+item, style: style, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(width: 33,),
                          Flexible(child: Text(user, style: style.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(width: 33,),
                          Text(date, style: TextStyle(color: dateColor, fontSize: 15),)
                        ],
                      ),


                      SizedBox(height: 4,)
                    ],
                  ),
                ),
              ],

            ),
          ),
        ),
      ),

    );
  }
}


class AddShoppingRoute extends StatefulWidget {
  final ShoppingData data;
  AddShoppingRoute({this.data});

  @override
  _AddShoppingRouteState createState() => _AddShoppingRouteState();
}

class _AddShoppingRouteState extends State<AddShoppingRoute> {
  TextEditingController itemController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  Future<bool> success;
  bool waiting=false;

  Future<bool> _postNewShopping(String item, String quantity) async{
    waiting=true;
    Map<String, dynamic> map = {
      "type":"request",
      "user":currentUser,
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
      appBar: AppBar(title: Text('Új listaelem felvétele')),
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
//                    Container(
//                        padding: EdgeInsets.all(5),
//                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
//                        child: Text('Tétel', style: Theme.of(context).textTheme.button,)
//                    ),
                    Row(
                      children: <Widget>[
                        Text('Tétel', style: Theme.of(context).textTheme.body2,),
                        SizedBox(width: 20,),
                        Flexible(
                          child: TextField(
                            controller: itemController,
                            keyboardType: TextInputType.text,
                            style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                            cursorColor: Theme.of(context).colorScheme.secondary,
                            decoration: InputDecoration(hintText: 'Büdös zokni'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
//                    Container(
//                        padding: EdgeInsets.all(5),
//                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
//                        child: Text('', style: Theme.of(context).textTheme.button,)
//                    ),
                    Row(
                      children: <Widget>[
                        Text('Mennyiség', style: Theme.of(context).textTheme.body2,),
                        SizedBox(width: 20,),
                        Flexible(
                          child: TextField(
                            controller: quantityController,
                            style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.body2.color),
                            cursorColor: Theme.of(context).colorScheme.secondary,
                            decoration: InputDecoration(hintText: '2 kiló'),
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

                          FocusScope.of(context).unfocus();
                          success=null;
                          String quantity = quantityController.text;
                          String item = itemController.text;
                          if(quantity!='' && item!=''){
                            Future<bool> success = _postNewShopping(item, quantity);
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
                                            Flexible(child: Text("A tétel fel lett véve a bevásárlólistára!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
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
                            if(widget.data!=null){
                              _deleteShopping(widget.data.shoppingId);
                            }
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
                                  Flexible(child: Text("Nem töltötted ki az egyik mezőt!", style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white))),
                                ],
                              ),
                            );
                            FlutterToast ft = FlutterToast(context);
                            ft.showToast(child: toast, toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
                            return;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ShoppingList(),

          ],

        ),
      ),
    );
  }
}
