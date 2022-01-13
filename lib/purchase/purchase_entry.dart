import 'dart:io' show Platform;

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/app_theme.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';
import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/widgets/add_reaction_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/essentials/widgets/past_reaction_container.dart';
import 'package:csocsort_szamla/purchase/purchase_all_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PurchaseData {
  DateTime updatedAt;
  String buyerUsername, buyerNickname;
  int buyerId;
  List<Member> receivers;
  double totalAmount;
  int purchaseId;
  String name;
  List<Reaction> reactions;

  PurchaseData(
      {this.updatedAt,
      this.buyerUsername,
      this.buyerNickname,
      this.buyerId,
      this.receivers,
      this.totalAmount,
      this.purchaseId,
      this.name,
      this.reactions});

  factory PurchaseData.fromJson(Map<String, dynamic> json) {
    return PurchaseData(
        purchaseId: json['purchase_id'],
        name: json['name'],
        updatedAt: json['updated_at'] == null
            ? DateTime.now()
            : DateTime.parse(json['updated_at']).toLocal(),
        buyerUsername: json['buyer_username'],
        buyerId: json['buyer_id'],
        buyerNickname: json['buyer_nickname'],
        totalAmount: (json['total_amount'] * 1.0),
        receivers: json['receivers']
            .map<Member>((element) => Member.fromJson(element))
            .toList(),
        reactions: json['reactions']
            .map<Reaction>((reaction) => Reaction.fromJson(reaction))
            .toList());
  }
}

class PurchaseEntry extends StatefulWidget {
  final PurchaseData data;
  final Function({bool purchase, bool payment}) callback;

  const PurchaseEntry({this.data, this.callback});

  @override
  _PurchaseEntryState createState() => _PurchaseEntryState();
}

class _PurchaseEntryState extends State<PurchaseEntry> {
  Color dateColor;
  Icon icon;
  TextStyle style;
  BoxDecoration boxDecoration;
  String note;
  String names;
  String amount;
  String selfAmount = '';

  void callbackForReaction(String reaction) {
    //TODO: currentNickname
    int idToUse = (guestNickname != null && guestGroupId == currentGroupId)
        ? guestUserId
        : currentUserId;
    Reaction oldReaction = widget.data.reactions
        .firstWhere((element) => element.userId == idToUse, orElse: () => null);
    bool alreadyReacted = oldReaction != null;
    bool sameReaction =
        alreadyReacted ? oldReaction.reaction == reaction : false;
    if (sameReaction) {
      widget.data.reactions.remove(oldReaction);
      setState(() {});
    } else if (!alreadyReacted) {
      widget.data.reactions.add(Reaction(
          nickname: idToUse == currentUserId ? currentUsername : guestNickname,
          reaction: reaction,
          userId: idToUse));
      setState(() {});
    } else {
      widget.data.reactions.add(Reaction(
          nickname: oldReaction.nickname, reaction: reaction, userId: idToUse));
      widget.data.reactions.remove(oldReaction);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    note = (widget.data.name == '')
        ? 'no_note'.tr()
        : widget.data.name[0].toUpperCase() + widget.data.name.substring(1);
    int idToUse = (guestNickname != null && guestGroupId == currentGroupId)
        ? guestUserId
        : currentUserId;
    bool bought = widget.data.buyerId == idToUse;
    bool received = widget.data.receivers
        .where((element) => element.memberId == idToUse)
        .isNotEmpty;
    /* Set icon, amount and names */
    if (bought && received) {
      icon = Icon(Icons.swap_horiz,
          color: Theme.of(context).textTheme.button.color);
      amount = widget.data.totalAmount.printMoney(currentGroupCurrency);
      selfAmount = (-widget.data.receivers
              .firstWhere((member) => member.memberId == idToUse)
              .balance)
          .printMoney(currentGroupCurrency);
      if (widget.data.receivers.length > 1) {
        names = widget.data.receivers.join(', ');
      } else {
        names = widget.data.receivers[0].nickname;
      }
    } else if (bought) {
      icon = Icon(Icons.call_made,
          color: Theme.of(context).textTheme.button.color);
      amount = widget.data.totalAmount.printMoney(currentGroupCurrency);
      if (widget.data.receivers.length > 1) {
        names = widget.data.receivers.join(', ');
      } else {
        names = widget.data.receivers[0].nickname;
      }
    } else if (received) {
      icon = Icon(Icons.call_received,
          color: Theme.of(context).textTheme.bodyText1.color);
      names = widget.data.buyerNickname;
      amount = (-widget.data.receivers
              .firstWhere((element) => element.memberId == idToUse)
              .balance)
          .printMoney(currentGroupCurrency);
    }

    /* Set style color */
    if (bought) {
      style = Theme.of(context).textTheme.button;
      dateColor = Theme.of(context).textTheme.button.color;
      boxDecoration = BoxDecoration(
        // boxShadow: ( Theme.of(context).brightness==Brightness.light)
        //     ?[ BoxShadow(
        //       color: Colors.grey[500],
        //       offset: Offset(0.0, 1.5),
        //       blurRadius: 1.5,
        //     )]
        //     : [],
        gradient:
            AppTheme.gradientFromTheme(Theme.of(context), useSecondary: true),
        borderRadius: BorderRadius.circular(15),
      );
    } else {
      style = Theme.of(context).textTheme.bodyText1;
      dateColor = Theme.of(context).colorScheme.surface;
      boxDecoration = BoxDecoration();
    }

    return Stack(
      children: [
        Container(
          height: !kIsWeb && Platform.isWindows ? 85 : 80,
          width: MediaQuery.of(context).size.width,
          decoration: boxDecoration,
          margin: EdgeInsets.only(
              top: widget.data.reactions.length == 0 ? 0 : 14,
              bottom: 4,
              left: 4,
              right: 4),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onLongPress: () {
                showDialog(
                    builder: (context) => AddReactionDialog(
                          type: 'purchases',
                          reactions: widget.data.reactions,
                          reactToId: widget.data.purchaseId,
                          callback: this.callbackForReaction,
                        ),
                    context: context);
              },
              onTap: () async {
                showModalBottomSheetCustom(
                    context: context,
                    backgroundColor: Theme.of(context).cardTheme.color,
                    builder: (context) => SingleChildScrollView(
                        child: PurchaseAllInfo(widget.data))).then((val) {
                  if (val == 'deleted')
                    widget.callback(purchase: true, payment: false);
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                      visible: received && bought,
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
        ),
        PastReactionContainer(
          reactions: widget.data.reactions,
          reactedToId: widget.data.purchaseId,
          isSecondaryColor: bought,
          type: 'purchases',
          callback: this.callbackForReaction,
        ),
      ],
    );
  }
}
