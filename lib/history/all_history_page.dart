import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/transaction/transaction_entry.dart';
import 'package:csocsort_szamla/payment/payment_entry.dart';
import 'package:csocsort_szamla/http_handler.dart';

class AllHistoryRoute extends StatefulWidget {
  @override
  _AllHistoryRouteState createState() => _AllHistoryRouteState();
}

class _AllHistoryRouteState extends State<AllHistoryRoute>
    with TickerProviderStateMixin {
  Future<List<TransactionData>> _transactions;
  Future<List<PaymentData>> _payments;

  ScrollController _transactionScrollController = ScrollController();
  ScrollController _paymentScrollController = ScrollController();
  TabController _tabController;
  int _selectedIndex = 0;

  Future<List<TransactionData>> _getTransactions() async {
    try {
      http.Response response = await httpGet(
          uri: '/transactions?group=' + currentGroupId.toString(),
          context: context);
      List<dynamic> decoded = jsonDecode(response.body)['data'];
      List<TransactionData> transactionData = [];
      for (var data in decoded) {
        transactionData.add(TransactionData.fromJson(data));
      }
      return transactionData;

    } catch (_) {
      throw _;
    }
  }

  Future<List<PaymentData>> _getPayments() async {
    try {
      http.Response response = await httpGet(
          uri: '/payments?group=' + currentGroupId.toString(),
          context: context);

      List<dynamic> response2 = jsonDecode(response.body)['data'];
      List<PaymentData> paymentData = [];
      for (var data in response2) {
        paymentData.add(PaymentData.fromJson(data));
      }
      return paymentData;
    } catch (_) {
      throw _;
    }
  }

  void callback() {
    setState(() {
      _transactions = null;
      _transactions = _getTransactions();

      _payments = null;
      _payments = _getPayments();
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    _transactions = null;
    _transactions = _getTransactions();

    _payments = null;
    _payments = _getPayments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('history'.tr()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (_index) {
          setState(() {
            _selectedIndex = _index;
            _tabController.animateTo(_index);
          });
        },
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              title: Text('transactions'.tr())),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), title: Text('payments'.tr()))
        ],
      ),
      body: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            FutureBuilder(
              future: _transactions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return ListView(
                        controller: _transactionScrollController,
                        key: PageStorageKey('transactionList'),
                        padding: EdgeInsets.all(10),
                        shrinkWrap: true,
                        children: _generateTransactions(snapshot.data));
                  } else {
                    return InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(snapshot.error.toString()),
                        ),
                        onTap: () {
                          setState(() {
                            _transactions = null;
                            _transactions = _getTransactions();
                          });
                        });
                  }
                }
                return Center(
                  child: CircularProgressIndicator(),
                  heightFactor: 2,
                );
              },
            ),
            FutureBuilder(
              future: _payments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return ListView(
                        controller: _paymentScrollController,
                        key: PageStorageKey('paymentList'),
                        padding: EdgeInsets.all(10),
                        shrinkWrap: true,
                        children: _generatePayments(snapshot.data));
                  } else {
                    return InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(snapshot.error.toString()),
                        ),
                        onTap: () {
                          setState(() {
                            _payments = null;
                            _payments = _getPayments();
                          });
                        });
                  }
                }
                return Center(
                  child: CircularProgressIndicator(),
                  heightFactor: 2,
                );
              },
            ),
          ]),
      //TODO:hide on top
      floatingActionButton: Visibility(
        visible: true,
        child: FloatingActionButton(
          onPressed: () {
            if (_selectedIndex == 0 &&
                _transactionScrollController.hasClients) {
              _transactionScrollController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
            } else if (_selectedIndex == 1 &&
                _paymentScrollController.hasClients) {
              _paymentScrollController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
            }
          },
//          child: ImageIcon(AssetImage('assets/dodo_color.png')),
          child: Icon(
            Icons.keyboard_arrow_up,
            color: Theme.of(context).textTheme.button.color,
          ),
        ),
      ),
    );
  }

  List<Widget> _generatePayments(List<PaymentData> data) {
    Function callback = this.callback;
    return data.map((element) {
      return PaymentEntry(
        data: element,
        callback: callback,
      );
    }).toList();
  }

  List<Widget> _generateTransactions(List<TransactionData> data) {
    Function callback = this.callback;
    return data.map((element) {
      return TransactionEntry(
        data: element,
        callback: callback,
      );
    }).toList();
  }
}
