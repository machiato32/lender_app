import 'dart:convert';
import 'dart:io';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';
import 'package:csocsort_szamla/essentials/http_handler.dart';
import 'package:csocsort_szamla/essentials/save_preferences.dart';
import 'package:csocsort_szamla/essentials/widgets/future_success_dialog.dart';
import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/essentials/widgets/currency_picker_dropdown.dart';
import 'package:csocsort_szamla/groups/join_group.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../essentials/app_theme.dart';

class RegisterAlmostDonePage extends StatefulWidget {
  final String inviteURL;
  final String username;
  final String password;
  RegisterAlmostDonePage({this.inviteURL, this.username, this.password});
  @override
  _RegisterAlmostDonePageState createState() => _RegisterAlmostDonePageState();
}

class _RegisterAlmostDonePageState extends State<RegisterAlmostDonePage> {
  TextEditingController _passwordReminderController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _defaultCurrencyValue = "EUR";

  ExpandableController _reminderExplanationController = ExpandableController();

  bool _personalisedAds = false;

  void _changeCurrencyValue(String currency) {
    setState(() {
      _defaultCurrencyValue = currency;
    });
  }

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
          title: Text('register'.tr()),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: ListView(
            padding: EdgeInsets.all(20),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Center(
                child: Text(
                  'just_few_things_left'.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 20,
              ),
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
                    controller: _passwordReminderController,
                    decoration: InputDecoration(
                      labelText: 'password_reminder'.tr(),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.search,
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
                      // FilteringTextInputFormatter.allow(RegExp('[a-z0-9]')),
                      LengthLimitingTextInputFormatter(50),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 9),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _reminderExplanationController.expanded =
                                !_reminderExplanationController.expanded;
                          });
                        },
                        splashRadius: 0.1,
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
                controller: _reminderExplanationController,
                collapsed: Container(),
                expanded: Container(
                    constraints: BoxConstraints(maxHeight: 80),
                    child: Row(
                      children: [
                        Flexible(
                            child: Text(
                          'reminder_explanation'.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                        )),
                      ],
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'your_currency'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: CurrencyPickerDropdown(
                      currencyChanged: _changeCurrencyValue,
                      defaultCurrencyValue: _defaultCurrencyValue,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: InkWell(
                        onTap: () {
                          launchUrlString(
                              'https://policies.google.com/privacy');
                        },
                        child: Text(
                          'personalised_ads'.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              .copyWith(
                                  decoration: TextDecoration.underline,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  Checkbox(
                    value: _personalisedAds,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (value) {
                      setState(() {
                        _personalisedAds = value;
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
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState.validate()) {
                        String passwordReminder =
                            _passwordReminderController.text;
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return FutureSuccessDialog(
                              future: _register(
                                  widget.username,
                                  widget.password,
                                  passwordReminder,
                                  _defaultCurrencyValue),
                              dataTrueText: 'registration_scf',
                            );
                          },
                        );
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onRegister() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => JoinGroup(
                  fromAuth: true,
                  inviteURL: widget.inviteURL,
                )),
        (r) => false);
  }

  Future<bool> _register(String username, String password, String reminder,
      String currency) async {
    try {
      dynamic token;
      if (!kIsWeb && Platform.isAndroid) {
        FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
        token = await _firebaseMessaging.getToken();
      }
      Map<String, dynamic> body = {
        "username": username,
        "default_currency": currency,
        "password": password,
        "password_confirmation": password,
        "password_reminder": reminder,
        "fcm_token": token,
        "language": context.locale.languageCode,
        "personalised_ads": _personalisedAds ? 1 : 0
      };
      Map<String, String> header = {
        "Content-Type": "application/json",
      };

      String bodyEncoded = jsonEncode(body);
      http.Response response = await http.post(
          Uri.parse((useTest ? TEST_URL : APP_URL) + '/register'),
          headers: header,
          body: bodyEncoded);
      if (response.statusCode == 201) {
        Map<String, dynamic> decoded = jsonDecode(response.body);
        showAds = false;
        useGradients = true;
        trialVersion = true;
        saveApiToken(decoded['api_token']);
        saveUsername(decoded['username']);
        saveUserId(decoded['id']);
        await clearAllCache();
        Future.delayed(delayTime()).then((value) => _onRegister());
        return true;
      } else {
        Map<String, dynamic> error = jsonDecode(response.body);
        throw error['error'];
      }
    } on FormatException {
      throw 'format_exception'.tr() + ' F01';
    } on SocketException {
      throw 'cannot_connect'.tr() + ' F02';
    } catch (_) {
      throw _;
    }
  }
}
