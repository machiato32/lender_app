import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/payment/payment_all_info.dart';
import 'package:csocsort_szamla/app_theme.dart';

class PaymentData {
  int paymentId;
  int amount;
  DateTime updatedAt;
  String payerUsername, payerNickname, takerUsername, takerNickname, note;
  int payerId, takerId;

  PaymentData(
      {this.paymentId,
      this.amount,
      this.updatedAt,
      this.payerUsername,
      this.payerId,
      this.payerNickname,
      this.takerUsername,
      this.takerId,
      this.takerNickname,
      this.note});

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
        paymentId: json['payment_id'],
        amount: (json['amount'] * 1.0).round(),
        updatedAt: json['updated_at'] == null
            ? DateTime.now()
            : DateTime.parse(json['updated_at']).toLocal(),
        payerId: json['payer_id'],
        payerUsername: json['payer_username'],
        payerNickname: json['payer_nickname'],
        takerId: json['taker_id'],
        takerUsername: json['taker_username'],
        takerNickname: json['taker_nickname'],
        note: json['note']);
  }
}

class PaymentEntry extends StatefulWidget {
  final PaymentData data;
  final Function callback;

  const PaymentEntry({this.data, this.callback});

  @override
  _PaymentEntryState createState() => _PaymentEntryState();
}

class _PaymentEntryState extends State<PaymentEntry> {
  Color dateColor;
  Icon icon;
  TextStyle style;
  BoxDecoration boxDecoration;
  String date;
  String note;
  String takerName;
  String amount;

  @override
  Widget build(BuildContext context) {
    date = DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.updatedAt);
    note = (widget.data.note == '' || widget.data.note == null)
        ? 'no_note'.tr()
        : widget.data.note[0].toUpperCase() + widget.data.note.substring(1);
    if (widget.data.payerId == currentUserId) {
      icon = Icon(Icons.call_made,
          color: Theme.of(context).textTheme.button.color);
      style = Theme.of(context).textTheme.button;
      dateColor = Theme.of(context).textTheme.button.color;
      boxDecoration = BoxDecoration(
        gradient: AppTheme.gradientFromTheme(Theme.of(context)),
        // color: (Theme.of(context).brightness == Brightness.dark)
        //     ? Colors.transparent
        //     : Theme.of(context).colorScheme.secondary,
        // border: Border.all(
        //     color: (Theme.of(context).brightness == Brightness.dark)
        //         ? Theme.of(context).colorScheme.secondary
        //         : Colors.transparent,
        //     width: 1.5),
        borderRadius: BorderRadius.circular(15),
      );
      takerName = widget.data.takerNickname;
      amount = widget.data.amount.toString();
    } else {
      icon = Icon(Icons.call_received,
          color: Theme.of(context).textTheme.bodyText1.color);
      style = Theme.of(context).textTheme.bodyText1;
      dateColor = Theme.of(context).colorScheme.surface;
      takerName = widget.data.payerNickname;
      amount = (-widget.data.amount).toString();
      boxDecoration = BoxDecoration();
    }
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      decoration: boxDecoration,
      margin: EdgeInsets.only(bottom: 4),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () async {
            showModalBottomSheetCustom(
                context: context,
                backgroundColor: Theme.of(context).cardTheme.color,
                builder: (context) => SingleChildScrollView(
                    child: PaymentAllInfo(widget.data))).then((val) {
              if (val == 'deleted') widget.callback();
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Flexible(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Row(
                              children: <Widget>[
                                icon,
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Flexible(
                                          child: Text(
                                        takerName,
                                        style: style.copyWith(fontSize: 21),
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                      Flexible(
                                          child: Text(
                                        note,
                                        style: TextStyle(
                                            color: dateColor, fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            amount,
                            style: style,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
