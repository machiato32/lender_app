import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PinPad extends StatefulWidget {
  final String pin, pinConfirm;
  final bool isPinInput;
  final ValueChanged<String> onPinChanged;
  final ValueChanged<String> onPinConfirmChanged;
  final ValueChanged<bool> onIsPinInputChanged;
  final bool useConfirm;
  final String validationText;
  final ValueChanged<String> onValidationTextChanged;
  final double maxWidth;
  PinPad({
    this.pin,
    this.pinConfirm,
    this.isPinInput = true,
    this.onIsPinInputChanged,
    this.onPinChanged,
    this.onPinConfirmChanged,
    this.validationText,
    this.onValidationTextChanged,
    this.useConfirm = true,
    this.maxWidth,
  }) {
    assert(pin != null);
    assert(onPinChanged != null);
    assert(onValidationTextChanged != null);
    if (useConfirm) {
      assert(pinConfirm != null);
      assert(onPinConfirmChanged != null);
      assert(onIsPinInputChanged != null);
    }
  }
  @override
  State<PinPad> createState() => _PinPadState(); //TODO: savePinOrPassword
}

class _PinPadState extends State<PinPad> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                    String textToShow = widget.pin;
                    if (textToShow == '') {
                      textToShow = 'pin'.tr();
                    } else {
                      textToShow = '•' * textToShow.length;
                    }
                    if (!widget.isPinInput) {
                      textToShow = widget.pinConfirm;
                      if (widget.pinConfirm == '') {
                        textToShow = 'confirm_pin'.tr();
                      } else {
                        textToShow = '•' * textToShow.length;
                      }
                    }

                    return Text(
                      textToShow,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    );
                  }),
                ),
                AnimatedCrossFade(
                  duration: Duration(milliseconds: 100),
                  crossFadeState: (widget.isPinInput && widget.pin != '') ||
                          (!widget.isPinInput && widget.pinConfirm != '')
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Container(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      widget.isPinInput ? 'pin'.tr() : 'confirm_pin'.tr(),
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
          visible: widget.validationText != null,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              (widget.validationText ?? '').tr(),
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
              maxWidth: widget.maxWidth ?? min(300, MediaQuery.of(context).size.height / 7 * 3),
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
                  (widget.isPinInput && number == 'C' && widget.pin == '') ||
                  (!widget.isPinInput && number == 'C' && widget.pinConfirm == '')
              ? null
              : () {
                  if (number != '' && number != 'C') {
                    setState(() {
                      if (widget.isPinInput) {
                        if (widget.pin.length == 3) {
                          widget.onPinChanged(widget.pin + number);
                          widget.onValidationTextChanged(null);
                        } else if (widget.pin.length < 4) {
                          widget.onPinChanged(widget.pin + number);
                        }
                      } else {
                        if (widget.pinConfirm.length == 3) {
                          widget.onPinConfirmChanged(widget.pinConfirm + number);
                          widget.onValidationTextChanged(null);
                        } else if (widget.pinConfirm.length < 4) {
                          widget.onPinConfirmChanged(widget.pinConfirm + number);
                        }
                      }
                    });
                  } else if (number == 'C') {
                    setState(() {
                      if (widget.isPinInput) {
                        widget.onPinChanged('');
                      } else {
                        widget.onPinConfirmChanged('');
                      }
                    });
                  }
                },
          child: Center(
            child: Builder(builder: (context) {
              if (number == 'C') {
                if ((widget.isPinInput && widget.pin != '') ||
                    (!widget.isPinInput && widget.pinConfirm != '')) {
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
