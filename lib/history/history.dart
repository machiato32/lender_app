import 'dart:convert';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/history/all_history_page.dart';
import 'package:csocsort_szamla/payment/payment_entry.dart';
import 'package:csocsort_szamla/purchase/purchase_entry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../essentials/app_theme.dart';
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
  Future<List<PurchaseData>> _purchases;
  TabController _tabController;
  int _selectedIndex;
  Future<List<PurchaseData>> _getPurchases({bool overwriteCache = false}) async {
    try {
      bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
      http.Response response = await httpGet(
          uri: generateUri(GetUriKeys.purchasesFirst6),
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
          uri: generateUri(GetUriKeys.paymentsFirst6),
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
    widget.callback();
    setState(() {
      if (payment) {
        _payments = null;
        _payments = _getPayments(overwriteCache: true);
      }
      if (purchase) {
        _purchases = null;
        _purchases = _getPurchases(overwriteCache: true);
      }
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.selectedIndex);
    _selectedIndex = widget.selectedIndex;
    _payments = null;
    _payments = _getPayments();
    _purchases = null;
    _purchases = _getPurchases();
    super.initState();
  }

  @override
  void didUpdateWidget(History oldWidget) {
    _payments = null;
    _payments = _getPayments();
    _purchases = null;
    _purchases = _getPurchases();
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
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'history_explanation'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            TabBar(
              indicatorColor: Colors.transparent,
              controller: _tabController,
              onTap: (_newIndex) {
                setState(() {
                  _selectedIndex = _newIndex;
                });
              },
              overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
              tabs: <Widget>[
                InkWell(
                  splashFactory: InkSparkle.splashFactory,
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    _selectedIndex = 0;
                    _tabController.animateTo(_selectedIndex);
                    Future.delayed(Duration(milliseconds: 50)).then((value) {
                      setState(() {});
                    });
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: _selectedIndex == 0
                          ? AppTheme.gradientFromTheme(currentThemeName)
                          : LinearGradient(colors: [
                              ElevationOverlay.applyOverlay(
                                  context, Theme.of(context).colorScheme.surface, 10),
                              ElevationOverlay.applyOverlay(
                                  context, Theme.of(context).colorScheme.surface, 10)
                            ]),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart,
                            color: _selectedIndex == 0
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurfaceVariant),
                        SizedBox(
                          width: 3,
                        ),
                        Flexible(
                          child: Text(
                            'purchases'.tr(),
                            style: Theme.of(context).textTheme.labelLarge.copyWith(
                                color: _selectedIndex == 0
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  splashFactory: InkSparkle.splashFactory,
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    _selectedIndex = 1;
                    _tabController.animateTo(_selectedIndex);
                    Future.delayed(Duration(milliseconds: 50)).then((value) {
                      setState(() {});
                    });
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: _selectedIndex == 1
                          ? AppTheme.gradientFromTheme(currentThemeName)
                          : LinearGradient(colors: [
                              ElevationOverlay.applyOverlay(
                                  context, Theme.of(context).colorScheme.surface, 10),
                              ElevationOverlay.applyOverlay(
                                  context, Theme.of(context).colorScheme.surface, 10)
                            ]),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.attach_money,
                            color: _selectedIndex == 1
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurfaceVariant),
                        SizedBox(
                          width: 3,
                        ),
                        Flexible(
                          child: Text(
                            'payments'.tr(),
                            style: Theme.of(context).textTheme.labelLarge.copyWith(
                                color: _selectedIndex == 1
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 550,
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: <Widget>[
                  FutureBuilder(
                    future: _purchases,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          if (snapshot.data.length == 0) {
                            return Padding(
                              padding: EdgeInsets.all(25),
                              child: Text(
                                'nothing_to_show'.tr(),
                                style: Theme.of(context).textTheme.bodyText1,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 490,
                                child: Column(
                                  children: _generatePurchases(snapshot.data),
                                ),
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
                                                  builder: (context) => AllHistoryRoute(
                                                      startingIndex: _tabController.index)));
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.more_horiz,
                                              color: Theme.of(context).colorScheme.onPrimary,
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              'more'.tr(),
                                              style: Theme.of(context).textTheme.button.copyWith(
                                                  color: Theme.of(context).colorScheme.onPrimary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ))
                            ],
                          );
                        } else {
                          return ErrorMessage(
                            error: snapshot.error.toString(),
                            locationOfError: 'purchase_history',
                            callback: () {
                              setState(() {
                                _purchases = null;
                                _purchases = _getPurchases();
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
                          if (snapshot.data.length == 0) {
                            return Padding(
                              padding: EdgeInsets.all(25),
                              child: Text(
                                'nothing_to_show'.tr(),
                                style: Theme.of(context).textTheme.bodyText1,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 490,
                                child: Column(children: _generatePayments(snapshot.data)),
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
                                                builder: (context) => AllHistoryRoute(
                                                      startingIndex: _tabController.index,
                                                    )));
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.more_horiz,
                                            color: Theme.of(context).colorScheme.onPrimary,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            'more'.tr(),
                                            style: Theme.of(context).textTheme.labelLarge.copyWith(
                                                color: Theme.of(context).colorScheme.onPrimary),
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
                            callback: () {
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

  List<Widget> _generatePurchases(List<PurchaseData> data) {
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
