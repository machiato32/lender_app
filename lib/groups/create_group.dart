import 'package:csocsort_szamla/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:csocsort_szamla/main.dart';
import 'package:csocsort_szamla/http_handler.dart';
import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';

import '../app_theme.dart';
import 'package:csocsort_szamla/currencies.dart';

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  TextEditingController _groupName = TextEditingController();
  TextEditingController _nicknameController = TextEditingController(
      text: currentUsername[0].toUpperCase() +
          currentUsername.substring(1));

  var _formKey = GlobalKey<FormState>();
  String _defaultValue = "CML";

  Future<bool> _createGroup(String groupName, String nickname, String currency) async {
    try {
      Map<String, dynamic> body = {
        'group_name': groupName,
        'currency': currency,
        'member_nickname': nickname
      };
      http.Response response =
          await httpPost(uri: '/groups', body: body, context: context);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      currentGroupName = decoded['group_name'];
      currentGroupId = decoded['group_id'];
      currentGroupCurrency = decoded['currency'];

      SharedPreferences.getInstance().then((_prefs) {
        _prefs.setString('current_group_name', currentGroupName);
        _prefs.setInt('current_group_id', currentGroupId);
        _prefs.setString('current_group_currency', currentGroupCurrency);
      });
      return response.statusCode == 201;
    } catch (_) {
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: AppTheme.gradientFromTheme(Theme.of(context))
            ),
          ),
          title: Text(
            'create'.tr(),
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, letterSpacing: 0.25, fontSize: 24),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            padding: const EdgeInsets.all(15),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'group_name'.tr(),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'field_empty'.tr();
                        }
                        if (value.length < 1) {
                          return 'minimal_length'.tr(args: ['1']);
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                        ),
                      ),
                      controller: _groupName,
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyText1.color),
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'nickname_in_group'.tr(),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'field_empty'.tr();
                        }
                        if (value.length < 1) {
                          return 'minimal_length'.tr(args: ['1']);
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'example_nickname'.tr(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                        ),
                      ),
                      controller: _nicknameController,
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyText1.color),
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'currency_of_group'.tr(),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton(
                        isExpanded: true,
                        onChanged: (value){
                          setState(() {
                            _defaultValue=value;
                          });
                        },
                        value: _defaultValue,
                        style: Theme.of(context).textTheme.bodyText1,
                        items: enumerateCurrencies().map((currency) => DropdownMenuItem(
                          child: Text(currency.split(';')[0].trim()+" ("+currency.split(';')[1].trim()+")",),
                          value: currency.split(';')[0].trim(),
                          onTap: (){

                          },
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientButton(
                    child: Text('create_group'.tr(),
                        style: Theme.of(context).textTheme.button),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        String token = _groupName.text;
                        String nickname = _nicknameController.text;
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            child: FutureSuccessDialog(
                              future: _createGroup(token, nickname, _defaultValue),
                              onDataTrue: () async {
                                await clearCache();
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainPage()),
                                    (r) => false);
                              },
                              dataTrueText: 'creation_scf',
                            ));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future clearCache() async {
    await deleteCache(uri: '/groups/' + currentGroupId.toString());
    await deleteCache(uri: '/groups');
    await deleteCache(uri: '/user');
    await deleteCache(uri: '/payments?group=' + currentGroupId.toString());
    await deleteCache(uri: '/transactions?group=' + currentGroupId.toString());
  }
}
