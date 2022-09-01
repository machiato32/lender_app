import 'dart:convert';
import 'dart:math';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/ad_management.dart';
import 'package:csocsort_szamla/essentials/app_theme.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';
import 'package:csocsort_szamla/essentials/group_objects.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/bottom_sheet_custom.dart';
import 'package:csocsort_szamla/essentials/widgets/calculator.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/essentials/widgets/member_chips.dart';
import 'package:csocsort_szamla/main/is_guest_banner.dart';
import 'package:csocsort_szamla/shopping/shopping_list.dart';
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

  Future<bool> _postPurchase(
      List<Member> members, double amount, String name) async {
    bool useGuest = guestNickname != null && guestGroupId == currentGroupId;
    try {
      Map<String, dynamic> body = {
        "name": name,
        "group": currentGroupId,
        "amount": amount,
        "receivers": members.map((e) => e.toJson()).toList()
      };

      await httpPost(
          uri: '/purchases', body: body, context: context, useGuest: useGuest);
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
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'purchase'.tr(),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          // flexibleSpace: Container(
          //   decoration: BoxDecoration(
          //       gradient: AppTheme.gradientFromTheme(Theme.of(context))),
          // ),
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
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'field_empty'.tr();
                                        }
                                        if (value.length < 3) {
                                          return 'minimal_length'
                                              .tr(args: ['3']);
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'note'.tr(),
                                        // fillColor: Theme.of(context)
                                        //     .colorScheme
                                        //     .onSurface,
                                        filled: true,
                                        prefixIcon: Icon(
                                          Icons.note,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(50)
                                      ],
                                      controller: noteController,
                                      // style: TextStyle(
                                      //     fontSize: 20,
                                      //     color: Theme.of(context)
                                      //         .textTheme
                                      //         .bodyText1
                                      //         .color),
                                      // cursorColor: Theme.of(context)
                                      //     .colorScheme
                                      //     .secondary,
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
                                            if (double.tryParse(value) ==
                                                null) {
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
                                            // fillColor: Theme.of(context)
                                            //     .colorScheme
                                            //     .onSurface,
                                            filled: true,
                                            prefixIcon: Icon(
                                              Icons.pin,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                            suffixIcon: Icon(
                                              Icons.calculate,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          controller: _amountController,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp('[0-9\\.]'))
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
                                                        initial:
                                                            _amountController
                                                                .text,
                                                        callback:
                                                            (String fromCalc) {
                                                          setState(() {
                                                            _amountController
                                                                    .text =
                                                                fromCalc;
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
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: FutureBuilder(
                                  future: _members,
                                  builder: (context,
                                      AsyncSnapshot<List<Member>> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasData) {
                                        for (Member member in snapshot.data) {
                                          memberChipBool.putIfAbsent(
                                              member, () => false);
                                        }
                                        if (widget.type ==
                                            PurchaseType.fromShopping) {
                                          memberChipBool[snapshot.data
                                              .firstWhere((member) =>
                                                  member.memberId ==
                                                  widget.shoppingData
                                                      .requesterId)] = true;
                                        }
                                        return MemberChips(
                                          allowMultiple: true,
                                          allMembers: snapshot.data,
                                          membersChosen: snapshot.data
                                              .where((member) =>
                                                  memberChipBool[member])
                                              .toList(),
                                          membersChanged: (members) {
                                            setState(() {
                                              for (Member member
                                                  in snapshot.data) {
                                                memberChipBool[member] =
                                                    members.contains(member);
                                              }
                                            });
                                          },
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Material(
                                      type: MaterialType.transparency,
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface),
                                          shape: BoxShape.circle,
                                        ),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(1000.0),
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            for (Member member
                                                in memberChipBool.keys) {
                                              memberChipBool[member] =
                                                  !memberChipBool[member];
                                            }
                                            setState(() {});
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Icon(Icons.swap_horiz,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                          ),
                                        ),
                                      )),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          _amountController.text != '' &&
                                                  memberChipBool.values
                                                          .where((element) =>
                                                              element == true)
                                                          .toList()
                                                          .length >
                                                      0
                                              ? ((double.tryParse(_amountController
                                                                  .text) ??
                                                              0) /
                                                          memberChipBool.values
                                                              .where(
                                                                  (element) =>
                                                                      element ==
                                                                      true)
                                                              .toList()
                                                              .length)
                                                      .toStringAsFixed(2) +
                                                  'per_person'.tr(args: [
                                                    currencies[
                                                            currentGroupCurrency]
                                                        ['symbol']
                                                  ])
                                              : '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Material(
                                      type: MaterialType.transparency,
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface),
                                          shape: BoxShape.circle,
                                        ),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(1000.0),
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            for (Member member
                                                in memberChipBool.keys) {
                                              memberChipBool[member] = false;
                                            }
                                            setState(() {});
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Icon(Icons.clear,
                                                color: Colors.red),
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: MediaQuery.of(context).viewInsets.bottom == 0,
                  child: adUnitForSite('purchase'),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child:
              Icon(Icons.send, color: Theme.of(context).colorScheme.onTertiary),
          onPressed: () {
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
              showDialog(
                  builder: (context) => FutureSuccessDialog(
                        future: _postPurchase(members, amount, name),
                        dataTrue: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'purchase_scf'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    .copyWith(color: Colors.white),
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
                                      Icon(Icons.check,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        'okay'.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
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
                                      Icon(Icons.add,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        'add_new'.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
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
          },
        ),
      ),
    );
  }
}
