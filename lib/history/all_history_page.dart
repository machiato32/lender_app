import 'dart:convert';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/ad_management.dart';
import 'package:csocsort_szamla/essentials/app_theme.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/error_message.dart';
import 'package:csocsort_szamla/main/is_guest_banner.dart';
import 'package:csocsort_szamla/payment/payment_entry.dart';
import 'package:csocsort_szamla/purchase/purchase_entry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AllHistoryRoute extends StatefulWidget {
  ///Defines whether to show purchases (0) or payments (1)
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

  Future<List<PurchaseData>> _getPurchases(
      {bool overwriteCache = false}) async {
    try {
      bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
      http.Response response = await httpGet(
          uri: generateUri(GetUriKeys.purchasesAll),
          context: context,
          overwriteCache: overwriteCache,
          useGuest: useGuest);
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

  Future<List<PaymentData>> _getPayments({bool overwriteCache = false}) async {
    try {
      bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
      http.Response response = await httpGet(
          uri: generateUri(GetUriKeys.paymentsAll),
          context: context,
          overwriteCache: overwriteCache,
          useGuest: useGuest);

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

  void callback({bool purchase = false, bool payment = false}) {
    if (!purchase && !payment) {
      //IsGuestBanner callback
      clearGroupCache();
      setState(() {
        _payments = null;
        _payments = _getPayments(overwriteCache: true);
        _purchases = null;
        _purchases = _getPurchases(overwriteCache: true);
      });
      return;
    }
    setState(() {
      if (payment) {
        deleteCache(uri: generateUri(GetUriKeys.paymentsAll));
        deleteCache(uri: generateUri(GetUriKeys.paymentsFirst6));
        deleteCache(
            uri: 'payments?group=$currentGroupId&from_date',
            multipleArgs: true); //payments date
        _payments = null;
        _payments = _getPayments(overwriteCache: true);
      }
      if (purchase) {
        deleteCache(uri: generateUri(GetUriKeys.purchasesAll));
        deleteCache(uri: generateUri(GetUriKeys.purchasesFirst6));
        deleteCache(
            uri: 'purchases?group=$currentGroupId&from_date',
            multipleArgs: true); //purchases date
        _purchases = null;
        _purchases = _getPurchases(overwriteCache: true);
      }
      deleteCache(uri: generateUri(GetUriKeys.groupCurrent)); //Balances
      deleteCache(uri: generateUri(GetUriKeys.userBalanceSum));
    });
  }

  @override
  void initState() {
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.startingIndex);
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
        title: Text(
          'history'.tr(),
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: AppTheme.gradientFromTheme(Theme.of(context))),
        ),
        actions: [
          //TODO:daterange
          // IconButton(
          //   icon: Icon(Icons.search_rounded),
          //   onPressed: (){
          //
          //   },
          // )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).cardTheme.color,
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
              icon: Icon(Icons.attach_money), label: 'payments'.tr())
        ],
      ),
      body: Column(
        children: [
          IsGuestBanner(
            callback: callback,
          ),
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
                              shrinkWrap: true,
                              children: _generatePurchase(snapshot.data));
                        } else {
                          return ErrorMessage(
                            error: snapshot.error.toString(),
                            locationOfError: 'purchase_history_page',
                            callback: () {
                              setState(() {
                                _purchases = null;
                                _purchases = _getPurchases();
                              });
                            },
                          );
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
                              shrinkWrap: true,
                              children: _generatePayments(snapshot.data));
                        } else {
                          return ErrorMessage(
                            error: snapshot.error.toString(),
                            locationOfError: 'payment_history_page',
                            callback: () {
                              setState(() {
                                _payments = null;
                                _payments = _getPayments();
                              });
                            },
                          );
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
              child: adUnitForSite('history')),
        ],
      ),
      //TODO:hide on top
      floatingActionButton: Visibility(
        visible: true,
        child: FloatingActionButton(
          onPressed: () {
            if (_selectedIndex == 0 && _purchaseScrollController.hasClients) {
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
    //Initial
    DateTime now = DateTime(nowNow.year, nowNow.month, nowNow.day);
    Widget initial;
    if (now.difference(data[0].updatedAt).inDays > 7) {
      int toSubtract = (now.difference(data[0].updatedAt).inDays / 7).floor();
      now = now.subtract(Duration(days: toSubtract * 7));
      initial = Column(
        children: [
          Container(
              padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: Text(
                DateFormat('yyyy/MM/dd')
                        .format(now.subtract(Duration(days: 7))) +
                    ' - ' +
                    DateFormat('yyyy/MM/dd')
                        .format(now.subtract(Duration(days: 1))),
                style: Theme.of(context).textTheme.subtitle2,
              )),
        ],
      );
    } else {
      initial = Center(
        child: Container(
            padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Text(
              DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 7))) +
                  ' - ' +
                  DateFormat('yyyy/MM/dd')
                      .format(now.subtract(Duration(days: 1))),
              style: Theme.of(context).textTheme.subtitle2,
            )),
      );
    }
    List<Widget> allEntries = [initial];
    List<PaymentEntry> weekEntries = [];
    for (PaymentData data in data) {
      if (now.difference(data.updatedAt).inDays > 7) {
        int toSubtract = (now.difference(data.updatedAt).inDays / 7).floor();
        now = now.subtract(Duration(days: toSubtract * 7));
        allEntries.add(Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: weekEntries,
            ),
          ),
        ));
        weekEntries = [];
        allEntries.add(Center(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Text(
              DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 7))) +
                  ' - ' +
                  DateFormat('yyyy/MM/dd')
                      .format(now.subtract(Duration(days: 1))),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
        ));
      } else {
        weekEntries.add(PaymentEntry(
          data: data,
          callback: callback,
        ));
      }
    }
    if (weekEntries.isNotEmpty) {
      allEntries.add(Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: weekEntries,
          ),
        ),
      ));
    }
    return allEntries;
  }

  List<Widget> _generatePurchase(List<PurchaseData> data) {
    Function callback = this.callback;
    DateTime nowNow = DateTime.now();
    DateTime now = DateTime(nowNow.year, nowNow.month, nowNow.day);
    Widget initial;
    if (now.difference(data[0].updatedAt).inDays > 7) {
      int toSubtract = (now.difference(data[0].updatedAt).inDays / 7).floor();
      now = now.subtract(Duration(days: toSubtract * 7));
      initial = Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Text(
              DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 7))) +
                  ' - ' +
                  DateFormat('yyyy/MM/dd')
                      .format(now.subtract(Duration(days: 1))),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
        ],
      );
    } else {
      initial = Center(
        child: Container(
            padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Text(
              DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 7))) +
                  ' - ' +
                  DateFormat('yyyy/MM/dd')
                      .format(now.subtract(Duration(days: 1))),
              style: Theme.of(context).textTheme.subtitle2,
            )),
      );
    }
    List<Widget> allEntries = [initial];
    List<PurchaseEntry> weekEntries = [];
    for (PurchaseData data in data) {
      if (now.difference(data.updatedAt).inDays > 7) {
        int toSubtract = (now.difference(data.updatedAt).inDays / 7).floor();
        now = now.subtract(Duration(days: toSubtract * 7));
        allEntries.add(Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: weekEntries,
            ),
          ),
        ));
        weekEntries = [];
        allEntries.add(Center(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Text(
              DateFormat('yyyy/MM/dd').format(now.subtract(Duration(days: 7))) +
                  ' - ' +
                  DateFormat('yyyy/MM/dd')
                      .format(now.subtract(Duration(days: 1))),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
        ));
      } else {
        weekEntries.add(PurchaseEntry(
          data: data,
          callback: callback,
        ));
      }
    }
    if (weekEntries.isNotEmpty) {
      allEntries.add(Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: weekEntries,
          ),
        ),
      ));
    }
    return allEntries;
  }
}
