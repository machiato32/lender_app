import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/history/all_history_page.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/payment/payment_entry.dart';
import 'package:csocsort_szamla/purchase/purchase_entry.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';

import '../essentials/widgets/error_message.dart';
import '../essentials/widgets/gradient_button.dart';

class History extends StatefulWidget {
  final Function callback;
  final int selectedIndex;
  History({this.callback, this.selectedIndex});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  Future<List<PaymentData>> _payments;
  Future<List<PurchaseData>> _transactions;
  TabController _tabController;

  Future<List<PurchaseData>> _getTransactions({bool overwriteCache=false}) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      http.Response response = await httpGet(
        uri: '/purchases?group=' + currentGroupId.toString()+'&limit=6',
        context: context,
        overwriteCache: overwriteCache,
        useGuest: useGuest
      );

      List<dynamic> decoded = jsonDecode(response.body)['data'];
      List<PurchaseData> transactionData = [];
      for (var data in decoded) {
        transactionData.add(PurchaseData.fromJson(data));
      }
      return transactionData;

    } catch (_) {
      throw _;
    }
  }

  Future<List<PaymentData>> _getPayments({bool overwriteCache=false}) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      http.Response response = await httpGet(
        uri: '/payments?group=' + currentGroupId.toString()+'&limit=6',
        context: context,
        overwriteCache: overwriteCache,
        useGuest: useGuest
      );
      List<dynamic> decoded = jsonDecode(response.body)['data'];
      List<PaymentData> paymentData = [];
      for (var data in decoded) {
        paymentData.add(PaymentData.fromJson(data));
      }
      return paymentData;
    } catch (_) {
      throw _;
    }
  }

  void callback({bool purchase=false, bool payment=false, bool reaction=false}) {
    if(!reaction){
      widget.callback();
      _payments = null;
      _payments = _getPayments(overwriteCache: true);
      _transactions = null;
      _transactions = _getTransactions(overwriteCache: true);
    }else{
      setState(() {
        if(payment){
          _payments = null;
          _payments = _getPayments(overwriteCache: true);
        }
        if(purchase){
          _transactions = null;
          _transactions = _getTransactions(overwriteCache: true);
        }
      });

    }

  }

  @override
  void initState() {

    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.selectedIndex);
    _payments = null;
    _payments = _getPayments();
    _transactions = null;
    _transactions = _getTransactions();
    super.initState();
  }

  @override
  void didUpdateWidget(History oldWidget) {
    _payments = null;
    _payments = _getPayments();
    _transactions = null;
    _transactions = _getTransactions();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Text(
              'history'.tr(),
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'history_explanation'.tr(),
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Tab(
                  icon: Icon(
                    Icons.shopping_cart,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Tab(
                    icon: Icon(
                  Icons.payments,
                  color: Theme.of(context).colorScheme.secondary,
                )),
              ],
            ),
            Container(
              height: 550,
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  FutureBuilder(
                    future: _transactions,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          if(snapshot.data.length==0){
                            return Padding(
                              padding: EdgeInsets.all(25),
                              child: Text('nothing_to_show'.tr(), style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center,),
                            );
                          }
                          return Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Column(
                                children: _generateTransactions(snapshot.data),
                              ),
                              Visibility(
                                visible: (snapshot.data as List).length > 5,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GradientButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AllHistoryRoute(startingIndex: _tabController.index)
                                            )
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                          Icons.more_horiz,
                                          color: Theme.of(context)
                                              .textTheme
                                              .button
                                              .color,
                                          ),
                                          SizedBox(width: 4,),
                                          Text(
                                          'more'.tr(),
                                          style: Theme.of(context).textTheme.button,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              )
                            ],
                          );
                        } else {
                          return ErrorMessage(
                            error: snapshot.error.toString(),
                            locationOfError: 'purchase_history',
                            callback: (){
                              setState(() {
                                _transactions = null;
                                _transactions = _getTransactions();
                              });
                            },
                          );
                        }
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                  FutureBuilder(
                    future: _payments,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          if(snapshot.data.length==0){
                            return Padding(
                              padding: EdgeInsets.all(25),
                              child: Text('nothing_to_show'.tr(), style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center,),
                            );
                          }
                          return Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Column(
                                  children: _generatePayments(snapshot.data)),
                              Visibility(
                                visible: (snapshot.data as List).length > 5,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GradientButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AllHistoryRoute(startingIndex: _tabController.index,)));
                                        },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.more_horiz,
                                            color: Theme.of(context)
                                                .textTheme
                                                .button
                                                .color,
                                          ),
                                          SizedBox(width: 4,),
                                          Text(
                                            'more'.tr(),
                                            style: Theme.of(context).textTheme.button,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        } else {
                          return ErrorMessage(
                            error: snapshot.error.toString(),
                            locationOfError: 'payment_history',
                            callback: (){
                              setState(() {
                                _payments = null;
                                _payments = _getPayments();
                              });
                            },
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

  List<Widget> _generatePayments(List<PaymentData> data) {
    if (data.length > 5) {
      data = data.take(5).toList();
    }
    Function callback = this.callback;
    return data.map((element) {
      return PaymentEntry(
        data: element,
        callback: callback,
      );
    }).toList();
  }

  List<Widget> _generateTransactions(List<PurchaseData> data) {
    if (data.length > 5) {
      data = data.take(5).toList();
    }
    Function callback = this.callback;
    return data.map((element) {
      return PurchaseEntry(
        data: element,
        callback: callback,
      );
    }).toList();
  }
}
