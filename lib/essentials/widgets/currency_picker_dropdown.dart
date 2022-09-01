import 'package:flutter/material.dart';
import '../currencies.dart';

class CurrencyPickerDropdown extends StatefulWidget {
  final String defaultCurrencyValue;
  final ValueChanged<String> currencyChanged;
  CurrencyPickerDropdown(
      {@required this.defaultCurrencyValue, @required this.currencyChanged});

  @override
  State<CurrencyPickerDropdown> createState() => _CurrencyPickerDropdownState();
}

class _CurrencyPickerDropdownState extends State<CurrencyPickerDropdown> {
  String _defaultCurrencyValue;

  @override
  void initState() {
    super.initState();
    _defaultCurrencyValue = widget.defaultCurrencyValue;
  }

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        elevation: 0,
        isExpanded: true,
        onChanged: (value) {
          widget.currencyChanged(value);
          setState(() {
            _defaultCurrencyValue = value;
          });
        },
        value: _defaultCurrencyValue,
        borderRadius: BorderRadius.circular(30),
        dropdownColor: ElevationOverlay.applyOverlay(
            context, Theme.of(context).colorScheme.surface, 10),
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        menuMaxHeight: 500,
        items: enumerateCurrencies()
            .map((currency) => DropdownMenuItem(
                  child: Center(
                    child: Text(
                      currency.split(';')[0].trim() +
                          " (" +
                          currency.split(';')[1].trim() +
                          ")",
                    ),
                  ),
                  value: currency.split(';')[0].trim(),
                  onTap: () {},
                ))
            .toList(),
      ),
    );
  }
}
