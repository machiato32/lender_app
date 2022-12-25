import 'package:csocsort_szamla/essentials/currencies.dart';
import 'package:csocsort_szamla/essentials/widgets/confirm_choice_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/purchase/add_purchase_page.dart';
import 'package:csocsort_szamla/purchase/modify_purchase_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/models.dart';

class PurchaseAllInfo extends StatefulWidget {
  final Purchase data;

  PurchaseAllInfo(this.data);

  @override
  _PurchaseAllInfoState createState() => _PurchaseAllInfoState();
}

class _PurchaseAllInfoState extends State<PurchaseAllInfo> {
  Future<bool> _deleteElement(int id) async {
    try {
      bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
      await httpDelete(uri: '/purchases/' + id.toString(), context: context, useGuest: useGuest);
      Future.delayed(delayTime()).then((value) => _onDeleteElement());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onDeleteElement() {
    Navigator.pop(context);
    Navigator.pop(context, 'deleted');
  }

  @override
  Widget build(BuildContext context) {
    String note = '';
    if (widget.data.name == '') {
      note = 'no_note'.tr();
    } else {
      note = widget.data.name[0].toUpperCase() + widget.data.name.substring(1);
    }
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.note, color: Theme.of(context).colorScheme.secondary),
              Flexible(
                  child: Text(
                ' - ' + note,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              )),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: <Widget>[
              Icon(Icons.account_circle, color: Theme.of(context).colorScheme.secondary),
              Flexible(
                  child: Text(
                ' - ' + widget.data.buyerNickname,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              )),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.people, color: Theme.of(context).colorScheme.secondary),
              Flexible(
                  child: Text(
                ' - ' + widget.data.receivers.join(', '),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              )),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: <Widget>[
              Icon(Icons.attach_money, color: Theme.of(context).colorScheme.secondary),
              Flexible(
                  child: Text(' - ' + widget.data.totalAmount.printMoney(currentGroupCurrency),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          .copyWith(color: Theme.of(context).colorScheme.onSurface))),
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
                          .copyWith(color: Theme.of(context).colorScheme.onSurface))),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Visibility(
            visible: widget.data.buyerId == idToUse(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GradientButton(
                  onPressed: () {
                    showDialog(
                      builder: (context) => ModifyPurchaseDialog(
                        savedPurchase: SavedPurchase(
                            buyerNickname: widget.data.buyerNickname,
                            buyerId: widget.data.buyerId,
                            buyerUsername: widget.data.buyerUsername,
                            receivers: widget.data.receivers,
                            totalAmount: widget.data.totalAmount,
                            name: widget.data.name,
                            purchaseId: widget.data.purchaseId),
                      ),
                      context: context,
                    ).then((value) {
                      if (value ?? false) {
                        Navigator.pop(context, 'deleted');
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        'modify'.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ],
                  ),
                ),
                GradientButton(
                  onPressed: () {
                    showDialog(
                            builder: (context) => ConfirmChoiceDialog(
                                  choice: 'want_delete',
                                ),
                            context: context)
                        .then((value) {
                      if (value != null && value) {
                        showDialog(
                            builder: (context) => FutureSuccessDialog(
                                  future: _deleteElement(widget.data.purchaseId),
                                  dataTrueText: 'delete_scf',
                                  onDataTrue: () {
                                    _onDeleteElement();
                                  },
                                ),
                            barrierDismissible: false,
                            context: context);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Theme.of(context).colorScheme.onPrimary),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        'revoke'.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
