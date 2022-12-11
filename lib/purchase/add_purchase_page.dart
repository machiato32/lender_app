import 'dart:convert';
import 'dart:math';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/ad_management.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';
import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/calculator.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/essentials/widgets/member_chips.dart';
import 'package:csocsort_szamla/main/is_guest_banner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../essentials/widgets/error_message.dart';
import '../shopping/shopping_list_entry.dart';

Random random = Random();

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
  Map<Member, bool> memberChipBool = Map<Member, bool>();
  Map<Member, double> percentageMap = Map<Member, double>();
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
        "receivers": members.map((e) => e.toJson()).toList()
      };

      await httpPost(uri: '/purchases', body: body, context: context, useGuest: useGuest);
      return true;
    } catch (_) {
      throw _;
    }
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
    // print(memberChipBool);
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
                                      .titleSmall
                                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
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
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                                controller: noteController,
                                onFieldSubmitted: (value) => _buttonPush(),
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
                                    focusNode: _focusNode,
                                    decoration: InputDecoration(
                                      hintText: 'full_amount'.tr(),
                                      filled: true,
                                      prefixIcon: Icon(
                                        Icons.pin,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      suffixIcon: Icon(
                                        Icons.calculate,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    controller: _amountController,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp('[0-9\\.]'))
                                    ],
                                    onFieldSubmitted: (value) => _buttonPush(),
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
                                            showModalBottomSheet(
                                              isScrollControlled: true,
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
                                          if (!memberChipBool.containsKey(member)) {
                                            memberChipBool[member] = false;
                                          }
                                        }
                                        if (widget.type == PurchaseType.fromShopping) {
                                          memberChipBool[snapshot.data.firstWhere((member) =>
                                              member.memberId ==
                                              widget.shoppingData.requesterId)] = true;
                                        }
                                        return MemberChips(
                                          allowMultiple: true,
                                          allMembers: snapshot.data,
                                          membersChosen: snapshot.data
                                              .where((member) => memberChipBool[member])
                                              .toList(),
                                          membersChanged: (members) {
                                            setState(() {
                                              for (Member member in snapshot.data) {
                                                memberChipBool[member] = members.contains(member);
                                              }
                                            });
                                          },
                                          percentagesChanged: (Map<Member, double> percentages) {
                                            percentageMap = percentages;
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        for (Member member in memberChipBool.keys) {
                                          memberChipBool[member] = !memberChipBool[member];
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      Icons.swap_horiz,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        for (Member member in memberChipBool.keys) {
                                          memberChipBool[member] = false;
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
      String name = noteController.text;
      List<Member> members = [];
      memberChipBool.forEach((Member key, bool value) {
        if (value) members.add(key);
      });
      //TODO: add percentages to post (what to send exactly?)
      showDialog(
          builder: (context) => FutureSuccessDialog(
                future: _postPurchase(members, amount, name),
                dataTrue: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'purchase_scf'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientButton(
                          child: Row(
                            children: [
                              Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimary),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                'okay'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                              ),
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
                          child: Row(
                            children: [
                              Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                'add_new'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                              ),
                            ],
                          ),
                          onPressed: () {
                            setState(() {
                              _amountController.text = '';
                              noteController.text = '';
                              for (Member key in memberChipBool.keys) {
                                memberChipBool[key] = false;
                              }
                            });
                            Navigator.pop(context);
                          },
                          useShadow: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          barrierDismissible: false,
          context: context);
    }
  }
}
