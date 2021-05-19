import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/widgets/add_reaction_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/past_reaction_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/widgets/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/payment/payment_all_info.dart';
import 'package:csocsort_szamla/essentials/app_theme.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';

class PaymentData {
  int paymentId;
  double amount;
  DateTime updatedAt;
  String payerUsername, payerNickname, takerUsername, takerNickname, note;
  int payerId, takerId;
  List<Reaction> reactions;

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
      this.note,
      this.reactions});

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
        paymentId: json['payment_id'],
        amount: (json['amount'] * 1.0),
        updatedAt: json['updated_at'] == null
            ? DateTime.now()
            : DateTime.parse(json['updated_at']).toLocal(),
        payerId: json['payer_id'],
        payerUsername: json['payer_username'],
        payerNickname: json['payer_nickname'],
        takerId: json['taker_id'],
        takerUsername: json['taker_username'],
        takerNickname: json['taker_nickname'],
        note: json['note'],
        reactions: json['reactions']
            .map<Reaction>((reaction) => Reaction.fromJson(reaction))
            .toList()
    );
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

  void callbackForReaction(String reaction){//TODO: currentNickname
    int idToUse=(guestNickname!=null && guestGroupId==currentGroupId)?guestUserId:currentUserId;
    Reaction oldReaction=widget.data.reactions.firstWhere((element) => element.userId==idToUse, orElse: () => null);
    bool alreadyReacted = oldReaction!=null;
    bool sameReaction = alreadyReacted?oldReaction.reaction==reaction:false;
    if(sameReaction){
      widget.data.reactions.remove(oldReaction);
      setState(() {

      });
    }else if(!alreadyReacted){
      widget.data.reactions.add(Reaction(nickname: idToUse==currentUserId?currentUsername:guestNickname, reaction: reaction, userId: idToUse));
      setState(() {

      });
    }else{
      widget.data.reactions.add(Reaction(nickname: oldReaction.nickname, reaction: reaction, userId: idToUse));
      widget.data.reactions.remove(oldReaction);
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    date = DateFormat('yyyy/MM/dd - HH:mm').format(widget.data.updatedAt);
    note = (widget.data.note == '' || widget.data.note == null)
        ? 'no_note'.tr()
        : widget.data.note[0].toUpperCase() + widget.data.note.substring(1);
    int idToUse=(guestNickname!=null && guestGroupId==currentGroupId)?guestUserId:currentUserId;
    if (widget.data.payerId==idToUse) {
      icon = Icon(Icons.call_made,
          color: Theme.of(context).textTheme.button.color);
      style = Theme.of(context).textTheme.button;
      dateColor = Theme.of(context).textTheme.button.color;
      boxDecoration = BoxDecoration(
        gradient: AppTheme.gradientFromTheme(Theme.of(context), useSecondary: true),
        borderRadius: BorderRadius.circular(15),
        boxShadow: ( Theme.of(context).brightness==Brightness.light)
            ?[ BoxShadow(
              color: Colors.grey[500],
              offset: Offset(0.0, 1.5),
              blurRadius: 1.5,
            )]
            : [],
      );
      takerName = widget.data.takerNickname;
      amount = widget.data.amount.printMoney(currentGroupCurrency);
    } else {
      icon = Icon(Icons.call_received,
          color: Theme.of(context).textTheme.bodyText1.color);
      style = Theme.of(context).textTheme.bodyText1;
      dateColor = Theme.of(context).colorScheme.surface;
      takerName = widget.data.payerNickname;
      amount = (-widget.data.amount).printMoney(currentGroupCurrency);
      boxDecoration = BoxDecoration();
    }
    return Stack(
      children: [
        Container(
          height: 80,
          width: MediaQuery.of(context).size.width,
          decoration: boxDecoration,
          margin: EdgeInsets.only(top: widget.data.reactions.length==0?0:14, bottom: 4, left: 4, right: 4),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onLongPress: (){
                showDialog(context: context, child: AddReactionDialog(
                    type: 'payments',
                    reactions: widget.data.reactions,
                    reactToId: widget.data.paymentId,
                    callback: this.callbackForReaction,
                  )
                );
              },
              onTap: () async {
                showModalBottomSheetCustom(
                    context: context,
                    backgroundColor: Theme.of(context).cardTheme.color,
                    builder: (context) => SingleChildScrollView(
                        child: PaymentAllInfo(widget.data))).then((val) {
                  if (val == 'deleted') widget.callback(payment: true);
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
        ),
        PastReactionContainer(
          reactedToId: widget.data.paymentId,
          reactions: widget.data.reactions,
          callback: this.callbackForReaction,
          isSecondaryColor: widget.data.payerId==idToUse,
          type:'payments'
        )
      ],
    );
  }
}
