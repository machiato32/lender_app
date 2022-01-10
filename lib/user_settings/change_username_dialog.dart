import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../essentials/http_handler.dart';
import '../essentials/widgets/future_success_dialog.dart';
import '../essentials/widgets/gradient_button.dart';
import '../groups/main_group_page.dart';

class ChangeUsernameDialog extends StatefulWidget {
  @override
  _ChangeUsernameDialogState createState() => _ChangeUsernameDialogState();
}

class _ChangeUsernameDialogState extends State<ChangeUsernameDialog> {
  var _usernameFormKey = GlobalKey<FormState>();
  var _usernameController = TextEditingController();

  Future<bool> _updateUsername(String newUsername) async {
    try {
      Map<String, dynamic> body = {'username': newUsername};

      await httpPut(uri: '/user', context: context, body: body);
      saveUsername(newUsername);
      Future.delayed(delayTime()).then((value) => _onUpdateUsername());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onUpdateUsername() {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => MainGroupPage()), (r) => false);
    _usernameController.text = '';
    // clearAllCache();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _usernameFormKey,
      child: Dialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'change_username'.tr(),
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
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
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'new_name'.tr(),
                    fillColor: Theme.of(context).colorScheme.onSurface,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.account_circle,
                      color: Theme.of(context).textTheme.bodyText1.color,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyText1.color),
                  cursorColor: Theme.of(context).colorScheme.secondary,
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
                      if (_usernameFormKey.currentState.validate()) {
                        FocusScope.of(context).unfocus();
                        String username = _usernameController.text;
                        showDialog(
                            builder: (context) => FutureSuccessDialog(
                                  future: _updateUsername(username),
                                  dataTrueText: 'nickname_scf',
                                  onDataTrue: () {
                                    _onUpdateUsername();
                                  },
                                ),
                            barrierDismissible: false,
                            context: context);
                      }
                    },
                    child: Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.onSecondary,
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
