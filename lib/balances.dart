import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'config.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';
import 'package:csocsort_szamla/payments_needed.dart';
import 'package:easy_localization/easy_localization.dart';
import 'group_objects.dart';
import 'package:csocsort_szamla/payment/payment_entry.dart';
import 'http_handler.dart';
import 'app_theme.dart';
import 'gradient_button.dart';

class Balances extends StatefulWidget {
  final Function callback;
  Balances({this.callback});
  @override
  _BalancesState createState() => _BalancesState();
}

class _BalancesState extends State<Balances> {
  Future<List<Member>> _money;

  Future<bool> _postPayment(double amount, String note, int takerId) async {
    try {

      Map<String, dynamic> body = {
        'group': currentGroupId,
        'amount': amount,
        'note': note,
        'taker_id': takerId
      };

      await httpPost(uri: '/payments', body: body, context: context);
      return true;
    } catch (_) {
      throw _;
    }
  }

  Future<bool> _postPayments(List<PaymentData> payments) async {
    for(PaymentData payment in payments){
      if(await _postPayment(payment.amount*1.0, 'Auto', payment.takerId)){
        continue;
      }
    }
    return true;
  }

  Future<List<Member>> _getMoney() async {
    try {

      http.Response response = await httpGet(
          uri: '/groups/' + currentGroupId.toString(),
          context: context
      );

      Map<String, dynamic> decoded = jsonDecode(response.body);
      List<Member> members = [];
      for (var member in decoded['data']['members']) {
        members.add(Member(
            nickname: member['nickname'],
            balance: (member['balance'] * 1.0).round(),
            username: member['username'],
            memberId: member['user_id']
          )
        );
      }
      members.sort((member1, member2)=>member2.balance.compareTo(member1.balance));
      return members;

    } catch (_) {
      throw _;
    }
  }

  @override
  void initState() {
    super.initState();
    _money = null;
    _money = _getMoney();
  }

  @override
  void didUpdateWidget(Balances oldWidget) {
    super.didUpdateWidget(oldWidget);
    _money = null;
    _money = _getMoney();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                'balances'.tr(),
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: FutureBuilder(
                future: _money,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Column(children: _generateBalances(snapshot.data)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GradientButton(
                                onPressed: (){
                                  List<PaymentData> payments = paymentsNeeded(snapshot.data).where((payment) => payment.payerId==currentUserId).toList();
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder:(BuildContext context){
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15)
                                        ),
                                        
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('payments_needed'.tr(),
                                                style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              _generatePaymentsNeeded(payments),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  GradientButton(
                                                    onPressed: (){
                                                      Navigator.pop(context);
                                                    },
                                                    // color: Theme.of(context).colorScheme.primary,
                                                    child: Text('back'.tr(), style: Theme.of(context).textTheme.button,),
                                                  ),
                                                  Visibility(
                                                    visible: payments.length>0,
                                                    child: GradientButton(
                                                      onPressed: () async {
                                                        showDialog(
                                                            context: context,
                                                            child: FutureSuccessDialog(
                                                              future: _postPayments(payments),
                                                              dataTrueText: 'payment_scf',
                                                              onDataTrue: (){
                                                                Navigator.pop(context);
                                                                Navigator.pop(context);
                                                                widget.callback();
                                                              },
                                                            )
                                                        );
                                                      },
                                                      child: Text('pay'.tr(), style: Theme.of(context).textTheme.button,),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  );
                                },

                                // text: 'who_to_pay'.tr(),
                                // color: Theme.of(context).colorScheme.secondary,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('who_to_pay'.tr(), style: Theme.of(context).textTheme.button,),
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    } else {
                      return InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(snapshot.error.toString()),
                          ),
                          onTap: () {
                            setState(() {
                              _money = null;
                              _money = _getMoney();
                            });
                          });
                    }
                  }
                  return CircularProgressIndicator();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _generatePaymentsNeeded(List<PaymentData> payments){
    if(payments.length!=0){
      return Flexible(
        child: ListView(
          shrinkWrap: true,
          children: payments.map<Widget>((PaymentData payment) {
            var icon = Icon(Icons.call_made,
                color: Theme.of(context).textTheme.button.color);
            var style = Theme.of(context).textTheme.button;
            var dateColor = Theme.of(context).textTheme.button.color;
            var boxDecoration = BoxDecoration(
              gradient: AppTheme.gradientFromTheme(Theme.of(context)),
              borderRadius: BorderRadius.circular(15),
            );
            var amount = payment.amount.toString();
            return Container(
              height: 55,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(bottom: 4),
              decoration: boxDecoration,
              child: Padding(
                padding: EdgeInsets.all(5),
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
                                                    payment.takerNickname,
                                                    style: style.copyWith(fontSize: 22),
                                                    overflow: TextOverflow.ellipsis,
                                                  )),
                                              Flexible(
                                                  child: Text(
                                                    'auto_payment'.tr(),
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
                        )
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );

    }else{
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text('you_are_good'.tr(), style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center,)),
        ],
      );
    }
  }

  List<Widget> _generateBalances(List<Member> members) {
    return members.map<Widget>((Member member) {
      if (member.memberId == currentUserId) {
        TextStyle style = Theme.of(context).textTheme.button;
        return Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientFromTheme(Theme.of(context)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      member.nickname,
                      style: style,
                    ),
                    Text(
                      member.balance.toString(),
                      style: style,
                    )
                  ],
                )),
            SizedBox(
              height: 3,
            )
          ],
        );
      }
      return Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    member.nickname,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    member.balance.toString(),
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              )),
          SizedBox(
            height: 3,
          )
        ],
      );
    }).toList();
  }
}
