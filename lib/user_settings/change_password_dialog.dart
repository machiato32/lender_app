import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../essentials/http_handler.dart';
import '../essentials/widgets/future_success_dialog.dart';
import '../essentials/widgets/gradient_button.dart';
import '../groups/main_group_page.dart';

class ChangePasswordDialog extends StatefulWidget {
  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _passwordReminderController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  int _index = 0;
  List<TextFormField> textFields = List<TextFormField>();

  Future<bool> _updatePassword(
      String oldPassword, String newPassword, String reminder) async {
    try {
      Map<String, dynamic> body = {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
        "password_reminder": reminder,
      };

      await httpPut(uri: '/user', context: context, body: body);
      Future.delayed(delayTime()).then((value) => _onUpdatePassword());
      return true;
    } catch (_) {
      throw _;
    }
  }

  void _onUpdatePassword() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainGroupPage()),
        (route) => false);
  }

  void initTextFields() {
    textFields = [
      TextFormField(
        validator: (value) {
          if (value.isEmpty) {
            return 'field_empty'.tr();
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'old_password'.tr(),
          fillColor: Theme.of(context).colorScheme.onSurface,
          filled: true,
          prefixIcon: Icon(
            Icons.password,
            color: Theme.of(context).textTheme.bodyText1.color,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
        ],
        controller: _oldPasswordController,
        obscureText: true,
        style: TextStyle(
            fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
        cursorColor: Theme.of(context).colorScheme.secondary,
      ),
      TextFormField(
        validator: (value) {
          if (value.isEmpty) {
            return 'field_empty'.tr();
          }
          if (value.length < 4) {
            return 'minimal_length'.tr(args: ['4']);
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'new_password'.tr(),
          fillColor: Theme.of(context).colorScheme.onSurface,
          filled: true,
          prefixIcon: Icon(
            Icons.password,
            color: Theme.of(context).textTheme.bodyText1.color,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
        ],
        controller: _newPasswordController,
        obscureText: true,
        style: TextStyle(
            fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
        cursorColor: Theme.of(context).colorScheme.secondary,
      ),
      TextFormField(
        validator: (value) {
          if (value != _newPasswordController.text) {
            return 'passwords_not_match'.tr();
          }
          if (value.isEmpty) {
            return 'field_empty'.tr();
          }
          if (value.length < 4) {
            return 'minimal_length'.tr(args: ['4']);
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'new_password_confirm'.tr(),
          fillColor: Theme.of(context).colorScheme.onSurface,
          filled: true,
          prefixIcon: Icon(
            Icons.password,
            color: Theme.of(context).textTheme.bodyText1.color,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
        ],
        controller: _confirmPasswordController,
        obscureText: true,
        style: TextStyle(
            fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
        cursorColor: Theme.of(context).colorScheme.secondary,
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
        controller: _passwordReminderController,
        decoration: InputDecoration(
          hintText: 'password_reminder'.tr(),
          fillColor: Theme.of(context).colorScheme.onSurface,
          filled: true,
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).textTheme.bodyText1.color,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(50),
        ],
        style: TextStyle(
            fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
        cursorColor: Theme.of(context).colorScheme.secondary,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    initTextFields();
    return Form(
      key: _formKey,
      child: Dialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'change_password'.tr(),
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: textFields[_index],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: _index != 0,
                    child: GradientButton(
                      onPressed: () {
                        setState(() {
                          _index--;
                        });
                      },
                      child: Icon(
                        Icons.arrow_left,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  GradientButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        FocusScope.of(context).unfocus();
                        if (_index < 3) {
                          setState(() {
                            _index++;
                          });
                        } else {
                          showDialog(
                              builder: (context) => FutureSuccessDialog(
                                    future: _updatePassword(
                                        _oldPasswordController.text,
                                        _newPasswordController.text,
                                        _passwordReminderController.text),
                                    dataTrueText: 'change_password_scf',
                                    onDataTrue: () {
                                      _onUpdatePassword();
                                    },
                                  ),
                              barrierDismissible: false,
                              context: context);
                        }
                      }
                    },
                    child: Icon(
                      _index == 3 ? Icons.check : Icons.arrow_right,
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
