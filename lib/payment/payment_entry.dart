import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/app_theme.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';
import 'package:csocsort_szamla/essentials/models.dart';
import 'package:csocsort_szamla/essentials/widgets/add_reaction_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/past_reaction_container.dart';
import 'package:csocsort_szamla/payment/payment_all_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PaymentEntry extends StatefulWidget {
  final bool isTappable;
  final Payment data;
  final Function({bool purchase, bool payment}) callback;
  final int selectedMemberId;
  const PaymentEntry({this.data, this.selectedMemberId, this.callback, this.isTappable = true});

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
        .firstWhere((element) => element.userId == currentUserId, orElse: () => null);
    bool alreadyReacted = oldReaction != null;
    bool sameReaction = alreadyReacted ? oldReaction.reaction == reaction : false;
    if (sameReaction) {
      widget.data.reactions.remove(oldReaction);
      setState(() {});
    } else if (!alreadyReacted) {
      widget.data.reactions.add(Reaction(
        nickname: currentUsername,
        reaction: reaction,
        userId: currentUserId,
      ));
      setState(() {});
    } else {
      widget.data.reactions
          .add(Reaction(nickname: oldReaction.nickname, reaction: reaction, userId: currentUserId));
      widget.data.reactions.remove(oldReaction);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedMemberId = widget.selectedMemberId ?? currentUserId;
    date = DateFormat('yyyy/MM/dd - HH:mm').format(widget.data.updatedAt);
    note = (widget.data.note == '' || widget.data.note == null)
        ? 'no_note'.tr()
        : widget.data.note[0].toUpperCase() + widget.data.note.substring(1);
    if (widget.data.payerId == selectedMemberId) {
      takerName = widget.data.takerNickname;
      amount = widget.data.amountOriginalCurrency
          .toMoneyString(widget.data.originalCurrency, withSymbol: true);
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
      amount = (-widget.data.amountOriginalCurrency)
          .toMoneyString(widget.data.originalCurrency, withSymbol: true);
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
                  : selectedMemberId != currentUserId
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
        Visibility(
          visible: selectedMemberId == currentUserId,
          child: PastReactionContainer(
            reactedToId: widget.data.paymentId,
            reactions: widget.data.reactions,
            callback: this.callbackForReaction,
            isSecondaryColor: widget.data.payerId == currentUserId,
            type: 'payments',
          ),
        )
      ],
    );
  }
}
