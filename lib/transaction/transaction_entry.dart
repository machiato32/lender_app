import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/group_objects.dart';
import 'package:csocsort_szamla/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/transaction/transaction_all_info.dart';
import 'package:csocsort_szamla/config.dart';

class TransactionData {
  String type;
  DateTime updatedAt;
  String buyerUsername, buyerNickname;
  int buyerId;
  List<Member> receivers;
  int totalAmount;
  int transactionId;
  String name;

  TransactionData(
      {this.type,
      this.updatedAt,
      this.buyerUsername,
      this.buyerNickname,
      this.buyerId,
      this.receivers,
      this.totalAmount,
      this.transactionId,
      this.name});

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
        type: json['type'],
        transactionId: json['data']['transaction_id'],
        name: json['data']['name'],
        updatedAt: json['data']['updated_at'] == null
            ? DateTime.now()
            : DateTime.parse(json['data']['updated_at']).toLocal(),
        buyerUsername: json['data']['buyer_username'],
        buyerId: json['data']['buyer_id'],
        buyerNickname: json['data']['buyer_nickname'],
        totalAmount: (json['data']['total_amount'] * 1.0).round(),
        receivers: json['data']['receivers']
            .map<Member>((element) => Member.fromJson(element))
            .toList());
  }
}

class TransactionEntry extends StatefulWidget {
  final TransactionData data;
  final Function callback;

  const TransactionEntry({this.data, this.callback});

  @override
  _TransactionEntryState createState() => _TransactionEntryState();
}

class _TransactionEntryState extends State<TransactionEntry> {
  Color dateColor;
  Icon icon;
  TextStyle style;
  BoxDecoration boxDecoration;
  String date;
  String note;
  String names;
  String amount;
  String selfAmount = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    date = DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.updatedAt);
    note = (widget.data.name == '')
        ? 'no_note'.tr()
        : widget.data.name[0].toUpperCase() + widget.data.name.substring(1);
    if (widget.data.type == 'buyed') {
      icon = Icon(Icons.call_made,
          color: (Theme.of(context).brightness == Brightness.dark)
              ? Theme.of(context).textTheme.bodyText1.color
              : Theme.of(context).textTheme.button.color);
      style = (Theme.of(context).brightness == Brightness.dark)
          ? Theme.of(context).textTheme.bodyText1
          : Theme.of(context).textTheme.button;
      dateColor = (Theme.of(context).brightness == Brightness.dark)
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).textTheme.button.color;
      boxDecoration = BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark)
            ? Colors.transparent
            : Theme.of(context).colorScheme.secondary,
        border: Border.all(
            color: (Theme.of(context).brightness == Brightness.dark)
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
            width: 1.5),
        borderRadius: BorderRadius.circular(15),
      );
      if (widget.data.receivers.length > 1) {
        names = widget.data.receivers.join(', ');
      } else {
        names = widget.data.receivers[0].nickname;
      }
      amount = widget.data.totalAmount.toString();
    } else if (widget.data.type == 'buyed_received') {
      icon = Icon(Icons.swap_horiz,
          color: (Theme.of(context).brightness == Brightness.dark)
              ? Theme.of(context).textTheme.bodyText1.color
              : Theme.of(context).textTheme.button.color);
      style = (Theme.of(context).brightness == Brightness.dark)
          ? Theme.of(context).textTheme.bodyText1
          : Theme.of(context).textTheme.button;
      dateColor = (Theme.of(context).brightness == Brightness.dark)
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).textTheme.button.color;
      boxDecoration = BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark)
            ? Colors.transparent
            : Theme.of(context).colorScheme.secondary,
        border: Border.all(
            color: (Theme.of(context).brightness == Brightness.dark)
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
            width: 1.5),
        borderRadius: BorderRadius.circular(15),
      );
      if (widget.data.receivers.length > 1) {
        names = widget.data.receivers.join(', ');
      } else {
        names = widget.data.receivers[0].nickname;
      }
      amount = widget.data.totalAmount.toString();
      selfAmount = (-widget.data.receivers
              .firstWhere((member) => member.memberId == currentUserId)
              .balance)
          .toString();
    } else if (widget.data.type == 'received') {
      icon = Icon(Icons.call_received,
          color: Theme.of(context).textTheme.bodyText1.color);
      style = Theme.of(context).textTheme.bodyText1;
      dateColor = Theme.of(context).colorScheme.surface;
      names = widget.data.buyerNickname;
      amount = (-widget.data.receivers
              .firstWhere((element) => element.memberId == currentUserId)
              .balance)
          .toString();
      boxDecoration = BoxDecoration();
    }
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      decoration: boxDecoration,
      margin: EdgeInsets.only(bottom: 4, left: 4, right: 4),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () async {
            showModalBottomSheetCustom(
                context: context,
                backgroundColor: Theme.of(context).cardTheme.color,
                builder: (context) => SingleChildScrollView(
                    child: TransactionAllInfo(widget.data))).then((val) {
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
                                        note,
                                        style: style.copyWith(fontSize: 21),
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                      Flexible(
                                          child: Text(
                                        names,
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                amount,
                                style: style,
                              ),
                              Visibility(
                                  visible: widget.data.type == 'buyed_received',
                                  child: Text(
                                    selfAmount,
                                    style: style,
                                  )),
                            ],
                          )
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
