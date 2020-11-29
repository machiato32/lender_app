import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/group_objects.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';
import 'package:csocsort_szamla/http_handler.dart';

import '../app_theme.dart';
import '../gradient_button.dart';

class SavedPayment{
  String note;
  int payerId, takerId;
  int amount;
  int paymentId;
  SavedPayment({this.note, this.payerId, this.takerId, this.amount, this.paymentId});
}

class AddPaymentRoute extends StatefulWidget {
  final SavedPayment payment;
  AddPaymentRoute({this.payment});
  @override
  _AddPaymentRouteState createState() => _AddPaymentRouteState();
}

class _AddPaymentRouteState extends State<AddPaymentRoute> {
  Member _dropdownValue;
  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  Future<List<Member>> _members;

  var _formKey = GlobalKey<FormState>();

  Future<List<Member>> _getMembers({bool overwriteCache=false}) async {
    try {
      http.Response response = await httpGet(
          uri: '/groups/' + currentGroupId.toString(),
          context: context, overwriteCache: overwriteCache);

      Map<String, dynamic> decoded = jsonDecode(response.body);
      List<Member> members = [];
      for (var member in decoded['data']['members']) {
        if(member['user_id']!=currentUserId){
          members.add(Member(
              nickname: member['nickname'],
              balance: (member['balance'] * 1.0).round(),
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
      Map<String, dynamic> body = {
        'group': currentGroupId,
        'amount': amount,
        'note': note,
        'taker_id': toMember.memberId
      };

      await httpPost(uri: '/payments', body: body, context: context);
      return true;
    } catch (_) {
      throw _;
    }
  }

  Future<bool> _updatePayment(double amount, String note, Member toMember, int paymentId) async {
    try {
      print(toMember.memberId);

      Map<String, dynamic> body = {
        'amount': amount,
        'note': note,
        'taker_id': toMember.memberId
      };

      await httpPut(uri: '/payments/'+paymentId.toString(), body: body, context: context);
      return true;
    } catch (_) {
      throw _;
    }
  }

  
  
  @override
  void initState() {
    super.initState();
    if(widget.payment!=null){
      _amountController.text=widget.payment.amount.toString();
      _noteController.text=widget.payment.note;
    }
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

          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.send),
            onPressed: () {
              FocusScope.of(context).unfocus();
              if (_formKey.currentState.validate()) {
                if (_dropdownValue == null) {
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
                            child: Text(
                          "person_not_chosen".tr(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
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
                double amount = double.parse(_amountController.text);
                String note = _noteController.text;
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    child: FutureSuccessDialog(
                      future: widget.payment!=null?_updatePayment(amount, note, _dropdownValue, widget.payment.paymentId):_postPayment(amount, note, _dropdownValue),
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
                                  _dropdownValue = null;
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
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
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
                        SizedBox(
                          height: 20,
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
                          inputFormatters: [LengthLimitingTextInputFormatter(25)],
                          controller: _noteController,
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).textTheme.bodyText1.color),
                          cursorColor: Theme.of(context).colorScheme.secondary,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(),
                        Center(
                          child: FutureBuilder(
                            future: _members,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData) {
                                  if(widget.payment!=null && widget.payment.takerId!=-1){
                                    Member selectMember = (snapshot.data as List<Member>).firstWhere((element) => element.memberId==widget.payment.takerId, orElse: null);
                                    if(selectMember!=null)
                                      _dropdownValue=selectMember;
                                    widget.payment.takerId=-1;
                                  }
                                  return Wrap(
                                    spacing: 10,
                                    children: snapshot.data
                                        .map<ChoiceChip>((Member member) =>
                                            ChoiceChip(
                                              label: Text(member.nickname),
                                              pressElevation: 30,
                                              selected: _dropdownValue ==
                                                  member,
                                              onSelected: (bool newValue) {
                                                FocusScope.of(context).unfocus();
                                                setState(() {
                                                  _dropdownValue = member;
                                                  // _selectedMember = member;
                                                });
                                              },
                                              labelStyle: _dropdownValue ==
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
                                  return InkWell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: Text(snapshot.error.toString()),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _members=null;
                                          _members=_getMembers();
                                        });
                                      });
                                }
                              }

                              return Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
//              Balances()
                ],
              ),
            ),
          )),
    );
  }
}
