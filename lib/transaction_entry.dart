import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'person.dart';
import 'bottom_sheet_custom.dart';
import 'transaction_all_info.dart';
import 'config.dart';

class TransactionData {
  String type;
  DateTime updatedAt;
  String buyerId, buyerNickname;
  List<Member> receivers;
  double totalAmount;
  int transactionId;
  String name;

  TransactionData({this.type, this.updatedAt, this.buyerId,
    this.buyerNickname, this.receivers, this.totalAmount, this.transactionId,
    this.name});

  factory TransactionData.fromJson(Map<String, dynamic> json){
    return TransactionData(
        type: json['type'],
        transactionId: json['data']['transaction_id'],
        name: json['data']['name'],
        updatedAt: json['data']['updated_at']==null?DateTime.now():DateTime.parse(json['data']['updated_at']),
        buyerId: json['data']['buyer_id'],
        buyerNickname: json['data']['buyer_nickname'],
        totalAmount: json['data']['total_amount']*1.0,
        receivers: json['data']['receivers'].map<Member>((element)=>Member.fromJson(element)).toList()
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
  String selfAmount='';

  @override
  Widget build(BuildContext context) {
    date = DateFormat('yyyy/MM/dd - kk:mm').format(widget.data.updatedAt);
    note = (widget.data.name=='')?'(Nincs megjegyzés)':widget.data.name[0].toUpperCase()+widget.data.name.substring(1);
    if(widget.data.type=='buyed'){
      icon=Icon(Icons.call_made,
          color: (Theme.of(context).brightness==Brightness.dark)?
          Theme.of(context).textTheme.body2.color:
          Theme.of(context).textTheme.button.color);
      style=(Theme.of(context).brightness==Brightness.dark)?
      Theme.of(context).textTheme.body2:
      Theme.of(context).textTheme.button;
      dateColor=(Theme.of(context).brightness==Brightness.dark)?
      Theme.of(context).colorScheme.surface:
      Theme.of(context).textTheme.button.color;
      boxDecoration=BoxDecoration(
        color: (Theme.of(context).brightness==Brightness.dark)?Colors.transparent:Theme.of(context).colorScheme.secondary,
        border: Border.all(color: (Theme.of(context).brightness==Brightness.dark)?Theme.of(context).colorScheme.secondary:Colors.transparent, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      );
      if(widget.data.receivers.length>1){
        names=widget.data.receivers.join(', ');
      }else{
        names=widget.data.receivers[0].nickname;
      }
      amount = widget.data.totalAmount.toString();
    }else if(widget.data.type=='buyed_received'){
      icon=Icon(Icons.swap_horiz,
          color: (Theme.of(context).brightness==Brightness.dark)?
          Theme.of(context).textTheme.body2.color:
          Theme.of(context).textTheme.button.color);
      style=(Theme.of(context).brightness==Brightness.dark)?
      Theme.of(context).textTheme.body2:
      Theme.of(context).textTheme.button;
      dateColor=(Theme.of(context).brightness==Brightness.dark)?
      Theme.of(context).colorScheme.surface:
      Theme.of(context).textTheme.button.color;
      boxDecoration=BoxDecoration(
        color: (Theme.of(context).brightness==Brightness.dark)?Colors.transparent:Theme.of(context).colorScheme.secondary,
        border: Border.all(color: (Theme.of(context).brightness==Brightness.dark)?Theme.of(context).colorScheme.secondary:Colors.transparent, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      );
      if(widget.data.receivers.length>1){
        names=widget.data.receivers.join(', ');
      }else{
        names=widget.data.receivers[0].nickname;
      }
      amount = widget.data.totalAmount.toString();
      selfAmount = (-widget.data.receivers.firstWhere((member) => member.userId==currentUser).balance).toString();
    }else if(widget.data.type=='received'){
      icon=Icon(Icons.call_received, color: Theme.of(context).textTheme.body2.color);
      style=Theme.of(context).textTheme.body2;
      dateColor=Theme.of(context).colorScheme.surface;
      names = widget.data.buyerNickname;
      amount = (-widget.data.totalAmount).toString();
      boxDecoration=BoxDecoration();
    }
    return Container(
      height: 75,
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
                builder: (context)=>SingleChildScrollView(
                    child: TransactionAllInfo(widget.data)
                )
            ).then((val){
              if(val=='deleted')
                widget.callback();
            });


          },
          borderRadius: BorderRadius.circular(4.0),

          child: Padding(

            padding: EdgeInsets.all(15),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Flexible(
                    child:Column(
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
                                    Flexible(child: SizedBox(width: 20,),),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Flexible(child: Text(note, style: style, overflow: TextOverflow.ellipsis,)),
                                          Flexible(child: Text(names, style: TextStyle(color: dateColor, fontSize: 15), overflow: TextOverflow.ellipsis,))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                children: <Widget>[
                                  Text(amount, style: style,),
                                  Visibility(
                                    visible: widget.data.type=='buyed_received',
                                    child: Text(selfAmount, style: style,)
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}