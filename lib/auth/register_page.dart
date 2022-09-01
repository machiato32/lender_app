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
import 'package:url_launcher/url_launcher_string.dart';

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
          // flexibleSpace: Container(
          //   decoration: BoxDecoration(
          //       gradient: AppTheme.gradientFromTheme(Theme.of(context))),
          // ),
          title: Text(
            'register'.tr(),
          ),
        ),
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
                        hintText: 'username'.tr(),
                        filled: true,
                        prefixIcon: Icon(
                          Icons.account_circle,
                        ),
                        suffixIcon: Icon(
                          Icons.info_outline,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[a-z0-9]')),
                        LengthLimitingTextInputFormatter(15),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 9),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _usernameExplanationController.expanded =
                                  !_usernameExplanationController.expanded;
                            });
                          },
                          splashRadius: 0.1,
                          splashColor: Colors.transparent,
                          icon: Icon(
                            Icons.info_outline,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
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
                    hintText: 'password'.tr(),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.password,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  ],
                  obscureText: true,
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
                    hintText: 'confirm_password'.tr(),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.password,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  ],
                  obscureText: true,
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
                            launchUrlString(
                                'https://lenderapp.net/privacy-policy');
                          },
                          child: Text(
                            'accept_privacy_policy'.tr() + '*',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                .copyWith(
                                    decoration: TextDecoration.underline,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
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
                        color: Theme.of(context).colorScheme.onPrimary,
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
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.clear,
                                      color:
                                          Theme.of(context).colorScheme.onError,
                                    ),
                                    SizedBox(
                                      width: 12.0,
                                    ),
                                    Flexible(
                                        child: Text(
                                            "must_accept_privacy_policy".tr(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onError))),
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
                                color: Theme.of(context).colorScheme.error,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.clear,
                                    color:
                                        Theme.of(context).colorScheme.onError,
                                  ),
                                  SizedBox(
                                    width: 12.0,
                                  ),
                                  Flexible(
                                    child: Text("passwords_not_match".tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onError)),
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
