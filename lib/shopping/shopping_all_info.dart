import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/shopping/edit_request_dialog.dart';
import 'package:csocsort_szamla/shopping/shopping_list_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/purchase/add_purchase_page.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';

class ShoppingAllInfo extends StatefulWidget {
  final ShoppingRequestData data;

  ShoppingAllInfo(this.data);

  @override
  _ShoppingAllInfoState createState() => _ShoppingAllInfoState();
}

class _ShoppingAllInfoState extends State<ShoppingAllInfo> {
  Future<bool> _fulfillShoppingRequest(int id) async {
    try {
      bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
      await httpDelete(uri: '/requests/' + id.toString(), context: context, useGuest: useGuest);
      Future.delayed(delayTime()).then((value) => _onFulfillShoppingRequest());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onFulfillShoppingRequest() {
    Navigator.pop(context, true);
    Navigator.pop(context, 'deleted');
  }

  Future<bool> _deleteShoppingRequest(int id) async {
    try {
      bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
      await httpDelete(uri: '/requests/' + id.toString(), context: context, useGuest: useGuest);
      Future.delayed(delayTime()).then((value) => _onDeleteShoppingRequest());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onDeleteShoppingRequest() {
    Navigator.pop(context);
    Navigator.pop(context, 'deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.account_circle, color: Theme.of(context).colorScheme.secondary),
              Flexible(
                child: Text(
                  ' - ' + widget.data.requesterNickname,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.secondary),
              Flexible(
                child: Text(
                  ' - ' + widget.data.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.date_range,
                color: Theme.of(context).colorScheme.secondary,
              ),
              Flexible(
                child: Text(
                  ' - ' + DateFormat('yyyy/MM/dd - HH:mm').format(widget.data.updatedAt),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Visibility(
            visible: widget.data.requesterId == idToUse(),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(
                        onPressed: () {
                          showDialog(
                            builder: (context) => EditRequestDialog(
                              requestId: widget.data.requestId,
                              textBefore: widget.data.name,
                            ),
                            context: context,
                          ).then((value) {
                            if (value ?? false) {
                              Navigator.pop(context, 'edited');
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'modify'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(
                        onPressed: () {
                          showDialog(
                              builder: (context) => FutureSuccessDialog(
                                    future: _deleteShoppingRequest(widget.data.requestId),
                                    dataTrueText: 'delete_scf',
                                    onDataTrue: () {
                                      _onDeleteShoppingRequest();
                                    },
                                  ),
                              barrierDismissible: false,
                              context: context);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Theme.of(context).colorScheme.onPrimary),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'delete'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: widget.data.requesterId != idToUse(),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(
                        onPressed: () {
                          showDialog(
                              builder: (context) => FutureSuccessDialog(
                                    future: _fulfillShoppingRequest(widget.data.requestId),
                                    dataTrueText: 'fulfill_scf',
                                    onDataTrue: () {
                                      _onFulfillShoppingRequest();
                                    },
                                  ),
                              barrierDismissible: false,
                              context: context);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimary),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'remove_from_list'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(
                        onPressed: () {
                          showDialog(
                                  builder: (context) => FutureSuccessDialog(
                                        future: _fulfillShoppingRequest(widget.data.requestId),
                                        dataTrueText: 'fulfill_scf',
                                        onDataTrue: () {
                                          _onFulfillShoppingRequest();
                                        },
                                      ),
                                  barrierDismissible: false,
                                  context: context)
                              .then((value) {
                            if (value == true) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPurchaseRoute(
                                    type: PurchaseType.fromShopping,
                                    shoppingData: widget.data,
                                  ),
                                ),
                              );
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.attach_money,
                                color: Theme.of(context).colorScheme.onPrimary),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'add_as_expense'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
