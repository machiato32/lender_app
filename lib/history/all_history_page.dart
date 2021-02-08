import 'package:csocsort_szamla/essentials/ad_management.dart';
import 'package:csocsort_szamla/main/is_guest_banner.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/purchase/purchase_entry.dart';
import 'package:csocsort_szamla/payment/payment_entry.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/app_theme.dart';

class AllHistoryRoute extends StatefulWidget {
  final int startingIndex;
  AllHistoryRoute({@required this.startingIndex});
  @override
  _AllHistoryRouteState createState() => _AllHistoryRouteState();
}

class _AllHistoryRouteState extends State<AllHistoryRoute>
    with TickerProviderStateMixin {
  Future<List<PurchaseData>> _purchases;
  Future<List<PaymentData>> _payments;

  ScrollController _purchaseScrollController = ScrollController();
  ScrollController _paymentScrollController = ScrollController();
  TabController _tabController;
  int _selectedIndex = 0;

  Future<List<PurchaseData>> _getPurchases({bool overwriteCache=false}) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      http.Response response = await httpGet(
        uri: '/purchases?group=' + currentGroupId.toString(),
        context: context,
        overwriteCache: overwriteCache,
        useGuest: useGuest
      );
      List<dynamic> decoded = jsonDecode(response.body)['data'];
      List<PurchaseData> purchaseData = [];
      for (var data in decoded) {
        purchaseData.add(PurchaseData.fromJson(data));
      }
      return purchaseData;

    } catch (_) {
      throw _;
    }
  }

  Future<List<PaymentData>> _getPayments({bool overwriteCache=false}) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      http.Response response = await httpGet(
        uri: '/payments?group=' + currentGroupId.toString(),
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
      clearAllCache();
      setState(() {
        _payments = null;
        _payments = _getPayments(overwriteCache: true);
        _purchases = null;
        _purchases = _getPurchases(overwriteCache: true);
      });
    }else{
      setState(() {
        if(payment){
          _payments = null;
          _payments = _getPayments(overwriteCache: true);
        }
        if(purchase){
          _purchases = null;
          _purchases = _getPurchases(overwriteCache: true);
        }
      });

    }

  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.startingIndex);
    _selectedIndex = widget.startingIndex;

    _purchases = null;
    _purchases = _getPurchases();

    _payments = null;
    _payments = _getPayments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('history'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: AppTheme.gradientFromTheme(Theme.of(context))
          ),
        ),
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
              label: 'purchases'.tr(),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'payments'.tr()
          )
        ],
      ),
      body: Column(
        children: [
          IsGuestBanner(callback: callback,),
          Expanded(
            child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  FutureBuilder(
                    future: _purchases,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return ListView(
                              controller: _purchaseScrollController,
                              key: PageStorageKey('purchaseList'),
                              padding: EdgeInsets.all(10),
                              shrinkWrap: true,
                              children: _generatePurchase(snapshot.data));
                        } else {
                          return InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(snapshot.error.toString()),
                              ),
                              onTap: () {
                                setState(() {
                                  _purchases = null;
                                  _purchases = _getPurchases();
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
          ),
          Visibility(
              visible: MediaQuery.of(context).viewInsets.bottom == 0,
              child: adUnitForSite('history')
          ),
        ],
      ),
      //TODO:hide on top
      floatingActionButton: Visibility(
        visible: true,
        child: FloatingActionButton(
          onPressed: () {
            if (_selectedIndex == 0 &&
                _purchaseScrollController.hasClients) {
              _purchaseScrollController.animateTo(
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
    DateTime nowNow = DateTime.now();
    DateTime now = DateTime(nowNow.year, nowNow.month, nowNow.day);
    Widget initial =
    Center(
      child: Container(
          padding: EdgeInsets.all(8),
          child: Text(DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 1)))+' - '+DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 7))), style: Theme.of(context).textTheme.subtitle2,)
      ),
    );
    return [initial]..addAll(data.map((element) {
      if(now.difference(element.updatedAt).inDays>7){
        int toSubtract = (now.difference(element.updatedAt).inDays/7).floor();
        now=now.subtract(Duration(days: toSubtract*7));
        return
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: Text(DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 1)))+' - '+DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 7))), style: Theme.of(context).textTheme.subtitle2,)
            ),
            PaymentEntry(
              data: element,
              callback: callback,
            ),
          ],
        );
      }
      return PaymentEntry(
        data: element,
        callback: callback,
      );
    }).toList());
  }

  List<Widget> _generatePurchase(List<PurchaseData> data) {
    Function callback = this.callback;
    DateTime nowNow = DateTime.now();
    DateTime now = DateTime(nowNow.year, nowNow.month, nowNow.day);
    Widget initial =
    Center(
      child: Container(
          padding: EdgeInsets.all(8),
          child: Text(DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 1)))+' - '+DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 7))), style: Theme.of(context).textTheme.subtitle2,)
      ),
    );
    return [initial]..addAll(data.map((element) {
      if(now.difference(element.updatedAt).inDays>7){
        int toSubtract = (now.difference(element.updatedAt).inDays/7).floor();
        now=now.subtract(Duration(days: toSubtract*7));
        return
          Column(
            children: [
              Container(
                  padding: EdgeInsets.all(8),
                  child: Text(DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 1)))+' - '+DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 7))), style: Theme.of(context).textTheme.subtitle2,)
              ),
              PurchaseEntry(
                data: element,
                callback: callback,
              ),
            ],
          );
      }
      return PurchaseEntry(
        data: element,
        callback: callback,
      );
    }).toList());
  }
}
