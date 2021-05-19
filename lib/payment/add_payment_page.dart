import 'package:csocsort_szamla/essentials/ad_management.dart';
import 'package:csocsort_szamla/essentials/widgets/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/essentials/widgets/calculator.dart';
import 'package:csocsort_szamla/main/is_guest_banner.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';

import '../essentials/app_theme.dart';
import '../essentials/widgets/error_message.dart';
import '../essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';

class SavedPayment{
  String note;
  int payerId, takerId;
  double amount;
  int paymentId;
  SavedPayment({this.note, this.payerId, this.takerId, this.amount, this.paymentId});
}

class AddPaymentRoute extends StatefulWidget {
  @override
  _AddPaymentRouteState createState() => _AddPaymentRouteState();
}

class _AddPaymentRouteState extends State<AddPaymentRoute> {
  Member _chipChoiceValue;
  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  Future<List<Member>> _members;

  var _formKey = GlobalKey<FormState>();

  Future<List<Member>> _getMembers({bool overwriteCache=false}) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      http.Response response = await httpGet(
        uri: generateUri(GetUriKeys.groupCurrent),
        context: context,
        overwriteCache: overwriteCache,
        useGuest: useGuest
      );

      Map<String, dynamic> decoded = jsonDecode(response.body);
      List<Member> members = [];
      int idToUse=(guestNickname!=null && guestGroupId==currentGroupId)?guestUserId:currentUserId;
      for (var member in decoded['data']['members']) {
        if(member['user_id']!=idToUse){
          members.add(Member(
              nickname: member['nickname'],
              balance: (member['balance'] * 1.0),
              memberId: member['user_id']
          )
          );
        }
      }
      return members;

    } catch (_) {
      throw _;
    }
  }

  Future<bool> _postPayment(double amount, String note, Member toMember) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      Map<String, dynamic> body = {
        'group': currentGroupId,
        'amount': amount,
        'note': note,
        'taker_id': toMember.memberId
      };

      await httpPost(uri: '/payments', body: body, context: context, useGuest: useGuest);
      return true;
    } catch (_) {
      throw _;
    }
  }
  
  @override
  void initState() {
    super.initState();
    _members = _getMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('payment'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: AppTheme.gradientFromTheme(Theme.of(context))
            ),
          ),
        ),


        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _members=_getMembers(overwriteCache: true);
            });
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                IsGuestBanner(callback: (){setState(() { _members=null; _members=_getMembers();});},),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'note'.tr(),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.onSurface),
                                    //  when the TextFormField in unfocused
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.primary,
                                        width: 2),
                                  ),
                                ),
                                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                                controller: _noteController,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context).textTheme.bodyText1.color),
                                cursorColor: Theme.of(context).colorScheme.secondary,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Stack(
                                children: [
                                  TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'field_empty'.tr();
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'not_valid_num'.tr();
                                      }
                                      if (double.parse(value) < 0) {
                                        return 'not_valid_num'.tr();
                                      }
                                      return null;
                                    },
                                    controller: _amountController,
                                    decoration: InputDecoration(
                                      labelText: 'amount'.tr(),
                                      hintText: getSymbol(currentGroupCurrency),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.onSurface),
                                        //  when the TextFormField in unfocused
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.primary,
                                            width: 2),
                                      ),
                                    ),
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).textTheme.bodyText1.color),
                                    cursorColor: Theme.of(context).colorScheme.secondary,
                                    keyboardType:
                                    TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp('[0-9\\.]'))
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top:20),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: IconButton(
                                          icon: Icon(Icons.calculate, color: Theme.of(context).colorScheme.primary,),
                                          onPressed: (){
                                            showModalBottomSheetCustom(
                                              context: context,
                                              builder: (context) {
                                                return SingleChildScrollView(
                                                    child: Calculator(
                                                      callback: (String fromCalc){
                                                        setState(() {
                                                          _amountController.text=fromCalc;
                                                        });
                                                      },
                                                    )
                                                );
                                              },
                                            );
                                          }
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: FutureBuilder(
                                  future: _members,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasData) {
                                        return Wrap(
                                          spacing: 10,
                                          children: snapshot.data
                                              .map<ChoiceChip>((Member member) =>
                                                  ChoiceChip(
                                                    label: Text(member.nickname),
                                                    pressElevation: 30,
                                                    selected: _chipChoiceValue ==
                                                        member,
                                                    onSelected: (bool newValue) {
                                                      FocusScope.of(context).unfocus();
                                                      setState(() {
                                                        _chipChoiceValue = member;
                                                        // _selectedMember = member;
                                                      });
                                                    },
                                                    labelStyle: _chipChoiceValue ==
                                                            member
                                                        ? Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            .copyWith(
                                                                color: Theme.of(context)
                                                                    .colorScheme
                                                                    .onSecondary)
                                                        : Theme.of(context)
                                                            .textTheme
                                                            .bodyText1,
                                                    backgroundColor: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                    selectedColor: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ))
                                              .toList(),
                                        );
                                      } else {
                                        return ErrorMessage(
                                          error: snapshot.error.toString(),
                                          locationOfError: 'add_payment',
                                          callback: (){
                                            setState(() {
                                              _members = null;
                                              _members = _getMembers();
                                            });
                                          },
                                        );
                                      }
                                    }

                                    return Center(child: CircularProgressIndicator());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
//              Balances()
                    ],
                  ),
                ),
                Visibility(
                    visible: MediaQuery.of(context).viewInsets.bottom == 0,
                    child: adUnitForSite('payment'),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.send),
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (_formKey.currentState.validate()) {
              if (_chipChoiceValue == null) {
                FlutterToast ft = FlutterToast(context);
                ft.showToast(
                    child: errorToast('person_not_chosen', context),
                    toastDuration: Duration(seconds: 2),
                    gravity: ToastGravity.BOTTOM);
                return;
              }
              double amount = double.parse(_amountController.text);
              String note = _noteController.text;
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  child: FutureSuccessDialog(
                    future: _postPayment(amount, note, _chipChoiceValue),
                    dataTrue: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Text("payment_scf".tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(color: Colors.white),
                                textAlign: TextAlign.center)),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GradientButton(
                              child:Row(
                                children: [
                                  Icon(Icons.check, color: Theme.of(context).colorScheme.onSecondary),
                                  SizedBox(width: 3,),
                                  Text('okay'.tr(), style: Theme.of(context).textTheme.button,),
                                ],
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              useShadow: false,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GradientButton(
                              child:Row(
                                children: [
                                  Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary),
                                  SizedBox(width: 3,),
                                  Text('add_new'.tr(), style: Theme.of(context).textTheme.button,),
                                ],
                              ),
                              onPressed: () {
                                _amountController.text = '';
                                _noteController.text = '';
                                _chipChoiceValue = null;
                                Navigator.pop(context);
                              },
                              useShadow: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
            }
          },
        ),
      ),
    );
  }
}
