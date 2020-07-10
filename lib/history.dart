import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'main.dart';
import 'history_route.dart';
import 'all_history_route.dart';

class HistoryData {
  DateTime date;
  String fromUser;
  List<String> toUser;
  String type;
  int amount, transactionID;
  String note;

  HistoryData({this.date, this.fromUser, this.toUser, this.type, this.amount, this.transactionID, this.note});

  factory HistoryData.fromJson(Map<String,dynamic> json){
//    json['Amount']=-json['Amount'];
    return HistoryData(
      amount: json['Amount'],
      fromUser: json['From_User'],
      toUser: json['To_User'].split(','),
      date: DateTime.parse(json['Date']),
      note: json['Note'],
      type: json['Type'],
      transactionID: json['Transaction_Id']
    );
  }

}

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();

}

class _HistoryState extends State<History> {
  Future<List<HistoryData>> history;
  
  Future<List<HistoryData>> getHistory() async{
    Map<String,dynamic> map ={
      'name':currentUser
    };
    String encoded = jsonEncode(map);
    http.Response response = await http.post('http://katkodominik.web.elte.hu/JSON/history/', body: encoded);

    List<dynamic> decoded = jsonDecode(response.body)['history'];

    List<HistoryData> history = new List<HistoryData>();
    decoded.forEach((element){history.add(HistoryData.fromJson(element));});
    history = history.reversed.toList();
    return history;
  }

  void callback() {

    setState(() {
      history = null;
      history=getHistory();
    });
  }

  @override
  void initState() {
//    history=null;
    history = getHistory();
    super.initState();

  }
  @override
  void didUpdateWidget(History oldWidget) {
//    history=null;
//    history = getHistory();
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Text('Előzmények', style: Theme.of(context).textTheme.title,),
            SizedBox(height: 40,),
            Column(
              children: <Widget>[
                FutureBuilder(
                  future: history,
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      return Column(
                        children: <Widget>[
                          Column(
                              children: generateHistory(snapshot.data)
                          ),
                          Visibility(
                            visible: (snapshot.data as List).length>0,
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

              ],
            ),
          ],
        ),
      ),
    );
  }
  List<Widget> generateHistory(List<HistoryData> data){
    if(data.length>5){
      data=data.take(5).toList();
    }
    Function callback=this.callback;
    return data.map((element){return HistoryEntry(data: element, callback: callback,);}).toList();
  }

}

class HistoryEntry extends StatefulWidget {
  final HistoryData data;
  final Function callback;
  const HistoryEntry({this.data, this.callback});
  @override
  _HistoryEntryState createState() => _HistoryEntryState();
}

class _HistoryEntryState extends State<HistoryEntry> {
  Color dateColor;
  Icon icon;
  TextStyle style;
  BoxDecoration boxDecoration;
  String date;
  String note;
  String names;
  String amount;
  int type;

  @override
  Widget build(BuildContext context) {
    date = DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.date);
    note = (widget.data.note=='')?'(nincs megjegyzés)':widget.data.note;
    if(widget.data.type=='add_expense'){
      type=0;
      icon=Icon(Icons.shopping_cart, color: Theme.of(context).textTheme.button.color);
      style=Theme.of(context).textTheme.button;
      dateColor=Theme.of(context).textTheme.button.color;
      boxDecoration=BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(4),
      );
      if(widget.data.toUser.length>1 && widget.data.toUser[1]!=''){
        names=widget.data.toUser.join(', ');
//        names = widget.data.toUser[0]+' és még ${widget.data.toUser.length-1}';
      }else{
        names=widget.data.toUser[0];
      }
      amount = widget.data.amount.toString();
    }else if(widget.data.type=='new_expense'){
      type=1;
      icon=Icon(Icons.shopping_basket, color: Theme.of(context).textTheme.body2.color);
      style=Theme.of(context).textTheme.body2;
      dateColor=Theme.of(context).colorScheme.surface;
      names = widget.data.fromUser;
      amount = (-widget.data.amount).toString();
      boxDecoration=BoxDecoration();
    }else if(widget.data.fromUser==currentUser){
      type=2;
      icon=Icon(Icons.call_made, color: Theme.of(context).textTheme.button.color);
      style=Theme.of(context).textTheme.button;
      dateColor=Theme.of(context).textTheme.button.color;
      boxDecoration=BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(4),
      );
      names = widget.data.toUser[0];
      amount = widget.data.amount.toString();
    }else{
      type=3;
      icon=Icon(Icons.call_received, color: Theme.of(context).textTheme.body2.color);
      style=Theme.of(context).textTheme.body2;
      dateColor=Theme.of(context).colorScheme.surface;
      names = widget.data.fromUser;
      amount = (-widget.data.amount).toString();
      boxDecoration=BoxDecoration();
    }
    return Container(
      decoration: boxDecoration,
      margin: EdgeInsets.only(bottom: 4),
      child: Material(
        type: MaterialType.transparency,

        child: InkWell(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryRoute(data: widget.data,))).then((val){
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
                          Flexible(child: Text(' - '+names, style: style, overflow: TextOverflow.ellipsis,)),
                          Text(': '+amount, style: style,)
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(width: 20,),
                          Text(date, style: TextStyle(color: dateColor, fontSize: 15),)
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,

                        children: <Widget>[
                          SizedBox(width: 20,),
                          Flexible(
                            child: Text(note, style: TextStyle(color: dateColor, fontSize: 15),overflow: TextOverflow.ellipsis,),
                            flex: 1,
                          ),

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

