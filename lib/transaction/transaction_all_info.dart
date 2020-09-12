import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/transaction/transaction_entry.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';

class TransactionAllInfo extends StatefulWidget {
  final TransactionData data;

  TransactionAllInfo(this.data);

  @override
  _TransactionAllInfoState createState() => _TransactionAllInfoState();
}

class _TransactionAllInfoState extends State<TransactionAllInfo> {
  Future<bool> _deleteElement(int id) async {
    try {
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + apiToken
      };

      http.Response response = await http
          .delete(APPURL + '/transactions/' + id.toString(), headers: header);
      return response.statusCode == 204;
    } catch (_) {
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Text(widget.data.totalAmount.toString(),
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
            visible: widget.data.buyerId == currentUser,
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
                                  Text(
                                    'want_delete'.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(color: Colors.white),
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
                                                  future: _deleteElement(widget
                                                      .data.transactionId),
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
