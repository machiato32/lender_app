import 'package:csocsort_szamla/essentials/models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CategoryPickerDropdown extends StatefulWidget {
  final Category defaultCategoryValue;
  final ValueChanged<Category> onCategoryChanged;
  final bool filled;
  final bool noContentPadding;
  final bool showSymbol;
  final Color dropdownColor;
  final Color textColor;
  CategoryPickerDropdown({
    @required this.defaultCategoryValue,
    @required this.onCategoryChanged,
    this.filled = true,
    this.noContentPadding = false,
    this.showSymbol = true,
    this.textColor,
    this.dropdownColor,
  });

  @override
  State<CategoryPickerDropdown> createState() => _CategoryPickerDropdown();
}

class _CategoryPickerDropdown extends State<CategoryPickerDropdown> {
  Category _defaultCurrencyValue;

  @override
  void initState() {
    super.initState();
    _defaultCurrencyValue = widget.defaultCategoryValue;
  }

  @override
  Widget build(BuildContext context) {
    _defaultCurrencyValue = widget.defaultCategoryValue;
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField(
        decoration: InputDecoration(
            filled: widget.filled,
            contentPadding: widget.noContentPadding ? EdgeInsets.only(top: 0) : null),
        elevation: 0,
        isExpanded: true,
        iconEnabledColor: widget.textColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
        onChanged: (Category value) {
          widget.onCategoryChanged(value);
          setState(() {
            _defaultCurrencyValue = value;
          });
        },
        value: _defaultCurrencyValue,
        borderRadius: BorderRadius.circular(12),
        dropdownColor: ElevationOverlay.applySurfaceTint(
            widget.dropdownColor ?? Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceTint,
            2),
        style: Theme.of(context)
            .textTheme
            .labelLarge
            .copyWith(color: widget.textColor ?? Theme.of(context).colorScheme.onSurfaceVariant),
        menuMaxHeight: 500,
        hint: Text('category_hint'.tr()),
        items: Category.categories
            .map((category) => DropdownMenuItem(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(category.text.tr())),
                        Icon(
                          category.icon,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  value: category,
                  onTap: () {},
                ))
            .toList(),
      ),
    );
  }
}
