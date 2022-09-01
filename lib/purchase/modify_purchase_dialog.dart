import 'dart:convert';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';
import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/essentials/widgets/calculator.dart';
import 'package:csocsort_szamla/essentials/widgets/error_message.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/purchase/add_purchase_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../essentials/widgets/member_chips.dart';

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

  int _index = 0;

  Future<List<Member>> _getMembers({bool overwriteCache = false}) async {
    try {
      bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
      http.Response response = await httpGet(
          uri: generateUri(GetUriKeys.groupCurrent),
          context: context,
          overwriteCache: overwriteCache,
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
      return members;
    } catch (_) {
      throw _;
    }
  }

  Future<bool> _updatePurchase(
      List<Member> members, double amount, String name, int purchaseId) async {
    try {
      bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
      Map<String, dynamic> body = {
        "name": name,
        "amount": amount,
        "receivers": members.map((e) => e.toJson()).toList()
      };

      await httpPut(
          uri: '/purchases/' + purchaseId.toString(),
          body: body,
          context: context,
          useGuest: useGuest);
      Future.delayed(delayTime()).then((value) => _onUpdatePurchase());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onUpdatePurchase() {
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    _members = _getMembers();
    _noteController.text = widget.savedPurchase.name;
    _amountController.text =
        widget.savedPurchase.totalAmount.money(currentGroupCurrency);
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
              Center(
                  child: Text(
                'modify_purchase'.tr(),
                style: Theme.of(context).textTheme.titleLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              )),
              SizedBox(
                height: 15,
              ),
              Center(
                  child: Text(
                'modify_purchase_explanation'.tr(),
                style: Theme.of(context).textTheme.titleSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              )),
              SizedBox(
                height: 10,
              ),
              Visibility(
                visible: _index == 0,
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
                    hintText: 'note'.tr(),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.note,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  controller: _noteController,
                ),
              ),
              Visibility(
                visible: _index == 1,
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
                        hintText: 'full_amount'.tr(),
                        filled: true,
                        prefixIcon: Icon(
                          Icons.pin,
                        ),
                        suffixIcon: Icon(
                          Icons.calculate,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      controller: _amountController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9\\.]'))
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 9),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                            splashRadius: 0.1,
                            icon: Icon(
                              Icons.calculate,
                              color: Colors.transparent,
                            ),
                            onPressed: () {
                              showModalBottomSheetCustom(
                                context: context,
                                builder: (context) {
                                  return SingleChildScrollView(
                                      child: Calculator(
                                    initial: _amountController.text,
                                    callback: (String fromCalc) {
                                      setState(() {
                                        _amountController.text = fromCalc;
                                      });
                                    },
                                  ));
                                },
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _index == 2,
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
                          if (widget.savedPurchase.receivers != null) {
                            for (Member member
                                in widget.savedPurchase.receivers) {
                              print(member.username);
                              Member memberInCheckbox =
                                  snapshotMembers.firstWhere(
                                      (element) =>
                                          element.memberId == member.memberId,
                                      orElse: () => null);
                              if (memberInCheckbox != null)
                                memberChipBool[memberInCheckbox] = true;
                            }
                            widget.savedPurchase.receivers =
                                null; //Needed so it happens only once
                          }
                          return ListView(
                            shrinkWrap: true,
                            children: [
                              Center(
                                child: MemberChips(
                                  allowMultiple: true,
                                  allMembers: snapshot.data,
                                  membersChosen: snapshot.data
                                      .where((member) => memberChipBool[member])
                                      .toList(),
                                  membersChanged: (members) {
                                    setState(() {
                                      for (Member member in snapshot.data) {
                                        memberChipBool[member] =
                                            members.contains(member);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        } else {
                          return ErrorMessage(
                            error: snapshot.error.toString(),
                            locationOfError: 'modify_purchase',
                            callback: () {
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
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: _index != 0,
                    child: GradientButton(
                      onPressed: () {
                        setState(() {
                          _index--;
                        });
                      },
                      child: Icon(Icons.navigate_before,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  GradientButton(
                    onPressed: () {
                      if (_index != 2) {
                        if (_formKey.currentState.validate()) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _index++;
                          });
                        }
                      } else {
                        if (_formKey.currentState.validate()) {
                          FocusScope.of(context).unfocus();
                          if (!memberChipBool.containsValue(true)) {
                            FToast ft = FToast();
                            ft.init(context);
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
                              builder: (context) => FutureSuccessDialog(
                                    future: _updatePurchase(members, amount,
                                        name, widget.savedPurchase.purchaseId),
                                  ),
                              context: context);
                        }
                      }
                    },
                    child: Icon(_index == 2 ? Icons.check : Icons.navigate_next,
                        color: Theme.of(context).colorScheme.onPrimary),
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
