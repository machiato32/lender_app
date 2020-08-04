import 'package:flutter/material.dart';
import 'history.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'transaction_entry.dart';

class AllHistoryRoute extends StatefulWidget {
  @override
  _AllHistoryRouteState createState() => _AllHistoryRouteState();
}

class _AllHistoryRouteState extends State<AllHistoryRoute> {
  Future<List<TransactionData>> history;
  ScrollController _scrollController = ScrollController();


  Future<List<TransactionData>> _getHistory() async{
    Map<String,dynamic> map ={
      'name':'Samu'
    };
    String encoded = jsonEncode(map);
    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/history/', body: encoded);

    List<dynamic> decoded = jsonDecode(response.body)['history'];

    List<TransactionData> history = new List<TransactionData>();
    decoded.forEach((element){history.add(TransactionData.fromJson(element));});
    history = history.reversed.toList();
    return history;
  }
  void callback() {

    setState(() {
      history = null;
      history=_getHistory();
    });

  }

  @override
  void initState() {
    history = _getHistory();
    super.initState();

  }

  List<Widget> _generateHistory(List<TransactionData> data){
    Function callback=this.callback;
    return data.map((element){return TransactionEntry(data: element, callback: callback,);}).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Előzmények'),),
      body: ListView(
        controller: _scrollController,
        shrinkWrap: true,
        children: <Widget>[
          Card(
            child: FutureBuilder(
              future: history,
              builder: (context, snapshot){
                if(snapshot.hasData){
                  return Column(
                      children: _generateHistory(snapshot.data)
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
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
