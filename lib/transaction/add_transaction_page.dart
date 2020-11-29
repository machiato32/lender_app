import 'package:csocsort_szamla/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/group_objects.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/shopping/shopping_list.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';
import 'package:csocsort_szamla/http_handler.dart';
import 'package:csocsort_szamla/app_theme.dart';

Random random = Random();

class SavedTransaction {
  String buyerNickname, buyerUsername;
  int buyerId;
  String name;  
  List<Member> receivers;
  int totalAmount;
  int transactionId;

  SavedTransaction({this.buyerId, this.buyerUsername, this.buyerNickname,
    this.receivers, this.totalAmount, this.name, this.transactionId});
}

enum TransactionType { fromShopping, fromModifyExpense, newExpense }

class AddTransactionRoute extends StatefulWidget {
  final TransactionType type;
  final SavedTransaction expense;
  final ShoppingRequestData shoppingData;

  AddTransactionRoute({@required this.type, this.expense, this.shoppingData});

  @override
  _AddTransactionRouteState createState() => _AddTransactionRouteState();
}

class _AddTransactionRouteState extends State<AddTransactionRoute> {
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  Future<List<Member>> _members;
  Future<bool> success;
  Map<Member, bool> checkboxBool = Map<Member, bool>();
  FocusNode _focusNode = FocusNode();

  var _formKey = GlobalKey<FormState>();

  Future<List<Member>> _getMembers({bool overwriteCache=false}) async {
    try {
      http.Response response = await httpGet(
          uri: '/groups/' + currentGroupId.toString(),
          context: context, overwriteCache: overwriteCache);

      Map<String, dynamic> decoded = jsonDecode(response.body);
      List<Member> members = [];
      for (var member in decoded['data']['members']) {
        members.add(Member(
          nickname: member['nickname'],
          balance: (member['balance'] * 1.0).round(),
          username: member['username'],
          memberId: member['user_id']
        ));
      }
      return members;

    } catch (_) {
      throw _;
    }
  }

  Future<bool> _postTransaction(
      List<Member> members, double amount, String name) async {
    try {
      Map<String, dynamic> body = {
        "name": name,
        "group": currentGroupId,
        "amount": amount,
        "receivers": members.map((e) => e.toJson()).toList()
      };

      await httpPost(uri: '/transactions',
          body: body, context: context);
      return true;

    } catch (_) {
      throw _;
    }
  }

  Future<bool> _updateTransaction(
      List<Member> members, double amount, String name, int transactionId) async {
    try {
      Map<String, dynamic> body = {
        "name": name,
        "amount": amount,
        "receivers": members.map((e) => e.toJson()).toList()
      };

      await httpPut(uri: '/transactions/'+transactionId.toString(),
          body: body, context: context);
      return true;

    } catch (_) {
      throw _;
    }
  }

  void setInitialValues() {
    if (widget.type == TransactionType.fromModifyExpense) {
      noteController.text = widget.expense.name;
      amountController.text = widget.expense.totalAmount.toString();
    } else {
      noteController.text = widget.shoppingData.name;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.type == TransactionType.fromModifyExpense ||
        widget.type == TransactionType.fromShopping) {
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
          title: Text('expense'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: AppTheme.gradientFromTheme(Theme.of(context))
            ),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: RefreshIndicator(
            onRefresh: () async {
              _members=null;
              _members=_getMembers(overwriteCache: true);
            },
            child: ListView(
              children: <Widget>[
                Padding(
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
                                labelText: 'full_amount'.tr(),
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
                              controller: amountController,
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
                                LengthLimitingTextInputFormatter(30)
                              ],
                              controller: noteController,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color),
                              cursorColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(),
                      Center(
                        child: FutureBuilder(
                          future: _members,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData) {
                                List<Member> snapshotMembers = snapshot.data;
                                for (Member member in snapshot.data) {
                                  checkboxBool.putIfAbsent(member, () => false);
                                }
                               if(widget.type==TransactionType.fromModifyExpense && widget.expense.receivers!=null){
                                 for(Member member in widget.expense.receivers){
                                   Member memberInCheckbox = snapshotMembers.firstWhere((element) => element.memberId==member.memberId, orElse: null);
                                   if(memberInCheckbox!=null)
                                     checkboxBool[memberInCheckbox]=true;
                                 }
                                 widget.expense.receivers=null;
                               }else if (widget.type == TransactionType.fromShopping) {
                                  checkboxBool[(snapshot.data as List<Member>)
                                          .firstWhere((member) =>
                                              member.memberId ==
                                              widget.shoppingData.requesterId)] =
                                      true;
                                }
                                return Wrap(
                                  spacing: 10,
                                  children: snapshot.data
                                      .map<ChoiceChip>((Member member) =>
                                          ChoiceChip(
                                            label: Text(member.nickname),
                                            pressElevation: 30,
                                            selected: checkboxBool[member],
                                            onSelected: (bool newValue) {
                                              FocusScope.of(context).unfocus();
                                              setState(() {
                                                checkboxBool[member] = newValue;
                                              });
                                            },
                                            labelStyle: checkboxBool[member]
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
                                return InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Text(snapshot.error.toString()),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _members = null;
                                        _members = _getMembers();
                                      });
                                    });
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
                                  borderRadius: BorderRadius.circular(1000.0),
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    for (Member member in checkboxBool.keys) {
                                      checkboxBool[member] =
                                          !checkboxBool[member];
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
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  amountController.text != '' &&
                                          checkboxBool.values
                                                  .where((element) =>
                                                      element == true)
                                                  .toList()
                                                  .length >
                                              0
                                      ? ((double.tryParse(amountController
                                                          .text) ??
                                                      0) /
                                                  checkboxBool.values
                                                      .where((element) =>
                                                          element == true)
                                                      .toList()
                                                      .length)
                                              .toStringAsFixed(2) +
                                          'per_person'.tr()
                                      : '',
                                  style: Theme.of(context).textTheme.bodyText2,
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
                                  borderRadius: BorderRadius.circular(1000.0),
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    for (Member member in checkboxBool.keys) {
                                      checkboxBool[member] = false;
                                    }
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Icon(Icons.clear, color: Colors.red),
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
//            Balances()
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.send),
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (_formKey.currentState.validate()) {
              if (!checkboxBool.containsValue(true)) {
                Widget toast = Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.red,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      Flexible(
                          child: Text("person_not_chosen".tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(color: Colors.white))),
                    ],
                  ),
                );
                FlutterToast ft = FlutterToast(context);
                ft.showToast(
                    child: toast,
                    toastDuration: Duration(seconds: 2),
                    gravity: ToastGravity.BOTTOM);
                return;
              }
              double amount = double.parse(amountController.text);
              String name = noteController.text;
              List<Member> members = new List<Member>();
              checkboxBool.forEach((Member key, bool value) {
                if (value) members.add(key);
              });
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  child: FutureSuccessDialog(
                    future: widget.type==TransactionType.fromModifyExpense?_updateTransaction(members, amount, name, widget.expense.transactionId):_postTransaction(members, amount, name),
                    dataTrue: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Text(
                          "transaction_scf".tr(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
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
                                setState(() {
                                  amountController.text = '';
                                  noteController.text = '';
                                  for (Member key in checkboxBool.keys) {
                                    checkboxBool[key] = false;
                                  }
                                });
                                Navigator.pop(context);
                              },
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
