import 'dart:convert';

import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/essentials/widgets/calculator.dart';
import 'package:csocsort_szamla/essentials/widgets/error_message.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';

import 'add_payment_page.dart';


class ModifyPaymentDialog extends StatefulWidget {
  final SavedPayment savedPayment;
  ModifyPaymentDialog({@required this.savedPayment});
  @override
  _ModifyPaymentDialogState createState() => _ModifyPaymentDialogState();
}

class _ModifyPaymentDialogState extends State<ModifyPaymentDialog> {

  TextEditingController _noteController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  Future<List<Member>> _members;
  Member _chipChoiceValue;
  var _formKey = GlobalKey<FormState>();

  int _index=0;

  Future<List<Member>> _getMembers({bool overwriteCache=false}) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      http.Response response = await httpGet(
          uri: '/groups/' + currentGroupId.toString(),
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

  Future<bool> _updatePayment(double amount, String note, Member toMember, int paymentId) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      Map<String, dynamic> body = {
        'amount': amount,
        'note': note,
        'taker_id': toMember.memberId
      };

      await httpPut(uri: '/payments/'+paymentId.toString(), body: body, context: context, useGuest: useGuest);
      Future.delayed(delayTime()).then((value) => _onUpdatePayment());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onUpdatePayment(){
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    _members=_getMembers();
    if(widget.savedPayment!=null){
      _amountController.text=widget.savedPayment.amount.money(currentGroupCurrency);
      _noteController.text=widget.savedPayment.note;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Text('modify_payment'.tr(), style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,)),
              SizedBox(height: 15,),
              Center(child: Text('modify_payment_explanation'.tr(), style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.center,)),
              SizedBox(height: 10,),
              Visibility(
                visible: _index==0,
                child: TextField(
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
              ),
              Visibility(
                visible: _index==1,
                child: Stack(
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
              ),
              Visibility(
                visible: _index==2,
                child: Center(
                  child: FutureBuilder(
                    future: _members,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.done) {
                        if (snapshot.hasData) {
                          if(widget.savedPayment!=null && widget.savedPayment.takerId!=-1){
                            Member selectMember = (snapshot.data as List<Member>).firstWhere((element) => element.memberId==widget.savedPayment.takerId, orElse: null);
                            if(selectMember!=null)
                              _chipChoiceValue=selectMember;
                            widget.savedPayment.takerId=-1;
                          }
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
                            locationOfError: 'update_payment',
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
              ),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: _index!=0,
                    child: GradientButton(
                      onPressed: () {
                        setState(() {
                          _index--;
                        });
                      },
                      child: Icon(Icons.navigate_before, color: Theme.of(context).textTheme.button.color),
                    ),
                  ),
                  GradientButton(
                    onPressed: () {
                      if(_index!=2){
                        if(_formKey.currentState.validate()){
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _index++;
                          });
                        }
                      }else{
                        if (_formKey.currentState.validate()) {
                          FocusScope.of(context).unfocus();
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
                            context: context,
                            child: FutureSuccessDialog(
                              future: _updatePayment(amount, note, _chipChoiceValue, widget.savedPayment.paymentId),
                            )
                          );
                        }
                      }
                    },
                    child: Icon(_index==2?Icons.check:Icons.navigate_next, color: Theme.of(context).textTheme.button.color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
