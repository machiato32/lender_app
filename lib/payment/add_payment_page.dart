import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/group_objects.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';

class AddPaymentRoute extends StatefulWidget {
  @override
  _AddPaymentRouteState createState() => _AddPaymentRouteState();
}

class _AddPaymentRouteState extends State<AddPaymentRoute> {
  String dropdownValue;
  Member selectedMember;
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  Future<List<Member>> names;

  var _formKey = GlobalKey<FormState>();

  Future<List<Member>> _getNames() async {
    try {
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + apiToken
      };

      http.Response response = await http.get(
          APPURL + '/groups/' + currentGroupId.toString(),
          headers: header);

      if (response.statusCode == 200) {
        Map<String, dynamic> response2 = jsonDecode(response.body);
        List<Member> members = [];
        for (var member in response2['data']['members']) {
          members.add(Member(
              nickname: member['nickname'],
              balance: member['balance'] * 1.0,
              userId: member['user_id']));
        }
        return members;
      } else {
        Map<String, dynamic> error = jsonDecode(response.body);
        if (error['error'] == 'Unauthenticated.') {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
              (r) => false);
        }
        throw error['error'];
      }
    } catch (_) {
      throw 'Hiba';
    }
  }

  Future<bool> _postPayment(double amount, String note, Member toMember) async {
    try {
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + apiToken
      };

      Map<String, dynamic> map = {
        'group': currentGroupId,
        'amount': amount,
        'note': note,
        'taker_id': toMember.userId
      };
      String encoded = json.encode(map);

      http.Response response =
          await http.post(APPURL + '/payments', body: encoded, headers: header);
      return response.statusCode == 200;
    } catch (_) {
      throw _;
    }
  }

  @override
  void initState() {
    super.initState();
    names = _getNames();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
          appBar: AppBar(
            title: Text('payment'.tr()),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.send),
            onPressed: () {
              FocusScope.of(context).unfocus();
              if (_formKey.currentState.validate()) {
                if (dropdownValue == null) {
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
                double amount = double.parse(amountController.text);
                String note = noteController.text;
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    child: FutureSuccessDialog(
                      future: _postPayment(amount, note, selectedMember),
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
                          FlatButton.icon(
                            icon: Icon(Icons.check,
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            label: Text(
                              'okay'.tr(),
                              style: Theme.of(context).textTheme.button,
                            ),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          FlatButton.icon(
                            icon: Icon(Icons.add,
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                            onPressed: () {
                              amountController.text = '';
                              noteController.text = '';
                              dropdownValue = null;
                              Navigator.pop(context);
                            },
                            label: Text(
                              'add_new'.tr(),
                              style: Theme.of(context).textTheme.button,
                            ),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ],
                      ),
                    ));
              }
            },
          ),
          body: GestureDetector(
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
                        controller: amountController,
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
                        controller: noteController,
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
                          future: names,
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
                                            selected: dropdownValue ==
                                                member.nickname,
                                            onSelected: (bool newValue) {
                                              FocusScope.of(context).unfocus();
                                              setState(() {
                                                dropdownValue = member.nickname;
                                                selectedMember = member;
                                              });
                                            },
                                            labelStyle: dropdownValue ==
                                                    member.nickname
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
                                      setState(() {});
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
          )),
    );
  }
}