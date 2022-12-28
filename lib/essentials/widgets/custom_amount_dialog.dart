import 'package:csocsort_szamla/essentials/widgets/gradient_button.dart';
import 'package:csocsort_szamla/essentials/widgets/tap_or_hold_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:csocsort_szamla/essentials/currencies.dart';
import 'package:csocsort_szamla/config.dart';

class CustomAmountDialog extends StatefulWidget {
  final double initialValue;
  final double maxValue;
  final double maxMoney;
  final double minValue;
  final bool alreadyCustom;
  final String currency;
  const CustomAmountDialog(
      {this.initialValue,
      this.maxValue,
      this.maxMoney,
      this.alreadyCustom,
      this.currency,
      this.minValue = 0});

  @override
  State<CustomAmountDialog> createState() => _CustomAmountDialogState();
}

class _CustomAmountDialogState extends State<CustomAmountDialog> {
  double sliderValue;
  double magnet;
  String currency;
  @override
  void initState() {
    super.initState();
    sliderValue = widget.initialValue;
    magnet = 0.5;
    currency = widget.currency ?? currentGroupCurrency;
  }

  double roundLogically(double value) {
    double stepSize = (widget.maxValue - widget.minValue) / 20;
    print(stepSize);
    double roundTo = 1;
    if (hasSubunit(currency)) {
      if (stepSize < 0.01) {
        roundTo = 0.01;
      } else if (stepSize < 0.1) {
        roundTo = 0.1;
      } else if (stepSize < 0.5) {
        roundTo = 0.5;
      }
    }
    return (value - roundTo).roundToDouble() + roundTo;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'custom_amount'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            Text(
              'custom_amount_explanation'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
                'chosen_amount'.tr() +
                    sliderValue.toMoneyString(currency, withSymbol: true) +
                    ' / ' +
                    (sliderValue / widget.maxMoney * 100).roundToDouble().toStringAsFixed(0) +
                    '%',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Row(
              children: [
                TapOrHoldButton(
                  onUpdate: () {
                    double value = hasSubunit(currency) ? 0.01 : 1;
                    setState(() {
                      if (sliderValue - value >= widget.minValue) {
                        sliderValue -= value;
                      }
                    });
                  },
                  icon: Icons.remove,
                ),
                Expanded(
                  child: Slider(
                    value: sliderValue,
                    divisions: 20,
                    max: widget.maxValue,
                    min: widget.minValue,
                    thumbColor: Theme.of(context).colorScheme.primary,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (value) {
                      setState(() {
                        sliderValue = value;
                      });
                    },
                  ),
                ),
                TapOrHoldButton(
                  onUpdate: () {
                    double value = hasSubunit(currency) ? 0.01 : 1;
                    setState(() {
                      if (sliderValue + value <= widget.maxValue) {
                        sliderValue += value;
                      }
                    });
                  },
                  icon: Icons.add,
                ),
              ],
            ),
            Visibility(
              visible: widget.alreadyCustom,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context, -1);
                },
                child: Text('reset'.tr()),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GradientButton(
                  child: Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () {
                    Navigator.pop(context, sliderValue);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
