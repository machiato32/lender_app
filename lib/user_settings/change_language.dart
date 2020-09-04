import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguagePicker extends StatefulWidget {
  @override
  _LanguagePickerState createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> {
  List<Widget> _getLocales() {
    return context.supportedLocales.map((locale) {
      return LanguageElement(
        localeName: locale.languageCode,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
                child: Text(
              'change_language'.tr(),
              style: Theme.of(context).textTheme.headline6,
            )),
            SizedBox(height: 10),
            Container(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: _getLocales(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LanguageElement extends StatefulWidget {
  final String localeName;

  const LanguageElement({this.localeName});

  @override
  _LanguageElementState createState() => _LanguageElementState();
}

class _LanguageElementState extends State<LanguageElement> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            context.locale = Locale(widget.localeName);
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: (widget.localeName == context.locale.languageCode)
                    ? Colors.grey
                    : Colors.transparent,
                shape: BoxShape.circle),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: (widget.localeName == context.locale.languageCode)
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.white,
                  shape: BoxShape.circle),
              child: Center(
                  child: Text(
                widget.localeName.toUpperCase(),
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: (widget.localeName == context.locale.languageCode)
                        ? Theme.of(context).textTheme.button.color
                        : Colors.black),
              )),
            ),
          ),
        ),
        SizedBox(
          width: 5,
        )
      ],
    );
  }
}
