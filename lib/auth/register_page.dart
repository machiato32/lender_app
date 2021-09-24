import 'dart:io';

import 'package:csocsort_szamla/auth/register_page_2.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../essentials/app_theme.dart';

class RegisterPage extends StatefulWidget {
  final String inviteURL;
  RegisterPage({this.inviteURL});
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ExpandableController _usernameExplanationController = ExpandableController();

  bool _privacyPolicy = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: AppTheme.gradientFromTheme(Theme.of(context))),
            ),
            title: Text('register'.tr(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    letterSpacing: 0.25,
                    fontSize: 24))),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Center(
            child: ListView(
              padding: EdgeInsets.only(left: 20, right: 20),
              shrinkWrap: true,
              children: <Widget>[
                Stack(
                  children: [
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
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'example_name'.tr(),
                        labelText: 'username'.tr(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[a-z0-9]')),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyText1.color),
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _usernameExplanationController.expanded =
                                      !_usernameExplanationController.expanded;
                                });
                              },
                              icon: Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.secondary,
                              ))),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expandable(
                  controller: _usernameExplanationController,
                  collapsed: Container(),
                  expanded: Container(
                      constraints: BoxConstraints(maxHeight: 80),
                      child: Row(
                        children: [
                          Flexible(
                              child: Text(
                            'username_explanation'.tr(),
                            style: Theme.of(context).textTheme.subtitle2,
                          )),
                        ],
                      )),
                ),
                SizedBox(
                  height: 10,
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
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'password'.tr(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 2),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  ],
                  obscureText: true,
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyText1.color),
                  cursorColor: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  validator: (value) {
                    if (value != _passwordController.text) {
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
                  controller: _passwordConfirmController,
                  decoration: InputDecoration(
                    labelText: 'confirm_password'.tr(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 2),
                      //  when the TextFormField in unfocused
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  ],
                  obscureText: true,
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyText1.color),
                  cursorColor: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: InkWell(
                          onTap: () {
                            launch('https://lenderapp.net/privacy-policy');
                          },
                          child: Text(
                            'accept_privacy_policy'.tr() + '*',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2
                                .copyWith(decoration: TextDecoration.underline),
                            textAlign: TextAlign.center,
                          )),
                    ),
                    Checkbox(
                      value: _privacyPolicy,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (value) {
                        setState(() {
                          _privacyPolicy = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GradientButton(
                      child: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      onPressed: () {
                        //TODO: check if username is already used
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState.validate()) {
                          String username = _usernameController.text;
                          if (_passwordController.text ==
                              _passwordConfirmController.text) {
                            if (_privacyPolicy) {
                              String password = _passwordConfirmController.text;
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return FutureSuccessDialog(
                                    future: _register(username, password),
                                    dataTrueText: 'registration_scf',
                                  );
                                },
                              );
                            } else {
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
                                            "must_accept_privacy_policy".tr(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                    color: Colors.white))),
                                  ],
                                ),
                              );
                              // FlutterToast ft = FlutterToast(context);
                              FToast ft = FToast();
                              ft.init(context);
                              ft.showToast(
                                  child: toast,
                                  toastDuration: Duration(seconds: 2),
                                  gravity: ToastGravity.BOTTOM);
                            }
                          } else {
                            Widget toast = Container(
                              padding: EdgeInsets.symmetric(
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
                                    child: Text("passwords_not_match".tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                            FToast ft = FToast();
                            ft.init(context);
                            ft.showToast(
                                child: toast,
                                toastDuration: Duration(seconds: 2),
                                gravity: ToastGravity.BOTTOM);
                          }
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onRegister(String username, String password) {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegisterAlmostDonePage(
                  inviteURL: widget.inviteURL,
                  username: username,
                  password: password,
                )));
  }

  Future<bool> _register(String username, String password) async {
    try {
      await Future.delayed(Duration(seconds: 1));
      Future.delayed(delayTime())
          .then((value) => _onRegister(username, password));
      return true;
    } on FormatException {
      throw 'format_exception'.tr() + ' F01';
    } on SocketException {
      throw 'cannot_connect'.tr() + ' F02';
    } catch (_) {
      throw _;
    }
  }
}
