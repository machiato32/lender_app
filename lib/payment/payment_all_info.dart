import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/payment/payment_entry.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';
import 'package:csocsort_szamla/http_handler.dart';

class PaymentAllInfo extends StatefulWidget {
  final PaymentData data;

  PaymentAllInfo(this.data);

  @override
  _PaymentAllInfoState createState() => _PaymentAllInfoState();
}

class _PaymentAllInfoState extends State<PaymentAllInfo> {
  Future<bool> _deleteElement(int id) async {
    try {
      await httpDelete(uri: '/payments/' + id.toString(), context: context);
      return true;
    } catch (_) {
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Text(widget.data.amount.toString(),
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
                      DateFormat('yyyy/MM/dd - kk:mm')
                          .format(widget.data.updatedAt),
                      style: Theme.of(context).textTheme.bodyText1)),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Visibility(
            visible: widget.data.payerId == currentUserId,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
//                          FlatButton.icon(
//
//                            onPressed: (){
//                              showDialog(
//                                  context: context,
//                                  child: Dialog(
//                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//                                    backgroundColor: Theme.of(context).colorScheme.onBackground,
//                                    child: Container(
//                                      padding: EdgeInsets.all(8),
//                                      child: Column(
//                                        crossAxisAlignment: CrossAxisAlignment.center,
//                                        mainAxisSize: MainAxisSize.min,
//                                        children: <Widget>[
//                                          Text('Szerkeszteni szeretnéd a tételt?', style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
//                                          SizedBox(height: 15,),
//                                          Row(
//                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                            children: <Widget>[
//                                              RaisedButton(
//                                                  color: Theme.of(context).colorScheme.secondary,
//                                                  onPressed: (){
//                                                        Navigator.pop(context);
//                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewExpense(type: ExpenseType.fromSavedExpense,
//                                                          expense: new SavedExpense(name: widget.data.fromUser,
//                                                              names: widget.data.toUser,
//                                                              amount: widget.data.amount,
//                                                              note: widget.data.note,
//                                                              iD: widget.data.transactionID
//                                                          ),
//                                                        )));
//                                                  },
//                                                  child: Text('Igen', style: Theme.of(context).textTheme.button)
//                                              ),
//                                              RaisedButton(
//                                                  color: Theme.of(context).colorScheme.secondary,
//                                                  onPressed: (){ Navigator.pop(context);},
//                                                  child: Text('Nem', style: Theme.of(context).textTheme.button)
//                                              )
//                                            ],
//                                          )
//                                        ],
//                                      ),
//                                    ),
//                                  )
//                              );
//                            },
//                            color: Theme.of(context).colorScheme.secondary,
//                            label: Text('Szerkesztés', style: Theme.of(context).textTheme.button,),
//                            icon: Icon(Icons.edit, color: Theme.of(context).textTheme.button.color),
//                          ),
                FlatButton.icon(
                    onPressed: () {
                      showDialog(
                          context: context,
                          child: Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  //TODO: edit here and transaction
                                  Text(
                                    'want_delete'.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      RaisedButton(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                child: FutureSuccessDialog(
                                                  future: _deleteElement(
                                                      widget.data.paymentId),
                                                  dataTrueText: 'delete_scf',
                                                  onDataTrue: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(
                                                        context, 'deleted');
                                                  },
                                                ));
                                          },
                                          child: Text('yes'.tr(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .button)),
                                      RaisedButton(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('no'.tr(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .button))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ));
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    label: Text(
                      'revoke'.tr(),
                      style: Theme.of(context).textTheme.button,
                    ),
                    icon: Icon(Icons.delete,
                        color: Theme.of(context).textTheme.button.color)),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
