import 'package:csocsort_szamla/balance/tab.dart';
import 'package:csocsort_szamla/essentials/widgets/currency_picker_dropdown.dart';
import 'package:flutter/material.dart';

import '../config.dart';

class SelectBalanceCurrency extends StatefulWidget {
  final String selectedCurrency;
  final Function(String) onCurrencyChange;
  const SelectBalanceCurrency({this.selectedCurrency, this.onCurrencyChange});

  @override
  State<SelectBalanceCurrency> createState() => _SelectBalanceCurrencyState();
}

class _SelectBalanceCurrencyState extends State<SelectBalanceCurrency> {
  String _selectedCurrency;
  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.selectedCurrency;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomTab(
          onDoubleTap: () {
            setState(() {
              _selectedCurrency = currentGroupCurrency;
            });
            widget.onCurrencyChange(currentGroupCurrency);
          },
          selected: widget.selectedCurrency != currentGroupCurrency,
          child: Container(
            width: 80,
            child: CurrencyPickerDropdown(
              currencyChanged: (newCurrency) {
                _selectedCurrency = newCurrency;
                widget.onCurrencyChange(newCurrency);
              },
              defaultCurrencyValue: _selectedCurrency,
              filled: false,
              noContentPadding: true,
              showSymbol: false,
              textColor: widget.selectedCurrency != currentGroupCurrency
                  ? Theme.of(context).colorScheme.onPrimary
                  : null,
              dropdownColor: widget.selectedCurrency != currentGroupCurrency
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
