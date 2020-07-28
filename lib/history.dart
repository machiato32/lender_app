import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'history_route.dart';
import 'all_history_route.dart';
import 'bottom_sheet_custom.dart';
import 'config.dart';
import 'payment_entry.dart';
import 'person.dart';


class TransactionData {
  String type;
  DateTime updatedAt;
  String buyerId, buyerNickname;
  List<Member> receivers;
  double totalAmount;
  int transactionId;
  String name;

  TransactionData({this.type, this.updatedAt, this.buyerId,
      this.buyerNickname, this.receivers, this.totalAmount, this.transactionId,
      this.name});

  factory TransactionData.fromJson(Map<String, dynamic> json){
    return TransactionData(
      type: json['type'],
      transactionId: json['data']['transaction_id'],
      name: json['data']['name'],
      updatedAt: json['data']['updated_at']==null?DateTime.now():json['data']['updated_at'],
      buyerId: json['data']['buyer_id'],
      buyerNickname: json['data']['buyer_nickname'],
      totalAmount: json['data']['total_amount'],
      receivers: json['data']['receivers'].map<Member>((element)=>Member.fromJson(element)).toList()
    );
  }

}


class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();

}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin{
  Future<List<PaymentData>> payments;
  Future<List<TransactionData>> transactions;
  TabController _controller;


  Future<List<TransactionData>> _getTransactions() async{
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.get(APPURL+'/transactions/groups/'+currentGroupId.toString(), headers: header);
      List<dynamic> response2 = jsonDecode(response.body);
      if(response.statusCode==200){
        List<TransactionData> transactionData=[];
        for(var data in response2){
          transactionData.add(TransactionData.fromJson(data));
        }
        return transactionData;
      }else{
        throw 'ASD';
      }
    }catch(_){
      throw 'Hiba';
    }
  }

  Future<List<PaymentData>> _getPayments() async{
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.get(APPURL+'/payments/groups/'+currentGroupId.toString(), headers: header);
      List<dynamic> response2 = jsonDecode(response.body);
      if(response.statusCode==200){
        List<PaymentData> paymentData=[];
        for(var data in response2){
          paymentData.add(PaymentData.fromJson(data));
        }
        return paymentData;
      }else{
        throw 'ASD';
      }
    }catch(_){
      throw 'Hiba';
    }
  }

  void callback() {

    setState(() {
      payments = null;
      payments=_getPayments();
      transactions=null;
      transactions=_getTransactions();
    });
  }

  @override
  void initState() {
    _controller=TabController(length: 2, vsync: this);
    payments=null;
    payments = _getPayments();
    transactions=null;
    transactions=_getTransactions();
    super.initState();

  }
  @override
  void didUpdateWidget(History oldWidget) {
    payments=null;
    payments = _getPayments();
    transactions=null;
    transactions=_getTransactions();
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child:Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Előzmények', style: Theme.of(context).textTheme.title,),
            SizedBox(height: 40,),
            TabBar(
              controller: _controller,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.secondary,),
//                  child: Text('Kaptam', style: Theme.of(context).textTheme.body2.copyWith(color: Theme.of(context).colorScheme.secondary),),
                ),
                Tab(icon: Icon(Icons.attach_money, color: Theme.of(context).colorScheme.secondary,)),
              ],
            ),
            Container(
              height: 400,
              child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  FutureBuilder(
                    future: transactions,
                    builder: (context, snapshot){
                      if(snapshot.connectionState==ConnectionState.done){
                        if(snapshot.hasData){

                          return Column(
                            children: <Widget>[
                              SizedBox(height: 10,),
                              Column(
                                  children: _generateTransactions(snapshot.data)
                              ),
                              Visibility(
                                visible: (snapshot.data as List).length>5,
                                child: FlatButton.icon(
                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => AllHistoryRoute()));
                                    },
                                    icon: Icon(Icons.more_horiz, color: Theme.of(context).textTheme.button.color,),
                                    label: Text('Több', style: Theme.of(context).textTheme.button,),
                                    color: Theme.of(context).colorScheme.secondary
                                ),
                              )
                            ],
                          );
                        }else{
                          return InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(snapshot.error.toString()),
                              ),
                              onTap: (){
                                setState(() {
                                  payments=null;
                                  payments=_getPayments();
                                });
                              }
                          );
                        }
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                  FutureBuilder(
                    future: payments,
                    builder: (context, snapshot){
                      if(snapshot.connectionState==ConnectionState.done){
                        if(snapshot.hasData){

                          return Column(
                            children: <Widget>[
                              SizedBox(height: 10,),
                              Column(
                                  children: _generatePayment(snapshot.data)
                              ),
                              Visibility(
                                visible: (snapshot.data as List).length>5,
                                child: FlatButton.icon(
                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => AllHistoryRoute()));
                                    },
                                    icon: Icon(Icons.more_horiz, color: Theme.of(context).textTheme.button.color,),
                                    label: Text('Több', style: Theme.of(context).textTheme.button,),
                                    color: Theme.of(context).colorScheme.secondary
                                ),
                              )
                            ],
                          );
                        }else{
                          return InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(snapshot.error.toString()),
                              ),
                              onTap: (){
                                setState(() {
                                  payments=null;
                                  payments=_getPayments();
                                });
                              }
                          );
                        }
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                ],

              ),
            )

          ],
        ),

      ),
    );
  }
  List<Widget> _generatePayment(List<PaymentData> data){
    if(data.length>5){
      data=data.take(5).toList();
    }
    Function callback=this.callback;
    return data.map((element){return PaymentEntry(data: element, callback: callback,);}).toList();
  }

  List<Widget> _generateTransactions(List<TransactionData> data){
    if(data.length>5){
      data=data.take(5).toList();
    }
    Function callback=this.callback;
    return data.map((element){return TransactionEntry(data: element, callback: callback,);}).toList();
  }

}

class TransactionEntry extends StatefulWidget {
  final TransactionData data;
  final Function callback;
  const TransactionEntry({this.data, this.callback});
  @override
  _TransactionEntryState createState() => _TransactionEntryState();
}

class _TransactionEntryState extends State<TransactionEntry> {
  Color dateColor;
  Icon icon;
  TextStyle style;
  BoxDecoration boxDecoration;
  String date;
  String note;
  String names;
  String amount;

  @override
  Widget build(BuildContext context) {
    date = DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.updatedAt);
    note = (widget.data.name=='')?'(Nincs megjegyzés)':widget.data.name[0].toUpperCase()+widget.data.name.substring(1);
    if(widget.data.type=='buyed'){
      icon=Icon(Icons.shopping_cart, color: Theme.of(context).textTheme.button.color);
      style=Theme.of(context).textTheme.button;
      dateColor=Theme.of(context).textTheme.button.color;
      boxDecoration=BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(4),
      );
      if(widget.data.receivers.length>1){
        names=widget.data.receivers.join(', ');
      }else{
        names=widget.data.receivers[0].nickname;
      }
      amount = widget.data.totalAmount.toString();
    }else if(widget.data.type=='received'){
      icon=Icon(Icons.shopping_basket, color: Theme.of(context).textTheme.body2.color);
      style=Theme.of(context).textTheme.body2;
      dateColor=Theme.of(context).colorScheme.surface;
      names = widget.data.buyerNickname;
      amount = (-widget.data.totalAmount).toString();
      boxDecoration=BoxDecoration();
    }
    return Container(
      decoration: boxDecoration,
      margin: EdgeInsets.only(bottom: 4, left: 4, right: 4),
      child: Material(
        type: MaterialType.transparency,

        child: InkWell(
          onTap: () async {
//            await Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryRoute(data: widget.data,))).then((val){
//              widget.callback();
//            });
            showModalBottomSheetCustom(
                context: context,
                backgroundColor: Theme.of(context).cardTheme.color,
                builder: (context)=>SingleChildScrollView(
                    child: HistoryAllInfo(widget.data)
                )
            ).then((val){
              if(val=='deleted')
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
                          Flexible(child: Text('  '+note, style: style,overflow: TextOverflow.ellipsis,),),
                          Text(': '+amount, style: style,)
                        ],
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.max,

                        children: <Widget>[
                          SizedBox(width: 33,),
                          Flexible(
                            child: Text(names, style: TextStyle(color: dateColor, fontSize: 15), overflow: TextOverflow.ellipsis,),
                            flex: 1,
                          ),

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

