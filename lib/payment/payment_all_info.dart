import 'package:csocsort_szamla/essentials/widgets/confirm_choice_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/payment/add_payment_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/payment/payment_entry.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';

class PaymentAllInfo extends StatefulWidget {
  final PaymentData data;

  PaymentAllInfo(this.data);

  @override
  _PaymentAllInfoState createState() => _PaymentAllInfoState();
}

class _PaymentAllInfoState extends State<PaymentAllInfo> {
  Future<bool> _deletePayment(int id) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      await httpDelete(uri: '/payments/' + id.toString(), context: context, useGuest: useGuest);
      return true;
    } catch (_) {
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
    int idToUse=(guestNickname!=null && guestGroupId==currentGroupId)?guestUserId:currentUserId;
    String note = '';
    if (widget.data.note == '' || widget.data.note == null) {
      note = 'no_note'.tr();
    } else {
      note = widget.data.note[0].toUpperCase() + widget.data.note.substring(1);
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
                widget.data.payerNickname,
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
              Icon(Icons.account_box,
                  color: Theme.of(context).colorScheme.primary),
              Text(' - '),
              Flexible(
                  child: Text(
                widget.data.takerNickname,
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
                  child: Text(widget.data.amount.printMoney(currentGroupCurrency),
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
          Visibility(
            visible: widget.data.payerId == idToUse,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              AddPaymentRoute(
                                payment: SavedPayment(
                                    amount: widget.data.amount,
                                    note: widget.data.note,
                                    payerId: widget.data.payerId,
                                    takerId: widget.data.takerId,
                                    paymentId: widget.data.paymentId
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
                        )
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
                                ),
                            ).then((value){
                              if(value!=null && value){
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  child: FutureSuccessDialog(
                                    future: _deletePayment(widget.data.paymentId),
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
                              Icon(Icons.delete, color: Theme.of(context).textTheme.button.color),
                              SizedBox(width: 3,),
                              Text(
                                'revoke'.tr(),
                                style: Theme.of(context).textTheme.button,
                              ),
                            ],
                          ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}
