import 'dart:convert';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/ad_management.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';
import 'package:csocsort_szamla/essentials/models.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/calculator.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/member_chips.dart';
import 'package:csocsort_szamla/main/is_guest_banner.dart';
import 'package:csocsort_szamla/purchase/add_modify_purchase.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../essentials/validation_rules.dart';
import '../essentials/widgets/currency_picker_icon_button.dart';
import '../essentials/widgets/error_message.dart';
import '../shopping/shopping_list_entry.dart';

class SavedPurchase {
  String buyerNickname, buyerUsername;
  int buyerId;
  String name;
  List<Member> receivers;
  double totalAmount;
  int purchaseId;

  SavedPurchase(
      {this.buyerId,
      this.buyerUsername,
      this.buyerNickname,
      this.receivers,
      this.totalAmount,
      this.name,
      this.purchaseId});
}

enum PurchaseType { fromShopping, newPurchase }

class AddPurchaseRoute extends StatefulWidget {
  final PurchaseType type;
  final ShoppingRequestData shoppingData;

  AddPurchaseRoute({@required this.type, this.shoppingData});

  @override
  _AddPurchaseRouteState createState() => _AddPurchaseRouteState();
}

class _AddPurchaseRouteState extends State<AddPurchaseRoute> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  Future<List<Member>> _members;
  Map<Member, bool> membersMap = Map<Member, bool>();
  Map<Member, double> customAmountMap = Map<Member, double>();
  String selectedCurrency = currentGroupCurrency;
  FocusNode _focusNode = FocusNode();

  var _formKey = GlobalKey<FormState>();

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

  Future<bool> _postPurchase(List<Member> members, double amount, String name) async {
    bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
    try {
      Map<String, dynamic> body = {
        "name": name,
        "group": currentGroupId,
        "amount": amount,
        "currency": selectedCurrency,
        "receivers": members
            .map((member) => {
                  "user_id": member.memberId,
                  "amount": customAmountMap.containsKey(member) ? customAmountMap[member] : null,
                })
            .toList()
      };

      await httpPost(uri: '/purchases', body: body, context: context, useGuest: useGuest);
      Future.delayed(delayTime()).then((value) => _onPostPurchase());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onPostPurchase() {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  double amountForNonCustom() {
    double sumCustom = 0;
    customAmountMap.values.forEach((element) => sumCustom += element);
    double amount = (double.tryParse(_amountController.text) ?? 0.0) - sumCustom;
    int membersChosen = 0;
    for (bool isChosen in membersMap.values) {
      if (isChosen) {
        membersChosen++;
      }
    }
    return amount / (membersChosen - customAmountMap.length);
  }

  void setInitialValues() {
    noteController.text = widget.shoppingData.name;
  }

  @override
  void initState() {
    super.initState();
    if (widget.type == PurchaseType.fromShopping) {
      setInitialValues();
    }
    _members = _getMembers();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'purchase'.tr(),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: RefreshIndicator(
            onRefresh: () async {
              _members = null;
              _members = _getMembers(overwriteCache: true);
            },
            child: Column(
              children: [
                IsGuestBanner(
                  callback: () {
                    setState(() {
                      clearGroupCache();
                      _members = null;
                      _members = _getMembers();
                    });
                  },
                ),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  'add_purchase_explanation'.tr(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                validator: (value) => validateTextField({
                                  isEmpty: [value],
                                  minimalLength: [value, 3],
                                }),
                                decoration: InputDecoration(
                                  hintText: 'note'.tr(),
                                  filled: true,
                                  prefixIcon: Icon(
                                    Icons.note,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  // border: OutlineInputBorder(
                                  //   borderRadius: BorderRadius.circular(30),
                                  //   borderSide: BorderSide.none,
                                  // ),
                                ),
                                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                                controller: noteController,
                                onFieldSubmitted: (value) => _buttonPush(),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: Text(
                                  'amount_textbox_hint'.tr(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                validator: (value) => validateTextField({
                                  isEmpty: [value],
                                  notValidNumber: [
                                    value,
                                  ]
                                }),
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  hintText: 'full_amount'.tr(),
                                  filled: true,
                                  prefixIcon: GestureDetector(
                                    onDoubleTap: () {
                                      setState(() {
                                        selectedCurrency = currentGroupCurrency;
                                      });
                                    },
                                    child: CurrencyPickerIconButton(
                                      selectedCurrency: selectedCurrency,
                                      onCurrencyChanged: (newCurrency) {
                                        setState(() {
                                          selectedCurrency = newCurrency ?? selectedCurrency;
                                        });
                                      },
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return SingleChildScrollView(
                                            child: Calculator(
                                              initial: _amountController.text,
                                              callback: (String fromCalc) {
                                                setState(() {
                                                  _amountController.text =
                                                      (double.tryParse(fromCalc) ?? 0.0)
                                                          .money(selectedCurrency);
                                                });
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.calculate,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                controller: _amountController,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp('[0-9\\.]'))
                                ],
                                onFieldSubmitted: (value) => _buttonPush(),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: Text(
                                  'custom_amount_hint'.tr(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: FutureBuilder(
                                  future: _members,
                                  builder: (context, AsyncSnapshot<List<Member>> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      if (snapshot.hasData) {
                                        for (Member member in snapshot.data) {
                                          if (!membersMap.containsKey(member)) {
                                            membersMap[member] = false;
                                          }
                                        }
                                        if (widget.type == PurchaseType.fromShopping) {
                                          membersMap[snapshot.data.firstWhere((member) =>
                                              member.memberId ==
                                              widget.shoppingData.requesterId)] = true;
                                        }
                                        return MemberChips(
                                          selectedCurrency: selectedCurrency,
                                          allowMultiple: true,
                                          allMembers: snapshot.data,
                                          membersChosen: snapshot.data
                                              .where((member) => membersMap[member])
                                              .toList(),
                                          membersChanged: (members) {
                                            setState(() {
                                              for (Member member in snapshot.data) {
                                                membersMap[member] = members.contains(member);
                                              }
                                            });
                                          },
                                          customAmountsChanged: (Map<Member, double> amounts) {
                                            setState(() {
                                              customAmountMap = amounts;
                                            });
                                          },
                                          showDivisionDialog: true,
                                          getMaxAmount: () =>
                                              double.tryParse(_amountController.text) ?? 0.0,
                                        );
                                      } else {
                                        return ErrorMessage(
                                          error: snapshot.error.toString(),
                                          locationOfError: 'add_purchase',
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
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        for (Member member in membersMap.keys) {
                                          membersMap[member] = !membersMap[member];
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      Icons.swap_horiz,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Visibility(
                                    visible: _amountController.text != "" &&
                                        membersMap.containsValue(true),
                                    child: Center(
                                      child: Text(
                                          'per_person'.tr(args: [
                                            amountForNonCustom().printMoney(selectedCurrency)
                                          ]),
                                          style: Theme.of(context).textTheme.bodySmall.copyWith(
                                                color: Theme.of(context).colorScheme.tertiary,
                                              )),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        for (Member member in membersMap.keys) {
                                          membersMap[member] = false;
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: MediaQuery.of(context).viewInsets.bottom == 0,
                  child: AdUnitForSite(site: 'purchase'),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: Icon(Icons.send, color: Theme.of(context).colorScheme.onTertiary),
          onPressed: _buttonPush,
        ),
      ),
    );
  }

  void _buttonPush() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState.validate()) {
      if (!membersMap.containsValue(true)) {
        FToast ft = FToast();
        ft.init(context);
        ft.showToast(
            child: errorToast('person_not_chosen', context),
            toastDuration: Duration(seconds: 2),
            gravity: ToastGravity.BOTTOM);
        return;
      }
      double amount = double.parse(_amountController.text);
      String name = noteController.text;
      List<Member> members = [];
      membersMap.forEach((Member key, bool value) {
        if (value) members.add(key);
      });
      showDialog(
          builder: (context) => FutureSuccessDialog(
                future: _postPurchase(members, amount, name),
              ),
          barrierDismissible: false,
          context: context);
    }
  }
}
