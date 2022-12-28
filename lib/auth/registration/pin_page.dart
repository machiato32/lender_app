import 'dart:math';

import 'package:csocsort_szamla/auth/registration/currency_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../essentials/widgets/gradient_button.dart';

class PinPage extends StatefulWidget {
  final String inviteUrl;
  final String username;
  PinPage({this.inviteUrl, this.username});
  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  bool _isPinInput = true;
  String _pin = '';
  String _pinConfirm = '';
  String _validationText = null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('register'.tr()),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: ListView(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      shrinkWrap: true,
                      children: <Widget>[
                        Center(
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            height: 56,
                            child: Stack(
                              children: [
                                Center(
                                  child: Builder(builder: (context) {
                                    String textToShow = _pin;
                                    if (textToShow == '') {
                                      textToShow = 'pin'.tr();
                                    } else {
                                      textToShow = '•' * textToShow.length;
                                    }
                                    if (!_isPinInput) {
                                      textToShow = _pinConfirm;
                                      if (_pinConfirm == '') {
                                        textToShow = 'confirm_pin'.tr();
                                      } else {
                                        textToShow = '•' * textToShow.length;
                                      }
                                    }

                                    return Text(
                                      textToShow,
                                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    );
                                  }),
                                ),
                                AnimatedCrossFade(
                                  duration: Duration(milliseconds: 100),
                                  crossFadeState: (_isPinInput && _pin != '') ||
                                          (!_isPinInput && _pinConfirm != '')
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  firstChild: Container(),
                                  secondChild: Padding(
                                    padding: const EdgeInsets.only(left: 16, top: 8),
                                    child: Text(
                                      _isPinInput ? 'pin'.tr() : 'confirm_pin'.tr(),
                                      style: Theme.of(context).textTheme.bodySmall.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _validationText != null,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Text(
                              (_validationText ?? '').tr(),
                              style: Theme.of(context).textTheme.bodySmall.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: min(300, MediaQuery.of(context).size.height / 7 * 3),
                            ),
                            child: Table(
                              columnWidths: {
                                0: FractionColumnWidth(1 / 3),
                                1: FractionColumnWidth(1 / 3),
                                2: FractionColumnWidth(1 / 3),
                              },
                              children: [
                                TableRow(
                                  children: ['1', '2', '3'].map((number) {
                                    return numberButton(number);
                                  }).toList(),
                                ),
                                TableRow(
                                  children: ['4', '5', '6'].map((number) {
                                    return numberButton(number);
                                  }).toList(),
                                ),
                                TableRow(
                                  children: ['7', '8', '9'].map((number) {
                                    return numberButton(number);
                                  }).toList(),
                                ),
                                TableRow(
                                  children: ['', '0', 'C'].map((number) {
                                    return numberButton(number);
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GradientButton(
                        child: Icon(
                          Icons.arrow_left,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          if (_isPinInput) {
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              _isPinInput = true;
                            });
                          }
                        },
                      ),
                      GradientButton(
                        child: Icon(
                          Icons.arrow_right,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          if (_isPinInput) {
                            if (_pin.length == 4) {
                              setState(() {
                                _isPinInput = false;
                              });
                            } else {
                              setState(() {
                                _validationText = '4_needed';
                              });
                            }
                          } else {
                            if (_pinConfirm.length == 4) {
                              if (_pin == _pinConfirm) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CurrencyPage(
                                      inviteUrl: widget.inviteUrl,
                                      username: widget.username,
                                      pin: _pin,
                                    ),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _validationText = 'pins_not_match';
                                });
                              }
                            } else {
                              setState(() {
                                _validationText = '4_needed';
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget numberButton(String number) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: number == '' ||
                  (_isPinInput && number == 'C' && _pin == '') ||
                  (!_isPinInput && number == 'C' && _pinConfirm == '')
              ? null
              : () {
                  if (number != '' && number != 'C') {
                    setState(() {
                      if (_isPinInput) {
                        if (_pin.length == 3) {
                          _validationText = null;
                          _pin += number;
                        } else if (_pin.length < 4) {
                          _pin += number;
                        }
                      } else {
                        if (_pinConfirm.length == 3) {
                          _validationText = null;
                          _pinConfirm += number;
                        } else if (_pinConfirm.length < 4) {
                          _pinConfirm += number;
                        }
                      }
                    });
                  } else if (number == 'C') {
                    setState(() {
                      if (_isPinInput) {
                        _pin = '';
                      } else {
                        _pinConfirm = '';
                      }
                    });
                  }
                },
          child: Center(
            child: Builder(builder: (context) {
              if (number == 'C') {
                if ((_isPinInput && _pin != '') || (!_isPinInput && _pinConfirm != '')) {
                  return Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).colorScheme.tertiary,
                  );
                }
                return Container();
              }
              if (number == '') {
                return Container();
              }
              return Text(
                number,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              );
            }),
          ),
        ),
      ),
    );
  }
}
