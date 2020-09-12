import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'config.dart';

import 'package:csocsort_szamla/future_success_dialog.dart';

import 'package:csocsort_szamla/payments_needed.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'group_objects.dart';
import 'package:csocsort_szamla/payment/payment_entry.dart';

class Balances extends StatefulWidget {
  final Function callback;
  Balances({this.callback});
  @override
  _BalancesState createState() => _BalancesState();
}

class _BalancesState extends State<Balances> {
  Future<List<Member>> money;

  Future<bool> _postPayment(double amount, String note, String takerId) async {
    try {
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + apiToken
      };

      Map<String, dynamic> map = {
        'group': currentGroupId,
        'amount': amount,
        'note': note,
        'taker_id': takerId
      };
      String encoded = json.encode(map);

      http.Response response =
      await http.post(APPURL + '/payments', body: encoded, headers: header);
      return response.statusCode == 200;
    } catch (_) {
      throw _;
    }
  }

  Future<bool> _postPayments(List<PaymentData> payments) async {
    for(PaymentData payment in payments){
      if(await _postPayment(payment.amount, 'Auto', payment.takerId)){
        continue;
      }
    }
    return true;
  }

  Future<List<Member>> _getMoney() async {
    try {
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + apiToken
      };

      http.Response response = await http.get(
          APPURL + '/groups/' + currentGroupId.toString(),
          headers: header);

      if (response.statusCode == 200) {
        Map<String, dynamic> response2 = jsonDecode(response.body);
        List<Member> members = [];
        for (var member in response2['data']['members']) {
          members.add(Member(
              nickname: member['nickname'],
              balance: member['balance'] * 1.0,
              userId: member['user_id']));
        }
        return members;
      } else {
        Map<String, dynamic> error = jsonDecode(response.body);
        if (error['error'] == 'Unauthenticated.') {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
              (r) => false);
        }
        throw error['error'];
      }
    } catch (_) {
      throw _;
    }
  }

  @override
  void initState() {
    super.initState();
    money = null;
    money = _getMoney();
  }

  @override
  void didUpdateWidget(Balances oldWidget) {
    super.didUpdateWidget(oldWidget);
    money = null;
    money = _getMoney();
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
                future: money,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Column(children: _generateBalances(snapshot.data)),
                          RaisedButton(
                            onPressed: (){
                              List<PaymentData> payments = paymentsNeeded(snapshot.data).where((payment) => payment.payerId==currentUser).toList();
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder:(context){
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15)),
                                    title: Text('payments_needed'.tr(),
                                      style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
                                    ),
                                    content: _generatePaymentsNeeded(payments),
                                    actions: [
                                      RaisedButton(
                                        onPressed: (){
                                          Navigator.pop(context);
                                        },
                                        color: Theme.of(context).colorScheme.primary,
                                        child: Text('back'.tr(), style: Theme.of(context).textTheme.button,),
                                      ),
                                      Visibility(
                                        visible: payments.length>0,
                                        child: RaisedButton(
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
                                          color: Theme.of(context).colorScheme.primary,
                                          child: Text('pay'.tr(), style: Theme.of(context).textTheme.button,),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              );
                            },
                            color: Theme.of(context).colorScheme.primary,
                            child: Text('who_to_pay'.tr(), style: Theme.of(context).textTheme.button,),
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
                              money = null;
                              money = _getMoney();
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
      return Container(
        width: double.maxFinite,
        // padding: EdgeInsets.all(8),
        child: ListView(
          shrinkWrap: true,
          children: payments.map<Widget>((PaymentData payment) {
            var icon = Icon(Icons.call_made,
                color: (Theme.of(context).brightness == Brightness.dark)
                    ? Theme.of(context).textTheme.bodyText1.color
                    : Theme.of(context).textTheme.button.color);
            var style = (Theme.of(context).brightness == Brightness.dark)
                ? Theme.of(context).textTheme.bodyText1
                : Theme.of(context).textTheme.button;
            var dateColor = (Theme.of(context).brightness == Brightness.dark)
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).textTheme.button.color;
            var boxDecoration = BoxDecoration(
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
                                                    'automatic',
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
      if (member.userId == currentUser) {
        TextStyle style = (Theme.of(context).brightness == Brightness.dark)
            ? Theme.of(context).textTheme.bodyText1
            : Theme.of(context).textTheme.button;
        return Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (Theme.of(context).brightness == Brightness.dark)
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.secondary,
                  border: Border.all(
                      color: (Theme.of(context).brightness == Brightness.dark)
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.transparent,
                      width: 1.5),
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
