import 'dart:convert';

import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../essentials/widgets/future_success_dialog.dart';
import '../../essentials/widgets/gradient_button.dart';
import '../../essentials/http_handler.dart';
import 'package:csocsort_szamla/config.dart';

import '../../main.dart';

class RenameGroupDialog extends StatefulWidget {
  @override
  _RenameGroupDialogState createState() => _RenameGroupDialogState();
}

class _RenameGroupDialogState extends State<RenameGroupDialog> {
  var _groupNameFormKey = GlobalKey<FormState>();
  var _groupNameController = TextEditingController();

  Future<bool> _updateGroupName(String groupName) async {
    try {
      Map<String, dynamic> body = {"name": groupName};

      http.Response response = await httpPut(
          uri: '/groups/' + currentGroupId.toString(),
          context: context,
          body: body);

      Map<String, dynamic> decoded = jsonDecode(response.body);
      saveGroupName(decoded['group_name']);
      Future.delayed(delayTime()).then((value) => _onUpdateGroupName());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onUpdateGroupName(){
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MainPage()),
            (r) => false);
    _groupNameController.text ='';
    clearGroupCache();
    deleteCache(uri:generateUri(GetUriKeys.groups));
  }

  @override
  Widget build(BuildContext context) {
    return
    Form(
      key: _groupNameFormKey,
      child: Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'rename_group'.tr(),
                style:
                    Theme.of(context).textTheme.headline6,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 8, right: 8),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'field_empty'.tr();
                    }
                    if (value.length < 1) {
                      return 'minimal_length'
                          .tr(args: ['1']);
                    }
                    return null;
                  },
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    labelText: 'new_name'.tr(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface,
                          width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                          width: 2),
                    ),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .color),
                  cursorColor: Theme.of(context)
                      .colorScheme
                      .secondary,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientButton(
                    onPressed: () {
                      if (_groupNameFormKey.currentState
                          .validate()) {
                        FocusScope.of(context).unfocus();
                        String groupName =
                            _groupNameController.text;
                        showDialog(
                            builder: (context) => FutureSuccessDialog(
                              future: _updateGroupName(groupName),
                              dataTrueText: 'nickname_scf',
                              onDataTrue: () {
                                _onUpdateGroupName();
                              },
                            ), barrierDismissible: false,
                            context: context);
                      }
                    },
                    child: Icon(
                      Icons.check,
                      color: Theme.of(context)
                          .colorScheme
                          .onSecondary,
                    ),
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
