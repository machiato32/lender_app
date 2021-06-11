import 'dart:convert';

import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/essentials/widgets/calculator.dart';
import 'package:csocsort_szamla/essentials/widgets/error_message.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/purchase/add_purchase_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';


class ModifyPurchaseDialog extends StatefulWidget {
  final SavedPurchase savedPurchase;
  ModifyPurchaseDialog({@required this.savedPurchase});
  @override
  _ModifyPurchaseDialogState createState() => _ModifyPurchaseDialogState();
}

class _ModifyPurchaseDialogState extends State<ModifyPurchaseDialog> {

  TextEditingController _noteController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  Future<List<Member>> _members;
  Map<Member, bool> memberChipBool = Map<Member, bool>();
  var _formKey = GlobalKey<FormState>();

  int _index=0;

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
      for (var member in decoded['data']['members']) {
        members.add(Member(
            nickname: member['nickname'],
            balance: (member['balance'] * 1.0),
            username: member['username'],
            memberId: member['user_id']
        ));
      }
      return members;

    } catch (_) {
      throw _;
    }
  }

  Future<bool> _updatePurchase(List<Member> members, double amount, String name, int purchaseId) async {
    try {
      bool useGuest = guestNickname!=null && guestGroupId==currentGroupId;
      Map<String, dynamic> body = {
        "name": name,
        "amount": amount,
        "receivers": members.map((e) => e.toJson()).toList()
      };

      await httpPut(uri: '/purchases/'+purchaseId.toString(), body: body, context: context, useGuest: useGuest);
      Future.delayed(delayTime()).then((value) => _onUpdatePurchase());
      return true;

    } catch (_) {
      throw _;
    }
  }

  void _onUpdatePurchase(){
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    _members=_getMembers();
    _noteController.text= widget.savedPurchase.name;
    _amountController.text=widget.savedPurchase.totalAmount.money(currentGroupCurrency);
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
              Center(child: Text('modify_purchase'.tr(), style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,)),
              SizedBox(height: 15,),
              Center(child: Text('modify_purchase_explanation'.tr(), style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.center,)),
              SizedBox(height: 10,),
              Visibility(
                visible: _index==0,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'field_empty'.tr();
                    }
                    if (value.length < 3) {
                      return 'minimal_length'.tr(args: ['3']);
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'note'.tr(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                          Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50)
                  ],
                  controller: _noteController,
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .color),
                  cursorColor:
                  Theme.of(context).colorScheme.secondary,
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
                      decoration: InputDecoration(
                        labelText: 'full_amount'.tr(),
                        hintText: getSymbol(currentGroupCurrency),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface),
                          //  when the TextFormField in unfocused
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color:
                              Theme.of(context).colorScheme.primary,
                              width: 2),
                        ),
                      ),
                      controller: _amountController,
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .color),
                      cursorColor:
                      Theme.of(context).colorScheme.secondary,
                      keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp('[0-9\\.]'))
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
                                        initial: _amountController.text,
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
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          List<Member> snapshotMembers = snapshot.data;
                          for (Member member in snapshot.data) {
                            memberChipBool.putIfAbsent(member, () => false);
                          }
                          if(widget.savedPurchase.receivers!=null) {
                            for (Member member in widget.savedPurchase.receivers) {
                              print(member.username);
                              Member memberInCheckbox = snapshotMembers.firstWhere(
                                (element) => element.memberId == member.memberId,
                                orElse: () => null
                              );
                              if (memberInCheckbox != null)
                                memberChipBool[memberInCheckbox] = true;
                            }
                            widget.savedPurchase.receivers=null; //Needed so it happens only once
                          }
                          return ListView(
                            shrinkWrap: true,
                            children: [
                              Center(
                                child: Wrap(
                                  spacing: 10,
                                  children: snapshot.data
                                      .map<ChoiceChip>((Member member) =>
                                      ChoiceChip(
                                        shadowColor: Colors.transparent,
                                        elevation: 0,
                                        label: Text(member.nickname),
                                        pressElevation: 30,
                                        selected: memberChipBool[member],
                                        onSelected: (bool newValue) {
                                          FocusScope.of(context).unfocus();
                                          setState(() {
                                            memberChipBool[member] = newValue;
                                          });
                                        },
                                        labelStyle: memberChipBool[member]
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
                                ),
                              ),
                            ],
                          );
                        } else {
                          return ErrorMessage(
                            error: snapshot.error.toString(),
                            locationOfError: 'modify_purchase',
                            callback: (){
                              setState(() {
                                _members = null;
                                _members = _getMembers();
                              });
                            },
                          );
                        }
                      }
                      return CircularProgressIndicator();
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
                          if (!memberChipBool.containsValue(true)) {
                            FlutterToast ft = FlutterToast(context);
                            ft.showToast(
                                child: errorToast('person_not_chosen', context),
                                toastDuration: Duration(seconds: 2),
                                gravity: ToastGravity.BOTTOM);
                            return;
                          }
                          double amount = double.parse(_amountController.text);
                          String name = _noteController.text;
                          List<Member> members = new List<Member>();
                          memberChipBool.forEach((Member key, bool value) {
                            if (value) members.add(key);
                          });
                          showDialog(
                            context: context,
                            child: FutureSuccessDialog(
                              future: _updatePurchase(members, amount, name, widget.savedPurchase.purchaseId),
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
