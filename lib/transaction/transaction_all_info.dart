import 'package:csocsort_szamla/essentials/widgets/confirm_choice_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/transaction/add_transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/transaction/transaction_entry.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';

class PurchaseAllInfo extends StatefulWidget {
  final PurchaseData data;

  PurchaseAllInfo(this.data);

  @override
  _PurchaseAllInfoState createState() => _PurchaseAllInfoState();
}

class _PurchaseAllInfoState extends State<PurchaseAllInfo> {
  Future<bool> _deleteElement(int id) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      await httpDelete(uri: '/purchases/' + id.toString(), context: context, useGuest: useGuest);
      return true;
    } catch (_) {
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
    int idToUse=(guestNickname!=null && guestGroupId==currentGroupId)?guestUserId:currentUserId;
    String note = '';
    if (widget.data.name == '') {
      note = 'no_note'.tr();
    } else {
      note = widget.data.name[0].toUpperCase() + widget.data.name.substring(1);
    }
    return Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.note, color: Theme.of(context).colorScheme.primary),
                    Text(' - '),
                    Flexible(
                        child: Text(
                      note,
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.account_circle,
                        color: Theme.of(context).colorScheme.primary),
                    Text(' - '),
                    Flexible(
                        child: Text(
                      widget.data.buyerNickname,
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
                    Text(' - '),
                    Flexible(
                        child: Text(
                      widget.data.receivers.join(', '),
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.attach_money,
                        color: Theme.of(context).colorScheme.primary),
                    Text(' - '),
                    Flexible(
                        child: Text(widget.data.totalAmount.printMoney(currentGroupCurrency),
                            style: Theme.of(context).textTheme.bodyText1)),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.date_range,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Text(' - '),
                    Flexible(
                        child: Text(
                            DateFormat('yyyy/MM/dd - HH:mm')
                                .format(widget.data.updatedAt),
                            style: Theme.of(context).textTheme.bodyText1)),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Visibility(
                    visible: widget.data.buyerId == idToUse,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                         Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             GradientButton(
                               onPressed: (){
                                 Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                      AddPurchaseRoute(
                                        type: PurchaseType.fromModifyExpense,
                                        expense: SavedPurchase(
                                         buyerNickname: widget.data.buyerNickname,
                                         buyerId: widget.data.buyerId,
                                         buyerUsername: widget.data.buyerUsername,
                                         receivers: widget.data.receivers,
                                         totalAmount: widget.data.totalAmount,
                                         name: widget.data.name,
                                         purchaseId: widget.data.purchaseId
                                        ),
                                      )
                                    )
                                  ).then((value) => Navigator.pop(context, 'deleted'));
                               },
                               child: Row(
                                 children: [
                                   Icon(Icons.edit, color: Theme.of(context).textTheme.button.color),
                                   SizedBox(width: 3,),
                                   Text('modify'.tr(), style: Theme.of(context).textTheme.button,),
                                 ],
                               ),
                             ),
                           ],
                         ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GradientButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      child: ConfirmChoiceDialog(
                                        choice: 'want_delete',
                                      )
                                  ).then((value){
                                    if(value!=null && value){
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        child: FutureSuccessDialog(
                                          future: _deleteElement(widget
                                              .data.purchaseId),
                                          dataTrueText: 'delete_scf',
                                          onDataTrue: () {
                                            Navigator.pop(context);
                                            Navigator.pop(
                                                context, 'deleted');
                                          },
                                        )
                                      );
                                    }
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Theme.of(context).colorScheme.onSecondary),
                                    SizedBox(width: 3,),
                                    Text('revoke'.tr(), style: Theme.of(context).textTheme.button,),
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
        )
    );
  }
}
