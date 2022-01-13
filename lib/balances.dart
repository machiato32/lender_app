import 'dart:convert';

import 'package:csocsort_szamla/essentials/payments_needed.dart';
import 'package:csocsort_szamla/essentials/widgets/error_message.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/groups/dialogs/share_group_dialog.dart';
import 'package:csocsort_szamla/payment/payment_entry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';
import 'essentials/app_theme.dart';
import 'essentials/currencies.dart';
import 'essentials/group_objects.dart';
import 'essentials/http_handler.dart';
import 'essentials/widgets/gradient_button.dart';
import 'groups/main_group_page.dart';

class Balances extends StatefulWidget {
  final Function callback;
  final bool bigScreen;
  Balances({this.callback, this.bigScreen});
  @override
  _BalancesState createState() => _BalancesState();
}

class _BalancesState extends State<Balances> {
  Future<List<Member>> _money;

  Future<bool> _postPayment(double amount, String note, int takerId) async {
    try {
      bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
      Map<String, dynamic> body = {
        'group': currentGroupId,
        'amount': amount,
        'note': note,
        'taker_id': takerId
      };

      await httpPost(
          uri: '/payments', body: body, context: context, useGuest: useGuest);
      return true;
    } catch (_) {
      throw _;
    }
  }

  Future<bool> _postPayments(List<PaymentData> payments) async {
    for (PaymentData payment in payments) {
      if (await _postPayment(
          payment.amount * 1.0, '\$\$auto_payment\$\$'.tr(), payment.takerId)) {
        continue;
      }
    }
    Future.delayed(delayTime()).then((value) => _onPostPayments());
    return true;
  }

  void _onPostPayments() {
    Navigator.pop(context);
    Navigator.pop(context);
    widget.callback();
  }

  Future<List<Member>> _getMoney() async {
    try {
      bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
      http.Response response = await httpGet(
          uri: generateUri(GetUriKeys.groupCurrent,
              args: [currentGroupId.toString()]),
          context: context,
          useGuest: useGuest);

      Map<String, dynamic> decoded = jsonDecode(response.body);
      List<Member> members = [];
      for (var member in decoded['data']['members']) {
        members.add(Member(
            nickname: member['nickname'],
            balance: (member['balance'] * 1.0),
            username: member['username'],
            memberId: member['user_id']));
      }
      members.sort(
          (member1, member2) => member2.balance.compareTo(member1.balance));
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
                      int idToUse = (guestNickname != null &&
                              guestGroupId == currentGroupId)
                          ? guestUserId
                          : currentUserId;
                      Member currentMember = (snapshot.data as List<Member>)
                          .firstWhere((element) => element.memberId == idToUse,
                              orElse: () => null);
                      double currencyThreshold =
                          (currencies[currentGroupCurrency]['subunit'] == 1
                                  ? 0.01
                                  : 1) /
                              2;
                      return Column(
                        children: [
                          Column(children: _generateBalances(snapshot.data)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: currentMember == null
                                    ? false
                                    : (currentMember.balance <
                                        -currencyThreshold),
                                child: GradientButton(
                                  onPressed: () {
                                    List<PaymentData> payments =
                                        paymentsNeeded(snapshot.data)
                                            .where((payment) =>
                                                payment.payerId == idToUse)
                                            .toList();
                                    showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'payments_needed'.tr(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  _generatePaymentsNeeded(
                                                      payments),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        payments.length > 0
                                                            ? MainAxisAlignment
                                                                .spaceAround
                                                            : MainAxisAlignment
                                                                .center,
                                                    children: [
                                                      GradientButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          'back'.tr(),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .button,
                                                        ),
                                                      ),
                                                      Visibility(
                                                        maintainSize: false,
                                                        maintainState: false,
                                                        maintainAnimation:
                                                            false,
                                                        maintainSemantics:
                                                            false,
                                                        replacement: SizedBox(
                                                          height: 0,
                                                        ),
                                                        visible:
                                                            payments.length > 0,
                                                        child: GradientButton(
                                                          onPressed: () async {
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  true,
                                                              builder:
                                                                  (context) {
                                                                return FutureSuccessDialog(
                                                                  future: _postPayments(
                                                                      payments),
                                                                  dataTrueText:
                                                                      'payment_scf',
                                                                  onDataTrue:
                                                                      () {
                                                                    _onPostPayments();
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: Text(
                                                            'pay'.tr(),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .button,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'who_to_pay'.tr(),
                                      style: Theme.of(context).textTheme.button,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    } else {
                      return ErrorMessage(
                        error: snapshot.error.toString(),
                        locationOfError: 'balances',
                        callback: () {
                          setState(() {
                            _money = null;
                            _money = _getMoney();
                          });
                        },
                      );
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

  Widget _generatePaymentsNeeded(List<PaymentData> payments) {
    return Flexible(
      child: ListView(
        shrinkWrap: true,
        children: payments.map<Widget>((PaymentData payment) {
          var icon = Icon(Icons.call_made,
              color: Theme.of(context).textTheme.button.color);
          var style = Theme.of(context).textTheme.button;
          var dateColor = Theme.of(context).textTheme.button.color;
          var boxDecoration = BoxDecoration(
            gradient: AppTheme.gradientFromTheme(Theme.of(context),
                useSecondary: true),
            borderRadius: BorderRadius.circular(15),
          );
          var amount = payment.amount.money(currentGroupCurrency);
          return Container(
            height: 65,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(bottom: 4),
            decoration: boxDecoration,
            child: Padding(
              padding: EdgeInsets.all(10),
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
                  )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<String> _getInvitation() async {
    try {
      http.Response response = await httpGet(
        uri: generateUri(GetUriKeys.groupCurrent,
            args: [currentGroupId.toString()]),
        context: context,
      );
      Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded['data']['invitation'];
    } catch (_) {
      throw _;
    }
  }

  List<Widget> _generateBalances(List<Member> members) {
    int idToUse = (guestNickname != null && guestGroupId == currentGroupId)
        ? guestUserId
        : currentUserId;
    List<Widget> widgets = members.map<Widget>((Member member) {
      if (member.memberId == idToUse) {
        TextStyle style = Theme.of(context).textTheme.button;
        return Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientFromTheme(Theme.of(context),
                      useSecondary: true),
                  borderRadius: BorderRadius.circular(15),
                  // boxShadow: (Theme.of(context).brightness == Brightness.light)
                  //     ? [
                  //         BoxShadow(
                  //           color: Colors.grey[500],
                  //           offset: Offset(0.0, 1.5),
                  //           blurRadius: 1.5,
                  //         )
                  //       ]
                  //     : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      member.nickname,
                      style: style,
                    ),
                    Text(
                      member.balance.money(currentGroupCurrency),
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
                    member.balance.money(currentGroupCurrency),
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
    if (members.length == 1) {
      widgets.add(Column(
        children: [
          SizedBox(height: 20),
          Text(
            'you_seem_lonely'.tr(),
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 10),
          Text('invite_friends'.tr(),
              style:
                  Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 17)),
          SizedBox(height: 5),
          FutureBuilder(
            future: _getInvitation(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ShareGroupDialog(
                                      inviteCode: snapshot.data);
                                });
                          },
                          child: Icon(
                            Icons.share,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ErrorMessage(
                    error: snapshot.error.toString(),
                    locationOfError: 'invitation',
                    callback: () {
                      setState(() {
                        // _invitation = null;
                        // _invitation = _getInvitation();
                      });
                    },
                  );
                }
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
          SizedBox(height: 10),
          Text('add_guests_offline'.tr(),
              style:
                  Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 17)),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientButton(
                child: Icon(
                  Icons.person_add,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainPage(
                              selectedIndex: widget.bigScreen ? 1 : 2,
                              scrollTo: 'guests')),
                      (route) => false);
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'you_seem_lonely_explanation'.tr(),
            style: Theme.of(context).textTheme.subtitle2,
            textAlign: TextAlign.center,
          )
        ],
      ));
    }
    return widgets;
  }
}
