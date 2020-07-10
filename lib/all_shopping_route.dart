import 'package:flutter/material.dart';
import 'shopping.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllHistoryRoute extends StatefulWidget {
  @override
  _AllHistoryRouteState createState() => _AllHistoryRouteState();
}

class _AllHistoryRouteState extends State<AllHistoryRoute> {
  ScrollController _scrollController = ScrollController();
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
      shoppingList=null;
      shoppingList=_getShoppingList();
    });
  }

  @override
  void initState() {
    super.initState();
//    shoppingList=null;
    shoppingList = _getShoppingList();
  }

  List<Widget> _generateShoppingList(List<ShoppingData> data){
    data=data.where((element) => element.fulfilled==false).toList();
    Function callback=this.callback;
    return data.map((element){
      return ShoppingListEntry(data: element, callback: callback,);
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bevásárlólista'),),
      body: Card(
        child: FutureBuilder(
          future: shoppingList,
          builder: (context, snapshot){
            if(snapshot.hasData){
              return ListView(
                  controller: _scrollController,
                  shrinkWrap: true,
                  children: _generateShoppingList(snapshot.data)
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
      //TODO:hide on top
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _scrollController.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        },
        child: Icon(Icons.keyboard_arrow_up, color: Theme.of(context).textTheme.button.color,),
      ),
    );
  }
}
