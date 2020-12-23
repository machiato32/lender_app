import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../future_success_dialog.dart';
import '../gradient_button.dart';
import '../http_handler.dart';
import 'package:csocsort_szamla/config.dart';

import '../main.dart';

class ChangeUsernameDialog extends StatefulWidget {
  @override
  _ChangeUsernameDialogState createState() => _ChangeUsernameDialogState();
}

class _ChangeUsernameDialogState extends State<ChangeUsernameDialog> {
  var _usernameFormKey = GlobalKey<FormState>();
  var _usernameController = TextEditingController();

  Future<bool> _updateUsername(String newUsername) async {
    try {
      Map<String, dynamic> body = {
        'new_username': newUsername
      };

      await httpPost(uri: '/change_username',
          context: context, body: body);
      SharedPreferences.getInstance().then((prefs){
        prefs.setString('current_username', newUsername);
      });
      currentUsername=newUsername;
      return true;

    } catch (_) {
      throw _;
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Form(
        key: _usernameFormKey,
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
                  'change_username'.tr(),
                  style:
                  Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
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
                    controller: _usernameController,
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
                        if (_usernameFormKey.currentState
                            .validate()) {
                          FocusScope.of(context).unfocus();
                          String username =
                              _usernameController.text;
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              child: FutureSuccessDialog(
                                future: _updateUsername(
                                    username),
                                dataTrueText: 'nickname_scf',
                                onDataTrue: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MainPage()),
                                          (r) => false);
                                  _usernameController.text =
                                  '';
                                  clearAllCache();
                                },
                              ));
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
