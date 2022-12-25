import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/app_theme.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';
import 'package:csocsort_szamla/essentials/models.dart';
import 'package:csocsort_szamla/essentials/widgets/add_reaction_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/past_reaction_container.dart';
import 'package:csocsort_szamla/payment/payment_all_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentData {
  int paymentId;
  double amount, amountOriginalCurrency;
  DateTime updatedAt;
  String payerUsername, payerNickname, takerUsername, takerNickname, note;
  int payerId, takerId;
  List<Reaction> reactions;

  PaymentData({
    this.paymentId,
    this.amount,
    this.amountOriginalCurrency,
    this.updatedAt,
    this.payerUsername,
    this.payerId,
    this.payerNickname,
    this.takerUsername,
    this.takerId,
    this.takerNickname,
    this.note,
    this.reactions,
  });

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
        reactions:
            json['reactions'].map<Reaction>((reaction) => Reaction.fromJson(reaction)).toList());
  }
}

class PaymentEntry extends StatefulWidget {
  final bool isTappable;
  final PaymentData data;
  final Function({bool purchase, bool payment}) callback;

  const PaymentEntry({this.data, this.callback, this.isTappable = true});

  @override
  _PaymentEntryState createState() => _PaymentEntryState();
}

class _PaymentEntryState extends State<PaymentEntry> {
  Icon icon;
  TextStyle mainTextStyle;
  TextStyle subTextStyle;
  BoxDecoration boxDecoration;
  String date;
  String note;
  String takerName;
  String amount;

  void callbackForReaction(String reaction) {
    //TODO: currentNickname
    Reaction oldReaction = widget.data.reactions
        .firstWhere((element) => element.userId == idToUse(), orElse: () => null);
    bool alreadyReacted = oldReaction != null;
    bool sameReaction = alreadyReacted ? oldReaction.reaction == reaction : false;
    if (sameReaction) {
      widget.data.reactions.remove(oldReaction);
      setState(() {});
    } else if (!alreadyReacted) {
      widget.data.reactions.add(Reaction(
          nickname: idToUse() == currentUserId ? currentUsername : guestNickname,
          reaction: reaction,
          userId: idToUse()));
      setState(() {});
    } else {
      widget.data.reactions
          .add(Reaction(nickname: oldReaction.nickname, reaction: reaction, userId: idToUse()));
      widget.data.reactions.remove(oldReaction);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    date = DateFormat('yyyy/MM/dd - HH:mm').format(widget.data.updatedAt);
    note = (widget.data.note == '' || widget.data.note == null)
        ? 'no_note'.tr()
        : widget.data.note[0].toUpperCase() + widget.data.note.substring(1);
    if (widget.data.payerId == idToUse()) {
      takerName = widget.data.takerNickname;
      amount = widget.data.amount.toMoneyString(currentGroupCurrency, withSymbol: true);
      icon = Icon(Icons.call_made,
          color: currentThemeName.contains('Gradient')
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onPrimaryContainer);
      boxDecoration = BoxDecoration(
        gradient: AppTheme.gradientFromTheme(currentThemeName, usePrimaryContainer: true),
        borderRadius: BorderRadius.circular(15),
      );
      mainTextStyle = Theme.of(context).textTheme.bodyLarge.copyWith(
          color: currentThemeName.contains('Gradient')
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onPrimaryContainer);
      subTextStyle = Theme.of(context).textTheme.bodySmall.copyWith(
          color: currentThemeName.contains('Gradient')
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onPrimaryContainer);
    } else {
      icon = Icon(Icons.call_received, color: Theme.of(context).colorScheme.onSurfaceVariant);

      mainTextStyle = Theme.of(context)
          .textTheme
          .bodyLarge
          .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
      subTextStyle = Theme.of(context)
          .textTheme
          .bodySmall
          .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
      takerName = widget.data.payerNickname;
      amount = (-widget.data.amount).toMoneyString(currentGroupCurrency, withSymbol: true);
      boxDecoration = BoxDecoration();
    }
    return Stack(
      children: [
        Container(
          height: 80,
          width: MediaQuery.of(context).size.width,
          decoration: boxDecoration,
          margin: EdgeInsets.only(
              top: widget.data.reactions.length == 0 ? 0 : 14, bottom: 4, left: 4, right: 4),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onLongPress: !widget.isTappable
                  ? null
                  : () {
                      showDialog(
                          builder: (context) => AddReactionDialog(
                                type: 'payments',
                                reactions: widget.data.reactions,
                                reactToId: widget.data.paymentId,
                                callback: this.callbackForReaction,
                              ),
                          context: context);
                    },
              onTap: !widget.isTappable
                  ? null
                  : () async {
                      showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) =>
                                  SingleChildScrollView(child: PaymentAllInfo(widget.data)))
                          .then((returnValue) {
                        if (returnValue == 'deleted')
                          widget.callback(purchase: false, payment: true);
                      });
                    },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: EdgeInsets.all(15),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  takerName,
                                  style: mainTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  note,
                                  style: subTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      amount,
                      style: mainTextStyle,
                    ),
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
            isSecondaryColor: widget.data.payerId == idToUse(),
            type: 'payments')
      ],
    );
  }
}
