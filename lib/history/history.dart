import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:csocsort_szamla/history/all_history_page.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/payment/payment_entry.dart';
import 'package:csocsort_szamla/transaction/transaction_entry.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class History extends StatefulWidget {
  final Function callback;
  History({this.callback});
  @override
  _HistoryState createState() => _HistoryState();

}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin{
  Future<List<PaymentData>> _payments;
  Future<List<TransactionData>> _transactions;
  TabController _controller;


  Future<List<TransactionData>> _getTransactions() async{
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.get(APPURL+'/transactions?group='+currentGroupId.toString(), headers: header);

      if(response.statusCode==200){
        List<dynamic> response2 = jsonDecode(response.body)['data'];
        List<TransactionData> transactionData=[];
        for(var data in response2){
          transactionData.add(TransactionData.fromJson(data));
        }
        return transactionData;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterRoute()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }

  Future<List<PaymentData>> _getPayments() async{
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };
      http.Response response = await http.get(APPURL+'/payments?group='+currentGroupId.toString(), headers: header);

      if(response.statusCode==200){
        List<dynamic> response2 = jsonDecode(response.body)['data'];
        List<PaymentData> paymentData=[];
        for(var data in response2){
          paymentData.add(PaymentData.fromJson(data));
        }
        return paymentData;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          FlutterToast ft = FlutterToast(context);
          ft.showToast(child: Text('Sajnos újra be kell jelentkezned!'), toastDuration: Duration(seconds: 2), gravity: ToastGravity.BOTTOM);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterRoute()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }

  void callback() {
    widget.callback();
    _payments = null;
    _payments=_getPayments();
    _transactions=null;
    _transactions=_getTransactions();
  }

  @override
  void initState() {
    _controller=TabController(length: 2, vsync: this);
    _payments=null;
    _payments = _getPayments();
    _transactions=null;
    _transactions=_getTransactions();
    super.initState();

  }
  @override
  void didUpdateWidget(History oldWidget) {
    _payments=null;
    _payments = _getPayments();
    _transactions=null;
    _transactions=_getTransactions();
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child:Column(
//          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Előzmények', style: Theme.of(context).textTheme.headline6,),
            SizedBox(height: 40,),
            TabBar(
              controller: _controller,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.secondary,),
//                  child: Text('Kaptam', style: Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).colorScheme.secondary),),
                ),
                Tab(icon: Icon(Icons.attach_money, color: Theme.of(context).colorScheme.secondary,)),
              ],
            ),
            Container(
              height: 500,
              child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  FutureBuilder(
                    future: _transactions,
                    builder: (context, snapshot){
                      if(snapshot.connectionState==ConnectionState.done){
                        if(snapshot.hasData){

                          return Column(
                            children: <Widget>[
                              SizedBox(height: 10,),
                              Column(
                                children: _generateTransactions(snapshot.data),
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
                                  _payments=null;
                                  _payments=_getPayments();
                                });
                              }
                          );
                        }
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                  FutureBuilder(
                    future: _payments,
                    builder: (context, snapshot){
                      if(snapshot.connectionState==ConnectionState.done){
                        if(snapshot.hasData){

                          return Column(
                            children: <Widget>[
                              SizedBox(height: 10,),
                              Column(
                                  children: _generatePayments(snapshot.data)
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
                                  _payments=null;
                                  _payments=_getPayments();
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
  List<Widget> _generatePayments(List<PaymentData> data){
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



