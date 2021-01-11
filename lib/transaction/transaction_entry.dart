import 'dart:async';

import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/widgets/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/transaction/transaction_all_info.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/app_theme.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';

class TransactionData {
  DateTime updatedAt;
  String buyerUsername, buyerNickname;
  int buyerId;
  List<Member> receivers;
  double totalAmount;
  int transactionId;
  String name;
  List<Reaction> reactions;

  TransactionData(
    {
      this.updatedAt,
      this.buyerUsername,
      this.buyerNickname,
      this.buyerId,
      this.receivers,
      this.totalAmount,
      this.transactionId,
      this.name,
      this.reactions
    }
  );

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
        transactionId: json['transaction_id'],
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
            .toList()
    );
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

  bool showReactions=false;
  Map<String, bool> isSelected ={
    '❤':false, '❓':false, '💸':false, '👍':false, '😥':false, '🐶':false
  };
  Future<bool> _sendReaction (String reaction) async {
    try{
      Map<String, dynamic> body = {
        "purchase_id":widget.data.transactionId,
        "reaction":reaction
      };
      await httpPost(context: context, uri: '/purchases/reaction', body: body);
      return true;
    }catch(_){
      throw _;
    }
  }

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
    int idToUse=(guestNickname!=null && guestGroupId==currentGroupId)?guestUserId:currentUserId;
    bool bought = widget.data.buyerId == idToUse;
    bool received = widget.data.receivers.where((element) => element.memberId == idToUse).isNotEmpty;
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
        gradient: AppTheme.gradientFromTheme(Theme.of(context), useSecondary: true),
        borderRadius: BorderRadius.circular(15),
      );
    } else {
      style = Theme.of(context).textTheme.bodyText1;
      dateColor = Theme.of(context).colorScheme.surface;
      boxDecoration = BoxDecoration();
    }




    return GestureDetector( //TODO: haptic feedback permission, widget, animation
      onLongPressMoveUpdate: (details) {
        RenderBox box = context.findRenderObject();
        double width=box.size.width;
        double x = details.localPosition.dx/width;
        double y = details.localPosition.dy;
        if(y>0 && y<80){
          if(x>37/width && x<75/width){
            setState(() {
              isSelected['❤']=true;
            });
            HapticFeedback.selectionClick();
            // print('❤');
          }else{
            setState(() {
              isSelected['❤']=false;
            });
          }
          if(x>85/width && x<123/width){
            setState(() {
              isSelected['❓']=true;
            });
            HapticFeedback.selectionClick();
            // print('❓');
          }else{
            setState(() {
              isSelected['❓']=false;
            });
          }
          if(x>133/width && x<171/width){
            setState(() {
              isSelected['💸']=true;
            });
            HapticFeedback.selectionClick();
            // print('💸');
          }else{
            setState(() {
              isSelected['💸']=false;
            });
          }
          if(x>181/width && x<219/width){
            setState(() {
              isSelected['👍']=true;
            });
            HapticFeedback.selectionClick();
            // print('👍');
          }else{
            setState(() {
              isSelected['👍']=false;
            });
          }
          if(x>229/width && x<267/width){
            setState(() {
              isSelected['😥']=true;
            });
            HapticFeedback.selectionClick();
            // print('😥');
          }else{
            setState(() {
              isSelected['😥']=false;
            });
          }
          if(x>277/width && x<315/width){
            setState(() {
              isSelected['🐶']=true;
            });
            HapticFeedback.selectionClick();
            // print('🐶');
          }else{
            setState(() {
              isSelected['🐶']=false;
            });
          }
        }else{
          setState(() {
            isSelected['🐶']=false;
            isSelected['😥']=false;
            isSelected['👍']=false;
            isSelected['💸']=false;
            isSelected['❓']=false;
            isSelected['❤']=false;
          });
        }

      },
      onLongPressEnd: (details) {
        for(String key in isSelected.keys){
          if(isSelected[key]){
            showDialog(
              context: context,
              barrierDismissible: false,
              child: FutureSuccessDialog(
                future: _sendReaction(key),
                dataTrueText: 'reaction_scf',
                onDataTrue: (){
                  Navigator.pop(context);
                },
              )
            ).then((value){
              widget.callback();
            });
            return;
          }
        }
        setState(() {
          showReactions=false;
        });

      },
      onLongPress: (){
        setState(() {
          showReactions=true;
        });
        HapticFeedback.selectionClick();
      },
      child: Stack(
        children:
        [
          Container(
            height: 80,
            width: MediaQuery.of(context).size.width,
            decoration: boxDecoration,
            margin: EdgeInsets.only(top: widget.data.reactions.length==0?0:14, bottom: 4, left: 4, right: 4),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  if(showReactions){
                    setState(() {
                      showReactions=false;
                    });
                  }else{
                    showModalBottomSheetCustom(
                        context: context,
                        backgroundColor: Theme.of(context).cardTheme.color,
                        builder: (context) => SingleChildScrollView(
                            child: TransactionAllInfo(widget.data)
                        )
                    ).then((val) {
                      if (val == 'deleted') widget.callback();
                    });
                  }

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
          Visibility(
            visible: widget.data.reactions.length!=0 && !showReactions,
            child: AnimatedOpacity(
              opacity: widget.data.reactions.length!=0 && !showReactions?1:0,
              duration: Duration(milliseconds: 100),
              curve: Curves.ease,
              child: Container(
                margin: EdgeInsets.only(right: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top:4, bottom: 4, left: 6, right: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: Colors.grey[300],
                        boxShadow:  (Theme.of(context).brightness==Brightness.light)
                            ?[ BoxShadow(
                              color: Colors.grey[500],
                              offset: Offset(0.0, 1.5),
                              blurRadius: 1.5,
                            )]
                            : []
                      ),
                      // color: Colors.grey,
                      child: Row(
                        children: widget.data.reactions.map((e) => Text(e.reaction)).toList()
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: showReactions,
            child: AnimatedOpacity(
              opacity: showReactions?1:0,
              duration: Duration(milliseconds: 100),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: isSelected.containsValue(true)?
                            EdgeInsets.only(top:5, bottom: 5, left: 5, right: 5)
                            :EdgeInsets.only(top:10, bottom: 10, left: 5, right: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(300)),
                            color: Colors.grey[300],
                            boxShadow: (Theme.of(context).brightness==Brightness.light)
                                ?[ BoxShadow(
                                  color: Colors.grey[500],
                                  offset: Offset(0.0, 1.5),
                                  blurRadius: 1.5,
                                )]
                                : []
                        ),
                        // color: Colors.grey,
                        child: Row(
                            children: Reaction.possibleReactions.map((e) => Padding(
                              padding: !isSelected[e]?
                                EdgeInsets.only(left: 5, right:5)
                                :EdgeInsets.all(0),
                              child: Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                    color: widget.data.reactions.firstWhere((el) => el.userId==idToUse && el.reaction==e, orElse: ()=>null)!=null?
                                    Colors.grey:
                                    Colors.grey[300],

                                  ),
                                  child: Text(e, style: TextStyle(fontSize: isSelected[e]?33:25),)
                              ),
                            )).toList()
                        )
                    ),
                  ],
                ),
              ),
            ),
          )

        ]
      ),
    );
  }
}
