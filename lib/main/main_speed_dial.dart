import 'package:csocsort_szamla/payment/add_payment_page.dart';
import 'package:csocsort_szamla/purchase/add_purchase_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../essentials/app_theme.dart';

class MainPageSpeedDial extends StatefulWidget {
  final Function callback;
  MainPageSpeedDial({this.callback});
  @override
  _MainPageSpeedDialState createState() => _MainPageSpeedDialState();
}

class _MainPageSpeedDialState extends State<MainPageSpeedDial> {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: DescribedFeatureOverlay(
        featureId: 'add_payment_expense',
        tapTarget: Icon(
          Icons.add,
          color: Colors.black,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('discovery_add_floating_title'.tr()),
        description: Text('discovery_add_floating_description'.tr()),
        contentLocation: ContentLocation.above,
        overflowMode: OverflowMode.extendBackground,
        child: Icon(Icons.add),
      ),
      overlayColor: (Theme.of(context).brightness == Brightness.dark)
          ? Colors.black
          : Colors.white,
      curve: Curves.bounceIn,
      onOpen: () {
        FeatureDiscovery.discoverFeatures(
            context, <String>['add_payment_expense']);
      },
      children: [
        SpeedDialChild(
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          labelWidget: GestureDetector(
            onTap: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddPaymentRoute()))
                  .then((value) => widget.callback());
            },
            child: Padding(
              padding: EdgeInsets.only(right: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                    //                  margin: EdgeInsets.only(right: 18.0),
                    decoration: BoxDecoration(
                      gradient: AppTheme.gradientFromTheme(Theme.of(context)),
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.7),
                          offset: Offset(0.8, 0.8),
                          blurRadius: 2.4,
                        )
                      ],
                    ),
                    child: Text('payment'.tr(),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                            color: Theme.of(context).textTheme.button.color,
                            fontSize: 18)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'payment_explanation'.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          child: Icon(Icons.payments),
          onTap: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddPaymentRoute()))
                .then((value) => widget.callback());
          },
        ),
        SpeedDialChild(
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            backgroundColor: Theme.of(context).colorScheme.primary,
            labelWidget: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddPurchaseRoute(
                              type: null,
                            ))).then((value) {
                  widget.callback();
                });
              },
              child: Padding(
                padding: EdgeInsets.only(right: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                      decoration: BoxDecoration(
                        gradient: AppTheme.gradientFromTheme(Theme.of(context)),
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.7),
                            offset: Offset(0.8, 0.8),
                            blurRadius: 2.4,
                          )
                        ],
                      ),
                      child: Text('purchase'.tr(),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).textTheme.button.color,
                              fontSize: 18)),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'purchase_explanation'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            child: Icon(Icons.shopping_cart),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddPurchaseRoute(
                            type: PurchaseType.newPurchase,
                          ))).then((value) {
                widget.callback();
              });
            }),
      ],
    );
  }
}
